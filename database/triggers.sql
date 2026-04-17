-- ============================================================
--  FOOD MANAGEMENT SYSTEM — triggers.sql
-- ============================================================
-- DELIMITER is shown in comments; run via MySQL CLI or adjust
-- for your client tool.

-- ── TRIGGER 1: Auto-calculate subtotal on INSERT ──────────────
-- Fires BEFORE each row is inserted into Order_Details.
-- Sets subtotal = quantity × unit_price automatically.
DELIMITER $$
CREATE TRIGGER trg_od_subtotal_before_insert
BEFORE INSERT ON Order_Details
FOR EACH ROW
BEGIN
    SET NEW.subtotal = NEW.quantity * NEW.unit_price;
END$$
DELIMITER ;

-- ── TRIGGER 2: Recalculate subtotal on UPDATE ─────────────────
-- Fires BEFORE any update to quantity or unit_price in Order_Details.
DELIMITER $$
CREATE TRIGGER trg_od_subtotal_before_update
BEFORE UPDATE ON Order_Details
FOR EACH ROW
BEGIN
    SET NEW.subtotal = NEW.quantity * NEW.unit_price;
END$$
DELIMITER ;

-- ── TRIGGER 3: Auto-update Orders.total_amount after INSERT ───
-- Fires AFTER a row is inserted into Order_Details.
-- Recalculates the parent order's total from all its line-items.
DELIMITER $$
CREATE TRIGGER trg_order_total_after_od_insert
AFTER INSERT ON Order_Details
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET    total_amount = (
               SELECT COALESCE(SUM(subtotal), 0)
               FROM   Order_Details
               WHERE  order_id = NEW.order_id
           )
    WHERE  order_id = NEW.order_id;
END$$
DELIMITER ;

-- ── TRIGGER 4: Auto-update Orders.total_amount after UPDATE ───
DELIMITER $$
CREATE TRIGGER trg_order_total_after_od_update
AFTER UPDATE ON Order_Details
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET    total_amount = (
               SELECT COALESCE(SUM(subtotal), 0)
               FROM   Order_Details
               WHERE  order_id = NEW.order_id
           )
    WHERE  order_id = NEW.order_id;
END$$
DELIMITER ;

-- ── TRIGGER 5: Auto-update Orders.total_amount after DELETE ───
DELIMITER $$
CREATE TRIGGER trg_order_total_after_od_delete
AFTER DELETE ON Order_Details
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET    total_amount = (
               SELECT COALESCE(SUM(subtotal), 0)
               FROM   Order_Details
               WHERE  order_id = OLD.order_id
           )
    WHERE  order_id = OLD.order_id;
END$$
DELIMITER ;

-- ── TRIGGER 6: Prevent ordering from closed restaurant ────────
DELIMITER $$
CREATE TRIGGER trg_no_order_closed_restaurant
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE v_open TINYINT(1);
    SELECT is_open INTO v_open
    FROM   Restaurants
    WHERE  restaurant_id = NEW.restaurant_id;
    IF v_open = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot place order: restaurant is currently closed.';
    END IF;
END$$
DELIMITER ;
