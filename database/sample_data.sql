-- ============================================================
--  FOOD MANAGEMENT SYSTEM — sample_data.sql
--  Realistic seed data for all 7 tables
-- ============================================================

-- ── USERS ────────────────────────────────────────────────────
INSERT INTO Users (full_name, email, phone, address, city) VALUES
('Ali Hassan',      'ali.hassan@email.com',    '+92-300-1234567', 'House 12, Block B, Gulshan',  'Karachi'),
('Sara Khan',       'sara.khan@email.com',     '+92-321-2345678', 'Flat 5, Clifton Road',        'Karachi'),
('Ahmed Malik',     'ahmed.malik@email.com',   '+92-333-3456789', 'Street 4, F-7/2',             'Islamabad'),
('Fatima Raza',     'fatima.raza@email.com',   '+92-345-4567890', 'Plot 8, DHA Phase 5',         'Lahore'),
('Omar Sheikh',     'omar.sheikh@email.com',   '+92-311-5678901', 'House 22, Model Town',        'Lahore'),
('Zara Siddiqui',  'zara.siddiqui@email.com', '+92-322-6789012', 'Apt 9, Blue Area',            'Islamabad'),
('Bilal Chaudhry', 'bilal.ch@email.com',       '+92-334-7890123', 'House 7, PECHS Block 6',     'Karachi'),
('Hina Baig',      'hina.baig@email.com',      '+92-344-8901234', 'Sector G-11/3, House 45',    'Islamabad');

-- ── RESTAURANTS ──────────────────────────────────────────────
INSERT INTO Restaurants (name, cuisine_type, address, city, phone, rating) VALUES
('Hardee''s Karachi',       'Fast Food',    'Main Shahrah-e-Faisal', 'Karachi',   '+92-21-1111111', 4.20),
('Savour Foods',             'Desi',         'Blue Area F-7',         'Islamabad', '+92-51-2222222', 4.70),
('Pizza Max',                'Italian',      'MM Alam Road',          'Lahore',    '+92-42-3333333', 4.10),
('Monal Restaurant',         'Pakistani',    'Pir Sohawa Road',       'Islamabad', '+92-51-4444444', 4.80),
('KFC DHA Branch',           'Fast Food',    'Phase 6, DHA',          'Lahore',    '+92-42-5555555', 4.00),
('Butlers'' Chocolate Cafe', 'Desserts',     'Clifton Block 5',       'Karachi',   '+92-21-6666666', 4.50),
('Salt''n Pepper Village',   'Continental',  'Johar Town',            'Lahore',    '+92-42-7777777', 4.30),
('Hotspot Islamabad',        'BBQ',          'F-10 Markaz',           'Islamabad', '+92-51-8888888', 4.60);

-- ── MENU ─────────────────────────────────────────────────────
INSERT INTO Menu (restaurant_id, item_name, description, price, category) VALUES
-- Hardee's (1)
(1, 'Thickburger',        'Charbroiled beef patty, lettuce, tomato',   690.00, 'Burgers'),
(1, 'Chicken Stars',      'Crispy chicken bites, 6 pcs',               350.00, 'Snacks'),
(1, 'Mushroom & Swiss',   'Swiss cheese, sautéed mushrooms',           750.00, 'Burgers'),
(1, 'Large Fries',        'Crispy golden fries',                       280.00, 'Sides'),
(1, 'Chocolate Milkshake','Thick creamy chocolate shake',              380.00, 'Beverages'),
-- Savour Foods (2)
(2, 'Pulao (Full)',        'Fragrant rice with mixed meat',             950.00, 'Rice'),
(2, 'Seekh Kebab (6 pcs)','Spiced minced beef on skewers',             650.00, 'BBQ'),
(2, 'Nan Bread',          'Freshly baked tandoor bread',               80.00,  'Bread'),
(2, 'Raita',              'Yoghurt with cucumber and mint',            120.00, 'Sides'),
-- Pizza Max (3)
(3, 'Zinger Pizza (Lg)',  'Chicken zinger, jalapeños, mozzarella',    1450.00, 'Pizza'),
(3, 'BBQ Chicken Pizza',  'Smoky BBQ sauce, chicken, peppers',        1350.00, 'Pizza'),
(3, 'Garlic Bread',       'Toasted garlic butter baguette',            320.00, 'Sides'),
(3, 'Pasta Arrabiata',    'Penne in spicy tomato sauce',               680.00, 'Pasta'),
-- Monal (4)
(4, 'Lamb Karahi',        'Slow-cooked lamb in tomato masala',        1800.00, 'Mains'),
(4, 'Mix Grill Platter',  'Seekh, boti, tikka, naan',                2200.00, 'BBQ'),
(4, 'Daal Makhani',       'Black lentils in cream and butter',         680.00, 'Mains'),
(4, 'Mango Lassi',        'Chilled mango yoghurt drink',               280.00, 'Beverages'),
-- KFC (5)
(5, 'Zinger Burger',      'Crispy fried chicken in a toasted bun',    650.00, 'Burgers'),
(5, '3-Pc Meal',          'Three pieces chicken + fries + drink',     1100.00, 'Meals'),
(5, 'Coleslaw (Lg)',       'Creamy cabbage salad',                     220.00, 'Sides'),
-- Butlers (6)
(6, 'Chocolate Fondue',   'Premium chocolate dip with fruit',          980.00, 'Desserts'),
(6, 'Waffle with Nutella','Belgian waffle topped with Nutella',        750.00, 'Desserts'),
(6, 'Brownie a la Mode',  'Warm chocolate brownie + vanilla ice cream',680.00, 'Desserts'),
-- Salt'n Pepper (7)
(7, 'Grilled Fish',       'Marinated tilapia, herb butter',           1250.00, 'Mains'),
(7, 'Chicken Cordon Bleu','Stuffed chicken breast, creamy sauce',     1380.00, 'Mains'),
(7, 'Mushroom Soup',      'Creamy wild mushroom velouté',              480.00, 'Starters'),
-- Hotspot (8)
(8, 'BBQ Boti Platter',   'Tender beef boti, mint chutney',           1600.00, 'BBQ'),
(8, 'Chicken Tikka',      'Marinated chicken tikka, full',            1200.00, 'BBQ'),
(8, 'Peshwari Naan',      'Traditional bread with cardamom butter',    120.00, 'Bread');

-- ── ORDERS ───────────────────────────────────────────────────
INSERT INTO Orders (user_id, restaurant_id, status, total_amount, delivery_fee, special_notes) VALUES
(1, 1, 'Delivered',        1720.00, 80.00,  'Extra ketchup please'),
(2, 2, 'Delivered',        1800.00, 100.00, NULL),
(3, 4, 'Delivered',        4680.00, 120.00, 'No spice in daal'),
(4, 3, 'Out for Delivery', 2120.00, 90.00,  'Contactless delivery'),
(5, 5, 'Preparing',        1320.00, 70.00,  NULL),
(6, 8, 'Confirmed',        2920.00, 110.00, 'Call on arrival'),
(7, 6, 'Pending',          2410.00, 80.00,  NULL),
(8, 7, 'Cancelled',        1730.00, 90.00,  'Wrong address — cancelled'),
(1, 4, 'Delivered',        2200.00, 120.00, NULL),
(2, 3, 'Delivered',        2450.00, 90.00,  'Well-done pizza base'),
(3, 1, 'Delivered',        1970.00, 80.00,  NULL),
(4, 5, 'Delivered',        1100.00, 70.00,  NULL);

-- ── ORDER_DETAILS ─────────────────────────────────────────────
-- Note: subtotal will be recalculated by trigger; pre-filled for seed data.
INSERT INTO Order_Details (order_id, item_id, quantity, unit_price, subtotal) VALUES
-- Order 1 (Hardee's): Thickburger x2 + Fries + Milkshake
(1, 1, 2, 690.00, 1380.00),
(1, 4, 1, 280.00,  280.00),
(1, 5, 1, 380.00,  380.00),      -- total items = 2040; order total = 2040 - discounts approx
-- Order 2 (Savour): Pulao Full + Seekh x2
(2, 6, 1, 950.00,  950.00),
(2, 7, 1, 650.00,  650.00),
(2, 8, 2,  80.00,  160.00),
-- Order 3 (Monal): Lamb Karahi + Mix Grill + Daal + Mango Lassi x2
(3, 14, 1, 1800.00, 1800.00),
(3, 15, 1, 2200.00, 2200.00),
(3, 16, 1,  680.00,  680.00),
-- Order 4 (Pizza Max): Zinger Pizza + Garlic Bread + Arrabiata
(4, 10, 1, 1450.00, 1450.00),
(4, 12, 1,  320.00,  320.00),
(4, 13, 1,  680.00,  680.00),
-- Order 5 (KFC): 3-Pc Meal + Coleslaw
(5, 19, 1, 1100.00, 1100.00),
(5, 20, 1,  220.00,  220.00),
-- Order 6 (Hotspot): BBQ Boti + Chicken Tikka + Naan x2
(6, 27, 1, 1600.00, 1600.00),
(6, 28, 1, 1200.00, 1200.00),
(6, 29, 2,  120.00,  240.00),
-- Order 7 (Butlers): Fondue + Waffle + Brownie
(7, 21, 1,  980.00,  980.00),
(7, 22, 1,  750.00,  750.00),
(7, 23, 1,  680.00,  680.00),
-- Order 8 (Salt'n Pepper): Grilled Fish + Mushroom Soup
(8, 24, 1, 1250.00, 1250.00),
(8, 26, 1,  480.00,  480.00),
-- Order 9 (Monal): Mix Grill Platter x1
(9, 15, 1, 2200.00, 2200.00),
-- Order 10 (Pizza Max): BBQ Chicken + Garlic Bread
(10, 11, 1, 1350.00, 1350.00),
(10, 12, 1,  320.00,  320.00),
(10, 13, 1,  680.00,  680.00),
-- Order 11 (Hardee's): Mushroom Swiss + Fries + Shake + Stars
(11, 3, 1,  750.00,  750.00),
(11, 4, 2,  280.00,  560.00),
(11, 5, 1,  380.00,  380.00),
(11, 2, 1,  350.00,  350.00),
-- Order 12 (KFC): 3-Pc Meal x1
(12, 19, 1, 1100.00, 1100.00);

-- ── PAYMENTS ─────────────────────────────────────────────────
INSERT INTO Payments (order_id, payment_method, payment_status, amount_paid, paid_at, transaction_ref) VALUES
(1,  'Card',   'Completed', 1800.00, '2024-01-10 14:35:00', 'TXN-KHI-001'),
(2,  'Cash',   'Completed', 1900.00, '2024-01-11 13:10:00', NULL),
(3,  'Online', 'Completed', 4800.00, '2024-01-12 20:00:00', 'TXN-ISB-003'),
(4,  'Wallet', 'Pending',      0.00,  NULL,                  NULL),
(5,  'Card',   'Pending',      0.00,  NULL,                  NULL),
(6,  'Cash',   'Pending',      0.00,  NULL,                  NULL),
(7,  'Card',   'Pending',      0.00,  NULL,                  NULL),
(8,  'Online', 'Refunded',  1820.00, '2024-01-15 09:30:00', 'TXN-LHR-008'),
(9,  'Card',   'Completed', 2320.00, '2024-01-16 21:00:00', 'TXN-ISB-009'),
(10, 'Online', 'Completed', 2540.00, '2024-01-17 19:45:00', 'TXN-LHR-010'),
(11, 'Cash',   'Completed', 2050.00, '2024-01-18 12:20:00', NULL),
(12, 'Card',   'Completed', 1170.00, '2024-01-19 17:55:00', 'TXN-LHR-012');

-- ── DELIVERY ─────────────────────────────────────────────────
INSERT INTO Delivery (order_id, rider_name, rider_phone, delivery_address, pickup_time, delivered_time, status) VALUES
(1,  'Kamran Rider',  '+92-333-0001', 'House 12, Block B, Gulshan, Karachi',  '2024-01-10 14:40:00', '2024-01-10 15:05:00', 'Delivered'),
(2,  'Asif Rider',    '+92-333-0002', 'Flat 5, Clifton Road, Karachi',         '2024-01-11 13:15:00', '2024-01-11 13:45:00', 'Delivered'),
(3,  'Tariq Rider',   '+92-333-0003', 'Street 4, F-7/2, Islamabad',           '2024-01-12 20:10:00', '2024-01-12 20:50:00', 'Delivered'),
(4,  'Naeem Rider',   '+92-333-0004', 'Plot 8, DHA Phase 5, Lahore',          '2024-01-13 18:30:00', NULL,                  'En Route'),
(5,  'Raheel Rider',  '+92-333-0005', 'House 22, Model Town, Lahore',         NULL,                  NULL,                  'Assigned'),
(6,  'Usman Rider',   '+92-333-0006', 'Apt 9, Blue Area, Islamabad',          NULL,                  NULL,                  'Assigned'),
(9,  'Bilal Rider',   '+92-333-0009', 'House 12, Block B, Gulshan, Karachi',  '2024-01-16 21:05:00', '2024-01-16 21:50:00', 'Delivered'),
(10, 'Faizan Rider',  '+92-333-0010', 'Flat 5, Clifton Road, Karachi',        '2024-01-17 19:50:00', '2024-01-17 20:25:00', 'Delivered'),
(11, 'Zubair Rider',  '+92-333-0011', 'Street 4, F-7/2, Islamabad',           '2024-01-18 12:30:00', '2024-01-18 13:00:00', 'Delivered'),
(12, 'Hassan Rider',  '+92-333-0012', 'Plot 8, DHA Phase 5, Lahore',          '2024-01-19 17:58:00', '2024-01-19 18:30:00', 'Delivered');
