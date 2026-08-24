-- ============================================================
-- SQL-3: NHS-Style Hospital Outpatient Wait-Time SLA Analysis
-- Script 04: KPI Definitions & Business Insights
-- Tool: SQL Server Management Studio
-- ============================================================

-- ============================================================
-- KPI 1: SLA Compliance Rate
-- Definition: % of patients treated within 18 weeks
-- NHS Target: 92% or above
-- ============================================================
SELECT
    specialty_name,
    SUM(total_waiting)                                          AS total_patients,
    SUM(within_18_weeks)                                        AS within_sla,
    SUM(over_18_weeks)                                          AS breaching_sla,
    ROUND(SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                     AS sla_compliance_rate_pct,
    92.0                                                        AS target_pct,
    ROUND(92.0 - SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting), 0), 2)                     AS gap_to_target_pct,
    -- Positive gap = below target, Negative = above target
    CASE
        WHEN SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0) >= 92
            THEN 'COMPLIANT'
        ELSE 'NON-COMPLIANT'
    END                                                         AS compliance_status
FROM rtt_waiting_times
GROUP BY specialty_name
ORDER BY sla_compliance_rate_pct ASC;


-- ============================================================
-- KPI 2: Breach Volume — absolute number of patients overdue
-- Definition: COUNT of patients waiting > 18 weeks
-- Used for: Resource allocation, capacity planning
-- ============================================================
WITH breach_by_trust AS (
    SELECT
        provider_name,
        region_name,
        SUM(over_18_weeks)                                      AS total_breach_patients,
        SUM(total_waiting)                                      AS total_patients,
        ROUND(SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0), 2)                  AS compliance_rate
    FROM rtt_waiting_times
    GROUP BY provider_name, region_name
)
SELECT
    provider_name,
    region_name,
    total_breach_patients,
    total_patients,
    compliance_rate,
    RANK() OVER (ORDER BY total_breach_patients DESC)           AS breach_volume_rank,
    -- What % of all breaching patients does this trust represent?
    ROUND(total_breach_patients * 100.0
        / SUM(total_breach_patients) OVER (), 2)                AS share_of_all_breaches_pct
FROM breach_by_trust
ORDER BY total_breach_patients DESC;


-- ============================================================
-- KPI 3: Average Wait Time by Specialty
-- Definition: Weighted average wait weeks across all periods
-- Red flag: Average wait > 18 weeks = systemic failure
-- ============================================================
SELECT
    specialty_name,
    ROUND(AVG(avg_wait_weeks), 1)                               AS avg_wait_weeks,
    ROUND(AVG(median_wait_weeks), 1)                            AS avg_median_wait_weeks,
    MIN(avg_wait_weeks)                                         AS best_period_avg,
    MAX(avg_wait_weeks)                                         AS worst_period_avg,
    18.0                                                        AS sla_threshold_weeks,
    CASE
        WHEN AVG(avg_wait_weeks) > 26 THEN 'CRITICAL — avg wait > 6 months'
        WHEN AVG(avg_wait_weeks) > 18 THEN 'BREACHING — avg wait > 18 weeks'
        WHEN AVG(avg_wait_weeks) > 12 THEN 'ELEVATED — approaching threshold'
        ELSE 'ACCEPTABLE'
    END                                                         AS wait_time_status
FROM rtt_waiting_times
WHERE avg_wait_weeks IS NOT NULL
GROUP BY specialty_name
ORDER BY avg_wait_weeks DESC;


-- ============================================================
-- KPI 4: Backlog Growth Rate
-- Definition: MoM change in total patients waiting > 18 weeks
-- Positive = backlog growing (bad), Negative = clearing (good)
-- ============================================================
WITH monthly_breach AS (
    SELECT
        period,
        FORMAT(period, 'MMM yyyy')                              AS month_label,
        SUM(over_18_weeks)                                      AS breach_patients
    FROM rtt_waiting_times
    GROUP BY period
)
SELECT
    month_label,
    breach_patients,
    LAG(breach_patients) OVER (ORDER BY period)                 AS prev_month_breaching,
    breach_patients
        - LAG(breach_patients) OVER (ORDER BY period)           AS monthly_change,
    ROUND(
        (breach_patients - LAG(breach_patients) OVER (ORDER BY period))
        * 100.0
        / NULLIF(LAG(breach_patients) OVER (ORDER BY period), 0)
    , 1)                                                        AS growth_rate_pct,
    CASE
        WHEN breach_patients
            > LAG(breach_patients) OVER (ORDER BY period)
            THEN 'BACKLOG GROWING'
        WHEN breach_patients
            < LAG(breach_patients) OVER (ORDER BY period)
            THEN 'BACKLOG CLEARING'
        ELSE 'STABLE'
    END                                                         AS backlog_direction
FROM monthly_breach
ORDER BY period;


-- ============================================================
-- KPI 5: Trust Performance Quartile Banding
-- Definition: NTILE(4) ranking of all trusts by compliance rate
-- Used for: Identifying which trusts need support vs. best practice
-- ============================================================
WITH trust_summary AS (
    SELECT
        provider_code,
        provider_name,
        region_name,
        SUM(total_waiting)                                      AS total_patients,
        SUM(over_18_weeks)                                      AS total_breaching,
        ROUND(SUM(within_18_weeks) * 100.0
            / NULLIF(SUM(total_waiting),0), 2)                  AS compliance_rate,
        ROUND(AVG(avg_wait_weeks), 1)                           AS avg_wait_weeks
    FROM rtt_waiting_times
    GROUP BY provider_code, provider_name, region_name
)
SELECT
    provider_name,
    region_name,
    total_patients,
    total_breaching,
    compliance_rate,
    avg_wait_weeks,
    NTILE(4) OVER (ORDER BY compliance_rate DESC)               AS performance_quartile,
    CASE NTILE(4) OVER (ORDER BY compliance_rate DESC)
        WHEN 1 THEN 'Q1 — Top performers (best practice)'
        WHEN 2 THEN 'Q2 — Above average'
        WHEN 3 THEN 'Q3 — Below average (improvement plan)'
        WHEN 4 THEN 'Q4 — Bottom performers (urgent review)'
    END                                                         AS quartile_label,
    RANK() OVER (ORDER BY compliance_rate DESC)                 AS overall_rank
FROM trust_summary
ORDER BY compliance_rate DESC;


-- ============================================================
-- EXECUTIVE SUMMARY VIEW
-- ============================================================
GO
CREATE OR ALTER VIEW vw_rtt_kpi_summary AS
SELECT
    COUNT(DISTINCT provider_code)                               AS total_trusts,
    COUNT(DISTINCT specialty_name)                              AS total_specialties,
    COUNT(DISTINCT region_name)                                 AS total_regions,
    MIN(period)                                                 AS data_from,
    MAX(period)                                                 AS data_to,
    SUM(total_waiting)                                          AS total_patients_on_list,
    SUM(within_18_weeks)                                        AS total_within_sla,
    SUM(over_18_weeks)                                          AS total_breaching_sla,
    ISNULL(SUM(over_52_weeks), 0)                               AS total_over_52_weeks,
    ROUND(SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting),0), 2)                      AS overall_compliance_rate_pct,
    92.0                                                        AS sla_target_pct,
    ROUND(92.0 - SUM(within_18_weeks) * 100.0
        / NULLIF(SUM(total_waiting),0), 2)                      AS gap_to_target_pct
FROM rtt_waiting_times;
GO

SELECT * FROM vw_rtt_kpi_summary;
