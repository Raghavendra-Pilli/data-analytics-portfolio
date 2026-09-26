# Functional Specification — Regional Sales Performance Dashboard

## Document Control

| Item | Detail |
|------|--------|
| Version | 1.0 |
| Status | Draft |
| Author | Raghavendra Pilli |
| Last Updated | 2026 |

---

## 1. Report Structure

### 1.1 Page Inventory

| Page No. | Page Name | Purpose | Audience |
|----------|-----------|---------|----------|
| 1 | Executive Overview | Global KPIs + map | VP Sales, CSO |
| 2 | Regional Deep-Dive | Region & market trends | Sales Directors |
| 3 | Product Performance | Category & sub-category | Category Managers |
| 4 | Market Expansion | Expansion decision support | CSO, Strategy |
| 5 | Drill-Through: Market | Market-level detail | Analysts |

### 1.2 Navigation Design
- Navigation bar on left side — consistent across all pages
- Page icons + labels for each section
- Back button on drill-through page
- Bookmark buttons for Executive View / Analyst View on Page 1

---

## 2. Page 1 — Executive Overview

### Purpose
Give executives a single-screen view of global performance with the ability
to filter by year and region.

### Visuals

| Visual | Type | Fields | Purpose |
|--------|------|--------|---------|
| Total Revenue | KPI Card | [Total Revenue], [Revenue YoY %] | Headline metric |
| Total Profit | KPI Card | [Total Profit], [Profit YoY %] | Profitability |
| Profit Margin % | KPI Card | [Profit Margin %] | Efficiency |
| Total Orders | KPI Card | [Total Orders] | Volume |
| AOV | KPI Card | [Avg Order Value] | Basket size |
| Revenue by Region | Bar Chart | Region, [Total Revenue] | Regional split |
| Profit Margin by Region | Column Chart | Region, [Profit Margin %] | Margin comparison |
| Global Sales Map | Filled Map | Country, [Total Revenue] | Geographic spread |
| Revenue Trend | Line Chart | Year-Month, [Total Revenue] | Monthly trend |

### Slicers
| Slicer | Field | Type | Default |
|--------|-------|------|---------|
| Year | Dim_Date[Year] | Dropdown | All |
| Region | Dim_Geography[Region] | List | All |
| Segment | Dim_Customer[Segment] | Dropdown | All |

### Interactions
- All visuals cross-filter each other
- Map click filters all KPI cards and charts
- Bar chart click filters map and trend line
- Bookmarks: "Executive View" (KPIs + Map only) / "Full View" (all visuals)

### Conditional Formatting
- KPI card YoY %: Green if positive, Red if negative
- Bar chart: Top region highlighted in accent colour

---

## 3. Page 2 — Regional Deep-Dive

### Purpose
Allow sales directors to compare performance across regions and markets,
identify trends, and spot underperforming areas.

### Visuals

| Visual | Type | Fields | Purpose |
|--------|------|--------|---------|
| Revenue by Market | Bar Chart | Market, [Total Revenue] | Market comparison |
| Profit by Market | Bar Chart | Market, [Total Profit] | Profitability by market |
| YoY Revenue Growth | Column Chart | Year, Region, [Revenue YoY %] | Growth trends |
| Revenue vs Profit Scatter | Scatter Chart | [Total Revenue], [Total Profit], Market | Risk identification |
| Top 10 Countries | Table | Country, Revenue, Profit, Margin % | Country ranking |
| Market Share % | Donut Chart | Region, [Revenue %] | Share of wallet |

### Slicers
| Slicer | Field | Type |
|--------|-------|------|
| Year | Dim_Date[Year] | Dropdown |
| Region | Dim_Geography[Region] | List |
| Market | Dim_Geography[Market] | Dropdown |

### Business Rules
- Scatter chart quadrants: High Revenue + High Profit = Star markets
- Scatter chart quadrants: High Revenue + Low Profit = At-Risk markets
- YoY % coloured: ≥10% = Dark Green, 0–10% = Light Green, <0% = Red

### Drill-Through
- Right-click any market → Drill-Through to Page 5 (Market Detail)

---

## 4. Page 3 — Product Performance

### Purpose
Allow category managers to understand which products drive revenue and
margin by region, and identify discount impact on profitability.

### Visuals

| Visual | Type | Fields | Purpose |
|--------|------|--------|---------|
| Revenue by Category | Donut Chart | Category, [Total Revenue] | Category split |
| Profit Margin by Sub-Category | Bar Chart | Sub-Category, [Profit Margin %] | Margin ranking |
| Revenue vs Discount Scatter | Scatter Chart | [Avg Discount %], [Profit Margin %] | Discount impact |
| Top 10 Products by Revenue | Table | Product Name, Revenue, Profit, Margin % | Product ranking |
| Category Treemap | Treemap | Category, Sub-Category, [Total Revenue] | Hierarchy view |
| Sub-Category YoY | Matrix | Sub-Category × Year, [Revenue YoY %] | Trend matrix |

### Slicers
| Slicer | Field | Type |
|--------|-------|------|
| Region | Dim_Geography[Region] | List |
| Category | Dim_Product[Category] | Dropdown |
| Year | Dim_Date[Year] | Dropdown |

### Business Rules
- Products with Discount > 30% AND Profit Margin < 0% flagged in red
- Sub-categories sorted by Profit Margin % descending by default
- Treemap: size = Revenue, colour intensity = Profit Margin %

---

## 5. Page 4 — Market Expansion

### Purpose
Support the CSO and strategy team in identifying the best markets for
office expansion based on revenue growth, order volume, and profitability.

### Visuals

| Visual | Type | Fields | Purpose |
|--------|------|--------|---------|
| Growth vs Profitability Matrix | Scatter | [Revenue YoY %], [Profit Margin %], Market | Expansion quadrant |
| Market Revenue Trend | Line Chart | Year-Month, Market, [Total Revenue] | Growth trajectory |
| Top Markets by Orders | Bar Chart | Market, [Total Orders] | Volume ranking |
| Market AOV Comparison | Column Chart | Market, [Avg Order Value] | Basket size |
| Expansion Scorecard | Matrix | Market, Revenue, Growth %, Margin %, Orders | Decision table |
| Geographic Opportunity Map | Filled Map | Country, [Revenue YoY %] | Growth heatmap |

### Expansion Scoring Logic (DAX Calculated Column)
Markets scored on 3 criteria:
1. Revenue YoY % > 10% → 1 point
2. Profit Margin % > 15% → 1 point
3. Total Orders > 500 → 1 point

Score 3 = Strong Expand | Score 2 = Consider | Score 1/0 = Monitor

### Slicers
| Slicer | Field | Type |
|--------|-------|------|
| Year | Dim_Date[Year] | Dropdown |
| Segment | Dim_Customer[Segment] | Dropdown |

---

## 6. Page 5 — Drill-Through: Market Detail

### Purpose
Provide deep-dive analysis for a specific market when drilled through
from Page 2.

### Drill-Through Field
- `Dim_Geography[Market]`

### Visuals

| Visual | Type | Fields | Purpose |
|--------|------|--------|---------|
| Market KPIs | KPI Cards | Revenue, Profit, Orders, Margin % | Headline |
| Revenue Trend | Line Chart | Month, [Total Revenue] | Monthly pattern |
| Top Products | Bar Chart | Product Name, [Total Revenue] | Product mix |
| Customer Segments | Donut Chart | Segment, [Total Revenue] | Segment split |
| Order Detail Table | Table | Order ID, Date, Customer, Product, Sales, Profit | Transaction view |
| Back Button | Button | Navigate back to Page 2 | UX navigation |

---

## 7. KPI Definitions & Business Rules

| KPI | Formula | Format | Notes |
|-----|---------|--------|-------|
| Total Revenue | SUM(Fact_Orders[Sales]) | $#,##0 | Gross sales |
| Total Profit | SUM(Fact_Orders[Profit]) | $#,##0 | Net of discounts/costs |
| Profit Margin % | [Total Profit] / [Total Revenue] | 0.0% | Blank if Revenue = 0 |
| Total Orders | DISTINCTCOUNT(Fact_Orders[Order ID]) | #,##0 | Unique orders only |
| Avg Order Value | [Total Revenue] / [Total Orders] | $#,##0.00 | Blank if Orders = 0 |
| Revenue YoY % | ([Revenue TY] - [Revenue LY]) / [Revenue LY] | +0.0%;-0.0% | Blank if LY = 0 |
| Profit YoY % | ([Profit TY] - [Profit LY]) / [Profit LY] | +0.0%;-0.0% | Blank if LY = 0 |
| Revenue YTD | TOTALYTD([Total Revenue], Dim_Date[Date]) | $#,##0 | Resets Jan 1 |
| Profit YTD | TOTALYTD([Total Profit], Dim_Date[Date]) | $#,##0 | Resets Jan 1 |
| Avg Discount % | AVERAGE(Fact_Orders[Discount]) | 0.0% | Row-level discount |
| Return Rate % | [Returned Orders] / [Total Orders] | 0.0% | Requires Returns table |
| Shipping Cost % | SUM([Shipping Cost]) / [Total Revenue] | 0.0% | Cost efficiency |

---

## 8. Filters & Interactions

### Report-Level Filters (apply to all pages)
- None by default — all pages independently filtered

### Page-Level Filters
| Page | Filter | Default |
|------|--------|---------|
| All pages | Dim_Date[Year] | All years |
| Page 2 | Dim_Geography[Region] | All regions |
| Page 3 | Dim_Product[Category] | All categories |

### Visual-Level Filters
- Top 10 Products table: Profit Margin % filter — Top N = 10 by Revenue
- Sub-Category matrix: Exclude sub-categories with < 10 orders

### Cross-Filter Behaviour
- All visuals on same page cross-filter each other (default)
- Exception: Trend line chart does NOT filter map (one-directional)

---

## 9. Tooltips

| Visual | Tooltip Fields |
|--------|---------------|
| Map | Country, Revenue, Profit, Margin %, Orders |
| Bar Charts | Metric value, YoY %, Rank |
| Scatter Chart | Market/Product name, X value, Y value, Revenue |
| Trend Line | Date, Revenue, Profit, MoM % change |

---

## 10. Bookmarks

| Bookmark | Page | Purpose | Trigger |
|----------|------|---------|---------|
| Executive View | Page 1 | Hide detail visuals, show KPIs + Map only | Button |
| Full Analyst View | Page 1 | Show all visuals | Button |
| YTD View | Page 2 | Filter to current year only | Button |
| Full History | Page 2 | Show all years | Button |

---

## 11. Accessibility & UX Standards

- Minimum font size: 11pt for body, 14pt for KPI values, 18pt for titles
- Colour-blind safe palette: No red/green only — use icons + colour together
- Alt text on all visuals
- Tab order set for keyboard navigation
- Contrast ratio minimum 4.5:1 for text on background
- Consistent padding: 16px between visuals, 24px page margins

---

## 12. Performance Requirements

| Requirement | Target |
|-------------|--------|
| Report load time | < 5 seconds |
| Visual render time | < 2 seconds per visual |
| Filter response time | < 1 second |
| Dataset size | ~10,000 rows (no aggregation needed) |

### Optimisation Techniques
- Import mode (not DirectQuery) — dataset is static
- Date table marked as official date table
- Unused columns removed in Power Query
- Measures use CALCULATE + FILTER pattern not row-level iteration where possible
- No calculated columns that can be done in Power Query instead
