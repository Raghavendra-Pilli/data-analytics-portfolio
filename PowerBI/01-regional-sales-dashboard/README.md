# Regional Sales Performance Dashboard
> Which regions are growing and where should the business open its next office?

![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)
![Dataset](https://img.shields.io/badge/Dataset-Global%20Superstore-blue?style=flat)
![License](https://img.shields.io/badge/License-CC0%20Public%20Domain-green?style=flat)
![Status](https://img.shields.io/badge/Status-In%20Progress-orange?style=flat)

---

## Business Problem

A global retail company operates across multiple regions, countries, and product
categories. The senior leadership team needs a single source of truth to understand
which markets are growing, which are declining, and where to invest next.

**Key questions this dashboard answers:**
1. Which region generates the highest revenue and profit?
2. What is the YoY revenue growth rate by region and market?
3. Which product categories drive the most margin by region?
4. Where is revenue growing but profit declining (margin risk)?
5. Which markets should the business expand into next?

---

## Dashboard Preview

| Page | Purpose |
|------|---------|
| Executive Overview | Global KPIs, map, revenue trend |
| Regional Deep-Dive | Region & market comparison, YoY growth |
| Product Performance | Category & sub-category profitability |
| Market Expansion | Expansion scoring matrix |
| Drill-Through: Market | Market-level transaction detail |

---

## Key Results

| Metric | Value |
|--------|-------|
| Total Revenue | $12.6M |
| Total Profit | $1.47M |
| Profit Margin | 11.6% |
| Total Orders | 25,035 |
| Top Region | APAC |
| Highest Growth Market | APAC |
| Best Margin Category | Technology |

---

## Project Structure

```
01-regional-sales-dashboard/
├── data/
│   └── README.md                  ← Dataset download instructions
├── reports/
│   └── regional_sales.pbix        ← Power BI report file
├── docs/
│   ├── FUNCTIONAL_SPEC.md         ← Page layout, visuals, KPI definitions
│   ├── SEMANTIC_MODEL.md          ← Star schema, tables, relationships
│   ├── DAX_MEASURES.md            ← All 35 DAX measures with formulas
│   └── UI_UX_DESIGN.md            ← Design system, layout, typography
├── PROBLEM_STATEMENT.md           ← Business problem, objectives, scope
└── README.md                      ← This file
```

---

## Dataset

**Global Superstore** — Kaggle (Vivek468)
- License: CC0 Public Domain
- Size: ~10,000 rows
- Tables: Orders, Returns, People
- Period: 2011–2014

**Download:**
1. Go to: https://www.kaggle.com/datasets/vivek468/superstore-dataset-final
2. Download `Sample - Superstore.xls` or `superstore.csv`
3. Place in `/data/` folder

---

## Semantic Model

Star schema with 7 tables:

```
Dim_Date ──────────┐
Dim_Customer ──────┤
Dim_Product ───────┼──── Fact_Orders ──── Fact_Returns
Dim_Geography ─────┤
Dim_ShipMode ──────┘
```

Full documentation → `docs/SEMANTIC_MODEL.md`

---

## DAX Measures (35 total)

| Group | Examples |
|-------|---------|
| Core Sales | Total Revenue, Total Profit, Total Quantity |
| Profitability | Profit Margin %, Shipping Cost %, Loss Orders |
| Time Intelligence | Revenue YoY %, Revenue YTD, Revenue LY, Rolling 12M |
| Orders & Customers | Total Orders, AOV, Total Customers |
| Returns | Return Rate %, Returned Orders |
| Expansion Scoring | Expansion Score, Expansion Rating, Priority Rank |

Full documentation → `docs/DAX_MEASURES.md`

---

## How to Reproduce

### Prerequisites
- Power BI Desktop (latest version)
- Global Superstore dataset downloaded

### Steps
1. Clone this repository
```bash
git clone https://github.com/Raghavendra-Pilli/data-analytics-portfolio.git
```

2. Download dataset from Kaggle and place in `/data/` folder

3. Open `reports/regional_sales.pbix` in Power BI Desktop

4. If prompted, update data source path:
   - Home → Transform Data → Data Source Settings
   - Update path to your local `/data/` folder

5. Click Refresh to load data

6. All DAX measures, relationships, and visuals load automatically

---

## Documentation Index

| Document | Contents |
|----------|---------|
| `PROBLEM_STATEMENT.md` | Business context, objectives, KPI list, semantic model proposal |
| `docs/FUNCTIONAL_SPEC.md` | All 5 pages, visuals, slicers, interactions, business rules |
| `docs/SEMANTIC_MODEL.md` | 7 tables, relationships, Power Query steps, optimisation |
| `docs/DAX_MEASURES.md` | 35 measures with formulas, formats, edge cases |
| `docs/UI_UX_DESIGN.md` | Colour palette, typography, layout, accessibility |

---

## Skills Demonstrated

- Power BI Desktop — report design and development
- Power Query / M — multi-table transformation and star schema build
- DAX — time intelligence, ranking, dynamic titles, CALCULATE patterns
- Semantic modelling — star schema, relationships, date table
- UX/UI — enterprise dashboard design, bookmarks, drill-through, navigation
- Git — version control for Power BI projects

---

## Author

**Raghavendra Pilli**
- GitHub: https://github.com/Raghavendra-Pilli
- Portfolio: https://github.com/Raghavendra-Pilli/data-analytics-portfolio
