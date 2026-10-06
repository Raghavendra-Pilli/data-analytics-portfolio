# Semantic Model Design — Telecom Customer Churn Dashboard

## Document Control

| Item | Detail |
|------|--------|
| Version | 1.0 |
| Author | Raghavendra Pilli |
| Last Updated | 2026 |

---

## 1. Model Overview

| Item | Decision | Reason |
|------|----------|--------|
| Model Type | Star Schema | Clean separation of facts and dimensions |
| Storage Mode | Import | Static snapshot dataset, ~7K rows |
| Date Table | Not required | No time series in dataset |
| RLS | Not in scope | Single-user portfolio project |

---

## 2. Star Schema Diagram

```
Dim_Contract ──────────────┐
Dim_PaymentMethod ─────────┤
Dim_InternetService ───────┼──── Fact_Customers
Dim_TenureBand ────────────┤
Dim_Demographics ──────────┘
```

---

## 3. Table Definitions

### 3.1 Fact_Customers (Fact Table)
**Source:** WA_Fn-UseC_-Telco-Customer-Churn.csv
**Grain:** One row per customer

| Column | Data Type | Description |
|--------|-----------|-------------|
| Customer Key | Integer | Surrogate key (PK) |
| CustomerID | Text | Natural key |
| Contract Key | Integer | FK to Dim_Contract |
| Payment Key | Integer | FK to Dim_PaymentMethod |
| Internet Key | Integer | FK to Dim_InternetService |
| Tenure Band Key | Integer | FK to Dim_TenureBand |
| tenure | Integer | Months with company |
| MonthlyCharges | Decimal | Monthly bill ($) |
| TotalCharges | Decimal | Total charges (converted from text) |
| PhoneService | Text | Yes / No |
| MultipleLines | Text | Yes / No / No phone service |
| OnlineSecurity | Text | Yes / No / No internet service |
| OnlineBackup | Text | Yes / No / No internet service |
| DeviceProtection | Text | Yes / No / No internet service |
| TechSupport | Text | Yes / No / No internet service |
| StreamingTV | Text | Yes / No / No internet service |
| StreamingMovies | Text | Yes / No / No internet service |
| PaperlessBilling | Text | Yes / No |
| Churn | Text | Yes / No |
| Is Churned | Integer | 1 = Churned, 0 = Retained (calculated column) |
| gender | Text | Male / Female |
| SeniorCitizen | Integer | 1 = Senior, 0 = Not |
| Partner | Text | Yes / No |
| Dependents | Text | Yes / No |

---

### 3.2 Dim_Contract

| Column | Data Type | Description |
|--------|-----------|-------------|
| Contract Key | Integer | Surrogate key (PK) |
| Contract | Text | Month-to-month / One year / Two year |
| Contract Short | Text | MTM / 1Y / 2Y |
| Contract Risk | Text | High / Medium / Low |

**Contract Risk mapping:**
- Month-to-month → High
- One year → Medium
- Two year → Low

---

### 3.3 Dim_PaymentMethod

| Column | Data Type | Description |
|--------|-----------|-------------|
| Payment Key | Integer | Surrogate key (PK) |
| PaymentMethod | Text | Full payment method name |
| Payment Short | Text | E-Check / Mail / Bank / Card |
| Payment Type | Text | Automatic / Manual |

**Payment Type mapping:**
- Electronic check → Manual
- Mailed check → Manual
- Bank transfer (automatic) → Automatic
- Credit card (automatic) → Automatic

---

### 3.4 Dim_InternetService

| Column | Data Type | Description |
|--------|-----------|-------------|
| Internet Key | Integer | Surrogate key (PK) |
| InternetService | Text | DSL / Fiber optic / No |
| Has Internet | Text | Yes / No |

---

### 3.5 Dim_TenureBand

| Column | Data Type | Description |
|--------|-----------|-------------|
| Tenure Band Key | Integer | Surrogate key (PK) |
| Tenure Band | Text | 0-12 / 13-24 / 25-36 / 37-48 / 49-60 / 61+ |
| Tenure Band Sort | Integer | Sort order (1–6) |
| Tenure Group | Text | New / Developing / Established / Loyal |

**Tenure Group mapping:**
- 0–12 months → New
- 13–24 months → Developing
- 25–48 months → Established
- 49+ months → Loyal

---

## 4. Calculated Columns (Power Query)

| Table | Column | Logic |
|-------|--------|-------|
| Fact_Customers | Is Churned | if [Churn] = "Yes" then 1 else 0 |
| Fact_Customers | TotalCharges | Number.FromText([TotalCharges]) — handles blanks |
| Fact_Customers | Tenure Band | SWITCH on tenure ranges |
| Fact_Customers | Service Count | Count of Yes values across 6 service columns |
| Fact_Customers | Has Premium Services | if OnlineSecurity=Yes OR TechSupport=Yes then "Yes" else "No" |

---

## 5. Power Query Transformations

### Critical Transformation — TotalCharges
```
// TotalCharges is stored as text in source, some blanks exist
// Must convert to decimal — blanks become null

= Table.TransformColumnTypes(
    Source,
    {{"TotalCharges", type number}},
    "en-US"
  )

// Then replace nulls with 0 or MonthlyCharges × tenure
= Table.ReplaceValue(
    #"Changed Type",
    null,
    each [MonthlyCharges] * [tenure],
    Replacer.ReplaceValue,
    {"TotalCharges"}
  )
```

### Tenure Band Calculated Column
```
= Table.AddColumn(
    Source,
    "Tenure Band",
    each if [tenure] <= 12 then "0-12 Months"
         else if [tenure] <= 24 then "13-24 Months"
         else if [tenure] <= 36 then "25-36 Months"
         else if [tenure] <= 48 then "37-48 Months"
         else if [tenure] <= 60 then "49-60 Months"
         else "61+ Months"
  )
```

### Service Count Column
```
= Table.AddColumn(
    Source,
    "Service Count",
    each List.Count(
        List.Select(
            {[PhoneService], [MultipleLines], [OnlineSecurity],
             [OnlineBackup], [DeviceProtection], [TechSupport],
             [StreamingTV], [StreamingMovies]},
            each _ = "Yes"
        )
    )
  )
```

---

## 6. Relationships

| From | To | Cardinality | Direction | Active |
|------|----|-------------|-----------|--------|
| Fact_Customers[Contract Key] | Dim_Contract[Contract Key] | Many-to-One | Single | ✅ |
| Fact_Customers[Payment Key] | Dim_PaymentMethod[Payment Key] | Many-to-One | Single | ✅ |
| Fact_Customers[Internet Key] | Dim_InternetService[Internet Key] | Many-to-One | Single | ✅ |
| Fact_Customers[Tenure Band Key] | Dim_TenureBand[Tenure Band Key] | Many-to-One | Single | ✅ |

---

## 7. Model Optimisation

| Technique | Detail |
|-----------|--------|
| Import mode | Static 7K row dataset — no DirectQuery needed |
| Integer surrogate keys | Faster joins than text |
| Is Churned integer column | Enables SUM for churn count — faster than CALCULATE+FILTER |
| Remove unused columns | CustomerID hidden from report view after key created |
| Service columns simplified | "No internet service" → "No" in Power Query for cleaner visuals |

---

## 8. Model Validation Checklist

- [ ] Total customers = 7,043
- [ ] Total churned = 1,869 (26.5% churn rate)
- [ ] TotalCharges nulls handled — no blanks in model
- [ ] Tenure Band distribution covers all 7,043 customers
- [ ] Contract Key relationship shows correct cardinality
- [ ] Is Churned SUM = COUNTROWS where Churn = Yes
