# Telecom Customer Churn Analysis Dashboard
> Which customer segments are churning and what interventions have the highest retention ROI?

![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)
![Dataset](https://img.shields.io/badge/Dataset-IBM%20Telco%20Churn-blue?style=flat)
![License](https://img.shields.io/badge/License-CC0%20Public%20Domain-green?style=flat)
![Status](https://img.shields.io/badge/Status-In%20Progress-orange?style=flat)

---

## Business Problem

A telecom company serving 7,043 customers is losing customers at a 26.5% rate.
Acquiring a new customer costs 5–7× more than retaining one. The business needs
visibility into who is churning, why, and which interventions deliver the highest ROI.

**Key questions this dashboard answers:**
1. What is the overall churn rate by segment?
2. Which contract types and payment methods have highest churn?
3. What is the revenue at risk from churning customers?
4. Which product bundles are associated with lower churn?
5. What is the ROI of different retention interventions?

---

## Key Results

| Metric | Value |
|--------|-------|
| Total Customers | 7,043 |
| Overall Churn Rate | 26.5% |
| Total Churned | 1,869 |
| Monthly Revenue at Risk | ~$139K |
| Annual Revenue at Risk | ~$1.67M |
| Highest Risk Contract | Month-to-month (42.7%) |
| Highest Risk Service | Fiber Optic (41.9%) |
| Highest Risk Payment | Electronic Check (45.3%) |

---

## Dashboard Pages

| Page | Purpose |
|------|---------|
| Churn Overview | Global KPIs, donut, churn by contract/tenure/payment |
| Customer Segments | Demographics, contract, payment method analysis |
| Product & Services | Bundle and service churn correlation |
| Revenue at Risk | Financial impact, waterfall, avg charge comparison |
| Retention Planner | What-if ROI calculator by intervention |
| Drill-Through: Customer | Individual customer profile |

---

## Project Structure

```
02-telecom-churn-dashboard/
├── data/
│   └── README.md                    ← Dataset download instructions
├── reports/
│   └── telecom_churn.pbix           ← Power BI report file
├── docs/
│   ├── FUNCTIONAL_SPEC.md           ← Pages, visuals, interactions
│   ├── SEMANTIC_MODEL.md            ← Star schema, tables, Power Query
│   └── DAX_MEASURES.md              ← All DAX measures with formulas
├── PROBLEM_STATEMENT.md             ← Business problem, objectives, KPIs
└── README.md                        ← This file
```

---

## Dataset

**IBM Telco Customer Churn** — Kaggle
- License: CC0 Public Domain
- Rows: 7,043 customers, 21 columns
- Source: https://www.kaggle.com/datasets/blastchar/telco-customer-churn

**Download:**
1. Go to Kaggle link above
2. Download `WA_Fn-UseC_-Telco-Customer-Churn.csv`
3. Place in `/data/` folder

**Important:** `TotalCharges` column is stored as text in source —
converted to decimal in Power Query (see SEMANTIC_MODEL.md).

---

## Semantic Model

Star schema with 5 tables:

```
Dim_Contract ──────────────┐
Dim_PaymentMethod ─────────┤
Dim_InternetService ───────┼──── Fact_Customers
Dim_TenureBand ────────────┘
```

Full documentation → `docs/SEMANTIC_MODEL.md`

---

## DAX Measures (27 total)

| Group | Examples |
|-------|---------|
| Core Churn | Churn Rate %, Total Churned, Retention Rate % |
| Revenue & Financial | Monthly Revenue at Risk, Annual Revenue at Risk |
| Segment Analysis | MTM Churn Rate %, Fiber Churn Rate %, Senior Churn Rate % |
| Services Analysis | Tech Support Retention Lift, Service Count |
| Retention ROI | Retention ROI %, Retained Revenue, What-If parameters |

Full documentation → `docs/DAX_MEASURES.md`

---

## How to Reproduce

### Prerequisites
- Power BI Desktop (latest version)
- IBM Telco Churn dataset downloaded

### Steps
1. Clone this repository
```bash
git clone https://github.com/Raghavendra-Pilli/data-analytics-portfolio.git
```

2. Download dataset from Kaggle and place in `/data/`

3. Open `reports/telecom_churn.pbix` in Power BI Desktop

4. Update data source path if prompted

5. Click Refresh — all transformations, measures, and visuals load automatically

---

## Skills Demonstrated

- Power BI Desktop — churn analysis dashboard
- Power Query — TotalCharges text-to-decimal conversion, calculated columns
- DAX — CALCULATE + FILTER patterns, What-If parameters, dynamic labels
- Semantic modelling — star schema, tenure band dimension
- UX/UI — drill-through, bookmarks, conditional formatting, risk labels
- Business analysis — churn drivers, revenue at risk, retention ROI

---

## Author

**Raghavendra Pilli**
- GitHub: https://github.com/Raghavendra-Pilli
- Portfolio: https://github.com/Raghavendra-Pilli/data-analytics-portfolio
