-- ============================================================
-- SQL-2: Restaurant Menu Profitability & Ordering Patterns
-- Script 03: Core Business Analysis
-- Tool: SQL Server Management Studio
-- Stakeholder: Restaurant Operations Manager / CFO
-- ============================================================

-- ------------------------------------------------------------
-- ANALYSIS 1: Revenue by menu category
-- Business use: Which food category drives the most revenue?
-- SQL features: GROUP BY, SUM, ROUND, ORDER BY
-- ------------------------------------------------------------
SELECT
    category,
    COUNT(*)                            AS total_items_sold,
    ROUND(SUM(price), 2)                AS total_revenue,
    ROUND(AVG(price), 2)                AS avg_item_price,
    ROUND(SUM(price) * 100.0
        / SUM(SUM(price)) OVER (), 1)   AS revenue_share_pct
FROM vw_orders_master
GROUP BY category
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- ANALYSIS 2: Top 10 best-selling menu items by volume
-- Business use: Which items should never run out of ingredients?
-- SQL features: TOP, GROUP BY, COUNT, ORDER BY
-- ------------------------------------------------------------
SELECT TOP 10
    item_name,
    category,
    price,
    COUNT(*)                            AS times_ordered,
    ROUND(SUM(price), 2)                AS total_revenue,
    ROUND(COUNT(*) * 100.0
        / (SELECT COUNT(*) FROM vw_orders_master), 2) AS order_share_pct
FROM vw_orders_master
GROUP BY item_name, category, price
ORDER BY times_ordered DESC;


-- ------------------------------------------------------------
-- ANALYSIS 3: Top 10 highest revenue generating items
-- Business use: Which items are the most valuable on the menu?
-- SQL features: TOP, SUM, GROUP BY, subquery
-- ------------------------------------------------------------
SELECT TOP 10
    item_name,
    category,
    price,
    COUNT(*)                AS times_ordered,
    ROUND(SUM(price), 2)    AS total_revenue,
    ROUND(AVG(price), 2)    AS avg_price
FROM vw_orders_master
GROUP BY item_name, category, price
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- ANALYSIS 4: Bottom 10 least ordered items (menu review)
-- Business use: Which items should be removed from the menu?
-- SQL features: TOP, COUNT, GROUP BY, ORDER BY ASC
-- ------------------------------------------------------------
SELECT TOP 10
    item_name,
    category,
    price,
    COUNT(*)                AS times_ordered,
    ROUND(SUM(price), 2)    AS total_revenue
FROM vw_orders_master
GROUP BY item_name, category, price
ORDER BY times_ordered ASC;


-- ------------------------------------------------------------
-- ANALYSIS 5: Monthly revenue trend
-- Business use: Is the restaurant growing month over month?
-- SQL features: GROUP BY, SUM, FORMAT, ORDER BY
-- ------------------------------------------------------------
SELECT
    order_year,
    order_month,
    FORMAT(DATEFROMPARTS(order_year, order_month, 1), 'MMM yyyy') AS month_label,
    COUNT(DISTINCT order_id)            AS total_orders,
    COUNT(*)                            AS total_items_sold,
    ROUND(SUM(price), 2)                AS monthly_revenue,
    ROUND(AVG(price), 2)                AS avg_order_item_price
FROM vw_orders_master
GROUP BY order_year, order_month
ORDER BY order_year, order_month;


-- ------------------------------------------------------------
-- ANALYSIS 6: Revenue by day of week
-- Business use: Which days are busiest? When to schedule more staff?
-- SQL features: GROUP BY, AVG, CASE for sort order
-- ------------------------------------------------------------
SELECT
    day_of_week,
    COUNT(DISTINCT order_id)                AS total_orders,
    COUNT(*)                                AS total_items_sold,
    ROUND(SUM(price), 2)                    AS total_revenue,
    ROUND(AVG(price), 2)                    AS avg_item_price,
    ROUND(SUM(price) * 100.0
        / SUM(SUM(price)) OVER (), 1)       AS revenue_share_pct
FROM vw_orders_master
GROUP BY day_of_week
ORDER BY
    CASE day_of_week
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END;


-- ------------------------------------------------------------
-- ANALYSIS 7: Revenue by time of day (meal period)
-- Business use: Which meal service drives most revenue?
-- SQL features: GROUP BY, CASE classification, SUM
-- ------------------------------------------------------------
SELECT
    time_of_day,
    COUNT(DISTINCT order_id)            AS total_orders,
    COUNT(*)                            AS total_items_sold,
    ROUND(SUM(price), 2)                AS total_revenue,
    ROUND(AVG(price), 2)                AS avg_spend_per_item,
    ROUND(SUM(price) * 100.0
        / SUM(SUM(price)) OVER (), 1)   AS revenue_share_pct
FROM vw_orders_master
GROUP BY time_of_day
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- ANALYSIS 8: Category performance by meal period (cross analysis)
-- Business use: Which category drives lunch vs dinner revenue?
-- SQL features: Multi-column GROUP BY, pivot-style CASE
-- ------------------------------------------------------------
SELECT
    category,
    ROUND(SUM(CASE WHEN time_of_day = 'Breakfast'  THEN price ELSE 0 END), 2) AS breakfast_revenue,
    ROUND(SUM(CASE WHEN time_of_day = 'Lunch'      THEN price ELSE 0 END), 2) AS lunch_revenue,
    ROUND(SUM(CASE WHEN time_of_day = 'Afternoon'  THEN price ELSE 0 END), 2) AS afternoon_revenue,
    ROUND(SUM(CASE WHEN time_of_day = 'Dinner'     THEN price ELSE 0 END), 2) AS dinner_revenue,
    ROUND(SUM(price), 2)                                                        AS total_revenue
FROM vw_orders_master
GROUP BY category
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- ANALYSIS 9: Average items per order (order size analysis)
-- Business use: Are customers ordering more or fewer items over time?
-- SQL features: CTE, COUNT, AVG, GROUP BY
-- ------------------------------------------------------------
WITH order_size AS (
    SELECT
        order_id,
        order_date,
        order_year,
        order_month,
        COUNT(*)        AS items_in_order,
        SUM(price)      AS order_value
    FROM vw_orders_master
    GROUP BY order_id, order_date, order_year, order_month
)
SELECT
    order_year,
    order_month,
    FORMAT(DATEFROMPARTS(order_year, order_month, 1), 'MMM yyyy') AS month_label,
    COUNT(order_id)             AS total_orders,
    ROUND(AVG(items_in_order), 2) AS avg_items_per_order,
    ROUND(AVG(order_value), 2)  AS avg_order_value,
    ROUND(MAX(order_value), 2)  AS highest_order_value,
    ROUND(MIN(order_value), 2)  AS lowest_order_value
FROM order_size
GROUP BY order_year, order_month
ORDER BY order_year, order_month;


-- ------------------------------------------------------------
-- ANALYSIS 10: Menu item ranking within each category
-- Business use: What is the rank of each item within its category?
-- SQL features: Window functions — RANK() OVER (PARTITION BY)
-- ------------------------------------------------------------
SELECT
    category,
    item_name,
    price,
    COUNT(*)                                                    AS times_ordered,
    ROUND(SUM(price), 2)                                        AS total_revenue,
    RANK() OVER (
        PARTITION BY category
        ORDER BY COUNT(*) DESC
    )                                                           AS rank_within_category,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    )                                                           AS rank_overall
FROM vw_orders_master
GROUP BY category, item_name, price
ORDER BY category, rank_within_category;


-- ------------------------------------------------------------
-- ANALYSIS 11: Month-over-month revenue growth
-- Business use: Is revenue trending up or down?
-- SQL features: CTE, LAG window function, NULLIF, ROUND
-- ------------------------------------------------------------
WITH monthly_rev AS (
    SELECT
        order_year,
        order_month,
        FORMAT(DATEFROMPARTS(order_year, order_month, 1), 'MMM yyyy') AS month_label,
        ROUND(SUM(price), 2)        AS monthly_revenue,
        COUNT(DISTINCT order_id)    AS total_orders
    FROM vw_orders_master
    GROUP BY order_year, order_month
)
SELECT
    month_label,
    monthly_revenue,
    total_orders,
    LAG(monthly_revenue) OVER (ORDER BY order_year, order_month) AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_year, order_month))
        * 100.0
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY order_year, order_month), 0)
    , 1)                                                          AS mom_growth_pct,
    CASE
        WHEN monthly_revenue > LAG(monthly_revenue) OVER (ORDER BY order_year, order_month)
            THEN 'Growth'
        WHEN monthly_revenue < LAG(monthly_revenue) OVER (ORDER BY order_year, order_month)
            THEN 'Decline'
        ELSE 'Flat'
    END                                                           AS trend
FROM monthly_rev
ORDER BY order_year, order_month;
