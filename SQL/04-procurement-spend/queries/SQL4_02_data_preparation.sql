-- ============================================================
-- SQL-4: Procurement Spend Analysis — Vendor Performance & Risk
-- Script 02: Table Creation & Data Preparation
-- Tool: SQL Server Management Studio
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Create contracts table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS procurement_contracts;

CREATE TABLE procurement_contracts (
    contract_id         INT              NOT NULL PRIMARY KEY,
    contract_ref        NVARCHAR(30)     NOT NULL,
    vendor_code         NVARCHAR(10)     NOT NULL,
    vendor_name         NVARCHAR(200)    NOT NULL,
    vendor_category     NVARCHAR(100)    NOT NULL,
    department          NVARCHAR(100)    NOT NULL,
    contract_type       NVARCHAR(50)     NOT NULL,
    contract_start      DATE             NOT NULL,
    planned_end         DATE             NOT NULL,
    actual_end          DATE             NOT NULL,
    budget_amount       DECIMAL(14,2)    NOT NULL,
    actual_amount       DECIMAL(14,2)    NOT NULL,
    cost_variance       DECIMAL(14,2)    NOT NULL,
    cost_variance_pct   DECIMAL(8,2)     NOT NULL,
    delay_days          INT              NOT NULL,
    is_overrun          TINYINT          NOT NULL,
    is_late             TINYINT          NOT NULL,
    contract_year       INT              NOT NULL
);

-- ------------------------------------------------------------
-- STEP 2: BULK INSERT
-- ------------------------------------------------------------
BULK INSERT procurement_contracts
FROM 'C:\Users\pragh\data-analytics-portfolio\SQL\04-procurement-spend\data\procurement_contracts.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);

-- ------------------------------------------------------------
-- STEP 3: Add derived risk columns
-- ------------------------------------------------------------
ALTER TABLE procurement_contracts ADD contract_duration_days  INT;
ALTER TABLE procurement_contracts ADD actual_duration_days    INT;
ALTER TABLE procurement_contracts ADD risk_score              DECIMAL(5,2);
ALTER TABLE procurement_contracts ADD risk_band               NVARCHAR(30);
ALTER TABLE procurement_contracts ADD spend_band              NVARCHAR(20);

UPDATE procurement_contracts SET
    contract_duration_days = DATEDIFF(DAY, contract_start, planned_end),
    actual_duration_days   = DATEDIFF(DAY, contract_start, actual_end),
    -- Risk score: weighted combination of overrun + late + cost variance magnitude
    risk_score = ROUND(
        (is_overrun * 40)
        + (is_late  * 30)
        + (CASE WHEN cost_variance_pct > 20 THEN 20
                WHEN cost_variance_pct > 10 THEN 10
                WHEN cost_variance_pct > 5  THEN 5
                ELSE 0 END)
        + (CASE WHEN delay_days > 60 THEN 10
                WHEN delay_days > 30 THEN 5
                ELSE 0 END)
    , 0),
    spend_band = CASE
        WHEN budget_amount >= 250000 THEN 'High (£250k+)'
        WHEN budget_amount >= 100000 THEN 'Medium (£100k–250k)'
        WHEN budget_amount >= 25000  THEN 'Low-Medium (£25k–100k)'
        ELSE                              'Low (<£25k)'
    END;

UPDATE procurement_contracts SET
    risk_band = CASE
        WHEN risk_score >= 60 THEN 'HIGH RISK'
        WHEN risk_score >= 30 THEN 'MEDIUM RISK'
        WHEN risk_score >= 10 THEN 'LOW-MEDIUM RISK'
        ELSE                       'LOW RISK'
    END;

-- ------------------------------------------------------------
-- STEP 4: Verify preparation
-- ------------------------------------------------------------
SELECT
    COUNT(*)                            AS total_contracts,
    ROUND(SUM(budget_amount), 0)        AS total_budget,
    ROUND(SUM(actual_amount), 0)        AS total_actual_spend,
    ROUND(SUM(cost_variance), 0)        AS total_variance,
    SUM(is_overrun)                     AS overrun_contracts,
    SUM(is_late)                        AS late_contracts,
    ROUND(SUM(is_overrun) * 100.0
        / COUNT(*), 1)                  AS overrun_rate_pct,
    ROUND(SUM(is_late) * 100.0
        / COUNT(*), 1)                  AS late_rate_pct
FROM procurement_contracts;
