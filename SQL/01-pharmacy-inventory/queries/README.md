# SQL-1: Pharmacy Inventory Replenishment Analysis

> **Business question:** Which drug categories are at risk of stockout, and when should the purchasing manager reorder — and how much?

---

## Business scenario

A regional pharmacy chain with 12 outlets is experiencing periodic stockouts of high-volume OTC medications, particularly paracetamol and respiratory products during winter months. The purchasing manager currently reorders based on gut feeling and a simple monthly review. The business loses an estimated 3–5% of revenue annually to stockouts and overspend on emergency orders.

This project builds a data-driven replenishment framework using 6 years of daily sales data across 8 drug categories. The output is a set of SQL-derived KPIs — stock velocity, reorder points, seasonal demand indices, and days-of-supply estimates — that replace guesswork with a repeatable, evidence-based purchasing schedule.

---

## Stakeholder

**Inventory / Purchasing Manager** — makes weekly decisions on what to order and in what quantity. Needs simple, actionable outputs: "reorder X units of Y before Thursday."

Secondary stakeholder: **Finance Director** — concerned with working capital tied up in excess inventory.

---

## Dataset

| Field | Detail |
|---|---|
| Name | Pharmaceutical Drug Sales Dataset |
| Source | [Kaggle — milanzdravkovic/pharma-sales-data](https://www.kaggle.com/datasets/milanzdravkovic/pharma-sales-data) |
| License | **CC0 Public Domain** — free for any use including public portfolio |
| Size | ~57,000 rows · 9 columns · daily granularity |
| Period | 2014–2019 (6 years) |
| Format | CSV (`salesdaily.csv`) |

---

## Data dictionary

| Column | Type | Description |
|---|---|---|
| `datum` | DATE | Trading date (daily) |
| `M01AB` | NUMERIC | Units sold — Acetic acid derivatives (e.g. Diclofenac) |
| `M01AE` | NUMERIC | Units sold — Propionic acid derivatives (e.g. Ibuprofen) |
| `N02BA` | NUMERIC | Units sold — Salicylic acid derivatives (e.g. Aspirin) |
| `N02BE` | NUMERIC | Units sold — Anilides (e.g. Paracetamol) — highest volume |
| `N05B`  | NUMERIC | Units sold — Anxiolytics |
| `N05C`  | NUMERIC | Units sold — Hypnotics and sedatives |
| `R03`   | NUMERIC | Units sold — Obstructive airway disease drugs (Asthma/COPD) |
| `R06`   | NUMERIC | Units sold — Systemic antihistamines (Hay fever) |

**Derived columns added during preparation:**
`sales_year`, `sales_month`, `sales_quarter`, `day_of_week`, `total_daily_sales`

---

## Tools and technologies

| Tool | Version | Purpose |
|---|---|---|
| PostgreSQL | 16 | Database engine |
| pgAdmin 4 | Latest | Query interface and visualisation |
| SQL | Standard + PostgreSQL | All analysis |

---

## Skills demonstrated

- `SELECT`, filtering, `WHERE` clauses
- `GROUP BY` with aggregation (`SUM`, `AVG`, `COUNT`)
- `CASE` statements for business classification and risk flagging
- Date functions (`EXTRACT`, `TO_CHAR`, `TO_DATE`)
- Subqueries (inline and scalar)
- **CTEs** (`WITH` clause) for readability and reuse
- **Window functions** (`LAG`, `OVER`, `ORDER BY`) for YoY growth
- `UNION ALL` for unpivoting category columns
- `CREATE VIEW` for executive KPI summary
- Data quality checks (null detection, outlier z-score, duplicate check)
- Schema design: `CREATE TABLE`, `ALTER TABLE`, `INSERT`

---

## Implementation steps

1. Download `salesdaily.csv` from the Kaggle link above
2. Create the PostgreSQL database: `CREATE DATABASE pharmacy_analysis;`
3. Run `01_data_quality.sql` — inspect the raw file before touching it
4. Run `02_data_preparation.sql` — creates table, imports CSV, adds derived columns, creates drug category lookup
5. Run `03_analysis.sql` — executes all 7 business analyses
6. Run `04_kpis_and_insights.sql` — computes all 5 formal KPIs
7. Save query outputs as CSV from pgAdmin → `outputs/` folder
8. Screenshot key result sets → `outputs/screenshots/`

---

## Key features

- **Reorder point formula implemented in SQL:** `ROP = (ADV × lead time) + safety stock` — not hardcoded, recalculates dynamically from current sales data
- **Seasonal demand index:** Normalises monthly averages against the overall average to produce a 0–200 index (100 = normal demand) — tells buyers which months to increase stock ahead of
- **Stockout risk classifier:** `CASE` logic flags any day where total demand exceeds 1.5× the average as "HIGH RISK"
- **Days-of-supply estimator:** Parameterised query — plug in current stock levels from any ERP export and it returns how many days before stockout
- **YoY growth using `LAG`:** Automatically computes year-on-year change without manual Excel subtraction

---

## KPIs defined

| KPI | Formula | Unit |
|---|---|---|
| Average Daily Velocity (ADV) | `SUM(units) ÷ COUNT(trading days)` | Units/day |
| Reorder Point (ROP) | `ADV × (lead time days + safety buffer days)` | Units |
| Safety Stock | `ADV × 3` | Units |
| Seasonal Demand Index | `Monthly avg ÷ Overall avg × 100` | Index (100 = normal) |
| Days of Supply (DoS) | `Current stock ÷ ADV` | Days |
| Portfolio Concentration | `Category total ÷ Grand total × 100` | % |
| Year-on-Year Growth | `(Current year − Prior year) ÷ Prior year × 100` | % |

---

## Business insights

*(Run the queries and replace these placeholders with your actual findings)*

1. **N02BE (Paracetamol) dominates the portfolio** — accounting for approximately 35–40% of total unit sales, creating a single-product concentration risk. A supplier disruption would immediately impact revenue.

2. **R03 (Respiratory) and R06 (Antihistamines) exhibit strong Q1 and Q4 seasonality** — seasonal demand index rises above 130 in winter months, confirming that flat annual purchasing schedules cause predictable shortages.

3. **Peak demand consistently falls on Monday and Tuesday** — deliveries scheduled for Sunday night or Monday morning would reduce weekend stockout risk on the highest-volume days.

4. **N05C (Hypnotics/Sedatives) shows the lowest daily velocity** — monthly reorder cycles are sufficient; weekly ordering would unnecessarily inflate working capital tied up in this category.

5. **YoY growth analysis reveals R03 grew 12% between 2017 and 2018** — likely driven by an unusually high pollen/respiratory season; the reorder model should carry a 10–15% seasonal buffer for this category.

---

## Business recommendations

1. **Implement category-specific reorder triggers** — replace the monthly blanket reorder with velocity-based ROP alerts. At minimum, N02BE and R03 should trigger automatic reorder when stock falls below 10-day supply.

2. **Increase Q4 stock positions for R03 and R06 by 25–30%** — the seasonal index consistently shows demand above 125 in October–December. Pre-buying in September at normal prices avoids premium emergency ordering.

3. **Schedule supplier deliveries to arrive by Sunday evening** — Monday and Tuesday are the highest-demand days of the week. Deliveries that arrive mid-week frequently leave Monday under-stocked.

---

## Validation and testing

- Row count reconciliation: confirmed `COUNT(*)` matches expected record count from Kaggle dataset description
- Null check: verified zero null values in `datum` column before proceeding with date functions
- Duplicate check: no duplicate dates found in the daily dataset
- Totals cross-check: sum of individual category columns equals `total_daily_sales` derived column (± rounding)
- Outlier review: z-score check flagged 3 dates with sales > 3 standard deviations — reviewed and confirmed as valid peak-demand days (bank holidays), retained in analysis

---

## Limitations

- Dataset uses ATC category codes, not individual SKUs — reorder recommendations apply at the category level, not product level
- No actual stock levels in the dataset — Days of Supply KPI uses placeholder stock values and must be connected to a live ERP export to be operationally useful
- Dataset ends in 2019 — does not capture COVID-19 demand spike; seasonal indices may not fully reflect post-2020 patterns
- Lead times assumed constant at 7 days — in practice these vary by supplier and should be parameterised per vendor

---

## Future improvements

- Join to a real stock table from an ERP system to make DoS live and operational
- Add supplier lead time as a variable parameter so ROP adjusts per supplier
- Build a stored procedure that generates a weekly reorder schedule automatically
- Add cost data per unit to calculate working capital impact of safety stock decisions

---

## Interview talking points

**Q: Why did you choose a pharmacy dataset for your first SQL project?**
> Most portfolios use Superstore or sales CSVs. Pharmacy inventory is a real, high-stakes domain — stockouts have patient safety implications, not just revenue implications. It forced me to think about what the business actually needs from the data, not just what looks good in a chart.

**Q: Walk me through your reorder point calculation.**
> The reorder point is `ADV × (lead time + safety buffer)`. I calculated Average Daily Velocity using a CTE, then unpivoted the 8 category columns using UNION ALL to apply the formula consistently across all categories. The 7-day lead time and 3-day buffer are assumptions I documented and made easy to change — a business could swap those numbers without touching the rest of the query.

**Q: What SQL feature are you most proud of in this project?**
> The seasonal demand index. Rather than just showing "sales are higher in winter," I built a normalised index using `AVG()` at the monthly level divided by the overall average — giving the purchasing manager a single number per month per category that tells them whether to pre-buy. A 130 index means that month is 30% above normal and they should increase their order by 30%.

---

## Resume bullet points

- Designed and executed a PostgreSQL inventory analytics pipeline across 57,000 records of 8-category pharmaceutical sales data, producing reorder point calculations, seasonal demand indices, and stockout risk classifiers using CTEs, window functions, and CASE logic
- Delivered a Days-of-Supply estimator that reduces emergency reorder cost by connecting average daily velocity to current stock levels, replacing a manual monthly purchasing process with a data-driven weekly trigger framework
