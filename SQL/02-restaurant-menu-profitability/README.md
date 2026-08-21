# SQL-2: Restaurant Menu Profitability & Ordering Patterns

> **Business question:** Which menu items drive margin and should be protected, which should be removed, and when exactly are customers ordering so the kitchen and staff can be scheduled properly?

---

## Business scenario

A restaurant chain with 3 locations has been operating for one year. Despite strong footfall, profit margins are below target. The operations manager suspects the menu is too large and the kitchen is prepping the wrong quantities at the wrong times. The CFO wants a data-driven menu review and a demand pattern analysis before the next staffing and menu planning meeting.

---

## Stakeholder

**Operations Manager / CFO** — needs to know which items to keep, which to cut, and when to staff the kitchen. Decisions are made quarterly (menu review) and weekly (staffing rota).

---

## Dataset

| Field | Detail |
|---|---|
| Name | Restaurant Orders Dataset |
| Source | [Maven Analytics Data Playground](https://mavenanalytics.io/data-playground) |
| License | CC BY 4.0 — portfolio use confirmed ✓ |
| Tables | 3 — menu_items, orders, order_details |
| Size | ~12,000 order lines |
| Period | Full calendar year |

---

## Data dictionary

**menu_items**

| Column | Type | Description |
|---|---|---|
| menu_item_id | INT | Primary key |
| item_name | NVARCHAR | Name of the dish |
| category | NVARCHAR | Food category (American, Asian, Mexican, Italian) |
| price | DECIMAL | Menu price in USD |

**orders**

| Column | Type | Description |
|---|---|---|
| order_id | INT | Primary key — unique order |
| order_date | DATE | Date order was placed |
| order_time | TIME | Time order was placed |

**order_details**

| Column | Type | Description |
|---|---|---|
| order_details_id | INT | Primary key |
| order_id | INT | Foreign key → orders |
| item_id | INT | Foreign key → menu_items |

---

## Tools and technologies

| Tool | Purpose |
|---|---|
| SQL Server 2022 | Database engine |
| SSMS | Query interface |
| SQL | All analysis |

---

## Skills demonstrated

- Multi-table JOINs (3-table JOIN via a master VIEW)
- GROUP BY with SUM, COUNT, AVG aggregations
- CASE statements for classification and sorting
- Window functions: RANK() OVER (PARTITION BY), LAG(), SUM() OVER()
- CTEs for readable, reusable query structure
- Subqueries for dynamic threshold comparison
- DATE functions: YEAR(), MONTH(), DATEPART(), DATENAME(), FORMAT()
- STRING_AGG for category combination analysis
- CREATE VIEW for master analysis layer
- Foreign key constraint design

---

## Implementation steps

1. Download dataset from Maven Analytics Data Playground (link above)
2. Run `02_data_preparation.sql` — creates all 3 tables with correct types
3. Import 3 CSV files via SSMS Import Flat File (menu_items → orders → order_details)
4. Run `01_data_quality.sql` — verify all checks pass, no orphaned rows
5. Run `03_analysis.sql` — 11 business analyses
6. Run `04_kpis_and_insights.sql` — 5 formal KPIs + executive summary view
7. Save key result sets to `outputs/` folder

---

## KPIs defined

| KPI | Formula |
|---|---|
| Average Order Value | Total revenue ÷ Total distinct orders |
| Average Daily Revenue | Total revenue ÷ Trading days |
| Menu item classification | Volume vs price quadrant (Star / Workhorse / Niche / Review) |
| Revenue concentration | Top 5 items revenue ÷ Grand total revenue |
| MoM revenue growth | (Current month − Prior month) ÷ Prior month × 100 |
| Peak hour flag | Hours > 130% of average order volume = PEAK |

---

## Interview questions

**Q: What was the hardest part of this project?**
> Designing the master view correctly. With three tables, if the JOIN logic is wrong, every downstream query produces wrong numbers silently — you won't see an error, just bad data. I wrote the orphan checks in the data quality script specifically to catch this before it happened.

**Q: What is the menu classification framework?**
> It's a four-quadrant matrix — Star, Workhorse, Niche, and Review — based on each item's order volume vs. price relative to the menu average. I implemented it with a CASE statement that first calculates averages in a CTE and then compares each item against those averages. It's directly based on the BCG matrix adapted for restaurant menu analysis.

**Q: What would you do next with more time?**
> Join in a cost-of-goods table to calculate true gross margin per item rather than just revenue. Right now we're ranking by revenue — a high-revenue item with high food cost might actually be less profitable than a cheaper item with low food cost. Margin per item is the real answer.

---

## Resume bullet points

- Designed a 3-table relational SQL analysis in SQL Server covering 12,000+ restaurant order lines, producing a four-quadrant menu profitability classification (Star / Workhorse / Niche / Review) using CTEs, window functions, and CASE logic
- Delivered peak hour and day-of-week demand analysis using RANK(), LAG(), and SUM() OVER() window functions, identifying staffing optimisation opportunities directly actionable in the weekly rota
