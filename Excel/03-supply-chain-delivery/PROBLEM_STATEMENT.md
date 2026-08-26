# Excel Project 3 — Supply Chain Delivery Performance Report
### Problem Statement & Solution Narrative
**Tool:** Microsoft Excel + Power Query | **Level:** Advanced

---

## The Situation

A manufacturing company sources materials and components from 10
suppliers across 5 warehouses. The supply chain manager, David,
receives a monthly CSV export from the warehouse management system
showing every purchase order — what was ordered, when it was due,
when it actually arrived, how much was damaged, and the total value.

Three persistent problems:

1. **No supplier accountability** — when a delivery is late or
   damaged, there is no systematic record. By the next month,
   the incident is forgotten and the same supplier is reused.

2. **Manual monthly process** — David downloads the CSV, pastes it
   into Excel, manually formats it, creates a pivot table, and
   emails a summary. This takes 2–3 hours every month.

3. **No year-over-year view** — is supplier performance getting
   better or worse? Without a consistent tracking approach, there
   is no evidence base to renegotiate contracts or switch suppliers.

The Operations Director's ask:

> "I want one dashboard that tells me who our worst suppliers are,
>  what our on-time delivery rate is, and whether we are improving
>  year on year — and I want it to update automatically when the
>  new month's data arrives."

---

## The Data We Have

A 3-year order history (2022–2024) with 6,000+ purchase orders:

- 10 suppliers across 3 tiers
- 8 product categories
- 5 warehouses
- For each order: planned vs actual delivery, quantities ordered/
  received/damaged, defect rate, order value, delay days

---

## What Power Query Does in This Project

Without Power Query — the manual process every month:
1. Download CSV from warehouse system
2. Open Excel, paste data (risking format corruption)
3. Reformat columns, fix date types, recalculate derived fields
4. Rebuild pivot tables and charts
5. Total time: 2–3 hours

With Power Query — the automated process:
1. David clicks **Data → Refresh All**
2. Power Query loads the new CSV, applies all transformations,
   and updates the Supply Chain Data table automatically
3. Dashboard, Scorecard and Yearly Comparison all update instantly
4. Total time: 3 seconds

This is the core business case for Power Query — it replaces a
repetitive manual task with a one-click automated workflow.

---

## Key Power Query transformations applied

**Data type enforcement** — dates loaded as text become proper
Date columns. Numeric flags (0/1) are confirmed as integers.
Decimal values (unit cost, order value) are typed correctly.
This prevents formula errors when Excel tries to calculate on
text-formatted numbers.

**Column consistency** — supplier names and category values
are trimmed for leading/trailing spaces that cause SUMIFS
mismatches. Text case is standardised.

**Connection naming** — the query is named 'SC_Orders' so
it can be referenced and refreshed from the Data ribbon
without knowing the file path.

---

## Our Analytical Approach — Sheet by Sheet

### Sheet 1: Supply Chain Data
The raw order table — source of truth. Power Query loads here.
All other sheets pull from this table using SUMIFS, COUNTIFS,
and AVERAGEIFS. No manual data entry ever touches this sheet.

### Sheet 2: Dashboard
Six KPI cards at the top:
- Total Orders, On-Time Rate, Avg Delay Days,
  Total Order Value, Avg Defect Rate, Complete Order Rate

Below the KPIs, a 10-row supplier summary table showing
on-time rate, average delay, defect rate, order value, and
an automatic risk flag (HIGH / MEDIUM / LOW) based on
the on-time rate threshold.

Two charts: a horizontal bar chart ranking suppliers by
on-time rate, and a line chart showing the monthly on-time
trend across all 12 months.

### Sheet 3: Supplier Scorecard
A composite performance score out of 100:
- On-Time Rate contributes 40 points
- Defect Rate contributes 30 points (inverted — lower is better)
- Order Completeness contributes 30 points

Every supplier gets a score, a performance band (Excellent /
Good / Acceptable / Poor), and an action recommendation.
A horizontal bar chart ranks all 10 suppliers by score.

### Sheet 4: Yearly Comparison
Six key metrics compared across 2022, 2023, and 2024:
total orders, on-time rate, average delay, defect rate,
total order value, and order completeness.

Year-on-year change columns show the absolute improvement
or deterioration. A trend flag (▲ Improving / ▼ Declining
/ → Stable) gives an instant read for each metric.

### Sheet 5: Power Query Guide
A step-by-step setup guide for connecting the workbook to
the CSV file via Power Query — so any analyst can replicate
the automation in their own environment.

---

## What We Found — Key Insights

1. **Reliable Goods Co. (S010) and Northern Logistics (S008)
   have the highest delay rates** — both Tier 3 suppliers with
   on-time rates below 65%. Their composite scores place them
   firmly in the "Poor" performance band. Both are candidates
   for supplier replacement at the next contract review.

2. **FastTrack Logistics (S001) is the top performer** — on-time
   rate above 92%, defect rate below 3%, consistent across all
   three years. This supplier should be prioritised for increased
   volume and used as the benchmark in supplier negotiations.

3. **Defect rates are highest in Tier 3 suppliers** — averaging
   12–18% damaged goods vs. 2–4% for Tier 1. The cost of damage
   (wastage, reprocessing, delays) likely offsets any cost savings
   from using cheaper Tier 3 suppliers.

4. **On-time delivery shows a seasonal dip in Q4** — October
   through December sees consistently lower on-time rates across
   most suppliers. Pre-ordering critical components by September
   would reduce Q4 exposure.

5. **Year-over-year performance is improving** — on-time rates
   and defect rates show a consistent upward trend from 2022 to
   2024, suggesting that the supplier management programme is
   having a measurable effect.

---

## Business Recommendations

1. **Exit Tier 3 supplier relationships for high-volume categories**
   — Reliable Goods Co. and Northern Logistics have consistently
   poor performance scores. The cost of delays and damaged goods
   exceeds any procurement savings. Replace with Tier 1 alternatives
   for Electronics and Components categories specifically.

2. **Implement the Supplier Scorecard as a quarterly review tool**
   — share the scorecard with each supplier at the quarterly
   business review. Suppliers scoring below 60 receive a formal
   improvement notice with a 90-day deadline.

3. **Increase Q3 order volumes to buffer Q4 delivery risk** —
   the monthly trend analysis shows Q4 on-time rates dip
   consistently. Pre-building 20–25% additional inventory in
   September for critical SKUs would eliminate the Q4 exposure
   without changing supplier relationships.

---

## Excel + Power Query Skills Demonstrated

| Skill | Where used |
|---|---|
| Power Query — CSV connection | Supply Chain Data sheet — auto-load |
| Power Query — data type transforms | Date, integer, decimal type enforcement |
| Power Query — text cleaning | Trim, proper case for consistent matching |
| SUMIFS (multi-criteria) | All supplier revenue and quantity aggregations |
| COUNTIFS (multi-criteria) | On-time count, complete order count by supplier/year |
| AVERAGEIFS | Average delay days for late orders only |
| Composite scoring formula | Scorecard: weighted OT + defect + completeness |
| RANK() | Supplier ranking by score |
| YoY change columns | Yearly Comparison: current − prior year |
| Trend flag CASE | IF chain: Improving / Declining / Stable |
| KPI card layout | 6 colour-coded cards with border accents |
| Professional charts | Horizontal bar + line trend charts |
| Cross-sheet SUMIFS | All summaries pull from one source table |

---

## How to Explain This in an Interview

**"What was the problem?"**
A supply chain manager spent 2–3 hours every month manually
reformatting a CSV export to produce a supplier performance
report. There was no year-over-year tracking and no systematic
way to identify which suppliers were consistently failing.

**"What did Power Query do?"**
Power Query connected the workbook directly to the CSV source.
It applies data type transformations, text cleaning, and
structural fixes automatically every time the data is refreshed.
What took 2–3 hours of manual work is now one click — Data →
Refresh All — and everything updates in seconds.

**"What is the Supplier Scorecard formula?"**
It's a weighted composite score out of 100: on-time rate
multiplied by 40, plus the inverse of defect rate multiplied
by 30, plus order completeness multiplied by 30. This weights
delivery reliability most heavily because lateness has the
highest operational impact, followed by quality, then
completeness. The formula is transparent and auditable.

**"What would you do next?"**
Connect to a live ERP export rather than a static CSV so
the dashboard updates daily rather than monthly. Add a
warehouse-level performance view — some delays may be
warehousing issues rather than supplier issues, and the
current view cannot distinguish between the two.

---

*Project by: [Your Name]*
*Dataset: Synthetic supply chain order data — own work*
*Tool: Microsoft Excel + Power Query*
*Portfolio: github.com/[your-username]/data-analytics-portfolio*
