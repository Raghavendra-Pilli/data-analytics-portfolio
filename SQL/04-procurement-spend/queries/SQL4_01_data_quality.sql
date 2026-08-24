-- ============================================================
-- SQL-4: Procurement Spend Analysis — Vendor Performance & Risk
-- Script 01: Data Quality Checks
-- Tool: SQL Server Management Studio
-- Stakeholder: Chief Procurement Officer / Finance Director
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Basic row count and coverage
-- ------------------------------------------------------------
SELECT
    COUNT(*)                            AS total_contracts,
    COUNT(DISTINCT vendor_code)         AS distinct_vendors,
    COUNT(DISTINCT vendor_category)     AS distinct_categories,
    COUNT(DISTINCT department)          AS distinct_departments,
    COUNT(DISTINCT contract_year)       AS years_covered,
    MIN(contract_start)                 AS earliest_contract,
    MAX(actual_end)                     AS latest_end
FROM procurement_contracts;

-- ------------------------------------------------------------
-- STEP 2: NULL check on critical columns
-- ------------------------------------------------------------
SELECT
    COUNT(*) - COUNT(contract_ref)      AS null_contract_ref,
    COUNT(*) - COUNT(vendor_code)       AS null_vendor_code,
    COUNT(*) - COUNT(vendor_name)       AS null_vendor_name,
    COUNT(*) - COUNT(budget_amount)     AS null_budget,
    COUNT(*) - COUNT(actual_amount)     AS null_actual,
    COUNT(*) - COUNT(contract_start)    AS null_start_date,
    COUNT(*) - COUNT(planned_end)       AS null_planned_end,
    COUNT(*) - COUNT(actual_end)        AS null_actual_end
FROM procurement_contracts;

-- ------------------------------------------------------------
-- STEP 3: Validate amounts — no zero or negative budgets
-- ------------------------------------------------------------
SELECT
    SUM(CASE WHEN budget_amount <= 0  THEN 1 ELSE 0 END) AS zero_neg_budget,
    SUM(CASE WHEN actual_amount <= 0  THEN 1 ELSE 0 END) AS zero_neg_actual,
    MIN(budget_amount)                                    AS min_budget,
    MAX(budget_amount)                                    AS max_budget,
    ROUND(AVG(budget_amount), 2)                          AS avg_budget
FROM procurement_contracts;

-- ------------------------------------------------------------
-- STEP 4: Date logic check — actual_end before contract_start
-- ------------------------------------------------------------
SELECT COUNT(*) AS invalid_dates
FROM procurement_contracts
WHERE actual_end < contract_start;

-- ------------------------------------------------------------
-- STEP 5: Variance cross-check
-- actual_amount - budget_amount should equal cost_variance
-- ------------------------------------------------------------
SELECT COUNT(*) AS variance_mismatch
FROM procurement_contracts
WHERE ABS((actual_amount - budget_amount) - cost_variance) > 1;

-- ------------------------------------------------------------
-- STEP 6: Overrun and late flags distribution
-- ------------------------------------------------------------
SELECT
    is_overrun,
    is_late,
    COUNT(*)                                AS contract_count,
    ROUND(COUNT(*) * 100.0
        / (SELECT COUNT(*) FROM procurement_contracts), 1) AS pct_of_total
FROM procurement_contracts
GROUP BY is_overrun, is_late
ORDER BY is_overrun DESC, is_late DESC;

-- ------------------------------------------------------------
-- STEP 7: Spend by year — sanity check
-- ------------------------------------------------------------
SELECT
    contract_year,
    COUNT(*)                        AS contracts,
    ROUND(SUM(budget_amount), 0)    AS total_budget,
    ROUND(SUM(actual_amount), 0)    AS total_actual,
    ROUND(SUM(cost_variance), 0)    AS total_variance
FROM procurement_contracts
GROUP BY contract_year
ORDER BY contract_year;
