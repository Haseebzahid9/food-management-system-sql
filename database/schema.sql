-- ============================================================
--  FOOD MANAGEMENT SYSTEM — schema.sql
--  Author  : Database Designer
--  Engine  : MySQL 8.0+
--  Description: Full normalised schema (3NF) for a food-delivery
--               platform (Foodpanda / Uber Eats style)
-- ============================================================

-- ── Drop (for clean re-run) ──────────────────────────────────
DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Order_Details;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Menu;
DROP TABLE IF EXISTS Restaurants;
DROP TABLE IF EXISTS Users;

-- ── 1. USERS ─────────────────────────────────────────────────
-- 1NF : Every column is atomic; no repeating groups.
-- 2NF : Single-column PK → no partial dependency possible.
-- 3NF : No transitive dependency (city/zip not stored here to avoid redundancy).
CREATE TABLE Users (
    user_id      INT            NOT NULL AUTO_INCREMENT,
    full_name    VARCHAR(100)   NOT NULL,
    email        VARCHAR(150)   NOT NULL UNIQUE,
    phone        VARCHAR(20)    NOT NULL,
    address      VARCHAR(255)   NOT NULL,
    city         VARCHAR(80)    NOT NULL,
    created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);

-- ── 2. RESTAURANTS ───────────────────────────────────────────
CREATE TABLE Restaurants (
    restaurant_id   INT           NOT NULL AUTO_INCREMENT,
    name            VARCHAR(150)  NOT NULL,
    cuisine_type    VARCHAR(80)   NOT NULL,
    address         VARCHAR(255)  NOT NULL,
    city            VARCHAR(80)   NOT NULL,
    phone           VARCHAR(20)   NOT NULL,
    rating          DECIMAL(3,2)  NOT NULL DEFAULT 0.00
                        CHECK (rating BETWEEN 0 AND 5),
    is_open         TINYINT(1)    NOT NULL DEFAULT 1,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (restaurant_id)
);

-- ── 3. MENU ──────────────────────────────────────────────────
-- Many Menu items → One Restaurant  (1-to-Many)
CREATE TABLE Menu (
    item_id         INT            NOT NULL AUTO_INCREMENT,
    restaurant_id   INT            NOT NULL,
    item_name       VARCHAR(150)   NOT NULL,
    description     VARCHAR(300),
    price           DECIMAL(8,2)   NOT NULL CHECK (price >= 0),
    category        VARCHAR(80)    NOT NULL,
    is_available    TINYINT(1)     NOT NULL DEFAULT 1,
    PRIMARY KEY (item_id),
    CONSTRAINT fk_menu_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ── 4. ORDERS ────────────────────────────────────────────────
-- Many Orders → One User  (1-to-Many)
-- Many Orders → One Restaurant  (1-to-Many)
CREATE TABLE Orders (
    order_id        INT            NOT NULL AUTO_INCREMENT,
    user_id         INT            NOT NULL,
    restaurant_id   INT            NOT NULL,
    order_date      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('Pending','Confirmed','Preparing',
                         'Out for Delivery','Delivered','Cancelled')
                        NOT NULL DEFAULT 'Pending',
    total_amount    DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    delivery_fee    DECIMAL(6,2)   NOT NULL DEFAULT 0.00,
    special_notes   VARCHAR(300),
    PRIMARY KEY (order_id),
    CONSTRAINT fk_order_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ── 5. ORDER_DETAILS ─────────────────────────────────────────
-- Resolves the Many-to-Many between Orders and Menu.
-- Each row = one line-item in one order.
CREATE TABLE Order_Details (
    detail_id   INT            NOT NULL AUTO_INCREMENT,
    order_id    INT            NOT NULL,
    item_id     INT            NOT NULL,
    quantity    INT            NOT NULL CHECK (quantity > 0),
    unit_price  DECIMAL(8,2)   NOT NULL,        -- snapshot at order time
    subtotal    DECIMAL(10,2)  NOT NULL DEFAULT 0.00,  -- filled by trigger
    PRIMARY KEY (detail_id),
    CONSTRAINT fk_od_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_od_menu
        FOREIGN KEY (item_id) REFERENCES Menu(item_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ── 6. PAYMENTS ──────────────────────────────────────────────
-- One Payment → One Order  (1-to-1 in practice)
CREATE TABLE Payments (
    payment_id      INT            NOT NULL AUTO_INCREMENT,
    order_id        INT            NOT NULL UNIQUE,
    payment_method  ENUM('Cash','Card','Wallet','Online') NOT NULL,
    payment_status  ENUM('Pending','Completed','Failed','Refunded')
                        NOT NULL DEFAULT 'Pending',
    amount_paid     DECIMAL(10,2)  NOT NULL,
    paid_at         TIMESTAMP      NULL,
    transaction_ref VARCHAR(100),
    PRIMARY KEY (payment_id),
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ── 7. DELIVERY ──────────────────────────────────────────────
-- One Delivery → One Order  (1-to-1)
CREATE TABLE Delivery (
    delivery_id      INT            NOT NULL AUTO_INCREMENT,
    order_id         INT            NOT NULL UNIQUE,
    rider_name       VARCHAR(100)   NOT NULL,
    rider_phone      VARCHAR(20)    NOT NULL,
    delivery_address VARCHAR(255)   NOT NULL,
    pickup_time      TIMESTAMP      NULL,
    delivered_time   TIMESTAMP      NULL,
    status           ENUM('Assigned','Picked Up','En Route','Delivered','Failed')
                         NOT NULL DEFAULT 'Assigned',
    PRIMARY KEY (delivery_id),
    CONSTRAINT fk_delivery_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ── INDEXES FOR PERFORMANCE ───────────────────────────────────
CREATE INDEX idx_menu_restaurant    ON Menu(restaurant_id);
CREATE INDEX idx_orders_user        ON Orders(user_id);
CREATE INDEX idx_orders_restaurant  ON Orders(restaurant_id);
CREATE INDEX idx_orders_status      ON Orders(status);
CREATE INDEX idx_od_order           ON Order_Details(order_id);
CREATE INDEX idx_od_item            ON Order_Details(item_id);
CREATE INDEX idx_delivery_status    ON Delivery(status);
CREATE INDEX idx_payment_status     ON Payments(payment_status);
