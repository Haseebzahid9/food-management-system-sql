-- ============================================================
--  FOOD MANAGEMENT SYSTEM — views.sql
-- ============================================================

-- ── VIEW 1: vw_order_summary ─────────────────────────────────
-- A denormalised, human-readable snapshot of every order.
-- Used by admin dashboards and reporting tools.
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    u.full_name                        AS customer_name,
    u.phone                            AS customer_phone,
    r.name                             AS restaurant_name,
    r.cuisine_type,
    r.city                             AS restaurant_city,
    o.order_date,
    o.status                           AS order_status,
    o.total_amount,
    o.delivery_fee,
    (o.total_amount + o.delivery_fee)  AS grand_total,
    p.payment_method,
    p.payment_status,
    d.status                           AS delivery_status,
    d.rider_name,
    d.delivered_time
FROM       Orders       o
JOIN       Users        u  ON o.user_id       = u.user_id
JOIN       Restaurants  r  ON o.restaurant_id = r.restaurant_id
LEFT JOIN  Payments     p  ON o.order_id      = p.order_id
LEFT JOIN  Delivery     d  ON o.order_id      = d.order_id;

-- ── VIEW 2: vw_menu_with_restaurant ──────────────────────────
-- Full menu catalogue with restaurant details for customer-facing APIs.
CREATE OR REPLACE VIEW vw_menu_with_restaurant AS
SELECT
    m.item_id,
    m.item_name,
    m.description,
    m.price,
    m.category,
    m.is_available,
    r.restaurant_id,
    r.name          AS restaurant_name,
    r.cuisine_type,
    r.city,
    r.rating
FROM  Menu         m
JOIN  Restaurants  r ON m.restaurant_id = r.restaurant_id
WHERE m.is_available = 1
AND   r.is_open      = 1;

-- ── VIEW 3: vw_restaurant_revenue ────────────────────────────
-- Aggregated revenue per restaurant (only Delivered / paid orders).
CREATE OR REPLACE VIEW vw_restaurant_revenue AS
SELECT
    r.restaurant_id,
    r.name                         AS restaurant_name,
    r.city,
    COUNT(DISTINCT o.order_id)     AS total_orders,
    SUM(o.total_amount)            AS gross_revenue,
    SUM(o.delivery_fee)            AS total_delivery_fees,
    ROUND(AVG(o.total_amount), 2)  AS avg_order_value
FROM       Restaurants  r
JOIN       Orders       o  ON r.restaurant_id = o.restaurant_id
JOIN       Payments     p  ON o.order_id      = p.order_id
WHERE  o.status       = 'Delivered'
AND    p.payment_status = 'Completed'
GROUP BY r.restaurant_id, r.name, r.city;

-- ── VIEW 4: vw_top_menu_items ────────────────────────────────
-- Top-selling menu items ranked by total quantity sold.
CREATE OR REPLACE VIEW vw_top_menu_items AS
SELECT
    m.item_id,
    m.item_name,
    m.category,
    r.name                          AS restaurant_name,
    SUM(od.quantity)                AS total_qty_sold,
    SUM(od.subtotal)                AS total_revenue,
    ROUND(AVG(od.unit_price), 2)    AS avg_price
FROM       Menu         m
JOIN       Order_Details od  ON m.item_id       = od.item_id
JOIN       Orders        o   ON od.order_id     = o.order_id
JOIN       Restaurants   r   ON m.restaurant_id = r.restaurant_id
WHERE  o.status <> 'Cancelled'
GROUP BY m.item_id, m.item_name, m.category, r.name
ORDER BY total_qty_sold DESC;

-- ── VIEW 5: vw_pending_deliveries ────────────────────────────
-- All deliveries not yet completed — used by dispatch teams.
CREATE OR REPLACE VIEW vw_pending_deliveries AS
SELECT
    d.delivery_id,
    d.rider_name,
    d.rider_phone,
    d.status                         AS delivery_status,
    o.order_id,
    o.order_date,
    o.status                         AS order_status,
    u.full_name                      AS customer_name,
    u.phone                          AS customer_phone,
    d.delivery_address,
    r.name                           AS restaurant_name,
    d.pickup_time,
    TIMESTAMPDIFF(MINUTE, o.order_date, NOW()) AS minutes_since_order
FROM       Delivery     d
JOIN       Orders       o  ON d.order_id      = o.order_id
JOIN       Users        u  ON o.user_id       = u.user_id
JOIN       Restaurants  r  ON o.restaurant_id = r.restaurant_id
WHERE  d.status NOT IN ('Delivered', 'Failed');
