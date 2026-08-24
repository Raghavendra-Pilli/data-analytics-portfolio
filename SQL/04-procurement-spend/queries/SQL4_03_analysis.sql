-- ============================================================
-- SQL-4: Procurement Spend Analysis — Vendor Performance & Risk
-- Script 03: Core Business Analysis
-- Tool: SQL Server Management Studio
-- This is the most advanced SQL script in the portfolio —
-- demonstrates the full window function toolkit
-- ============================================================

-- ------------------------------------------------------------
-- ANALYSIS 1: Total spend by vendor — ranked with running total
-- Business use: Where is the organisation's money going?
-- SQL features: SUM, RANK(), running SUM() OVER(), PERCENT_RANK()
-- ------------------------------------------------------------
WITH vendor_spend AS (
    SELECT
        vendor_code,
        vendor_name,
        vendor_category,
        COUNT(*)                            AS total_contracts,
        ROUND(SUM(budget_amount), 0)        AS total_budget,
        ROUND(SUM(actual_amount), 0)        AS total_actual,
        ROUND(SUM(cost_variance), 0)        AS total_variance,
        SUM(is_overrun)                     AS overrun_count,
        SUM(is_late)                        AS late_count
    FROM procurement_contracts
    GROUP BY vendor_code, vendor_name, vendor_category
)
SELECT
    vendor_name,
    vendor_category,
    total_contracts,
    total_budget,
    total_actual,
    total_variance,
    overrun_count,
    late_count,
    RANK() OVER (ORDER BY total_actual DESC)                AS spend_rank,
    ROUND(total_actual * 100.0
        / SUM(total_actual) OVER (), 2)                     AS spend_share_pct,
    -- Running cumulative spend — shows when you hit 80% concentration
    ROUND(SUM(total_actual) OVER (
        ORDER BY total_actual DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) * 100.0 / SUM(total_actual) OVER (), 2)               AS cumulative_spend_pct,
    ROUND(PERCENT_RANK() OVER (
        ORDER BY total_actual DESC
    ) * 100, 1)                                             AS spend_percentile
FROM vendor_spend
ORDER BY spend_rank;


-- ------------------------------------------------------------
-- ANALYSIS 2: Vendor overrun rate and cost variance analysis
-- Business use: Which vendors consistently exceed their budgets?
-- SQL features: RANK(), CASE, ROUND, GROUP BY
-- ------------------------------------------------------------
SELECT
    vendor_name,
    vendor_category,
    COUNT(*)                                                AS total_contracts,
    SUM(is_overrun)                                         AS overrun_contracts,
    ROUND(SUM(is_overrun) * 100.0 / COUNT(*), 1)           AS overrun_rate_pct,
    ROUND(AVG(cost_variance_pct), 2)                        AS avg_cost_variance_pct,
    ROUND(MAX(cost_variance_pct), 2)                        AS worst_overrun_pct,
    ROUND(SUM(CASE WHEN cost_variance > 0
                   THEN cost_variance ELSE 0 END), 0)       AS total_overspend,
    RANK() OVER (ORDER BY SUM(is_overrun) * 100.0
        / COUNT(*) DESC)                                    AS overrun_rank,
    CASE
        WHEN SUM(is_overrun) * 100.0 / COUNT(*) >= 50
            THEN 'HIGH RISK — review contract terms'
        WHEN SUM(is_overrun) * 100.0 / COUNT(*) >= 25
            THEN 'MEDIUM RISK — increase monitoring'
        ELSE 'LOW RISK — acceptable performance'
    END                                                     AS overrun_risk_flag
FROM procurement_contracts
GROUP BY vendor_name, vendor_category
ORDER BY overrun_rate_pct DESC;


-- ------------------------------------------------------------
-- ANALYSIS 3: Vendor delivery performance — on-time rate
-- Business use: Which vendors cause the most project delays?
-- SQL features: GROUP BY, RANK(), AVG delay, CASE
-- ------------------------------------------------------------
SELECT
    vendor_name,
    vendor_category,
    COUNT(*)                                                AS total_contracts,
    SUM(is_late)                                            AS late_contracts,
    ROUND(SUM(is_late) * 100.0 / COUNT(*), 1)              AS late_rate_pct,
    ROUND(100.0 - SUM(is_late) * 100.0 / COUNT(*), 1)      AS on_time_rate_pct,
    ROUND(AVG(CAST(delay_days AS FLOAT)), 1)                AS avg_delay_days,
    MAX(delay_days)                                         AS worst_delay_days,
    RANK() OVER (ORDER BY SUM(is_late) * 100.0
        / COUNT(*) DESC)                                    AS late_rank,
    CASE
        WHEN SUM(is_late) * 100.0 / COUNT(*) >= 50
            THEN 'UNRELIABLE — escalate to CPO'
        WHEN SUM(is_late) * 100.0 / COUNT(*) >= 30
            THEN 'CONCERNING — add penalty clauses'
        WHEN SUM(is_late) * 100.0 / COUNT(*) >= 15
            THEN 'MONITOR — review at next renewal'
        ELSE 'RELIABLE'
    END                                                     AS delivery_flag
FROM procurement_contracts
GROUP BY vendor_name, vendor_category
ORDER BY late_rate_pct DESC;


-- ------------------------------------------------------------
-- ANALYSIS 4: Spend concentration risk (Pareto analysis)
-- Business use: Do 20% of vendors represent 80% of spend?
-- SQL features: CTE, cumulative SUM() OVER(), ROW_NUMBER()
-- ------------------------------------------------------------
WITH vendor_totals AS (
    SELECT
        vendor_name,
        vendor_category,
        ROUND(SUM(actual_amount), 0)    AS total_spend
    FROM procurement_contracts
    GROUP BY vendor_name, vendor_category
),
ranked AS (
    SELECT
        vendor_name,
        vendor_category,
        total_spend,
        ROW_NUMBER() OVER (ORDER BY total_spend DESC)       AS vendor_rank,
        ROUND(total_spend * 100.0
            / SUM(total_spend) OVER (), 2)                  AS spend_share_pct,
        ROUND(SUM(total_spend) OVER (
            ORDER BY total_spend DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0 / SUM(total_spend) OVER (), 2)            AS cumulative_pct
    FROM vendor_totals
)
SELECT
    vendor_rank,
    vendor_name,
    vendor_category,
    total_spend,
    spend_share_pct,
    cumulative_pct,
    CASE
        WHEN cumulative_pct <= 80 THEN 'TOP TIER — Pareto critical vendors'
        ELSE 'LONG TAIL — lower concentration risk'
    END                                                     AS pareto_band
FROM ranked
ORDER BY vendor_rank;


-- ------------------------------------------------------------
-- ANALYSIS 5: Year-over-year spend change per vendor
-- Business use: Which vendors are growing in spend? Is that planned?
-- SQL features: CTE, LAG(), NULLIF, CASE trend
-- ------------------------------------------------------------
WITH yearly_vendor_spend AS (
    SELECT
        vendor_name,
        contract_year,
        ROUND(SUM(actual_amount), 0)    AS annual_spend,
        COUNT(*)                        AS contracts_that_year
    FROM procurement_contracts
    GROUP BY vendor_name, contract_year
)
SELECT
    vendor_name,
    contract_year,
    annual_spend,
    contracts_that_year,
    LAG(annual_spend) OVER (
        PARTITION BY vendor_name
        ORDER BY contract_year
    )                                                       AS prev_year_spend,
    annual_spend - LAG(annual_spend) OVER (
        PARTITION BY vendor_name ORDER BY contract_year
    )                                                       AS yoy_change,
    ROUND(
        (annual_spend - LAG(annual_spend) OVER (
            PARTITION BY vendor_name ORDER BY contract_year)
        ) * 100.0
        / NULLIF(LAG(annual_spend) OVER (
            PARTITION BY vendor_name ORDER BY contract_year), 0)
    , 1)                                                    AS yoy_growth_pct,
    CASE
        WHEN annual_spend > LAG(annual_spend) OVER (
            PARTITION BY vendor_name ORDER BY contract_year)
            THEN 'SPEND GROWING'
        WHEN annual_spend < LAG(annual_spend) OVER (
            PARTITION BY vendor_name ORDER BY contract_year)
            THEN 'SPEND DECLINING'
        ELSE 'STABLE'
    END                                                     AS spend_trend
FROM yearly_vendor_spend
ORDER BY vendor_name, contract_year;


-- ------------------------------------------------------------
-- ANALYSIS 6: Department spend analysis
-- Business use: Which departments are over-budget most often?
-- SQL features: GROUP BY, RANK(), CASE
-- ------------------------------------------------------------
SELECT
    department,
    COUNT(*)                                                AS total_contracts,
    ROUND(SUM(budget_amount), 0)                            AS total_budget,
    ROUND(SUM(actual_amount), 0)                            AS total_actual,
    ROUND(SUM(cost_variance), 0)                            AS total_variance,
    ROUND(SUM(actual_amount) * 100.0
        / NULLIF(SUM(budget_amount), 0) - 100, 2)          AS dept_variance_pct,
    SUM(is_overrun)                                         AS overrun_contracts,
    ROUND(SUM(is_overrun) * 100.0 / COUNT(*), 1)           AS overrun_rate_pct,
    RANK() OVER (
        ORDER BY SUM(actual_amount) DESC
    )                                                       AS spend_rank,
    CASE
        WHEN SUM(actual_amount) * 100.0
            / NULLIF(SUM(budget_amount),0) > 110
            THEN 'OVER BUDGET — review approval process'
        WHEN SUM(actual_amount) * 100.0
            / NULLIF(SUM(budget_amount),0) > 105
            THEN 'SLIGHTLY OVER — monitor'
        ELSE 'WITHIN BUDGET'
    END                                                     AS budget_status
FROM procurement_contracts
GROUP BY department
ORDER BY total_actual DESC;


-- ------------------------------------------------------------
-- ANALYSIS 7: Composite vendor risk score ranking
-- Business use: Which vendors pose the highest overall risk?
-- SQL features: CTE, composite scoring, RANK(), NTILE()
-- ------------------------------------------------------------
WITH vendor_risk_summary AS (
    SELECT
        vendor_code,
        vendor_name,
        vendor_category,
        COUNT(*)                                            AS total_contracts,
        ROUND(SUM(actual_amount), 0)                        AS total_spend,
        ROUND(SUM(is_overrun) * 100.0 / COUNT(*), 1)       AS overrun_rate,
        ROUND(SUM(is_late) * 100.0 / COUNT(*), 1)          AS late_rate,
        ROUND(AVG(cost_variance_pct), 2)                    AS avg_cost_variance,
        ROUND(AVG(CAST(delay_days AS FLOAT)), 1)            AS avg_delay_days,
        ROUND(AVG(CAST(risk_score AS FLOAT)), 1)            AS avg_risk_score
    FROM procurement_contracts
    GROUP BY vendor_code, vendor_name, vendor_category
)
SELECT
    vendor_name,
    vendor_category,
    total_contracts,
    total_spend,
    overrun_rate                                            AS overrun_rate_pct,
    late_rate                                               AS late_rate_pct,
    avg_cost_variance                                       AS avg_cost_variance_pct,
    avg_delay_days,
    avg_risk_score,
    RANK()  OVER (ORDER BY avg_risk_score DESC)             AS risk_rank,
    NTILE(3) OVER (ORDER BY avg_risk_score DESC)            AS risk_tier,
    CASE NTILE(3) OVER (ORDER BY avg_risk_score DESC)
        WHEN 1 THEN 'TIER 1 — High risk: quarterly review'
        WHEN 2 THEN 'TIER 2 — Medium risk: bi-annual review'
        WHEN 3 THEN 'TIER 3 — Low risk: annual review'
    END                                                     AS review_cadence
FROM vendor_risk_summary
ORDER BY risk_rank;


-- ------------------------------------------------------------
-- ANALYSIS 8: Contract value vs delivery performance
-- Business use: Do higher-value contracts perform better or worse?
-- SQL features: CASE spend banding, GROUP BY, window function
-- ------------------------------------------------------------
SELECT
    spend_band,
    COUNT(*)                                                AS contract_count,
    ROUND(SUM(budget_amount), 0)                            AS total_budget,
    ROUND(AVG(budget_amount), 0)                            AS avg_contract_value,
    ROUND(SUM(is_overrun) * 100.0 / COUNT(*), 1)           AS overrun_rate_pct,
    ROUND(SUM(is_late) * 100.0 / COUNT(*), 1)              AS late_rate_pct,
    ROUND(AVG(cost_variance_pct), 2)                        AS avg_variance_pct,
    ROUND(AVG(CAST(delay_days AS FLOAT)), 1)                AS avg_delay_days
FROM procurement_contracts
GROUP BY spend_band
ORDER BY AVG(budget_amount) DESC;


-- ------------------------------------------------------------
-- ANALYSIS 9: Repeat vendor contracts — loyalty or dependency?
-- Business use: Are we over-reliant on any single vendor?
-- SQL features: ROW_NUMBER(), LEAD(), DATEDIFF, CTE
-- ------------------------------------------------------------
WITH vendor_contracts_ordered AS (
    SELECT
        vendor_name,
        vendor_category,
        contract_ref,
        contract_start,
        actual_end,
        budget_amount,
        ROW_NUMBER() OVER (
            PARTITION BY vendor_code
            ORDER BY contract_start
        )                                                   AS contract_sequence,
        LEAD(contract_start) OVER (
            PARTITION BY vendor_code
            ORDER BY contract_start
        )                                                   AS next_contract_start
    FROM procurement_contracts
)
SELECT
    vendor_name,
    vendor_category,
    contract_ref,
    contract_start,
    actual_end,
    budget_amount,
    contract_sequence,
    next_contract_start,
    DATEDIFF(DAY, actual_end, next_contract_start)          AS days_between_contracts,
    CASE
        WHEN DATEDIFF(DAY, actual_end, next_contract_start) <= 7
            THEN 'BACK-TO-BACK — review dependency'
        WHEN DATEDIFF(DAY, actual_end, next_contract_start) <= 30
            THEN 'QUICK RENEWAL — assess alternatives'
        WHEN next_contract_start IS NULL
            THEN 'LAST CONTRACT'
        ELSE 'NORMAL GAP'
    END                                                     AS renewal_pattern
FROM vendor_contracts_ordered
ORDER BY vendor_name, contract_sequence;
