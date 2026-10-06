# DAX Measures — Telecom Customer Churn Dashboard

## Document Control

| Item | Detail |
|------|--------|
| Version | 1.0 |
| Author | Raghavendra Pilli |
| Last Updated | 2026 |

---

## 1. Measure Organisation

All measures in dedicated `_Measures` table.

| Group | Count |
|-------|-------|
| Core Churn | 6 |
| Revenue & Financial | 5 |
| Segment Analysis | 6 |
| Services Analysis | 4 |
| Retention ROI | 3 |
| Dynamic & Context | 3 |

---

## 2. Core Churn Measures

### Total Customers
```dax
Total Customers =
COUNTROWS(Fact_Customers)
```
**Format:** #,##0

---

### Total Churned
```dax
Total Churned =
SUM(Fact_Customers[Is Churned])
```
**Format:** #,##0
**Note:** Uses integer column for performance over CALCULATE+FILTER

---

### Churn Rate %
```dax
Churn Rate % =
DIVIDE(
    [Total Churned],
    [Total Customers],
    BLANK()
)
```
**Format:** 0.0%

---

### Retained Customers
```dax
Retained Customers =
[Total Customers] - [Total Churned]
```
**Format:** #,##0

---

### Retention Rate %
```dax
Retention Rate % =
1 - [Churn Rate %]
```
**Format:** 0.0%

---

### Avg Tenure (Churners)
```dax
Avg Tenure Churners =
CALCULATE(
    AVERAGE(Fact_Customers[tenure]),
    Fact_Customers[Is Churned] = 1
)
```
**Format:** 0.0
**Purpose:** Shows how quickly customers churn

---

## 3. Revenue & Financial Measures

### Monthly Revenue at Risk
```dax
Monthly Revenue at Risk =
CALCULATE(
    SUM(Fact_Customers[MonthlyCharges]),
    Fact_Customers[Is Churned] = 1
)
```
**Format:** $#,##0
**Purpose:** Monthly revenue lost to churn

---

### Annual Revenue at Risk
```dax
Annual Revenue at Risk =
[Monthly Revenue at Risk] * 12
```
**Format:** $#,##0
**Purpose:** Annualised churn revenue impact

---

### Avg Monthly Charge (Churners)
```dax
Avg Monthly Charge Churners =
CALCULATE(
    AVERAGE(Fact_Customers[MonthlyCharges]),
    Fact_Customers[Is Churned] = 1
)
```
**Format:** $#,##0.00

---

### Avg Monthly Charge (Retained)
```dax
Avg Monthly Charge Retained =
CALCULATE(
    AVERAGE(Fact_Customers[MonthlyCharges]),
    Fact_Customers[Is Churned] = 0
)
```
**Format:** $#,##0.00
**Purpose:** Compare billing between churned and retained

---

### Total Revenue Lost
```dax
Total Revenue Lost =
CALCULATE(
    SUM(Fact_Customers[TotalCharges]),
    Fact_Customers[Is Churned] = 1
)
```
**Format:** $#,##0

---

## 4. Segment Analysis Measures

### Senior Citizen Churn Rate %
```dax
Senior Churn Rate % =
DIVIDE(
    CALCULATE([Total Churned], Fact_Customers[SeniorCitizen] = 1),
    CALCULATE([Total Customers], Fact_Customers[SeniorCitizen] = 1),
    BLANK()
)
```
**Format:** 0.0%

---

### Month-to-Month Churn Rate %
```dax
MTM Churn Rate % =
DIVIDE(
    CALCULATE(
        [Total Churned],
        Dim_Contract[Contract] = "Month-to-month"
    ),
    CALCULATE(
        [Total Customers],
        Dim_Contract[Contract] = "Month-to-month"
    ),
    BLANK()
)
```
**Format:** 0.0%

---

### Fiber Optic Churn Rate %
```dax
Fiber Churn Rate % =
DIVIDE(
    CALCULATE(
        [Total Churned],
        Dim_InternetService[InternetService] = "Fiber optic"
    ),
    CALCULATE(
        [Total Customers],
        Dim_InternetService[InternetService] = "Fiber optic"
    ),
    BLANK()
)
```
**Format:** 0.0%

---

### Churn Rate vs Average
```dax
Churn Rate vs Avg =
[Churn Rate %] -
CALCULATE(
    [Churn Rate %],
    ALL(Fact_Customers)
)
```
**Format:** +0.0%;-0.0%;0.0%
**Purpose:** Shows how current segment compares to overall average
**Used in:** Conditional formatting

---

### No Partner No Dependent Churn Rate %
```dax
Single No Dep Churn Rate % =
DIVIDE(
    CALCULATE(
        [Total Churned],
        Fact_Customers[Partner] = "No",
        Fact_Customers[Dependents] = "No"
    ),
    CALCULATE(
        [Total Customers],
        Fact_Customers[Partner] = "No",
        Fact_Customers[Dependents] = "No"
    ),
    BLANK()
)
```
**Format:** 0.0%

---

### Electronic Check Churn Rate %
```dax
ECheck Churn Rate % =
DIVIDE(
    CALCULATE(
        [Total Churned],
        Dim_PaymentMethod[PaymentMethod] = "Electronic check"
    ),
    CALCULATE(
        [Total Customers],
        Dim_PaymentMethod[PaymentMethod] = "Electronic check"
    ),
    BLANK()
)
```
**Format:** 0.0%

---

## 5. Services Analysis Measures

### Churn Rate by Service Count
```dax
Avg Services Churners =
CALCULATE(
    AVERAGE(Fact_Customers[Service Count]),
    Fact_Customers[Is Churned] = 1
)
```
**Format:** 0.0
**Purpose:** Do customers with more services churn less?

---

### No Online Security Churn Rate %
```dax
No Security Churn Rate % =
DIVIDE(
    CALCULATE(
        [Total Churned],
        Fact_Customers[OnlineSecurity] = "No"
    ),
    CALCULATE(
        [Total Customers],
        Fact_Customers[OnlineSecurity] = "No"
    ),
    BLANK()
)
```
**Format:** 0.0%

---

### Tech Support Retention Lift
```dax
Tech Support Retention Lift =
CALCULATE([Churn Rate %], Fact_Customers[TechSupport] = "No") -
CALCULATE([Churn Rate %], Fact_Customers[TechSupport] = "Yes")
```
**Format:** 0.0%
**Purpose:** How much does TechSupport reduce churn?

---

### Paperless Billing Churn Rate %
```dax
Paperless Churn Rate % =
DIVIDE(
    CALCULATE(
        [Total Churned],
        Fact_Customers[PaperlessBilling] = "Yes"
    ),
    CALCULATE(
        [Total Customers],
        Fact_Customers[PaperlessBilling] = "Yes"
    ),
    BLANK()
)
```
**Format:** 0.0%

---

## 6. Retention ROI Measures

### Retention Cost (What-If)
```dax
-- Requires What-If parameter: Retention Cost Per Customer ($0–$200, default $50)
Retention Cost Total =
[Retained by Intervention] * 'Retention Cost'[Retention Cost Value]
```
**Format:** $#,##0

---

### Retained Revenue
```dax
Retained Revenue =
[Retained by Intervention] * [Avg Monthly Charge Churners] * 12
```
**Format:** $#,##0
**Purpose:** Annual revenue saved if churners are retained

---

### Retention ROI %
```dax
Retention ROI % =
DIVIDE(
    [Retained Revenue] - [Retention Cost Total],
    [Retention Cost Total],
    BLANK()
)
```
**Format:** 0%
**Purpose:** Return on retention investment

---

## 7. Dynamic & Context Measures

### Dynamic Churn Title
```dax
Dynamic Churn Title =
VAR Segment = SELECTEDVALUE(Dim_Contract[Contract], "All Contracts")
VAR Rate = FORMAT([Churn Rate %], "0.0%")
RETURN
    "Churn Rate: " & Rate & " — " & Segment
```
**Format:** Text

---

### Churn Risk Label
```dax
Churn Risk Label =
SWITCH(
    TRUE(),
    [Churn Rate %] >= 0.40, "🔴 High Risk",
    [Churn Rate %] >= 0.25, "🟡 Medium Risk",
    [Churn Rate %] >= 0.10, "🟢 Low Risk",
    "⚪ Minimal Risk"
)
```
**Format:** Text
**Used in:** KPI cards, matrix conditional formatting

---

### Customer Count Label
```dax
Customer Count Label =
FORMAT([Total Customers], "#,##0") & " customers · " &
FORMAT([Churn Rate %], "0.0%") & " churn rate"
```
**Format:** Text
**Used in:** Report subtitle card

---

## 8. Measure Testing Checklist

- [ ] Total Customers = 7,043
- [ ] Total Churned = 1,869
- [ ] Churn Rate % = 26.5%
- [ ] MTM Churn Rate % ≈ 42.7%
- [ ] Fiber Optic Churn Rate % ≈ 41.9%
- [ ] Senior Citizen Churn Rate % ≈ 41.7%
- [ ] Monthly Revenue at Risk matches SUM of MonthlyCharges for churners
- [ ] Retention ROI responds to What-If parameter changes
