-- ============================================================
-- SQL-3: NHS-Style Hospital Outpatient Wait-Time SLA Analysis
-- Script 01: Data Quality Checks
-- Tool: SQL Server Management Studio
-- Stakeholder: Hospital Operations Director / NHS Trust Board
-- Business question: Which specialties and regions breach the
--                    18-week referral-to-treatment target?
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Row count and basic structure check
-- ------------------------------------------------------------
SELECT
    COUNT(*)                            AS total_rows,
    COUNT(DISTINCT period)              AS distinct_periods,
    COUNT(DISTINCT provider_code)       AS distinct_providers,
    COUNT(DISTINCT specialty_name)      AS distinct_specialties,
    COUNT(DISTINCT region_name)         AS distinct_regions
FROM rtt_waiting_times;

-- ------------------------------------------------------------
-- STEP 2: NULL check on critical columns
-- ------------------------------------------------------------
SELECT
    COUNT(*) - COUNT(period)                AS null_period,
    COUNT(*) - COUNT(provider_code)         AS null_provider_code,
    COUNT(*) - COUNT(provider_name)         AS null_provider_name,
    COUNT(*) - COUNT(specialty_name)        AS null_specialty_name,
    COUNT(*) - COUNT(region_name)           AS null_region_name,
    COUNT(*) - COUNT(total_waiting)         AS null_total_waiting,
    COUNT(*) - COUNT(within_18_weeks)       AS null_within_18_weeks,
    COUNT(*) - COUNT(over_18_weeks)         AS null_over_18_weeks
FROM rtt_waiting_times;

-- ------------------------------------------------------------
-- STEP 3: Date range validation
-- ------------------------------------------------------------
SELECT
    MIN(period)             AS earliest_period,
    MAX(period)             AS latest_period,
    COUNT(DISTINCT period)  AS total_periods,
    COUNT(DISTINCT YEAR(period)) AS years_covered
FROM rtt_waiting_times;

-- ------------------------------------------------------------
-- STEP 4: Validate waiting figures — no negatives
-- ------------------------------------------------------------
SELECT
    SUM(CASE WHEN total_waiting   < 0 THEN 1 ELSE 0 END) AS negative_total_waiting,
    SUM(CASE WHEN within_18_weeks < 0 THEN 1 ELSE 0 END) AS negative_within_18,
    SUM(CASE WHEN over_18_weeks   < 0 THEN 1 ELSE 0 END) AS negative_over_18
FROM rtt_waiting_times;

-- ------------------------------------------------------------
-- STEP 5: Sense check — within + over should equal total
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS rows_where_totals_mismatch
FROM rtt_waiting_times
WHERE ABS((within_18_weeks + over_18_weeks) - total_waiting) > 1;
-- Allow rounding tolerance of 1

-- ------------------------------------------------------------
-- STEP 6: Specialty distribution
-- ------------------------------------------------------------
SELECT
    specialty_name,
    COUNT(*)                    AS record_count,
    SUM(total_waiting)          AS total_patients_waiting,
    MIN(period)                 AS first_seen,
    MAX(period)                 AS last_seen
FROM rtt_waiting_times
GROUP BY specialty_name
ORDER BY total_patients_waiting DESC;

-- ------------------------------------------------------------
-- STEP 7: Region distribution
-- ------------------------------------------------------------
SELECT
    region_name,
    COUNT(DISTINCT provider_code)   AS providers_in_region,
    COUNT(*)                        AS record_count,
    SUM(total_waiting)              AS total_patients_waiting
FROM rtt_waiting_times
GROUP BY region_name
ORDER BY total_patients_waiting DESC;
