-- ============================================================
-- SQL-3: NHS-Style Hospital Outpatient Wait-Time SLA Analysis
-- Script 02: Table Creation & Data Preparation
-- Tool: SQL Server Management Studio
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Create main waiting times table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS rtt_waiting_times;

CREATE TABLE rtt_waiting_times (
    record_id           INT             NOT NULL PRIMARY KEY,
    period              DATE            NOT NULL,   -- month of reporting
    provider_code       NVARCHAR(10)    NOT NULL,   -- hospital trust code
    provider_name       NVARCHAR(200)   NOT NULL,   -- hospital trust name
    specialty_code      NVARCHAR(10),               -- ATC specialty code
    specialty_name      NVARCHAR(200)   NOT NULL,   -- readable specialty
    region_code         NVARCHAR(10),               -- NHS region code
    region_name         NVARCHAR(100)   NOT NULL,   -- NHS region name
    total_waiting       INT             NOT NULL,   -- total patients on list
    within_18_weeks     INT             NOT NULL,   -- patients within SLA
    over_18_weeks       INT             NOT NULL,   -- patients breaching SLA
    over_52_weeks       INT,                        -- severely overdue
    median_wait_weeks   DECIMAL(6,1),               -- median wait in weeks
    avg_wait_weeks      DECIMAL(6,1)                -- average wait in weeks
);

-- ------------------------------------------------------------
-- STEP 2: BULK INSERT the CSV
-- ------------------------------------------------------------
BULK INSERT rtt_waiting_times
FROM 'C:\Users\pragh\data-analytics-portfolio\SQL\03-hospital-wait-times\data\rtt_waiting_times.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);

-- ------------------------------------------------------------
-- STEP 3: Add derived columns
-- ------------------------------------------------------------
ALTER TABLE rtt_waiting_times ADD report_year         INT;
ALTER TABLE rtt_waiting_times ADD report_month        INT;
ALTER TABLE rtt_waiting_times ADD report_quarter      NVARCHAR(10);
ALTER TABLE rtt_waiting_times ADD pct_within_18_weeks DECIMAL(6,2);
ALTER TABLE rtt_waiting_times ADD pct_over_18_weeks   DECIMAL(6,2);
ALTER TABLE rtt_waiting_times ADD sla_status          NVARCHAR(30);

UPDATE rtt_waiting_times SET
    report_year         = YEAR(period),
    report_month        = MONTH(period),
    report_quarter      = 'Q' + CAST(DATEPART(QUARTER, period) AS NVARCHAR),
    pct_within_18_weeks = ROUND(within_18_weeks * 100.0
                            / NULLIF(total_waiting, 0), 2),
    pct_over_18_weeks   = ROUND(over_18_weeks * 100.0
                            / NULLIF(total_waiting, 0), 2),
    -- NHS SLA target: 92% of patients treated within 18 weeks
    sla_status          = CASE
                            WHEN within_18_weeks * 100.0
                                / NULLIF(total_waiting,0) >= 92
                                THEN 'MEETS TARGET'
                            WHEN within_18_weeks * 100.0
                                / NULLIF(total_waiting,0) >= 80
                                THEN 'NEAR MISS'
                            WHEN within_18_weeks * 100.0
                                / NULLIF(total_waiting,0) >= 60
                                THEN 'BREACHING'
                            ELSE 'SEVERELY BREACHING'
                          END;

-- ------------------------------------------------------------
-- STEP 4: Verify preparation
-- ------------------------------------------------------------
SELECT
    COUNT(*)                            AS total_records,
    COUNT(DISTINCT provider_code)       AS distinct_trusts,
    COUNT(DISTINCT specialty_name)      AS distinct_specialties,
    COUNT(DISTINCT region_name)         AS distinct_regions,
    MIN(period)                         AS data_from,
    MAX(period)                         AS data_to,
    SUM(total_waiting)                  AS total_patients_on_list,
    SUM(over_18_weeks)                  AS total_breaching_sla,
    ROUND(SUM(over_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting),0), 2) AS overall_breach_rate_pct
FROM rtt_waiting_times;

-- ------------------------------------------------------------
-- STEP 5: SLA status distribution
-- ------------------------------------------------------------
SELECT
    sla_status,
    COUNT(*)    AS record_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM rtt_waiting_times), 1)
                AS pct_of_records
FROM rtt_waiting_times
GROUP BY sla_status
ORDER BY record_count DESC;
