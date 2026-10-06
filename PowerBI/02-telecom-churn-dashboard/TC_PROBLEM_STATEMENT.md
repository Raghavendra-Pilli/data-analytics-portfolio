# Problem Statement — Telecom Customer Churn Analysis Dashboard

## Project Overview

| Item | Detail |
|------|--------|
| Project Name | Telecom Customer Churn Analysis Dashboard |
| Type | Power BI Dashboard |
| Domain | Telecoms / Customer Analytics |
| Complexity | Intermediate-Advanced |
| Tool | Power BI Desktop (.pbix) |
| Dataset | IBM Telco Customer Churn — Kaggle (CC0) |
| Author | Raghavendra Pilli |
| GitHub | https://github.com/Raghavendra-Pilli/data-analytics-portfolio |

---

## Business Context

A telecom company serving 7,043 customers is experiencing significant customer
churn. Acquiring a new customer costs 5–7× more than retaining an existing one.
The business has no current visibility into which customers are at risk of
churning, what is driving churn, and which retention interventions would
generate the highest ROI.

The Customer Success and Marketing teams currently rely on gut feel and
reactive outreach — contacting customers only after they have already left.

---

## Business Problem

The business cannot confidently answer the following questions:

1. What is the overall churn rate and how does it compare by segment?
2. Which customer profiles are most likely to churn?
3. Which contract types, payment methods, and tenure bands have the highest churn?
4. What is the estimated revenue at risk from churning customers?
5. Which retention interventions would have the highest ROI?
6. Which product bundles (internet, phone, streaming) are associated with lower churn?

---

## Business Questions (Primary)

| # | Question | Audience |
|---|----------|----------|
| 1 | What is the overall churn rate? | CEO, VP Customer Success |
| 2 | Which contract type has the highest churn? | VP Sales |
| 3 | Which tenure band churns most? | Customer Success Team |
| 4 | What is the revenue at risk from churners? | CFO |
| 5 | Which payment method correlates with churn? | Finance, Marketing |
| 6 | Do customers with dependents/partners churn less? | Marketing |
| 7 | Which internet/phone service bundle retains customers best? | Product Team |
| 8 | What is the estimated retention ROI per segment? | Strategy |

---

## Objectives

1. Build a Power BI dashboard that surfaces churn drivers clearly
2. Quantify revenue at risk from churning customers
3. Segment customers by churn risk profile
4. Enable drill-through from segment → individual customer detail
5. Provide retention ROI estimates by intervention type
6. Design for Customer Success team daily use — not just executive review

---

## Target Users

| User | Role | Primary Need |
|------|------|--------------|
| VP Customer Success | Executive | Overall churn rate and trend |
| Customer Success Manager | Manager | At-risk segments to prioritise |
| Marketing Manager | Analyst | Segment profiles for campaigns |
| CFO | Executive | Revenue at risk quantification |
| Product Manager | Analyst | Bundle/service churn correlation |

---

## Scope

| In Scope | Out of Scope |
|----------|-------------|
| Churn rate by segment, contract, tenure | Real-time churn prediction (ML) |
| Revenue at risk calculation | Customer PII beyond dataset |
| Product bundle churn correlation | Competitive benchmarking |
| Retention ROI estimation | Call centre integration |
| Drill-through to customer profile | Power BI Service deployment |

---

## Data Source

| Item | Detail |
|------|--------|
| Dataset Name | IBM Telco Customer Churn |
| Source | Kaggle — blastchar |
| License | CC0 — Public Domain |
| Format | .csv |
| Rows | 7,043 customers |
| Columns | 21 |
| Period | Single snapshot (no time series) |

### Key Columns

| Column | Type | Description |
|--------|------|-------------|
| CustomerID | Text | Unique customer identifier |
| gender | Text | Male / Female |
| SeniorCitizen | Integer | 1 = Senior, 0 = Not Senior |
| Partner | Text | Yes / No |
| Dependents | Text | Yes / No |
| tenure | Integer | Months with company |
| PhoneService | Text | Yes / No |
| MultipleLines | Text | Yes / No / No phone service |
| InternetService | Text | DSL / Fiber optic / No |
| OnlineSecurity | Text | Yes / No / No internet service |
| OnlineBackup | Text | Yes / No / No internet service |
| DeviceProtection | Text | Yes / No / No internet service |
| TechSupport | Text | Yes / No / No internet service |
| StreamingTV | Text | Yes / No / No internet service |
| StreamingMovies | Text | Yes / No / No internet service |
| Contract | Text | Month-to-month / One year / Two year |
| PaperlessBilling | Text | Yes / No |
| PaymentMethod | Text | Electronic check / Mailed check / Bank transfer / Credit card |
| MonthlyCharges | Decimal | Monthly bill amount ($) |
| TotalCharges | Text | Total charges to date ($) — note: stored as text, needs conversion |
| Churn | Text | Yes / No — TARGET VARIABLE |

---

## KPIs (Proposed)

| KPI | Definition | Type |
|-----|-----------|------|
| Total Customers | COUNT of CustomerID | Core |
| Total Churned | COUNT where Churn = Yes | Core |
| Churn Rate % | Churned / Total × 100 | Core |
| Retained Customers | COUNT where Churn = No | Core |
| Revenue at Risk | SUM MonthlyCharges where Churn = Yes | Financial |
| Avg Monthly Charge (Churners) | AVG MonthlyCharges where Churn = Yes | Financial |
| Avg Tenure (Churners) | AVG tenure where Churn = Yes | Behavioural |
| Avg Tenure (Retained) | AVG tenure where Churn = No | Behavioural |
| Senior Citizen Churn Rate % | Churned Seniors / Total Seniors × 100 | Segment |
| Month-to-Month Churn Rate % | Churned MTM / Total MTM × 100 | Segment |
| Fiber Optic Churn Rate % | Churned Fiber / Total Fiber × 100 | Segment |
| Retention ROI | (Retained Revenue − Retention Cost) / Cost | Financial |

---

## Proposed Dashboard Pages

| Page | Purpose | Primary Visuals |
|------|---------|----------------|
| 1. Churn Overview | Overall KPIs and churn summary | KPI cards, donut, bar |
| 2. Customer Segments | Churn by demographics and contract | Bar, matrix, scatter |
| 3. Product & Services | Bundle and service churn analysis | Stacked bar, heatmap |
| 4. Revenue at Risk | Financial impact of churn | Waterfall, KPI cards |
| 5. Retention Planner | ROI by intervention type | Table, bar, what-if |
| 6. Drill-Through: Customer | Individual customer profile | Card, table |

---

## Proposed Semantic Model

### Tables
| Table | Type | Description |
|-------|------|-------------|
| Fact_Customers | Fact | One row per customer with all attributes |
| Dim_Contract | Dimension | Contract type lookup |
| Dim_PaymentMethod | Dimension | Payment method lookup |
| Dim_InternetService | Dimension | Internet service type lookup |
| Dim_TenureBand | Dimension | Calculated tenure grouping |
| Dim_ChurnReason | Dimension | Churn reason categories (derived) |

### Key Relationships
| From | To | Cardinality |
|------|----|-------------|
| Fact_Customers[Contract Key] | Dim_Contract[Contract Key] | Many-to-One |
| Fact_Customers[Payment Key] | Dim_PaymentMethod[Payment Key] | Many-to-One |
| Fact_Customers[Internet Key] | Dim_InternetService[Internet Key] | Many-to-One |
| Fact_Customers[Tenure Band Key] | Dim_TenureBand[Tenure Band Key] | Many-to-One |

---

## Assumptions

| # | Assumption | Impact if Wrong |
|---|-----------|----------------|
| 1 | TotalCharges column converted from text to decimal in Power Query | Revenue calculations wrong |
| 2 | Churn = "Yes" means customer has already left | Churn rate overstated if includes at-risk |
| 3 | MonthlyCharges used as revenue proxy | Actual revenue may differ |
| 4 | No time series — single snapshot | Cannot show churn trend over time |
| 5 | Senior Citizen = 1 means age 65+ | Segment definition may differ |
| 6 | Retention cost assumed $50 per customer | ROI calculation is illustrative |

---

## Success Criteria

- [ ] Dashboard answers all 8 business questions
- [ ] Customer Success team can identify top 3 at-risk segments in under 2 minutes
- [ ] Revenue at risk quantified in dollar terms
- [ ] Drill-through to individual customer profile works correctly
- [ ] All KPIs validated against manual CSV calculation
- [ ] Git repo contains documentation, dataset, and PBIX file
- [ ] Any developer can reproduce from README alone
