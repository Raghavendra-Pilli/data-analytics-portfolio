-- ============================================================
-- SQL-1: Pharmacy Inventory Replenishment Analysis
-- Script 01: Data Quality Checks
-- SQL Server / SSMS compatible version
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Row count and basic completeness
-- ------------------------------------------------------------
SELECT
    COUNT(*)                          AS total_rows,
    COUNT(datum)                      AS rows_with_date,
    COUNT(m01ab)                      AS rows_with_m01ab,
    COUNT(*) - COUNT(datum)           AS missing_date,
    COUNT(*) - COUNT(m01ab)           AS missing_m01ab
FROM pharma_sales;

-- ------------------------------------------------------------
-- STEP 2: Check for duplicate dates
-- ------------------------------------------------------------
SELECT
    datum,
    COUNT(*) AS row_count
FROM pharma_sales
GROUP BY datum
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

-- ------------------------------------------------------------
-- STEP 3: Date range validation
-- ------------------------------------------------------------
SELECT
    MIN(datum)            AS earliest_date,
    MAX(datum)            AS latest_date,
    COUNT(DISTINCT datum) AS distinct_periods,
    YEAR(MIN(datum))      AS start_year,
    YEAR(MAX(datum))      AS end_year
FROM pharma_sales;

-- ------------------------------------------------------------
-- STEP 4: Negative or zero sales check
-- ------------------------------------------------------------
SELECT 'M01AB' AS drug_category, COUNT(*) AS zero_or_negative_rows FROM pharma_sales WHERE m01ab <= 0
UNION ALL
SELECT 'M01AE', COUNT(*) FROM pharma_sales WHERE m01ae <= 0
UNION ALL
SELECT 'N02BA', COUNT(*) FROM pharma_sales WHERE n02ba <= 0
UNION ALL
SELECT 'N02BE', COUNT(*) FROM pharma_sales WHERE n02be <= 0
UNION ALL
SELECT 'N05B',  COUNT(*) FROM pharma_sales WHERE n05b  <= 0
UNION ALL
SELECT 'N05C',  COUNT(*) FROM pharma_sales WHERE n05c  <= 0
UNION ALL
SELECT 'R03',   COUNT(*) FROM pharma_sales WHERE r03   <= 0
UNION ALL
SELECT 'R06',   COUNT(*) FROM pharma_sales WHERE r06   <= 0;

-- ------------------------------------------------------------
-- STEP 5: Outlier detection — sales > 3 standard deviations
-- ------------------------------------------------------------
WITH stats AS (
    SELECT
        AVG(m01ab)    AS avg_m01ab,
        STDEV(m01ab)  AS std_m01ab,
        AVG(n02be)    AS avg_n02be,
        STDEV(n02be)  AS std_n02be
    FROM pharma_sales
)
SELECT TOP 20
    p.datum,
    p.m01ab,
    p.n02be,
    ROUND((p.m01ab - s.avg_m01ab) / NULLIF(s.std_m01ab, 0), 2) AS m01ab_zscore,
    ROUND((p.n02be - s.avg_n02be) / NULLIF(s.std_n02be, 0), 2) AS n02be_zscore
FROM pharma_sales p
CROSS JOIN stats s
WHERE ABS((p.m01ab - s.avg_m01ab) / NULLIF(s.std_m01ab, 0)) > 3
   OR ABS((p.n02be - s.avg_n02be) / NULLIF(s.std_n02be, 0)) > 3
ORDER BY m01ab_zscore DESC;
