# Functional Specification — Telecom Customer Churn Dashboard

## Document Control

| Item | Detail |
|------|--------|
| Version | 1.0 |
| Author | Raghavendra Pilli |
| Last Updated | 2026 |

---

## 1. Report Structure

### Page Inventory

| Page | Name | Purpose | Audience |
|------|------|---------|----------|
| 1 | Churn Overview | Global KPIs and churn summary | All users |
| 2 | Customer Segments | Churn by demographics and contract | CS Manager |
| 3 | Product & Services | Bundle and service churn analysis | Product Team |
| 4 | Revenue at Risk | Financial impact of churn | CFO |
| 5 | Retention Planner | ROI by intervention | Strategy |
| 6 | Drill-Through: Customer | Individual customer profile | CS Team |

---

## 2. Page 1 — Churn Overview

### Visuals

| Visual | Type | Fields |
|--------|------|--------|
| Total Customers | KPI Card | [Total Customers] |
| Churn Rate % | KPI Card | [Churn Rate %], [Churn Risk Label] |
| Total Churned | KPI Card | [Total Churned] |
| Monthly Revenue at Risk | KPI Card | [Monthly Revenue at Risk] |
| Retained Customers | KPI Card | [Retained Customers] |
| Churn vs Retained | Donut Chart | Churn, [Total Customers] |
| Churn by Contract | Bar Chart | Contract, [Churn Rate %] |
| Churn by Tenure Band | Column Chart | Tenure Band, [Churn Rate %] |
| Churn by Payment Method | Bar Chart | PaymentMethod, [Churn Rate %] |

### Slicers
| Slicer | Field | Default |
|--------|-------|---------|
| Contract Type | Dim_Contract[Contract] | All |
| Internet Service | Dim_InternetService[InternetService] | All |
| Senior Citizen | Fact_Customers[SeniorCitizen] | All |

### Conditional Formatting
- Churn Rate % KPI: Red if > 30%, Amber if 20–30%, Green if < 20%
- Bar charts: Churned bars coloured red, retained green

---

## 3. Page 2 — Customer Segments

### Visuals

| Visual | Type | Fields |
|--------|------|--------|
| Churn by Gender | Bar Chart | gender, [Churn Rate %] |
| Churn by Senior Citizen | Column Chart | SeniorCitizen, [Churn Rate %] |
| Churn by Partner & Dependents | Matrix | Partner × Dependents, [Churn Rate %] |
| Churn by Contract Type | Bar Chart | Contract, [Total Churned], [Churn Rate %] |
| Churn by Payment Method | Bar Chart | PaymentMethod, [Churn Rate %] |
| Churn by Paperless Billing | Column Chart | PaperlessBilling, [Churn Rate %] |
| Segment Risk Matrix | Scatter Chart | [Total Customers], [Churn Rate %], Segment |

### Business Rules
- Segments with Churn Rate % > 35% highlighted in red
- Scatter quadrants: High Volume + High Churn = Priority intervention
- Matrix: colour scale from green (low churn) to red (high churn)

### Drill-Through
- Right-click any data point → Drill-Through to Page 6 (Customer Profile)

---

## 4. Page 3 — Product & Services

### Visuals

| Visual | Type | Fields |
|--------|------|--------|
| Churn by Internet Service | Bar Chart | InternetService, [Churn Rate %] |
| Churn by Phone Service | Column Chart | PhoneService, [Churn Rate %] |
| Service Adoption Heatmap | Matrix | Service × Churn, [Total Customers] |
| Churn by Service Count | Line Chart | Service Count, [Churn Rate %] |
| Online Security Impact | KPI Card | [No Security Churn Rate %] |
| Tech Support Retention Lift | KPI Card | [Tech Support Retention Lift] |
| Streaming Services Churn | Stacked Bar | StreamingTV, StreamingMovies, [Churn Rate %] |

### Business Rules
- Customers with 0–1 services have highest churn — flagged
- Fiber optic customers highlighted as high-risk segment
- Services shown in order of churn impact (descending)

---

## 5. Page 4 — Revenue at Risk

### Visuals

| Visual | Type | Fields |
|--------|------|--------|
| Monthly Revenue at Risk | KPI Card | [Monthly Revenue at Risk] |
| Annual Revenue at Risk | KPI Card | [Annual Revenue at Risk] |
| Revenue Lost (Total Charges) | KPI Card | [Total Revenue Lost] |
| Revenue at Risk by Contract | Waterfall Chart | Contract, Revenue contribution |
| Revenue at Risk by Segment | Bar Chart | Tenure Band, [Monthly Revenue at Risk] |
| Avg Charge: Churners vs Retained | Column Chart | Churn, [Avg Monthly Charge] |
| Revenue at Risk Trend | Line Chart | Tenure Band, [Monthly Revenue at Risk] |

### Business Rules
- Waterfall shows cumulative revenue at risk by contract type
- Monthly × 12 used for annual projection
- Churners avg charge vs retained avg charge shown side by side

---

## 6. Page 5 — Retention Planner

### Visuals

| Visual | Type | Fields |
|--------|------|--------|
| What-If: Retention Cost | Slicer | Parameter: $0–$200 per customer |
| What-If: Retention Rate | Slicer | Parameter: 10%–100% success rate |
| Retained Revenue | KPI Card | [Retained Revenue] |
| Retention Cost Total | KPI Card | [Retention Cost Total] |
| Retention ROI % | KPI Card | [Retention ROI %] |
| ROI by Segment | Bar Chart | Tenure Band, [Retention ROI %] |
| Intervention Priority Table | Table | Segment, Customers, Churn Rate, Revenue at Risk, ROI |

### What-If Parameters
| Parameter | Min | Max | Default | Increment |
|-----------|-----|-----|---------|-----------|
| Retention Cost Per Customer | $0 | $200 | $50 | $5 |
| Expected Retention Success % | 10% | 100% | 30% | 5% |

---

## 7. Page 6 — Drill-Through: Customer Profile

### Drill-Through Field
- `Fact_Customers[CustomerID]`

### Visuals

| Visual | Type | Fields |
|--------|------|--------|
| Customer ID | Card | CustomerID |
| Churn Status | Card | Churn, [Churn Risk Label] |
| Monthly Charges | Card | MonthlyCharges |
| Tenure | Card | tenure |
| Contract Type | Card | Contract |
| Payment Method | Card | PaymentMethod |
| Services Subscribed | Table | Service name, Status |
| Back Button | Button | Navigate to Page 2 |

---

## 8. Bookmarks

| Bookmark | Page | Purpose |
|----------|------|---------|
| Executive Summary | Page 1 | KPI cards only — hide charts |
| Full Analysis | Page 1 | All visuals visible |
| High Risk Only | Page 2 | Filter Churn Rate % > 35% |
| All Segments | Page 2 | Remove risk filter |

---

## 9. Performance Requirements

| Requirement | Target |
|-------------|--------|
| Report load time | < 3 seconds |
| Visual render | < 1 second |
| Dataset size | 7,043 rows — no aggregation needed |
| Storage mode | Import |
