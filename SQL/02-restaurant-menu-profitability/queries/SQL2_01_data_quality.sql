-- ============================================================
-- SQL-2: Restaurant Menu Profitability & Ordering Patterns
-- Script 01: Data Quality Checks
-- Tool: SQL Server Management Studio
-- Stakeholder: Restaurant Operations Manager / CFO
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Row counts across all three tables
-- ------------------------------------------------------------
SELECT 'menu_items'   AS table_name, COUNT(*) AS total_rows FROM menu_items
UNION ALL
SELECT 'orders',                      COUNT(*) FROM orders
UNION ALL
SELECT 'order_details',               COUNT(*) FROM order_details;

-- ------------------------------------------------------------
-- STEP 2: Check for NULLs in critical columns
-- ------------------------------------------------------------
-- Menu items nulls
SELECT
    COUNT(*)                        AS total_rows,
    COUNT(*) - COUNT(menu_item_id)  AS null_menu_item_id,
    COUNT(*) - COUNT(item_name)     AS null_item_name,
    COUNT(*) - COUNT(category)      AS null_category,
    COUNT(*) - COUNT(price)         AS null_price
FROM menu_items;

-- Orders nulls
SELECT
    COUNT(*)                        AS total_rows,
    COUNT(*) - COUNT(order_id)      AS null_order_id,
    COUNT(*) - COUNT(order_date)    AS null_order_date,
    COUNT(*) - COUNT(order_time)    AS null_order_time
FROM orders;

-- Order details nulls
SELECT
    COUNT(*)                            AS total_rows,
    COUNT(*) - COUNT(order_details_id)  AS null_order_details_id,
    COUNT(*) - COUNT(order_id)          AS null_order_id,
    COUNT(*) - COUNT(item_id)           AS null_item_id
FROM order_details;

-- ------------------------------------------------------------
-- STEP 3: Check for duplicate order IDs
-- ------------------------------------------------------------
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check duplicate order detail rows
SELECT order_details_id, COUNT(*) AS cnt
FROM order_details
HAVING COUNT(*) > 1
GROUP BY order_details_id;

-- ------------------------------------------------------------
-- STEP 4: Validate price range — flag suspiciously low or high
-- ------------------------------------------------------------
SELECT
    MIN(price)   AS min_price,
    MAX(price)   AS max_price,
    AVG(price)   AS avg_price,
    COUNT(*)     AS total_items,
    SUM(CASE WHEN price <= 0  THEN 1 ELSE 0 END) AS zero_or_negative_price,
    SUM(CASE WHEN price > 50  THEN 1 ELSE 0 END) AS price_over_50
FROM menu_items;

-- ------------------------------------------------------------
-- STEP 5: Date range and coverage check
-- ------------------------------------------------------------
SELECT
    MIN(order_date)            AS earliest_order,
    MAX(order_date)            AS latest_order,
    COUNT(DISTINCT order_date) AS distinct_order_days,
    COUNT(DISTINCT order_id)   AS total_orders
FROM orders;

-- ------------------------------------------------------------
-- STEP 6: Orphan check — order details with no matching order
-- ------------------------------------------------------------
SELECT COUNT(*) AS orphaned_order_details
FROM order_details od
LEFT JOIN orders o ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Orphan check — order details with no matching menu item
SELECT COUNT(*) AS orphaned_menu_items
FROM order_details od
LEFT JOIN menu_items mi ON od.item_id = mi.menu_item_id
WHERE mi.menu_item_id IS NULL;

-- ------------------------------------------------------------
-- STEP 7: Category distribution check
-- ------------------------------------------------------------
SELECT
    category,
    COUNT(*)        AS item_count,
    MIN(price)      AS min_price,
    MAX(price)      AS max_price,
    AVG(price)      AS avg_price
FROM menu_items
GROUP BY category
ORDER BY item_count DESC;
