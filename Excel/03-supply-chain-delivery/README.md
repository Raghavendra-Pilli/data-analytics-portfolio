# Excel-3: Supply Chain Delivery Performance Report

> **Business question:** Which suppliers are causing the most delivery delays and damage, and is overall supply chain performance improving year on year — with data that refreshes automatically from the warehouse CSV export?

---

## Business scenario

A manufacturing company tracks 6,000+ purchase orders across 10 suppliers, 5 warehouses, and 8 product categories over 3 years. The supply chain manager spends 2–3 hours monthly manually reformatting a CSV export to produce a performance report. This workbook replaces that manual process with a Power Query-connected dashboard that refreshes in one click.

---

## Stakeholder

**Supply Chain Manager / Operations Director** — monthly supplier reviews, contract renewal decisions, inventory planning.

---

## Dataset

| Field | Detail |
|---|---|
| Source | Synthetic supply chain order data — own work |
| Orders | 6,018 purchase orders |
| Suppliers | 10 (Tier 1 / Tier 2 / Tier 3) |
| Categories | 8 product categories |
| Warehouses | 5 distribution centres |
| Period | 2022–2024 (3 years) |

---

## Workbook structure

| Sheet | Purpose |
|---|---|
| Supply Chain Data | Power Query source table — raw order data |
| Dashboard | KPI cards + supplier summary + 2 charts |
| Supplier Scorecard | Composite score + ranking + action recommendations |
| Yearly Comparison | 2022 vs 2023 vs 2024 — 6 key metrics with trend flags |
| Power Query Guide | Step-by-step automation setup instructions |

---

## Excel + Power Query skills demonstrated

| Skill | Where |
|---|---|
| Power Query — CSV connection | Supply Chain Data — auto-load from file |
| Power Query — data type transforms | Dates, integers, decimals enforced |
| Power Query — text cleaning | Trim/case for SUMIFS consistency |
| SUMIFS / COUNTIFS / AVERAGEIFS | All supplier KPI calculations |
| Composite scoring formula | Scorecard: weighted 40/30/30 |
| RANK() | Supplier ranking by composite score |
| YoY change columns | Yearly Comparison absolute deltas |
| Trend flag | IF chain: ▲ Improving / ▼ Declining / → Stable |
| KPI card layout | 6 colour-coded cards with accent borders |
| Bar chart (horizontal) | Supplier on-time rate ranking |
| Line chart | Monthly on-time delivery trend |
| Cross-sheet formulas | All summaries reference Supply Chain Data |

---

## KPIs defined

| KPI | Formula logic |
|---|---|
| On-Time Rate | COUNTIFS(on_time=1) ÷ COUNTA(all orders) |
| Avg Delay Days | AVERAGEIFS(delay_days, on_time=0) |
| Defect Rate | AVERAGEIF(defect_rate > 0) |
| Complete Order Rate | COUNTIFS(complete=1) ÷ COUNTA(all) |
| Supplier Score | OT_rate×40 + (1−defect)×30 + complete×30 |

---

## Supplier performance tiers

| Score | Band | Action |
|---|---|---|
| 90–100 | Excellent | Best practice — increase volume |
| 75–89 | Good | Monitor quarterly |
| 60–74 | Acceptable | Improvement plan required |
| <60 | Poor | Immediate review — escalate |

---

## How to connect Power Query

1. Data → Get Data → From File → From Text/CSV
2. Select `supply_chain_orders.csv` → Load To → Table → Supply Chain Data!A3
3. Apply data type transforms in Power Query Editor
4. Close & Load → Data → Refresh All to update everything

See the **Power Query Guide** sheet for full step-by-step instructions.

---

## Resume bullet points

- Built a Power Query-connected Excel supply chain dashboard refreshing 6,000+ orders across 10 suppliers using SUMIFS, COUNTIFS, AVERAGEIFS, and a composite 100-point supplier scorecard — reducing monthly report preparation from 3 hours to one click
- Designed a 3-year YoY performance comparison with automatic trend flags and a ranked supplier scorecard driving quarterly review decisions for Tier 1/2/3 supplier contracts
