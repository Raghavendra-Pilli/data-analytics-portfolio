-- ============================================================
-- SQL-4: Procurement Spend Analysis — Vendor Performance & Risk
-- Script 04: KPI Definitions & Business Insights
-- Tool: SQL Server Management Studio
-- ============================================================

-- ============================================================
-- KPI 1: Total Spend vs Budget (overall portfolio)
-- Definition: Actual spend / Budget × 100 — portfolio efficiency
-- ============================================================
SELECT
    COUNT(*)                                                AS total_contracts,
    ROUND(SUM(budget_amount), 0)                            AS total_budget,
    ROUND(SUM(actual_amount), 0)                            AS total_actual_spend,
    ROUND(SUM(cost_variance), 0)                            AS total_cost_variance,
    ROUND(SUM(actual_amount) * 100.0
        / NULLIF(SUM(budget_amount), 0), 2)                 AS budget_utilisation_pct,
    ROUND(SUM(cost_variance) * 100.0
        / NULLIF(SUM(budget_amount), 0), 2)                 AS portfolio_variance_pct,
    SUM(is_overrun)                                         AS contracts_overrun,
    ROUND(SUM(is_overrun) * 100.0 / COUNT(*), 1)           AS overrun_rate_pct,
    SUM(is_late)                                            AS contracts_late,
    ROUND(SUM(is_late) * 100.0 / COUNT(*), 1)              AS late_rate_pct
FROM procurement_contracts;


-- ============================================================
-- KPI 2: Spend Concentration Index
-- Definition: % of total spend held by top 3 vendors
-- Red flag: Top 3 vendors > 50% of spend = concentration risk
-- ============================================================
WITH vendor_spend AS (
    SELECT
        vendor_name,
        ROUND(SUM(actual_amount), 0)    AS total_spend
    FROM procurement_contracts
    GROUP BY vendor_name
),
ranked AS (
    SELECT
        vendor_name,
        total_spend,
        RANK() OVER (ORDER BY total_spend DESC) AS rnk,
        SUM(total_spend) OVER ()                AS grand_total
    FROM vendor_spend
)
SELECT
    SUM(CASE WHEN rnk <= 3
             THEN total_spend ELSE 0 END)                   AS top3_vendor_spend,
    MAX(grand_total)                                        AS total_portfolio_spend,
    ROUND(SUM(CASE WHEN rnk <= 3
                   THEN total_spend ELSE 0 END) * 100.0
          / MAX(grand_total), 1)                            AS top3_concentration_pct,
    CASE
        WHEN SUM(CASE WHEN rnk <= 3
                      THEN total_spend ELSE 0 END) * 100.0
             / MAX(grand_total) > 50
            THEN 'CONCENTRATION RISK — too dependent on 3 vendors'
        WHEN SUM(CASE WHEN rnk <= 3
                      THEN total_spend ELSE 0 END) * 100.0
             / MAX(grand_total) > 35
            THEN 'ELEVATED — monitor vendor diversification'
        ELSE 'ACCEPTABLE — spend well distributed'
    END                                                     AS concentration_flag
FROM ranked;


-- ============================================================
-- KPI 3: Vendor On-Time Delivery Rate
-- Definition: Contracts delivered on or before planned_end / total
-- Target: > 85% on-time delivery
-- ============================================================
SELECT
    vendor_name,
    vendor_category,
    COUNT(*)                                                AS total_contracts,
    COUNT(*) - SUM(is_late)                                 AS on_time_contracts,
    SUM(is_late)                                            AS late_contracts,
    ROUND((COUNT(*) - SUM(is_late)) * 100.0
        / COUNT(*), 1)                                      AS on_time_rate_pct,
    85.0                                                    AS target_pct,
    ROUND(85.0 - (COUNT(*) - SUM(is_late)) * 100.0
        / COUNT(*), 1)                                      AS gap_to_target,
    ROUND(AVG(CAST(delay_days AS FLOAT)), 1)                AS avg_delay_days,
    RANK() OVER (
        ORDER BY (COUNT(*) - SUM(is_late)) * 100.0
            / COUNT(*) DESC
    )                                                       AS delivery_rank
FROM procurement_contracts
GROUP BY vendor_name, vendor_category
ORDER BY on_time_rate_pct DESC;


-- ============================================================
-- KPI 4: Average Cost Overrun per Vendor
-- Definition: Mean cost_variance_pct across overrun contracts only
-- Used to identify systematic over-pricing vs. scope creep
-- ============================================================
WITH overrun_contracts AS (
    SELECT
        vendor_name,
        vendor_category,
        cost_variance,
        cost_variance_pct,
        budget_amount,
        actual_amount
    FROM procurement_contracts
    WHERE is_overrun = 1
)
SELECT
    vendor_name,
    vendor_category,
    COUNT(*)                                                AS overrun_contract_count,
    ROUND(AVG(cost_variance_pct), 2)                        AS avg_overrun_pct,
    ROUND(MAX(cost_variance_pct), 2)                        AS worst_overrun_pct,
    ROUND(SUM(cost_variance), 0)                            AS total_overspend,
    ROUND(AVG(budget_amount), 0)                            AS avg_contract_value,
    RANK() OVER (ORDER BY AVG(cost_variance_pct) DESC)      AS overrun_severity_rank,
    CASE
        WHEN AVG(cost_variance_pct) > 30
            THEN 'SEVERE — formal contract review required'
        WHEN AVG(cost_variance_pct) > 15
            THEN 'HIGH — add cost control clauses at renewal'
        WHEN AVG(cost_variance_pct) > 5
            THEN 'MODERATE — monitor with monthly reporting'
        ELSE 'LOW — within acceptable tolerance'
    END                                                     AS overrun_action
FROM overrun_contracts
GROUP BY vendor_name, vendor_category
ORDER BY avg_overrun_pct DESC;


-- ============================================================
-- KPI 5: Vendor Risk Register
-- Definition: Composite risk tier for every vendor
-- Used for: Annual vendor review schedule and risk mitigation
-- ============================================================
WITH risk_register AS (
    SELECT
        vendor_code,
        vendor_name,
        vendor_category,
        COUNT(*)                                            AS contracts,
        ROUND(SUM(actual_amount), 0)                        AS total_spend,
        ROUND(SUM(is_overrun) * 100.0 / COUNT(*), 1)       AS overrun_rate,
        ROUND(SUM(is_late) * 100.0 / COUNT(*), 1)          AS late_rate,
        ROUND(AVG(cost_variance_pct), 2)                    AS avg_variance_pct,
        ROUND(AVG(CAST(risk_score AS FLOAT)), 1)            AS avg_risk_score,
        -- High spend + high risk = critical vendor
        ROUND(SUM(actual_amount), 0)
            * ROUND(AVG(CAST(risk_score AS FLOAT)), 1)      AS risk_exposure_index
    FROM procurement_contracts
    GROUP BY vendor_code, vendor_name, vendor_category
)
SELECT
    vendor_name,
    vendor_category,
    contracts,
    total_spend,
    overrun_rate                                            AS overrun_pct,
    late_rate                                               AS late_pct,
    avg_variance_pct,
    avg_risk_score,
    ROUND(risk_exposure_index, 0)                           AS risk_exposure_index,
    NTILE(3) OVER (ORDER BY risk_exposure_index DESC)       AS risk_tier,
    CASE NTILE(3) OVER (ORDER BY risk_exposure_index DESC)
        WHEN 1 THEN 'CRITICAL — quarterly exec review'
        WHEN 2 THEN 'ELEVATED — bi-annual review'
        WHEN 3 THEN 'STANDARD — annual review'
    END                                                     AS review_cadence,
    RANK() OVER (ORDER BY risk_exposure_index DESC)         AS risk_rank
FROM risk_register
ORDER BY risk_rank;


-- ============================================================
-- EXECUTIVE SUMMARY VIEW
-- ============================================================
GO
CREATE OR ALTER VIEW vw_procurement_kpi_summary AS
SELECT
    COUNT(*)                                                AS total_contracts,
    COUNT(DISTINCT vendor_code)                             AS total_vendors,
    COUNT(DISTINCT department)                              AS departments_buying,
    MIN(contract_start)                                     AS portfolio_start,
    MAX(actual_end)                                         AS portfolio_end,
    ROUND(SUM(budget_amount), 0)                            AS total_budget,
    ROUND(SUM(actual_amount), 0)                            AS total_actual_spend,
    ROUND(SUM(cost_variance), 0)                            AS total_variance,
    ROUND(SUM(actual_amount) * 100.0
        / NULLIF(SUM(budget_amount),0), 2)                  AS budget_utilisation_pct,
    SUM(is_overrun)                                         AS overrun_contracts,
    ROUND(SUM(is_overrun) * 100.0 / COUNT(*), 1)           AS overrun_rate_pct,
    SUM(is_late)                                            AS late_contracts,
    ROUND(SUM(is_late) * 100.0 / COUNT(*), 1)              AS late_rate_pct
FROM procurement_contracts;
GO

SELECT * FROM vw_procurement_kpi_summary;
