-- ============================================================
--  FOOD MANAGEMENT SYSTEM — stored_procedures.sql
-- ============================================================

-- ── SP 1: Place a new order ───────────────────────────────────
-- Creates an Order + Payments row in one atomic transaction.
DELIMITER $$
CREATE PROCEDURE sp_place_order(
    IN  p_user_id       INT,
    IN  p_restaurant_id INT,
    IN  p_delivery_fee  DECIMAL(6,2),
    IN  p_notes         VARCHAR(300),
    IN  p_payment_method ENUM('Cash','Card','Wallet','Online'),
    OUT p_order_id      INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO Orders (user_id, restaurant_id, delivery_fee, special_notes)
    VALUES (p_user_id, p_restaurant_id, p_delivery_fee, p_notes);

    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO Payments (order_id, payment_method, payment_status, amount_paid)
    VALUES (p_order_id, p_payment_method, 'Pending', 0.00);

    COMMIT;
END$$
DELIMITER ;

-- ── SP 2: Add item to order ───────────────────────────────────
DELIMITER $$
CREATE PROCEDURE sp_add_order_item(
    IN p_order_id INT,
    IN p_item_id  INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(8,2);

    SELECT price INTO v_price FROM Menu WHERE item_id = p_item_id;

    INSERT INTO Order_Details (order_id, item_id, quantity, unit_price)
    VALUES (p_order_id, p_item_id, p_quantity, v_price);
    -- Triggers handle subtotal + order total automatically
END$$
DELIMITER ;

-- ── SP 3: Get user order history ─────────────────────────────
DELIMITER $$
CREATE PROCEDURE sp_user_order_history(IN p_user_id INT)
BEGIN
    SELECT
        o.order_id,
        r.name         AS restaurant,
        o.order_date,
        o.status,
        o.total_amount,
        p.payment_method,
        p.payment_status
    FROM  Orders       o
    JOIN  Restaurants  r ON o.restaurant_id = r.restaurant_id
    LEFT  JOIN Payments p ON o.order_id     = p.order_id
    WHERE o.user_id = p_user_id
    ORDER BY o.order_date DESC;
END$$
DELIMITER ;

-- ── SP 4: Update order status ─────────────────────────────────
DELIMITER $$
CREATE PROCEDURE sp_update_order_status(
    IN p_order_id INT,
    IN p_status   ENUM('Pending','Confirmed','Preparing','Out for Delivery','Delivered','Cancelled')
)
BEGIN
    UPDATE Orders SET status = p_status WHERE order_id = p_order_id;

    -- If order delivered, mark payment completed and delivery delivered
    IF p_status = 'Delivered' THEN
        UPDATE Payments
        SET    payment_status = 'Completed',
               paid_at        = NOW()
        WHERE  order_id = p_order_id
        AND    payment_status = 'Pending';

        UPDATE Delivery
        SET    status         = 'Delivered',
               delivered_time = NOW()
        WHERE  order_id = p_order_id;
    END IF;
END$$
DELIMITER ;

-- ── SP 5: Restaurant revenue report ──────────────────────────
DELIMITER $$
CREATE PROCEDURE sp_restaurant_report(IN p_restaurant_id INT)
BEGIN
    SELECT
        r.name,
        r.city,
        COUNT(DISTINCT o.order_id)         AS total_orders,
        SUM(od.subtotal)                   AS gross_revenue,
        ROUND(AVG(o.total_amount), 2)      AS avg_order_value,
        SUM(od.quantity)                   AS items_sold
    FROM  Restaurants  r
    JOIN  Orders       o  ON r.restaurant_id  = o.restaurant_id
    JOIN  Order_Details od ON o.order_id      = od.order_id
    WHERE r.restaurant_id = p_restaurant_id
    AND   o.status = 'Delivered'
    GROUP BY r.restaurant_id, r.name, r.city;
END$$
DELIMITER ;
