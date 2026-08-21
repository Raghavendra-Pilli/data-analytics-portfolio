-- ============================================================
-- SQL-2: Restaurant Menu Profitability & Ordering Patterns
-- Script 02: Table Creation & Data Preparation
-- Tool: SQL Server Management Studio
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Create tables
-- Run these BEFORE importing CSVs
-- ------------------------------------------------------------

DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;

-- Menu items table
CREATE TABLE menu_items (
    menu_item_id    INT             NOT NULL PRIMARY KEY,
    item_name       NVARCHAR(100)   NOT NULL,
    category        NVARCHAR(50)    NOT NULL,
    price           DECIMAL(10,2)   NOT NULL
);

-- Orders table
CREATE TABLE orders (
    order_id        INT             NOT NULL PRIMARY KEY,
    order_date      DATE            NOT NULL,
    order_time      TIME            NOT NULL
);

-- Order details (junction table — links orders to menu items)
CREATE TABLE order_details (
    order_details_id    INT         NOT NULL PRIMARY KEY,
    order_id            INT         NOT NULL,
    item_id             INT,                    -- nullable: some orders had no item recorded
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id)  REFERENCES menu_items(menu_item_id)
);

-- ------------------------------------------------------------
-- STEP 2: Import CSVs using SSMS Import Flat File
-- Import in this order:
--   1. menu_items.csv     → menu_items table
--   2. orders.csv         → orders table
--   3. order_details.csv  → order_details table
--
-- For each: Right-click DB > Tasks > Import Flat File
--           FIRSTROW = 2, FIELDTERMINATOR = ','
--           ROWTERMINATOR = '\r\n'
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- STEP 3: Add derived columns to orders table
-- ------------------------------------------------------------
ALTER TABLE orders ADD order_year      INT;
ALTER TABLE orders ADD order_month     INT;
ALTER TABLE orders ADD order_quarter   INT;
ALTER TABLE orders ADD day_of_week     NVARCHAR(20);
ALTER TABLE orders ADD time_of_day     NVARCHAR(20);

UPDATE orders SET
    order_year    = YEAR(order_date),
    order_month   = MONTH(order_date),
    order_quarter = DATEPART(QUARTER, order_date),
    day_of_week   = DATENAME(WEEKDAY, order_date),
    time_of_day   = CASE
                        WHEN CAST(order_time AS TIME) >= '06:00' AND CAST(order_time AS TIME) < '11:00' THEN 'Breakfast'
                        WHEN CAST(order_time AS TIME) >= '11:00' AND CAST(order_time AS TIME) < '15:00' THEN 'Lunch'
                        WHEN CAST(order_time AS TIME) >= '15:00' AND CAST(order_time AS TIME) < '18:00' THEN 'Afternoon'
                        WHEN CAST(order_time AS TIME) >= '18:00' AND CAST(order_time AS TIME) < '22:00' THEN 'Dinner'
                        ELSE 'Late Night'
                    END;

-- ------------------------------------------------------------
-- STEP 4: Create master analysis view
-- Joins all three tables into one flat analysis table
-- ------------------------------------------------------------
CREATE OR ALTER VIEW vw_orders_master AS
SELECT
    od.order_details_id,
    od.order_id,
    o.order_date,
    o.order_year,
    o.order_month,
    o.order_quarter,
    o.day_of_week,
    o.time_of_day,
    o.order_time,
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    mi.price
FROM order_details od
JOIN orders     o  ON od.order_id = o.order_id
JOIN menu_items mi ON od.item_id  = mi.menu_item_id;

-- ------------------------------------------------------------
-- STEP 5: Verify the joined view
-- ------------------------------------------------------------
SELECT TOP 10 * FROM vw_orders_master;

SELECT
    COUNT(*)                    AS total_order_lines,
    COUNT(DISTINCT order_id)    AS total_orders,
    COUNT(DISTINCT item_name)   AS distinct_items,
    COUNT(DISTINCT category)    AS distinct_categories,
    MIN(order_date)             AS date_from,
    MAX(order_date)             AS date_to
FROM vw_orders_master;
