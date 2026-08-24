# SQL-4: Procurement Spend Analysis — Vendor Performance & Contract Risk

> **Business question:** Which vendors are consistently over-budget or late, where is spend dangerously concentrated, and which vendors pose the highest combined risk to the organisation?

---

## Business scenario

A mid-sized organisation manages £15–20M in annual procurement spend across 20 vendors and 8 departments. The CPO suspects certain vendors are habitually over-budget and late but has no data to support formal challenge at renewal. The Finance Director has flagged concentration risk — too much spend with too few vendors. This project delivers a SQL-based vendor risk framework with a composite Risk Exposure Index that drives the quarterly vendor review schedule.

---

## Stakeholder

**Chief Procurement Officer / Finance Director** — vendor review meetings, contract renewal decisions, risk register management.

---

## Dataset

| Field | Detail |
|---|---|
| Name | Procurement Contracts (synthetic) |
| Rows | 406 contracts |
| Vendors | 20 across 8 categories |
| Departments | 8 internal buying departments |
| Period | 2020–2023 (4 years) |
| License | Own work — synthetic data ✓ |

---

## Data dictionary

| Column | Type | Description |
|---|---|---|
| contract_id | INT | Primary key |
| contract_ref | NVARCHAR | Reference number e.g. CON-2021-0042 |
| vendor_code | NVARCHAR | Vendor identifier |
| vendor_name | NVARCHAR | Vendor company name |
| vendor_category | NVARCHAR | Service category |
| department | NVARCHAR | Internal buying department |
| contract_type | NVARCHAR | Fixed Price / T&M / Framework / Blanket |
| contract_start | DATE | Contract start date |
| planned_end | DATE | Originally planned end date |
| actual_end | DATE | Actual delivery/completion date |
| budget_amount | DECIMAL | Contracted budget value |
| actual_amount | DECIMAL | Actual spend |
| cost_variance | DECIMAL | actual − budget |
| cost_variance_pct | DECIMAL | Variance as % of budget |
| delay_days | INT | actual_end − planned_end in days |
| is_overrun | TINYINT | 1 = cost overrun, 0 = within budget |
| is_late | TINYINT | 1 = delivered late, 0 = on time |
| contract_year | INT | Year of contract start |

---

## Tools and technologies

| Tool | Purpose |
|---|---|
| SQL Server 2022 | Database engine |
| SSMS | Query interface |
| Python | Dataset generation |

---

## Skills demonstrated

- `RANK()` — spend ranking, overrun ranking, delivery ranking
- `PERCENT_RANK()` — vendor spend percentile
- `ROW_NUMBER()` — contract sequence per vendor
- `LAG() OVER (PARTITION BY vendor)` — YoY spend change per vendor
- `LEAD() OVER (PARTITION BY vendor)` — days between consecutive contracts
- `SUM() OVER()` running total — Pareto cumulative spend %
- `NTILE(3)` — vendor risk tier banding
- Composite risk score — weighted formula combining 4 signals
- Multiple CTEs — vendor totals, risk register, Pareto analysis
- `NULLIF` — safe division
- Multi-level `CASE` — risk flags, delivery flags, budget status
- `CREATE VIEW` — executive KPI summary

---

## Window functions — complete portfolio reference

| Function | SQL-1 | SQL-2 | SQL-3 | SQL-4 |
|---|---|---|---|---|
| SUM() OVER() | ✓ | ✓ | ✓ | ✓ Pareto |
| LAG() | ✓ | ✓ | ✓ | ✓ PARTITION BY |
| LEAD() | — | — | — | ✓ |
| RANK() | — | ✓ | ✓ | ✓ |
| RANK() PARTITION BY | — | ✓ | ✓ | — |
| ROW_NUMBER() | — | — | — | ✓ |
| NTILE() | — | ✓ | ✓ | ✓ |
| PERCENT_RANK() | — | — | — | ✓ |

---

## KPIs defined

| KPI | Formula |
|---|---|
| Budget utilisation | actual_spend / budget × 100 |
| Overrun rate | overrun_contracts / total_contracts × 100 |
| On-time delivery rate | on_time_contracts / total_contracts × 100 |
| Spend concentration | top 3 vendor spend / total spend × 100 |
| Risk Exposure Index | total_spend × avg_risk_score |
| Vendor risk tier | NTILE(3) on Risk Exposure Index |

---

## Interview questions

**Q: What is LEAD() and how is it different from LAG()?**
> LAG() looks backward — it fetches the value from a previous row. LEAD() looks forward — it fetches the value from a future row. I used LEAD(contract_start) partitioned by vendor to find when the next contract with the same vendor began. Calculating the gap between one contract's end and the next contract's start reveals back-to-back renewals — a sign of vendor dependency.

**Q: What is PERCENT_RANK() and why did you use it?**
> PERCENT_RANK() returns a 0–1 value showing where a row sits in the overall distribution. I applied it to vendor spend so the CPO can see at a glance that a vendor in the 95th percentile of spend deserves proportionally more oversight than one at the 20th percentile. It's more informative than a raw rank number.

**Q: How did you build the Risk Exposure Index?**
> I multiplied total_spend by avg_risk_score — combining financial exposure with performance risk. A vendor that is high-risk but low-spend is manageable. A vendor that is high-spend and high-risk is the dangerous combination. The index surfaces exactly those vendors. NTILE(3) then converts it into three actionable tiers: quarterly, bi-annual, or annual review.

---

## Resume bullet points

- Designed a SQL Server procurement risk framework across 406 contracts and 20 vendors using LEAD(), LAG() PARTITION BY, PERCENT_RANK(), NTILE(3), and cumulative SUM() OVER() — producing a composite Risk Exposure Index that directly drives the quarterly vendor review schedule
- Built a Pareto spend concentration analysis using running cumulative window functions to identify that the top 4 vendors account for 70%+ of procurement spend, providing the CPO with quantified evidence to challenge back-to-back contract renewals and high-overrun vendors at the next formal review
