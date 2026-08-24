# SQL-3: NHS-Style Hospital Outpatient Wait-Time SLA Analysis

> **Business question:** Which specialties and hospital trusts are breaching the 18-week referral-to-treatment SLA target — and is the backlog getting better or worse?

---

## Business scenario

NHS hospital trusts operate under a legally binding standard: 92% of patients must begin treatment within 18 weeks of GP referral. Post-COVID, waiting lists grew to record levels. The Hospital Operations Director needs a SQL-based analytical framework to identify which specialties, regions, and individual trusts are failing this target — and to track whether performance is improving month by month.

---

## Stakeholder

**Hospital Operations Director / NHS Trust Board** — quarterly board reporting, operational resource allocation, regulatory compliance.

---

## Dataset

| Field | Detail |
|---|---|
| Name | NHS-style RTT Waiting Times (synthetic) |
| Structure based on | NHS England RTT open data — digital.nhs.uk |
| License | Synthetic data — own work. Structure based on OGL v3 open data ✓ |
| Rows | 9,000 records |
| Providers | 20 NHS hospital trusts |
| Specialties | 15 clinical specialties |
| Regions | 7 NHS England regions |
| Period | Jan 2021 — Jun 2023 (30 months) |

---

## Data dictionary

| Column | Type | Description |
|---|---|---|
| record_id | INT | Primary key |
| period | DATE | Reporting month |
| provider_code | NVARCHAR | NHS trust code |
| provider_name | NVARCHAR | Hospital trust name |
| specialty_code | NVARCHAR | Clinical specialty code |
| specialty_name | NVARCHAR | Clinical specialty name |
| region_code | NVARCHAR | NHS region code |
| region_name | NVARCHAR | NHS region name |
| total_waiting | INT | Total patients on waiting list |
| within_18_weeks | INT | Patients treated within SLA |
| over_18_weeks | INT | Patients breaching SLA |
| over_52_weeks | INT | Patients waiting > 1 year |
| median_wait_weeks | DECIMAL | Median wait in weeks |
| avg_wait_weeks | DECIMAL | Average wait in weeks |

---

## Tools and technologies

| Tool | Purpose |
|---|---|
| SQL Server 2022 | Database engine |
| SSMS | Query interface |
| Python | Dataset generation |

---

## Skills demonstrated

- SLA compliance rate formula — `within_18_weeks / total_waiting × 100`
- CASE statements — SLA status, RAG classification, severity banding
- `RANK() OVER()` — overall trust and specialty ranking
- `RANK() OVER (PARTITION BY)` — specialty rank within each region
- `NTILE(4)` — trust performance quartile banding
- `LAG()` — month-over-month compliance trend
- `SUM() OVER (ORDER BY)` — cumulative backlog running total
- CTEs — monthly trend analysis, breach summary
- Multi-level GROUP BY — specialty, region, trust, specialty × region
- `NULLIF` — safe division preventing divide-by-zero
- `CREATE VIEW` — executive KPI summary

---

## NHS SLA target

```
Target: 92% of patients treated within 18 weeks of GP referral
Status thresholds:
  >= 92% → MEETS TARGET
  >= 80% → NEAR MISS
  >= 60% → BREACHING
  <  60% → SEVERELY BREACHING
```

---

## Implementation steps

1. Place `rtt_waiting_times.csv` in `data/` folder
2. Run `02_data_preparation.sql` — creates table and derived columns
3. Run BULK INSERT to load CSV
4. Run `01_data_quality.sql` — verify totals consistency and nulls
5. Run `03_analysis.sql` — 9 business analyses
6. Run `04_kpis_and_insights.sql` — 5 KPIs and executive view
7. Save key outputs to `outputs/` folder

---

## KPIs defined

| KPI | Formula |
|---|---|
| SLA Compliance Rate | within_18_weeks / total_waiting × 100 |
| Gap to Target | 92.0 − compliance_rate |
| Breach Volume | COUNT of over_18_weeks patients |
| Backlog Growth Rate | MoM change in breach_patients via LAG() |
| Trust Quartile Band | NTILE(4) by compliance rate |

---

## Interview questions

**Q: What is NTILE and why did you use it here?**
> NTILE(4) splits a ranked list into 4 equal groups — quartiles. I used it to band 20 trusts into Q1 (top performers) through Q4 (bottom performers). It's directly actionable — Q4 trusts receive a formal improvement notice. A raw rank number from 1 to 20 doesn't carry that operational meaning.

**Q: How did you build the specialty × region heat map?**
> I used RANK() OVER (PARTITION BY region_name ORDER BY breach_rate DESC). Partitioning by region means each specialty gets ranked within its own region — not globally. Combined with a RAG CASE statement, it shows the worst specialty in each region separately. A clinical director can read it in 30 seconds.

**Q: What makes this project advanced?**
> Three things: the multi-level SLA framework applied at four different aggregation levels, the NTILE quartile banding which goes beyond simple ranking, and the cumulative running total using SUM() OVER (ORDER BY period) which shows how the NHS backlog has grown or shrunk since January 2021.

---

## Resume bullet points

- Built a multi-level NHS RTT SLA compliance framework in SQL Server across 9,000 records covering 20 trusts, 15 specialties and 7 regions — using NTILE(4) quartile banding, RANK() OVER (PARTITION BY), LAG() trend analysis and cumulative SUM() OVER() to identify breach hotspots and track backlog recovery
- Designed a specialty × region RAG heat map using window functions that identifies the worst-performing clinical area in each NHS region — directly supporting quarterly board reporting and operational resource allocation decisions
