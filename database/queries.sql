-- ============================================================
--  FOOD MANAGEMENT SYSTEM — queries.sql
--  Categorised real-world SQL queries
-- ============================================================

-- ════════════════════════════════════════════════════════════
-- SECTION A — BASIC SELECT QUERIES
-- ════════════════════════════════════════════════════════════

-- A1. List all users
SELECT user_id, full_name, email, city FROM Users ORDER BY full_name;

-- A2. List all open restaurants in Karachi
SELECT name, cuisine_type, rating
FROM   Restaurants
WHERE  city = 'Karachi' AND is_open = 1
ORDER BY rating DESC;

-- A3. Available menu items priced under Rs. 1000
SELECT item_name, price, category
FROM   Menu
WHERE  price < 1000 AND is_available = 1
ORDER BY price ASC;

-- A4. Orders with status 'Pending' or 'Confirmed'
SELECT order_id, user_id, restaurant_id, order_date, total_amount, status
FROM   Orders
WHERE  status IN ('Pending', 'Confirmed')
ORDER BY order_date DESC;

-- A5. Payments that are still pending
SELECT p.payment_id, o.order_id, p.payment_method, p.payment_status
FROM   Payments p
JOIN   Orders   o ON p.order_id = o.order_id
WHERE  p.payment_status = 'Pending';


-- ════════════════════════════════════════════════════════════
-- SECTION B — JOIN QUERIES
-- ════════════════════════════════════════════════════════════

-- B1. INNER JOIN — User order history with restaurant name
SELECT
    u.full_name        AS customer,
    r.name             AS restaurant,
    o.order_date,
    o.status,
    o.total_amount     AS item_total,
    o.delivery_fee,
    (o.total_amount + o.delivery_fee) AS grand_total
FROM  Orders       o
INNER JOIN Users        u ON o.user_id       = u.user_id
INNER JOIN Restaurants  r ON o.restaurant_id = r.restaurant_id
ORDER BY o.order_date DESC;

-- B2. INNER JOIN — Detailed line-items for a specific order (order_id = 3)
SELECT
    od.detail_id,
    m.item_name,
    od.quantity,
    od.unit_price,
    od.subtotal
FROM  Order_Details od
INNER JOIN Menu m ON od.item_id = m.item_id
WHERE od.order_id = 3;

-- B3. LEFT JOIN — All restaurants, including those with no orders
SELECT
    r.name           AS restaurant,
    r.city,
    COUNT(o.order_id) AS total_orders
FROM  Restaurants r
LEFT  JOIN Orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.name, r.city
ORDER BY total_orders DESC;

-- B4. LEFT JOIN — All orders with delivery info (NULL if no delivery assigned)
SELECT
    o.order_id,
    o.status         AS order_status,
    d.rider_name,
    d.delivery_address,
    d.status         AS delivery_status,
    d.delivered_time
FROM  Orders   o
LEFT  JOIN Delivery d ON o.order_id = d.order_id
ORDER BY o.order_date DESC;

-- B5. INNER JOIN — Full order receipt with customer and payment
SELECT
    o.order_id,
    u.full_name       AS customer,
    r.name            AS restaurant,
    o.total_amount,
    p.payment_method,
    p.payment_status,
    p.paid_at
FROM  Orders      o
INNER JOIN Users       u ON o.user_id       = u.user_id
INNER JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
INNER JOIN Payments    p ON o.order_id      = p.order_id
WHERE p.payment_status = 'Completed'
ORDER BY p.paid_at DESC;


-- ════════════════════════════════════════════════════════════
-- SECTION C — GROUP BY WITH AGGREGATIONS
-- ════════════════════════════════════════════════════════════

-- C1. Revenue per restaurant (SUM)
SELECT
    r.name                         AS restaurant,
    r.city,
    COUNT(o.order_id)              AS delivered_orders,
    SUM(o.total_amount)            AS total_revenue,
    ROUND(AVG(o.total_amount), 2)  AS avg_order_value
FROM  Restaurants r
JOIN  Orders      o ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.restaurant_id, r.name, r.city
ORDER BY total_revenue DESC;

-- C2. Top-selling menu items by quantity
SELECT
    m.item_name,
    m.category,
    r.name                    AS restaurant,
    SUM(od.quantity)          AS units_sold,
    SUM(od.subtotal)          AS revenue_generated
FROM  Order_Details od
JOIN  Menu          m  ON od.item_id      = m.item_id
JOIN  Restaurants   r  ON m.restaurant_id = r.restaurant_id
JOIN  Orders        o  ON od.order_id     = o.order_id
WHERE o.status <> 'Cancelled'
GROUP BY m.item_id, m.item_name, m.category, r.name
ORDER BY units_sold DESC
LIMIT 10;

-- C3. Number of orders per city
SELECT
    r.city,
    COUNT(o.order_id)  AS total_orders,
    SUM(o.total_amount) AS city_revenue
FROM  Orders      o
JOIN  Restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY city_revenue DESC;

-- C4. Average order value per customer
SELECT
    u.full_name                    AS customer,
    COUNT(o.order_id)              AS total_orders,
    ROUND(AVG(o.total_amount), 2)  AS avg_spend
FROM  Users  u
JOIN  Orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.full_name
HAVING COUNT(o.order_id) > 1
ORDER BY avg_spend DESC;

-- C5. Orders grouped by status
SELECT
    status,
    COUNT(*) AS count,
    SUM(total_amount) AS total_value
FROM  Orders
GROUP BY status
ORDER BY count DESC;


-- ════════════════════════════════════════════════════════════
-- SECTION D — SUBQUERIES
-- ════════════════════════════════════════════════════════════

-- D1. Customers who have placed more than the average number of orders
SELECT full_name, email
FROM   Users
WHERE  user_id IN (
    SELECT user_id
    FROM   Orders
    GROUP BY user_id
    HAVING COUNT(*) > (SELECT AVG(order_count) FROM
                          (SELECT COUNT(*) AS order_count FROM Orders GROUP BY user_id) t)
);

-- D2. Most expensive item ever ordered (correlated-style)
SELECT item_name, price
FROM   Menu
WHERE  price = (SELECT MAX(price) FROM Menu);

-- D3. Restaurants that have never received an order
SELECT name, city
FROM   Restaurants
WHERE  restaurant_id NOT IN (SELECT DISTINCT restaurant_id FROM Orders);

-- D4. Orders whose total exceeds the restaurant's average order value
SELECT o.order_id, o.total_amount, r.name AS restaurant
FROM   Orders o
JOIN   Restaurants r ON o.restaurant_id = r.restaurant_id
WHERE  o.total_amount > (
    SELECT AVG(total_amount)
    FROM   Orders
    WHERE  restaurant_id = o.restaurant_id
);

-- D5. Pending deliveries with customer phone (for rider dispatch)
SELECT
    d.delivery_id,
    d.rider_name,
    d.delivery_address,
    (SELECT phone FROM Users WHERE user_id = o.user_id) AS customer_phone
FROM  Delivery d
JOIN  Orders   o ON d.order_id = o.order_id
WHERE d.status NOT IN ('Delivered', 'Failed');


-- ════════════════════════════════════════════════════════════
-- SECTION E — FILTERING AND SORTING
-- ════════════════════════════════════════════════════════════

-- E1. User order history for Ali Hassan (user_id = 1)
SELECT
    o.order_id,
    r.name      AS restaurant,
    o.order_date,
    o.status,
    o.total_amount
FROM  Orders       o
JOIN  Restaurants  r ON o.restaurant_id = r.restaurant_id
WHERE o.user_id = 1
ORDER BY o.order_date DESC;

-- E2. All delivered orders between Jan 10-19, 2024
SELECT order_id, user_id, restaurant_id, total_amount
FROM   Orders
WHERE  status = 'Delivered'
AND    order_date BETWEEN '2024-01-10' AND '2024-01-19 23:59:59'
ORDER BY order_date;

-- E3. Top 5 highest-value orders
SELECT o.order_id, u.full_name AS customer, o.total_amount
FROM   Orders o
JOIN   Users  u ON o.user_id = u.user_id
ORDER BY o.total_amount DESC
LIMIT 5;

-- E4. Pending deliveries (for dispatch dashboard)
SELECT
    d.delivery_id,
    d.rider_name,
    o.order_id,
    r.name  AS restaurant,
    u.phone AS customer_phone,
    d.delivery_address,
    d.status
FROM  Delivery    d
JOIN  Orders      o ON d.order_id      = o.order_id
JOIN  Users       u ON o.user_id       = u.user_id
JOIN  Restaurants r ON o.restaurant_id = r.restaurant_id
WHERE d.status NOT IN ('Delivered', 'Failed')
ORDER BY o.order_date ASC;

-- E5. Search menu items by keyword
SELECT m.item_name, m.price, m.category, r.name AS restaurant
FROM   Menu        m
JOIN   Restaurants r ON m.restaurant_id = r.restaurant_id
WHERE  m.item_name LIKE '%chicken%'
AND    m.is_available = 1
ORDER BY m.price ASC;


-- ════════════════════════════════════════════════════════════
-- SECTION F — USING VIEWS
-- ════════════════════════════════════════════════════════════

-- F1. Query the order summary view
SELECT * FROM vw_order_summary WHERE order_status = 'Delivered';

-- F2. Revenue dashboard
SELECT * FROM vw_restaurant_revenue ORDER BY gross_revenue DESC;

-- F3. Top 5 selling items
SELECT * FROM vw_top_menu_items LIMIT 5;

-- F4. Pending deliveries dashboard
SELECT * FROM vw_pending_deliveries;

-- F5. Available menu in Islamabad
SELECT item_name, price, category, restaurant_name, rating
FROM   vw_menu_with_restaurant
WHERE  city = 'Islamabad'
ORDER BY rating DESC, price ASC;
