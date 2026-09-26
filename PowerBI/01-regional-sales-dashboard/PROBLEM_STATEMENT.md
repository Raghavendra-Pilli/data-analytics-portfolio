# Problem Statement — Regional Sales Performance Dashboard

## Project Overview

| Item | Detail |
|------|--------|
| Project Name | Regional Sales Performance Dashboard |
| Type | Power BI Dashboard |
| Domain | Sales / Market Strategy |
| Complexity | Intermediate |
| Tool | Power BI Desktop (.pbix) |
| Dataset | Global Superstore — Kaggle (CC0) |
| Author | Raghavendra Pilli |
| GitHub | https://github.com/Raghavendra-Pilli/data-analytics-portfolio |

---

## Business Context

A global retail company operates across multiple regions, countries, and product
categories. The senior leadership team — including the VP of Sales and Chief
Strategy Officer — needs a single source of truth to understand which markets
are growing, which are declining, and where the business should invest next.

Currently, the team relies on static Excel reports that are manually refreshed
monthly, lack drill-down capability, and do not surface regional trends
or product-level profitability in an actionable way.

---

## Business Problem

The business cannot confidently answer the following questions from existing
reporting:

1. Which regions and markets are driving the most revenue and profit?
2. Which regions are growing year-over-year and which are declining?
3. Which product categories and sub-categories are most profitable by region?
4. Where should the business open its next office or expand investment?
5. Are there markets where high revenue is masking poor profitability?

---

## Business Questions (Primary)

| # | Question | Audience |
|---|----------|----------|
| 1 | Which region generates the highest revenue and profit? | VP Sales, CSO |
| 2 | What is the YoY revenue growth rate by region and market? | VP Sales |
| 3 | Which product categories drive the most margin by region? | Category Managers |
| 4 | Where is revenue growing but profit declining (margin risk)? | CFO, CSO |
| 5 | Which markets have the highest order volume and AOV? | Sales Directors |
| 6 | What is the top-performing sub-category in each region? | Category Managers |
| 7 | Which shipping modes are most used and how do they affect profit? | Operations |

---

## Objectives

1. Build a self-service Power BI dashboard that answers all 7 business questions
2. Design a star schema semantic model on top of Global Superstore data
3. Implement time intelligence DAX measures for YoY, YTD, and growth %
4. Create an interactive map visual for regional performance comparison
5. Enable drill-through from region → market → customer-level detail
6. Use bookmarks for executive vs. detailed analyst view
7. Ensure the report is structured for Git version control (PBIX + documentation)

---

## Target Users

| User | Role | Primary Need |
|------|------|--------------|
| VP of Sales | Executive | High-level regional performance overview |
| Chief Strategy Officer | Executive | Market expansion decision support |
| Regional Sales Director | Manager | Region-specific trends and category mix |
| Category Manager | Analyst | Sub-category profitability by region |
| BI Analyst | Technical | Self-service exploration and drill-down |

---

## Scope

| In Scope | Out of Scope |
|----------|-------------|
| Sales, profit, orders, quantity by region | Customer-level PII |
| YoY and YTD time intelligence | Real-time data refresh |
| Product category and sub-category analysis | Predictive forecasting |
| Shipping mode analysis | Supply chain integration |
| Map visual for geographic distribution | Mobile layout |
| Drill-through to market and product detail | Row-level security |

---

## Data Source

| Item | Detail |
|------|--------|
| Dataset Name | Global Superstore |
| Source | Kaggle — Vivek468 |
| License | CC0 — Public Domain |
| Format | .xlsx / .csv |
| Size | ~10,000 rows |
| Tables | Orders, Returns, People |
| Time Period | 2011–2014 |

### Key Columns (Orders table)
| Column | Description |
|--------|-------------|
| Order ID | Unique order identifier |
| Order Date | Date order was placed |
| Ship Date | Date order was shipped |
| Ship Mode | Shipping method used |
| Customer ID | Unique customer identifier |
| Customer Name | Customer full name |
| Segment | Customer segment (Consumer/Corporate/Home Office) |
| Country | Customer country |
| City | Customer city |
| State | Customer state/province |
| Region | Geographic region |
| Market | Geographic market (US/EU/APAC/LATAM/Africa/EMEA/Canada) |
| Product ID | Unique product identifier |
| Category | Product category |
| Sub-Category | Product sub-category |
| Product Name | Full product name |
| Sales | Order revenue ($) |
| Quantity | Units ordered |
| Discount | Discount applied (%) |
| Profit | Order profit ($) |
| Shipping Cost | Cost to ship order ($) |

---

## KPIs (Proposed)

| KPI | Definition | Type |
|-----|-----------|------|
| Total Revenue | SUM of Sales | Core |
| Total Profit | SUM of Profit | Core |
| Profit Margin % | Profit / Sales × 100 | Core |
| Total Orders | COUNT of Order ID | Core |
| Average Order Value (AOV) | Sales / Orders | Core |
| Revenue YoY % | (This Year Revenue − Last Year) / Last Year × 100 | Time Intelligence |
| Profit YoY % | (This Year Profit − Last Year) / Last Year × 100 | Time Intelligence |
| Revenue YTD | TOTALYTD of Sales | Time Intelligence |
| Profit YTD | TOTALYTD of Profit | Time Intelligence |
| Avg Discount % | AVERAGE of Discount | Operational |
| Shipping Cost % | Shipping Cost / Sales × 100 | Operational |
| Return Rate % | Returned Orders / Total Orders × 100 | Quality |

---

## Proposed Dashboard Pages

| Page | Purpose | Primary Visuals |
|------|---------|----------------|
| 1. Executive Overview | High-level KPIs, global map | KPI cards, map, bar chart |
| 2. Regional Deep-Dive | Region and market comparison | Bar/column, line trend, matrix |
| 3. Product Performance | Category and sub-category analysis | Treemap, bar, scatter |
| 4. Market Expansion | Where to open next office | Map, growth matrix, scatter |
| 5. Drill-Through: Market | Market-level detail | Tables, charts, KPI cards |

---

## Proposed Semantic Model

### Tables
| Table | Type | Description |
|-------|------|-------------|
| Fact_Orders | Fact | Core transactional data |
| Dim_Customer | Dimension | Customer attributes |
| Dim_Product | Dimension | Product hierarchy |
| Dim_Geography | Dimension | Region, Market, Country, City |
| Dim_Date | Dimension | Full date table for time intelligence |
| Dim_ShipMode | Dimension | Shipping mode lookup |
| Fact_Returns | Fact | Returned orders |

### Relationships
| From | To | Cardinality | Direction |
|------|----|-------------|-----------|
| Fact_Orders[Date Key] | Dim_Date[Date] | Many-to-One | Single |
| Fact_Orders[Customer Key] | Dim_Customer[Customer Key] | Many-to-One | Single |
| Fact_Orders[Product Key] | Dim_Product[Product Key] | Many-to-One | Single |
| Fact_Orders[Geography Key] | Dim_Geography[Geography Key] | Many-to-One | Single |
| Fact_Orders[Ship Mode Key] | Dim_ShipMode[Ship Mode Key] | Many-to-One | Single |
| Fact_Returns[Order ID] | Fact_Orders[Order ID] | Many-to-One | Single |

---

## Assumptions

| # | Assumption | Impact if Wrong |
|---|-----------|----------------|
| 1 | Global Superstore dataset is 2011–2014 | Time intelligence measures may need adjustment |
| 2 | "Market" column = geographic market for expansion analysis | Page 4 logic changes |
| 3 | Returns table joined on Order ID only | Return rate calculation changes |
| 4 | All currencies assumed USD | Multi-currency conversion not in scope |
| 5 | Discount is a decimal (0.2 = 20%) | DAX formatting changes |

---

## Success Criteria

- [ ] Dashboard answers all 7 business questions without needing Excel
- [ ] Executive can identify top 3 expansion markets in under 2 minutes
- [ ] All KPIs match manual Excel calculation (UAT passed)
- [ ] Report loads in under 5 seconds on standard hardware
- [ ] Git repo contains PBIX, documentation, dataset reference, and README
- [ ] Any developer can reproduce the project from the README alone
