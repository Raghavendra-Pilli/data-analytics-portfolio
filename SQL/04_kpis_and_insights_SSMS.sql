-- ============================================================
-- SQL-1: Pharmacy Inventory Replenishment Analysis
-- Script 04: KPI Definitions and Business Insights
-- SQL Server / SSMS compatible version
-- ============================================================

-- ============================================================
-- KPI 1: Stock Velocity — Average Daily Units Sold
-- ============================================================
SELECT 'M01AB — Acetic acid'       AS category, ROUND(AVG(m01ab),3) AS avg_daily_velocity, ROUND(AVG(m01ab)*7, 1) AS weekly_estimate, ROUND(AVG(m01ab)*30, 0) AS monthly_estimate FROM pharma_sales
UNION ALL
SELECT 'M01AE — Propionic acid',   ROUND(AVG(m01ae),3), ROUND(AVG(m01ae)*7,1), ROUND(AVG(m01ae)*30,0) FROM pharma_sales
UNION ALL
SELECT 'N02BA — Salicylic acid',   ROUND(AVG(n02ba),3), ROUND(AVG(n02ba)*7,1), ROUND(AVG(n02ba)*30,0) FROM pharma_sales
UNION ALL
SELECT 'N02BE — Paracetamol',      ROUND(AVG(n02be),3), ROUND(AVG(n02be)*7,1), ROUND(AVG(n02be)*30,0) FROM pharma_sales
UNION ALL
SELECT 'N05B  — Anxiolytics',      ROUND(AVG(n05b), 3), ROUND(AVG(n05b)*7, 1), ROUND(AVG(n05b)*30, 0) FROM pharma_sales
UNION ALL
SELECT 'N05C  — Hypnotics',        ROUND(AVG(n05c), 3), ROUND(AVG(n05c)*7, 1), ROUND(AVG(n05c)*30, 0) FROM pharma_sales
UNION ALL
SELECT 'R03   — Respiratory',      ROUND(AVG(r03),  3), ROUND(AVG(r03)*7,  1), ROUND(AVG(r03)*30,  0) FROM pharma_sales
UNION ALL
SELECT 'R06   — Antihistamines',   ROUND(AVG(r06),  3), ROUND(AVG(r06)*7,  1), ROUND(AVG(r06)*30,  0) FROM pharma_sales
ORDER BY avg_daily_velocity DESC;


-- ============================================================
-- KPI 2: Reorder Point (ROP)
-- Formula: ROP = (ADV × Lead Time Days) + Safety Stock
-- Assumption: 7-day lead time, 3-day safety buffer
-- ============================================================
WITH adv AS (
    SELECT
        AVG(m01ab) AS adv_m01ab, AVG(m01ae) AS adv_m01ae,
        AVG(n02ba) AS adv_n02ba, AVG(n02be) AS adv_n02be,
        AVG(n05b)  AS adv_n05b,  AVG(n05c)  AS adv_n05c,
        AVG(r03)   AS adv_r03,   AVG(r06)   AS adv_r06
    FROM pharma_sales
),
unpivoted AS (
    SELECT 'M01AB' AS category_code, adv_m01ab AS adv FROM adv UNION ALL
    SELECT 'M01AE', adv_m01ae FROM adv UNION ALL
    SELECT 'N02BA', adv_n02ba FROM adv UNION ALL
    SELECT 'N02BE', adv_n02be FROM adv UNION ALL
    SELECT 'N05B',  adv_n05b  FROM adv UNION ALL
    SELECT 'N05C',  adv_n05c  FROM adv UNION ALL
    SELECT 'R03',   adv_r03   FROM adv UNION ALL
    SELECT 'R06',   adv_r06   FROM adv
)
SELECT
    category_code,
    ROUND(adv, 3)               AS avg_daily_velocity,
    7                           AS lead_time_days,
    3                           AS safety_buffer_days,
    ROUND(adv * 7,    1)        AS demand_during_lead_time,
    ROUND(adv * 3,    1)        AS safety_stock,
    ROUND(adv * 10,   1)        AS reorder_point,
    ROUND(adv * 14,   0)        AS suggested_order_quantity
FROM unpivoted
ORDER BY reorder_point DESC;


-- ============================================================
-- KPI 3: Seasonal Demand Index
-- Definition: Monthly average / Overall average * 100
-- >120 = high season, <80 = low season
-- ============================================================
WITH overall AS (
    SELECT
        AVG(n02be) AS overall_n02be,
        AVG(r03)   AS overall_r03,
        AVG(r06)   AS overall_r06,
        AVG(m01ab) AS overall_m01ab
    FROM pharma_sales
),
monthly_avg AS (
    SELECT
        sales_month,
        FORMAT(DATEFROMPARTS(2024, sales_month, 1), 'MMM') AS month_name,
        AVG(n02be) AS mo_n02be,
        AVG(r03)   AS mo_r03,
        AVG(r06)   AS mo_r06,
        AVG(m01ab) AS mo_m01ab
    FROM pharma_sales
    GROUP BY sales_month
)
SELECT
    m.sales_month,
    m.month_name,
    ROUND(m.mo_n02be * 100.0 / NULLIF(o.overall_n02be, 0), 0) AS n02be_seasonal_index,
    ROUND(m.mo_r03   * 100.0 / NULLIF(o.overall_r03,   0), 0) AS r03_seasonal_index,
    ROUND(m.mo_r06   * 100.0 / NULLIF(o.overall_r06,   0), 0) AS r06_seasonal_index,
    ROUND(m.mo_m01ab * 100.0 / NULLIF(o.overall_m01ab, 0), 0) AS m01ab_seasonal_index,
    CASE
        WHEN ROUND(m.mo_n02be * 100.0 / NULLIF(o.overall_n02be,0),0) > 120 THEN 'HIGH SEASON — increase N02BE stock'
        WHEN ROUND(m.mo_r03   * 100.0 / NULLIF(o.overall_r03,  0),0) > 120 THEN 'HIGH SEASON — increase R03 stock'
        ELSE 'Normal demand'
    END AS purchasing_action
FROM monthly_avg m
CROSS JOIN overall o
ORDER BY m.sales_month;


-- ============================================================
-- KPI 4: Portfolio Concentration
-- ============================================================
WITH totals AS (
    SELECT
        SUM(m01ab) AS t_m01ab, SUM(m01ae) AS t_m01ae,
        SUM(n02ba) AS t_n02ba, SUM(n02be) AS t_n02be,
        SUM(n05b)  AS t_n05b,  SUM(n05c)  AS t_n05c,
        SUM(r03)   AS t_r03,   SUM(r06)   AS t_r06,
        SUM(total_daily_sales) AS grand_total
    FROM pharma_sales
),
breakdown AS (
    SELECT 'M01AB' AS category_code, 'Acetic acid derivatives'    AS category_name, t_m01ab AS total_units, grand_total FROM totals UNION ALL
    SELECT 'M01AE', 'Propionic acid derivatives',  t_m01ae, grand_total FROM totals UNION ALL
    SELECT 'N02BA', 'Salicylic acid derivatives',  t_n02ba, grand_total FROM totals UNION ALL
    SELECT 'N02BE', 'Anilides (Paracetamol)',       t_n02be, grand_total FROM totals UNION ALL
    SELECT 'N05B',  'Anxiolytics',                  t_n05b,  grand_total FROM totals UNION ALL
    SELECT 'N05C',  'Hypnotics and sedatives',       t_n05c,  grand_total FROM totals UNION ALL
    SELECT 'R03',   'Obstructive airway drugs',      t_r03,   grand_total FROM totals UNION ALL
    SELECT 'R06',   'Systemic antihistamines',       t_r06,   grand_total FROM totals
)
SELECT
    category_code,
    category_name,
    ROUND(total_units, 0)                                        AS total_units,
    ROUND(total_units * 100.0 / NULLIF(grand_total, 0), 1)      AS portfolio_share_pct,
    CASE
        WHEN total_units * 100.0 / NULLIF(grand_total,0) > 40 THEN 'CONCENTRATION RISK'
        WHEN total_units * 100.0 / NULLIF(grand_total,0) > 25 THEN 'Major category — monitor closely'
        WHEN total_units * 100.0 / NULLIF(grand_total,0) > 10 THEN 'Significant category'
        ELSE 'Minor category'
    END                                                          AS concentration_flag
FROM breakdown
ORDER BY portfolio_share_pct DESC;


-- ============================================================
-- KPI 5: Days of Supply Estimator
-- Replace current_stock values with real stock counts
-- ============================================================
WITH adv AS (
    SELECT
        AVG(m01ab) AS adv_m01ab, AVG(m01ae) AS adv_m01ae,
        AVG(n02ba) AS adv_n02ba, AVG(n02be) AS adv_n02be,
        AVG(n05b)  AS adv_n05b,  AVG(n05c)  AS adv_n05c,
        AVG(r03)   AS adv_r03,   AVG(r06)   AS adv_r06
    FROM pharma_sales
),
demo_stock (cat, current_stock) AS (
    SELECT 'M01AB', 500  UNION ALL
    SELECT 'M01AE', 1200 UNION ALL
    SELECT 'N02BA', 300  UNION ALL
    SELECT 'N02BE', 2500 UNION ALL
    SELECT 'N05B',  150  UNION ALL
    SELECT 'N05C',  80   UNION ALL
    SELECT 'R03',   600  UNION ALL
    SELECT 'R06',   450
),
velocity_table (cat, adv) AS (
    SELECT 'M01AB', adv_m01ab FROM adv UNION ALL
    SELECT 'M01AE', adv_m01ae FROM adv UNION ALL
    SELECT 'N02BA', adv_n02ba FROM adv UNION ALL
    SELECT 'N02BE', adv_n02be FROM adv UNION ALL
    SELECT 'N05B',  adv_n05b  FROM adv UNION ALL
    SELECT 'N05C',  adv_n05c  FROM adv UNION ALL
    SELECT 'R03',   adv_r03   FROM adv UNION ALL
    SELECT 'R06',   adv_r06   FROM adv
)
SELECT
    d.cat                                           AS category_code,
    d.current_stock,
    ROUND(v.adv, 3)                                 AS avg_daily_velocity,
    ROUND(d.current_stock / NULLIF(v.adv, 0), 0)   AS days_of_supply,
    CASE
        WHEN d.current_stock / NULLIF(v.adv,0) < 7  THEN 'REORDER NOW — < 7 days supply'
        WHEN d.current_stock / NULLIF(v.adv,0) < 14 THEN 'REORDER SOON — < 14 days supply'
        WHEN d.current_stock / NULLIF(v.adv,0) < 30 THEN 'Monitor — 14-30 days supply'
        ELSE                                              'Adequate stock'
    END                                             AS reorder_action
FROM demo_stock d
JOIN velocity_table v ON d.cat = v.cat
ORDER BY days_of_supply ASC;
