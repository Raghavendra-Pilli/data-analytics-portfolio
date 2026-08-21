-- ============================================================
-- SQL-2: Restaurant Menu Profitability & Ordering Patterns
-- Script 04: KPI Definitions & Business Insights
-- Tool: SQL Server Management Studio
-- ============================================================

-- ============================================================
-- KPI 1: Total Revenue, Orders and Average Order Value
-- ============================================================
SELECT
    COUNT(DISTINCT order_id)                        AS total_orders,
    COUNT(*)                                        AS total_items_sold,
    ROUND(SUM(price), 2)                            AS total_revenue,
    ROUND(AVG(price), 2)                            AS avg_item_price,
    ROUND(SUM(price) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_value,
    MIN(order_date)                                 AS date_from,
    MAX(order_date)                                 AS date_to,
    COUNT(DISTINCT order_date)                      AS trading_days,
    ROUND(SUM(price) / NULLIF(COUNT(DISTINCT order_date), 0), 2) AS avg_daily_revenue
FROM vw_orders_master;


-- ============================================================
-- KPI 2: Menu Item Profitability Score
-- High volume + High price = Star item (protect at all costs)
-- High volume + Low price  = Workhorse item (volume driver)
-- Low volume  + High price = Niche item (premium, low reach)
-- Low volume  + Low price  = Review item (candidate for removal)
-- ============================================================
WITH item_stats AS (
    SELECT
        item_name,
        category,
        price,
        COUNT(*)            AS times_ordered,
        ROUND(SUM(price),2) AS total_revenue
    FROM vw_orders_master
    GROUP BY item_name, category, price
),
averages AS (
    SELECT
        AVG(CAST(times_ordered AS FLOAT))   AS avg_orders,
        AVG(price)                          AS avg_price
    FROM item_stats
)
SELECT
    i.item_name,
    i.category,
    i.price,
    i.times_ordered,
    i.total_revenue,
    CASE
        WHEN i.times_ordered >= a.avg_orders AND i.price >= a.avg_price THEN 'STAR — high volume, high price'
        WHEN i.times_ordered >= a.avg_orders AND i.price <  a.avg_price THEN 'WORKHORSE — high volume, low price'
        WHEN i.times_ordered <  a.avg_orders AND i.price >= a.avg_price THEN 'NICHE — low volume, high price'
        ELSE                                                                  'REVIEW — low volume, low price'
    END                     AS menu_category_flag
FROM item_stats i
CROSS JOIN averages a
ORDER BY i.total_revenue DESC;


-- ============================================================
-- KPI 3: Revenue Concentration — top 5 items
-- Business risk: What % of revenue comes from just 5 items?
-- ============================================================
WITH item_revenue AS (
    SELECT
        item_name,
        ROUND(SUM(price), 2) AS item_revenue
    FROM vw_orders_master
    GROUP BY item_name
),
total AS (
    SELECT SUM(item_revenue) AS grand_total FROM item_revenue
)
SELECT TOP 5
    i.item_name,
    i.item_revenue,
    ROUND(i.item_revenue * 100.0 / t.grand_total, 1) AS revenue_share_pct,
    SUM(i.item_revenue * 100.0 / t.grand_total)
        OVER (ORDER BY i.item_revenue DESC
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_share_pct
FROM item_revenue i
CROSS JOIN total t
ORDER BY i.item_revenue DESC;


-- ============================================================
-- KPI 4: Peak Hour Analysis — orders by hour of day
-- Business use: Staff scheduling and kitchen prep planning
-- ============================================================
SELECT
    DATEPART(HOUR, order_time)              AS order_hour,
    FORMAT(CAST(CAST(DATEPART(HOUR, order_time) AS VARCHAR) + ':00' AS TIME), 'hh:mm tt') AS hour_label,
    COUNT(DISTINCT order_id)                AS total_orders,
    COUNT(*)                                AS total_items,
    ROUND(SUM(price), 2)                    AS total_revenue,
    CASE
        WHEN COUNT(DISTINCT order_id) >= (
            SELECT AVG(cnt) * 1.3
            FROM (
                SELECT DATEPART(HOUR, order_time) AS hr, COUNT(DISTINCT order_id) AS cnt
                FROM vw_orders_master
                GROUP BY DATEPART(HOUR, order_time)
            ) h
        ) THEN 'PEAK — full staff required'
        WHEN COUNT(DISTINCT order_id) >= (
            SELECT AVG(cnt)
            FROM (
                SELECT DATEPART(HOUR, order_time) AS hr, COUNT(DISTINCT order_id) AS cnt
                FROM vw_orders_master
                GROUP BY DATEPART(HOUR, order_time)
            ) h
        ) THEN 'BUSY — normal staffing'
        ELSE 'QUIET — reduced staffing possible'
    END                                     AS staffing_flag
FROM vw_orders_master
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_hour;


-- ============================================================
-- KPI 5: Category Attach Rate — how often categories appear together
-- Business use: Which categories are commonly ordered in same order?
-- Supports: bundling / combo deal decisions
-- ============================================================
WITH order_categories AS (
    SELECT
        order_id,
        STRING_AGG(DISTINCT category, ', ') WITHIN GROUP (ORDER BY category) AS categories_in_order,
        COUNT(DISTINCT category)             AS num_categories
    FROM vw_orders_master
    GROUP BY order_id
)
SELECT
    categories_in_order,
    COUNT(*)                AS order_count,
    ROUND(COUNT(*) * 100.0
        / (SELECT COUNT(*) FROM order_categories), 1) AS pct_of_orders
FROM order_categories
GROUP BY categories_in_order
ORDER BY order_count DESC;


-- ============================================================
-- EXECUTIVE SUMMARY VIEW
-- ============================================================
CREATE OR ALTER VIEW vw_restaurant_kpi_summary AS
SELECT
    COUNT(DISTINCT order_id)                                            AS total_orders,
    COUNT(*)                                                            AS total_items_sold,
    ROUND(SUM(price), 2)                                                AS total_revenue,
    ROUND(SUM(price) / NULLIF(COUNT(DISTINCT order_id), 0), 2)         AS avg_order_value,
    ROUND(SUM(price) / NULLIF(COUNT(DISTINCT order_date), 0), 2)       AS avg_daily_revenue,
    COUNT(DISTINCT item_name)                                           AS distinct_menu_items,
    COUNT(DISTINCT category)                                            AS distinct_categories,
    MIN(order_date)                                                     AS data_from,
    MAX(order_date)                                                     AS data_to
FROM vw_orders_master;

SELECT * FROM vw_restaurant_kpi_summary;
