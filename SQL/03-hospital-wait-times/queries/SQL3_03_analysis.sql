-- ============================================================
-- SQL-3: NHS-Style Hospital Outpatient Wait-Time SLA Analysis
-- Script 03: Core Business Analysis
-- Tool: SQL Server Management Studio
-- NHS SLA Target: 92% of patients treated within 18 weeks
-- ============================================================

-- ------------------------------------------------------------
-- ANALYSIS 1: Overall SLA performance summary
-- Business use: Board-level headline — are we hitting the target?
-- SQL features: CASE, SUM, ROUND, NULLIF
-- ------------------------------------------------------------
SELECT
    SUM(total_waiting)                                      AS total_patients_waiting,
    SUM(within_18_weeks)                                    AS total_within_sla,
    SUM(over_18_weeks)                                      AS total_breaching_sla,
    ROUND(SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS overall_pct_within_18_weeks,
    ROUND(SUM(over_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS overall_breach_rate_pct,
    92.0                                                    AS sla_target_pct,
    CASE
        WHEN SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0) >= 92
            THEN 'TARGET MET'
        ELSE 'TARGET MISSED'
    END                                                     AS sla_verdict
FROM rtt_waiting_times;


-- ------------------------------------------------------------
-- ANALYSIS 2: SLA performance by specialty — ranked worst first
-- Business use: Which clinical areas need urgent intervention?
-- SQL features: GROUP BY, ROUND, RANK() window function
-- ------------------------------------------------------------
SELECT
    specialty_name,
    SUM(total_waiting)                                      AS total_patients,
    SUM(within_18_weeks)                                    AS within_sla,
    SUM(over_18_weeks)                                      AS breaching_sla,
    ROUND(SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS pct_within_18_weeks,
    ROUND(SUM(over_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS breach_rate_pct,
    RANK() OVER (
        ORDER BY SUM(over_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting), 0) DESC
    )                                                       AS breach_rank,
    CASE
        WHEN SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0) >= 92
            THEN 'MEETS TARGET'
        WHEN SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0) >= 80
            THEN 'NEAR MISS'
        ELSE 'BREACHING'
    END                                                     AS sla_status
FROM rtt_waiting_times
GROUP BY specialty_name
ORDER BY breach_rate_pct DESC;


-- ------------------------------------------------------------
-- ANALYSIS 3: SLA performance by region
-- Business use: Are certain NHS regions systematically worse?
-- SQL features: GROUP BY, SUM, ROUND, ORDER BY
-- ------------------------------------------------------------
SELECT
    region_name,
    COUNT(DISTINCT provider_code)                           AS trusts_in_region,
    SUM(total_waiting)                                      AS total_patients,
    SUM(over_18_weeks)                                      AS total_breaching,
    ROUND(SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS pct_within_18_weeks,
    ROUND(SUM(over_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS breach_rate_pct,
    RANK() OVER (
        ORDER BY SUM(over_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting), 0) DESC
    )                                                       AS region_breach_rank
FROM rtt_waiting_times
GROUP BY region_name
ORDER BY breach_rate_pct DESC;


-- ------------------------------------------------------------
-- ANALYSIS 4: Monthly SLA trend — is performance improving?
-- Business use: Is the trust making progress or getting worse?
-- SQL features: GROUP BY, ORDER BY date, ROUND
-- ------------------------------------------------------------
SELECT
    period,
    FORMAT(period, 'MMM yyyy')                              AS month_label,
    SUM(total_waiting)                                      AS total_patients,
    SUM(within_18_weeks)                                    AS within_sla,
    SUM(over_18_weeks)                                      AS breaching_sla,
    ROUND(SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS pct_within_18_weeks,
    92.0                                                    AS sla_target,
    CASE
        WHEN SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0) >= 92
            THEN 'ON TARGET'
        ELSE 'BREACHING'
    END                                                     AS monthly_status
FROM rtt_waiting_times
GROUP BY period
ORDER BY period;


-- ------------------------------------------------------------
-- ANALYSIS 5: Month-over-month SLA change (trend direction)
-- Business use: Is performance trending better or worse?
-- SQL features: CTE, LAG window function, NULLIF
-- ------------------------------------------------------------
WITH monthly_sla AS (
    SELECT
        period,
        FORMAT(period, 'MMM yyyy')                          AS month_label,
        ROUND(SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting), 0), 2)             AS pct_within_18_weeks,
        SUM(over_18_weeks)                                  AS total_breaching
    FROM rtt_waiting_times
    GROUP BY period
)
SELECT
    month_label,
    pct_within_18_weeks,
    LAG(pct_within_18_weeks) OVER (ORDER BY period)         AS prev_month_pct,
    ROUND(
        pct_within_18_weeks
        - LAG(pct_within_18_weeks) OVER (ORDER BY period)
    , 2)                                                    AS pct_point_change,
    total_breaching,
    LAG(total_breaching) OVER (ORDER BY period)             AS prev_month_breaching,
    total_breaching
        - LAG(total_breaching) OVER (ORDER BY period)       AS breaching_change,
    CASE
        WHEN pct_within_18_weeks
            > LAG(pct_within_18_weeks) OVER (ORDER BY period)
            THEN 'IMPROVING'
        WHEN pct_within_18_weeks
            < LAG(pct_within_18_weeks) OVER (ORDER BY period)
            THEN 'DETERIORATING'
        ELSE 'STABLE'
    END                                                     AS trend
FROM monthly_sla
ORDER BY period;


-- ------------------------------------------------------------
-- ANALYSIS 6: Worst performing trusts by breach volume
-- Business use: Which hospitals need the most urgent support?
-- SQL features: CTE, RANK, NTILE, GROUP BY
-- ------------------------------------------------------------
WITH trust_performance AS (
    SELECT
        provider_code,
        provider_name,
        region_name,
        SUM(total_waiting)                                  AS total_patients,
        SUM(over_18_weeks)                                  AS total_breaching,
        ROUND(SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting), 0), 2)             AS pct_within_18_weeks
    FROM rtt_waiting_times
    GROUP BY provider_code, provider_name, region_name
)
SELECT
    provider_name,
    region_name,
    total_patients,
    total_breaching,
    pct_within_18_weeks,
    RANK() OVER (ORDER BY total_breaching DESC)             AS breach_volume_rank,
    RANK() OVER (ORDER BY pct_within_18_weeks ASC)          AS breach_rate_rank,
    NTILE(4) OVER (ORDER BY pct_within_18_weeks ASC)        AS performance_quartile,
    -- Q1 = worst 25% of trusts
    CASE NTILE(4) OVER (ORDER BY pct_within_18_weeks ASC)
        WHEN 1 THEN 'Bottom 25% — urgent review needed'
        WHEN 2 THEN 'Below average — improvement required'
        WHEN 3 THEN 'Above average — minor improvements'
        WHEN 4 THEN 'Top 25% — best practice'
    END                                                     AS performance_band
FROM trust_performance
ORDER BY total_breaching DESC;


-- ------------------------------------------------------------
-- ANALYSIS 7: Specialty × Region heat map
-- Business use: Which specialty is worst in which region?
-- SQL features: Multi-column GROUP BY, CASE pivot, RANK PARTITION
-- ------------------------------------------------------------
SELECT
    specialty_name,
    region_name,
    SUM(total_waiting)                                      AS patients,
    SUM(over_18_weeks)                                      AS breaching,
    ROUND(SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                 AS pct_within_18_weeks,
    RANK() OVER (
        PARTITION BY region_name
        ORDER BY SUM(over_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting), 0) DESC
    )                                                       AS rank_in_region,
    CASE
        WHEN SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0) >= 92
            THEN 'GREEN'
        WHEN SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0) >= 80
            THEN 'AMBER'
        ELSE 'RED'
    END                                                     AS rag_status
FROM rtt_waiting_times
GROUP BY specialty_name, region_name
ORDER BY region_name, pct_within_18_weeks ASC;


-- ------------------------------------------------------------
-- ANALYSIS 8: 52-week breaches — the most severe cases
-- Business use: Patients waiting over a year — regulatory risk
-- SQL features: WHERE filter, GROUP BY, ORDER BY, CASE
-- ------------------------------------------------------------
SELECT
    specialty_name,
    region_name,
    SUM(over_52_weeks)                                      AS total_over_52_weeks,
    SUM(total_waiting)                                      AS total_patients,
    ROUND(SUM(over_52_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 3)                 AS pct_over_52_weeks,
    CASE
        WHEN SUM(over_52_weeks) > 100 THEN 'CRITICAL — regulatory escalation risk'
        WHEN SUM(over_52_weeks) > 50  THEN 'HIGH — immediate action required'
        WHEN SUM(over_52_weeks) > 10  THEN 'MODERATE — monitor closely'
        ELSE 'LOW'
    END                                                     AS severity_flag
FROM rtt_waiting_times
WHERE over_52_weeks IS NOT NULL
GROUP BY specialty_name, region_name
ORDER BY total_over_52_weeks DESC;


-- ------------------------------------------------------------
-- ANALYSIS 9: Running cumulative patients breaching SLA
-- Business use: How has the total backlog grown over time?
-- SQL features: CTE, SUM() OVER (ORDER BY) running total
-- ------------------------------------------------------------
WITH monthly AS (
    SELECT
        period,
        FORMAT(period, 'MMM yyyy')          AS month_label,
        SUM(over_18_weeks)                  AS monthly_breaching,
        SUM(total_waiting)                  AS monthly_total
    FROM rtt_waiting_times
    GROUP BY period
)
SELECT
    month_label,
    monthly_breaching,
    monthly_total,
    SUM(monthly_breaching) OVER (
        ORDER BY period
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                       AS cumulative_breaching,
    ROUND(monthly_breaching * 100.0
        / NULLIF(monthly_total, 0), 2)      AS monthly_breach_rate_pct
FROM monthly
ORDER BY period;
