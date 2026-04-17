# 🍔 Food Management System
### Production-Level SQL Database — Food Delivery Platform

> A fully normalised (3NF) relational database modelling a real-world food-delivery platform similar to **Foodpanda** or **Uber Eats**, implemented in **MySQL 8.0**.

---

## 📋 Project Overview

This project implements a complete **Food Management System** using relational database design principles. It covers entity modelling, schema implementation, data population, query writing, triggers, views, stored procedures, and normalization — making it suitable for academic submission, GitHub portfolio display, and viva preparation.

---

## ✨ Features

| Feature | Details |
|---|---|
| **7 Normalised Tables** | Users, Restaurants, Menu, Orders, Order\_Details, Payments, Delivery |
| **Referential Integrity** | All FK relationships with CASCADE / RESTRICT rules |
| **Auto-calculations** | Triggers auto-compute subtotals and order totals |
| **5 Views** | Order summary, revenue, top items, pending deliveries, menu catalogue |
| **6 Triggers** | Subtotal calc, total sync, closed-restaurant guard |
| **5 Stored Procedures** | Place order, add item, order history, status update, revenue report |
| **Performance Indexes** | 8 composite and single-column indexes |
| **Realistic Seed Data** | 8 users · 8 restaurants · 29 menu items · 12 orders |

---

## 🗂️ Project Structure

```
Food-Management-System/
│
├── database/
│   ├── schema.sql              ← CREATE TABLE statements + indexes
│   ├── sample_data.sql         ← INSERT statements with realistic data
│   ├── queries.sql             ← 25+ categorised SQL queries
│   ├── triggers.sql            ← 6 automated triggers
│   ├── views.sql               ← 5 reusable views
│   └── stored_procedures.sql   ← 5 stored procedures
│
├── docs/
│   ├── ERD_conceptual.png      ← High-level entity diagram
│   ├── ERD_logical.png         ← Full attribute + key diagram
│   └── report.pdf              ← Full project report
│
└── README.md                   ← This file
```

### File Descriptions

| File | Purpose |
|---|---|
| `schema.sql` | All `CREATE TABLE` DDL statements, constraints, and indexes. Run this first. |
| `sample_data.sql` | Realistic `INSERT` statements for all 7 tables. Run after schema. |
| `queries.sql` | 25+ queries: SELECT, JOIN, GROUP BY, subqueries, filtering, sorting. |
| `triggers.sql` | 6 `BEFORE`/`AFTER` triggers for data automation. |
| `views.sql` | 5 virtual tables simplifying reporting queries. |
| `stored_procedures.sql` | 5 encapsulated business-logic procedures. |

---

## 🗄️ Database Design

### Entity-Relationship Summary

```
Users ──────< Orders >────── Restaurants
                │                  │
                │              Menu Items
                │                  │
           Order_Details ──────────┘
                │
           Payments   Delivery
```

### Table Overview

| Table | PK | FKs | Description |
|---|---|---|---|
| `Users` | `user_id` | — | Registered customers |
| `Restaurants` | `restaurant_id` | — | Restaurant partners |
| `Menu` | `item_id` | `restaurant_id` | Food items per restaurant |
| `Orders` | `order_id` | `user_id`, `restaurant_id` | Customer orders |
| `Order_Details` | `detail_id` | `order_id`, `item_id` | Line items (M-to-M resolver) |
| `Payments` | `payment_id` | `order_id` | Payment records |
| `Delivery` | `delivery_id` | `order_id` | Rider assignment & tracking |

---

## 📐 Normalization

### 1NF — First Normal Form
**Rule:** Atomic values, no repeating groups, each row uniquely identified.

✅ All tables satisfy 1NF:
- `Users.phone` stores one phone number (not "phone1, phone2")
- `Order_Details` breaks multi-item orders into individual rows
- Every table has a single-column `AUTO_INCREMENT` primary key

### 2NF — Second Normal Form
**Rule:** In 3NF and no partial dependency on a composite PK.

✅ All tables satisfy 2NF:
- All PKs are single-column → partial dependency is structurally impossible
- `Order_Details` uses `detail_id` (not a composite of `order_id + item_id`) so every non-key attribute (`quantity`, `unit_price`, `subtotal`) depends on the full PK

### 3NF — Third Normal Form
**Rule:** No transitive dependency (non-key → non-key).

✅ All tables satisfy 3NF:
- **Orders:** `total_amount` depends on `order_id`, not on `user_id` or `restaurant_id`
- **Menu:** `price` depends on `item_id`, not on `restaurant_id`
- **Payments:** `payment_status` depends on `payment_id`, not on `payment_method`
- City/address details are stored on each entity (not derived from another non-key column)

---

## 🔗 Relationships Explained

### One-to-Many

| Parent | Child | Meaning |
|---|---|---|
| `Users` | `Orders` | One user can place many orders |
| `Restaurants` | `Orders` | One restaurant fulfils many orders |
| `Restaurants` | `Menu` | One restaurant has many menu items |
| `Orders` | `Order_Details` | One order has many line-items |

### Many-to-Many (Orders ↔ Menu)

An order can contain **multiple menu items**, and a menu item can appear in **multiple orders**. This is resolved by the **`Order_Details`** junction table:

```
Orders (1) ───< Order_Details >─── (M) Menu
```

`Order_Details` also carries its own attributes (`quantity`, `unit_price`, `subtotal`) which belong to the relationship itself — confirming it is correct 3NF decomposition, not just a linking table.

---

## ⚡ Triggers

| Trigger | Event | Action |
|---|---|---|
| `trg_od_subtotal_before_insert` | BEFORE INSERT on Order\_Details | Sets `subtotal = qty × unit_price` |
| `trg_od_subtotal_before_update` | BEFORE UPDATE on Order\_Details | Recalculates `subtotal` |
| `trg_order_total_after_od_insert` | AFTER INSERT on Order\_Details | Updates `Orders.total_amount` |
| `trg_order_total_after_od_update` | AFTER UPDATE on Order\_Details | Updates `Orders.total_amount` |
| `trg_order_total_after_od_delete` | AFTER DELETE on Order\_Details | Updates `Orders.total_amount` |
| `trg_no_order_closed_restaurant` | BEFORE INSERT on Orders | Blocks order if restaurant is closed |

---

## 🚀 How to Run

### Prerequisites
- MySQL 8.0+ or MariaDB 10.6+
- MySQL Workbench / DBeaver / CLI

### Steps

```bash
# 1. Connect to MySQL
mysql -u root -p

# 2. Create and select the database
CREATE DATABASE food_management_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE food_management_db;

# 3. Run files IN ORDER
SOURCE database/schema.sql;
SOURCE database/triggers.sql;
SOURCE database/views.sql;
SOURCE database/stored_procedures.sql;
SOURCE database/sample_data.sql;

# 4. Run queries to explore
SOURCE database/queries.sql;
```

### Quick Test

```sql
-- Verify tables created
SHOW TABLES;

-- Check order summary view
SELECT * FROM vw_order_summary LIMIT 5;

-- Top-selling items
SELECT * FROM vw_top_menu_items LIMIT 5;

-- Test stored procedure
CALL sp_user_order_history(1);
```

---

## 🛠️ Technologies Used

| Technology | Version | Purpose |
|---|---|---|
| **MySQL** | 8.0+ | Primary RDBMS |
| **SQL (DDL/DML)** | — | Schema + data manipulation |
| **MySQL Workbench** | 8.x | ERD design & query testing |
| **Draw.io** | — | ERD diagram creation |

---

## 📊 Sample Query Results

### Revenue per Restaurant
```sql
SELECT * FROM vw_restaurant_revenue ORDER BY gross_revenue DESC;
```
| Restaurant | City | Orders | Revenue |
|---|---|---|---|
| Monal Restaurant | Islamabad | 2 | Rs. 6,880 |
| Pizza Max | Lahore | 2 | Rs. 3,800 |
| Hardee's Karachi | Karachi | 2 | Rs. 3,690 |

### Top Selling Items
```sql
SELECT item_name, units_sold, revenue_generated FROM vw_top_menu_items LIMIT 3;
```
| Item | Units Sold | Revenue |
|---|---|---|
| Mix Grill Platter | 2 | Rs. 4,400 |
| Zinger Pizza (Lg) | 1 | Rs. 1,450 |
| 3-Pc Meal | 2 | Rs. 2,200 |

---

## 👨‍💻 Author

Database Designer & SQL Developer  
Project: Food Management System  
Academic Year: 2025–2026
