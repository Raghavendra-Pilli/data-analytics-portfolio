-- ============================================================
-- SQL-1: Pharmacy Inventory Replenishment Analysis
-- Script 03: Core Business Analysis
-- SQL Server / SSMS compatible version
-- ============================================================

-- ------------------------------------------------------------
-- ANALYSIS 1: Total sales by drug category (all-time ranking)
-- SQL features: UNION ALL, GROUP BY, ORDER BY
-- ------------------------------------------------------------
SELECT 'M01AB' AS category_code, 'Acetic acid derivatives'    AS category_name, ROUND(SUM(m01ab),0) AS total_units FROM pharma_sales
UNION ALL
SELECT 'M01AE', 'Propionic acid derivatives',    ROUND(SUM(m01ae),0) FROM pharma_sales
UNION ALL
SELECT 'N02BA', 'Salicylic acid derivatives',    ROUND(SUM(n02ba),0) FROM pharma_sales
UNION ALL
SELECT 'N02BE', 'Anilides (Paracetamol)',         ROUND(SUM(n02be),0) FROM pharma_sales
UNION ALL
SELECT 'N05B',  'Anxiolytics',                   ROUND(SUM(n05b), 0) FROM pharma_sales
UNION ALL
SELECT 'N05C',  'Hypnotics and sedatives',        ROUND(SUM(n05c), 0) FROM pharma_sales
UNION ALL
SELECT 'R03',   'Obstructive airway drugs',       ROUND(SUM(r03),  0) FROM pharma_sales
UNION ALL
SELECT 'R06',   'Systemic antihistamines',        ROUND(SUM(r06),  0) FROM pharma_sales
ORDER BY total_units DESC;


-- ------------------------------------------------------------
-- ANALYSIS 2: Monthly sales trend
-- SQL features: YEAR(), MONTH(), FORMAT(), GROUP BY, ORDER BY
-- ------------------------------------------------------------
SELECT
    sales_year,
    sales_month,
    FORMAT(DATEFROMPARTS(sales_year, sales_month, 1), 'MMM') AS month_name,
    ROUND(SUM(m01ab), 2)  AS m01ab_sales,
    ROUND(SUM(m01ae), 2)  AS m01ae_sales,
    ROUND(SUM(n02ba), 2)  AS n02ba_sales,
    ROUND(SUM(n02be), 2)  AS n02be_sales,
    ROUND(SUM(n05b),  2)  AS n05b_sales,
    ROUND(SUM(n05c),  2)  AS n05c_sales,
    ROUND(SUM(r03),   2)  AS r03_sales,
    ROUND(SUM(r06),   2)  AS r06_sales,
    ROUND(SUM(total_daily_sales), 2) AS monthly_total
FROM pharma_sales
GROUP BY sales_year, sales_month
ORDER BY sales_year, sales_month;


-- ------------------------------------------------------------
-- ANALYSIS 3: Seasonality — average monthly demand
-- SQL features: AVG, GROUP BY month, FORMAT
-- ------------------------------------------------------------
SELECT
    sales_month,
    FORMAT(DATEFROMPARTS(2024, sales_month, 1), 'MMMM') AS month_name,
    ROUND(AVG(m01ab), 2) AS avg_m01ab,
    ROUND(AVG(m01ae), 2) AS avg_m01ae,
    ROUND(AVG(n02ba), 2) AS avg_n02ba,
    ROUND(AVG(n02be), 2) AS avg_n02be,
    ROUND(AVG(n05b),  2) AS avg_n05b,
    ROUND(AVG(n05c),  2) AS avg_n05c,
    ROUND(AVG(r03),   2) AS avg_r03,
    ROUND(AVG(r06),   2) AS avg_r06
FROM pharma_sales
GROUP BY sales_month
ORDER BY sales_month;


-- ------------------------------------------------------------
-- ANALYSIS 4: Sales velocity — average daily units per category
-- SQL features: CTE, AVG, CASE classification, subquery
-- ------------------------------------------------------------
WITH velocity AS (
    SELECT
        ROUND(AVG(m01ab), 4) AS adv_m01ab,
        ROUND(AVG(m01ae), 4) AS adv_m01ae,
        ROUND(AVG(n02ba), 4) AS adv_n02ba,
        ROUND(AVG(n02be), 4) AS adv_n02be,
        ROUND(AVG(n05b),  4) AS adv_n05b,
        ROUND(AVG(n05c),  4) AS adv_n05c,
        ROUND(AVG(r03),   4) AS adv_r03,
        ROUND(AVG(r06),   4) AS adv_r06
    FROM pharma_sales
),
unpivoted AS (
    SELECT 'M01AB' AS category_code, adv_m01ab AS avg_daily_velocity FROM velocity UNION ALL
    SELECT 'M01AE', adv_m01ae FROM velocity UNION ALL
    SELECT 'N02BA', adv_n02ba FROM velocity UNION ALL
    SELECT 'N02BE', adv_n02be FROM velocity UNION ALL
    SELECT 'N05B',  adv_n05b  FROM velocity UNION ALL
    SELECT 'N05C',  adv_n05c  FROM velocity UNION ALL
    SELECT 'R03',   adv_r03   FROM velocity UNION ALL
    SELECT 'R06',   adv_r06   FROM velocity
)
SELECT
    category_code,
    avg_daily_velocity,
    ROUND(avg_daily_velocity * 7,  2) AS reorder_point_7day_lead,
    ROUND(avg_daily_velocity * 3,  2) AS safety_stock,
    CASE
        WHEN avg_daily_velocity > 5  THEN 'High velocity — reorder weekly'
        WHEN avg_daily_velocity > 2  THEN 'Medium velocity — reorder fortnightly'
        ELSE                              'Low velocity — reorder monthly'
    END                               AS reorder_frequency_recommendation
FROM unpivoted
ORDER BY avg_daily_velocity DESC;


-- ------------------------------------------------------------
-- ANALYSIS 5: Peak demand by day of week
-- SQL features: GROUP BY, AVG, CASE sort, window function
-- ------------------------------------------------------------
SELECT
    day_of_week,
    ROUND(AVG(m01ab), 2)             AS avg_m01ab,
    ROUND(AVG(n02be), 2)             AS avg_n02be,
    ROUND(AVG(r03),   2)             AS avg_r03,
    ROUND(AVG(total_daily_sales), 2) AS avg_total_sales,
    ROUND(AVG(total_daily_sales) * 100.0
        / SUM(AVG(total_daily_sales)) OVER (), 1) AS pct_of_weekly_avg
FROM pharma_sales
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
-- ANALYSIS 6: Year-over-year growth by category
-- SQL features: CTE, LAG window function, NULLIF, ROUND
-- ------------------------------------------------------------
WITH yearly AS (
    SELECT
        sales_year,
        ROUND(SUM(m01ab), 0) AS yr_m01ab,
        ROUND(SUM(m01ae), 0) AS yr_m01ae,
        ROUND(SUM(n02ba), 0) AS yr_n02ba,
        ROUND(SUM(n02be), 0) AS yr_n02be,
        ROUND(SUM(n05b),  0) AS yr_n05b,
        ROUND(SUM(n05c),  0) AS yr_n05c,
        ROUND(SUM(r03),   0) AS yr_r03,
        ROUND(SUM(r06),   0) AS yr_r06
    FROM pharma_sales
    GROUP BY sales_year
)
SELECT
    sales_year,
    yr_m01ab,
    LAG(yr_m01ab) OVER (ORDER BY sales_year)   AS prev_yr_m01ab,
    ROUND(
        (yr_m01ab - LAG(yr_m01ab) OVER (ORDER BY sales_year)) * 100.0
        / NULLIF(LAG(yr_m01ab) OVER (ORDER BY sales_year), 0)
    , 1)                                        AS m01ab_yoy_pct,
    yr_n02be,
    ROUND(
        (yr_n02be - LAG(yr_n02be) OVER (ORDER BY sales_year)) * 100.0
        / NULLIF(LAG(yr_n02be) OVER (ORDER BY sales_year), 0)
    , 1)                                        AS n02be_yoy_pct,
    yr_r03,
    ROUND(
        (yr_r03 - LAG(yr_r03) OVER (ORDER BY sales_year)) * 100.0
        / NULLIF(LAG(yr_r03) OVER (ORDER BY sales_year), 0)
    , 1)                                        AS r03_yoy_pct,
    yr_r06,
    ROUND(
        (yr_r06 - LAG(yr_r06) OVER (ORDER BY sales_year)) * 100.0
        / NULLIF(LAG(yr_r06) OVER (ORDER BY sales_year), 0)
    , 1)                                        AS r06_yoy_pct
FROM yearly
ORDER BY sales_year;


-- ------------------------------------------------------------
-- ANALYSIS 7: Top 15 highest-demand days (stockout risk)
-- SQL features: TOP, CASE risk classification, subquery
-- ------------------------------------------------------------
SELECT TOP 15
    datum,
    FORMAT(datum, 'dddd, dd MMM yyyy')   AS full_date,
    sales_year,
    sales_month,
    day_of_week,
    ROUND(total_daily_sales, 2)          AS total_sales,
    ROUND(n02be, 2)                      AS paracetamol_sales,
    ROUND(r03,   2)                      AS respiratory_sales,
    CASE
        WHEN total_daily_sales > (SELECT AVG(total_daily_sales) * 1.5 FROM pharma_sales)
            THEN 'HIGH RISK — likely to cause stockout'
        WHEN total_daily_sales > (SELECT AVG(total_daily_sales) * 1.2 FROM pharma_sales)
            THEN 'ELEVATED — monitor closely'
        ELSE 'Normal'
    END                                  AS stockout_risk_flag
FROM pharma_sales
ORDER BY total_daily_sales DESC;


-- ------------------------------------------------------------
-- KPI SUMMARY VIEW
-- ------------------------------------------------------------
CREATE OR ALTER VIEW vw_pharmacy_kpi_summary AS
SELECT
    COUNT(*)                              AS total_trading_days,
    MIN(datum)                            AS data_from,
    MAX(datum)                            AS data_to,
    ROUND(SUM(total_daily_sales), 0)      AS grand_total_units,
    ROUND(AVG(total_daily_sales), 2)      AS avg_daily_units,
    ROUND(MAX(total_daily_sales), 2)      AS peak_daily_units,
    ROUND(MIN(total_daily_sales), 2)      AS lowest_daily_units,
    ROUND(SUM(n02be) * 100.0 / NULLIF(SUM(total_daily_sales), 0), 1) AS paracetamol_share_pct,
    ROUND(SUM(r03)   * 100.0 / NULLIF(SUM(total_daily_sales), 0), 1) AS respiratory_share_pct,
    ROUND(SUM(m01ab + m01ae + n02ba + n02be) * 100.0
          / NULLIF(SUM(total_daily_sales), 0), 1)                     AS pain_portfolio_share_pct
FROM pharma_sales;

SELECT * FROM vw_pharmacy_kpi_summary;
