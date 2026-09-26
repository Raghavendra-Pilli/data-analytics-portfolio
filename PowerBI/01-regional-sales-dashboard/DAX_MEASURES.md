# DAX Measures — Regional Sales Performance Dashboard

## Document Control

| Item | Detail |
|------|--------|
| Version | 1.0 |
| Status | Draft |
| Author | Raghavendra Pilli |
| Last Updated | 2026 |

---

## 1. Measure Organisation

All measures stored in a dedicated measure table called `_Measures`.
This keeps the field list clean and measures easy to find.

**To create measure table in Power BI:**
1. Enter Data → create a blank table named `_Measures`
2. Delete the auto-generated column
3. Add all measures to this table

### Measure Groups

| Group | Prefix | Count |
|-------|--------|-------|
| Core Sales | [Core] | 5 |
| Profitability | [Prof] | 4 |
| Time Intelligence | [TI] | 10 |
| Orders & Customers | [OC] | 4 |
| Returns | [Ret] | 3 |
| Shipping | [Ship] | 2 |
| Ranking & Context | [Rank] | 4 |
| Expansion Scoring | [Exp] | 3 |

---

## 2. Core Sales Measures

### Total Revenue
```dax
Total Revenue =
SUM(Fact_Orders[Sales])
```
**Format:** $#,##0  
**Purpose:** Headline revenue metric used on all pages

---

### Total Profit
```dax
Total Profit =
SUM(Fact_Orders[Profit])
```
**Format:** $#,##0  
**Purpose:** Net profit after discounts and costs

---

### Total Quantity
```dax
Total Quantity =
SUM(Fact_Orders[Quantity])
```
**Format:** #,##0  
**Purpose:** Total units sold

---

### Total Shipping Cost
```dax
Total Shipping Cost =
SUM(Fact_Orders[Shipping Cost])
```
**Format:** $#,##0  
**Purpose:** Logistics cost tracking

---

### Avg Discount %
```dax
Avg Discount % =
AVERAGE(Fact_Orders[Discount])
```
**Format:** 0.0%  
**Purpose:** Average discount rate applied across orders  
**Note:** Returns blank when no rows in context

---

## 3. Profitability Measures

### Profit Margin %
```dax
Profit Margin % =
DIVIDE(
    [Total Profit],
    [Total Revenue],
    BLANK()
)
```
**Format:** 0.0%  
**Purpose:** Core profitability KPI  
**Edge case:** Returns BLANK() when Revenue = 0 to avoid division error

---

### Shipping Cost %
```dax
Shipping Cost % =
DIVIDE(
    [Total Shipping Cost],
    [Total Revenue],
    BLANK()
)
```
**Format:** 0.0%  
**Purpose:** Shipping cost as % of revenue — logistics efficiency

---

### Loss Orders
```dax
Loss Orders =
CALCULATE(
    DISTINCTCOUNT(Fact_Orders[Order ID]),
    Fact_Orders[Profit] < 0
)
```
**Format:** #,##0  
**Purpose:** Count of orders generating negative profit

---

### Loss Revenue %
```dax
Loss Revenue % =
DIVIDE(
    CALCULATE([Total Revenue], Fact_Orders[Profit] < 0),
    [Total Revenue],
    BLANK()
)
```
**Format:** 0.0%  
**Purpose:** % of revenue coming from loss-making orders

---

## 4. Time Intelligence Measures

### Revenue TY (This Year)
```dax
Revenue TY =
CALCULATE(
    [Total Revenue],
    DATESYTD(Dim_Date[Date])
)
```
**Format:** $#,##0  
**Purpose:** Year-to-date revenue for current year in filter context

---

### Revenue LY (Last Year)
```dax
Revenue LY =
CALCULATE(
    [Total Revenue],
    SAMEPERIODLASTYEAR(Dim_Date[Date])
)
```
**Format:** $#,##0  
**Purpose:** Revenue for same period last year

---

### Revenue YoY %
```dax
Revenue YoY % =
DIVIDE(
    [Total Revenue] - [Revenue LY],
    [Revenue LY],
    BLANK()
)
```
**Format:** +0.0%;-0.0%;0.0%  
**Purpose:** Year-over-year growth rate  
**Edge case:** Returns BLANK() when last year has no data

---

### Revenue YTD
```dax
Revenue YTD =
TOTALYTD(
    [Total Revenue],
    Dim_Date[Date]
)
```
**Format:** $#,##0  
**Purpose:** Cumulative revenue from Jan 1 to current date

---

### Profit LY
```dax
Profit LY =
CALCULATE(
    [Total Profit],
    SAMEPERIODLASTYEAR(Dim_Date[Date])
)
```
**Format:** $#,##0  
**Purpose:** Profit for same period last year

---

### Profit YoY %
```dax
Profit YoY % =
DIVIDE(
    [Total Profit] - [Profit LY],
    ABS([Profit LY]),
    BLANK()
)
```
**Format:** +0.0%;-0.0%;0.0%  
**Purpose:** YoY profit growth  
**Note:** Uses ABS() on denominator to handle negative LY profit correctly

---

### Profit YTD
```dax
Profit YTD =
TOTALYTD(
    [Total Profit],
    Dim_Date[Date]
)
```
**Format:** $#,##0  
**Purpose:** Cumulative profit from Jan 1 to current date

---

### Revenue MTD
```dax
Revenue MTD =
TOTALMTD(
    [Total Revenue],
    Dim_Date[Date]
)
```
**Format:** $#,##0  
**Purpose:** Month-to-date revenue

---

### Revenue QTD
```dax
Revenue QTD =
TOTALQTD(
    [Total Revenue],
    Dim_Date[Date]
)
```
**Format:** $#,##0  
**Purpose:** Quarter-to-date revenue

---

### Revenue Rolling 12M
```dax
Revenue Rolling 12M =
CALCULATE(
    [Total Revenue],
    DATESINPERIOD(
        Dim_Date[Date],
        LASTDATE(Dim_Date[Date]),
        -12,
        MONTH
    )
)
```
**Format:** $#,##0  
**Purpose:** Trailing 12-month revenue — smooths seasonality

---

## 5. Orders & Customers Measures

### Total Orders
```dax
Total Orders =
DISTINCTCOUNT(Fact_Orders[Order ID])
```
**Format:** #,##0  
**Purpose:** Unique order count (not line items)

---

### Avg Order Value
```dax
Avg Order Value =
DIVIDE(
    [Total Revenue],
    [Total Orders],
    BLANK()
)
```
**Format:** $#,##0.00  
**Purpose:** Average revenue per order

---

### Total Customers
```dax
Total Customers =
DISTINCTCOUNT(Fact_Orders[Customer ID])
```
**Format:** #,##0  
**Purpose:** Unique customer count in context

---

### Avg Orders Per Customer
```dax
Avg Orders Per Customer =
DIVIDE(
    [Total Orders],
    [Total Customers],
    BLANK()
)
```
**Format:** 0.00  
**Purpose:** Purchase frequency metric

---

## 6. Returns Measures

### Returned Orders
```dax
Returned Orders =
CALCULATE(
    DISTINCTCOUNT(Fact_Returns[Order ID]),
    Fact_Returns[Returned] = "Yes"
)
```
**Format:** #,##0  
**Purpose:** Count of returned orders

---

### Return Rate %
```dax
Return Rate % =
DIVIDE(
    [Returned Orders],
    [Total Orders],
    BLANK()
)
```
**Format:** 0.0%  
**Purpose:** % of orders returned — quality metric

---

### Return Revenue Impact
```dax
Return Revenue Impact =
CALCULATE(
    [Total Revenue],
    FILTER(
        Fact_Orders,
        RELATED(Fact_Returns[Returned]) = "Yes"
    )
)
```
**Format:** $#,##0  
**Purpose:** Revenue value of returned orders

---

## 7. Shipping Measures

### Avg Ship Days
```dax
Avg Ship Days =
AVERAGEX(
    Fact_Orders,
    DATEDIFF(
        RELATED(Dim_Date[Date]),
        Fact_Orders[Ship Date],
        DAY
    )
)
```
**Format:** 0.0  
**Purpose:** Average days from order to shipment  
**Note:** Uses USERELATIONSHIP not needed here — Ship Date stored in Fact

---

### On-Time Delivery %
```dax
On-Time Delivery % =
DIVIDE(
    CALCULATE(
        [Total Orders],
        Fact_Orders[Ship Days] <= 3
    ),
    [Total Orders],
    BLANK()
)
```
**Format:** 0.0%  
**Purpose:** % of orders shipped within 3 days  
**Prerequisite:** Requires Ship Days calculated column in Fact_Orders

---

## 8. Ranking & Context Measures

### Revenue Rank (Region)
```dax
Revenue Rank Region =
RANKX(
    ALL(Dim_Geography[Region]),
    [Total Revenue],
    ,
    DESC,
    DENSE
)
```
**Format:** #0  
**Purpose:** Rank current region by revenue — used in tooltips

---

### Revenue % of Total
```dax
Revenue % of Total =
DIVIDE(
    [Total Revenue],
    CALCULATE([Total Revenue], ALL(Dim_Geography)),
    BLANK()
)
```
**Format:** 0.0%  
**Purpose:** Each region's share of total revenue

---

### Profit Margin vs Avg
```dax
Profit Margin vs Avg =
[Profit Margin %] -
CALCULATE(
    [Profit Margin %],
    ALL(Dim_Geography[Region])
)
```
**Format:** +0.0%;-0.0%;0.0%  
**Purpose:** How this region's margin compares to overall average  
**Used in:** Conditional formatting — above/below average indicator

---

### Dynamic Title
```dax
Dynamic Title =
VAR SelectedRegion =
    SELECTEDVALUE(Dim_Geography[Region], "All Regions")
VAR SelectedYear =
    SELECTEDVALUE(Dim_Date[Year], "All Years")
RETURN
    "Sales Performance — " & SelectedRegion & " | " & SelectedYear
```
**Format:** Text  
**Purpose:** Card visual title that updates based on slicer selection

---

## 9. Expansion Scoring Measures

### Expansion Score
```dax
Expansion Score =
VAR GrowthScore =
    IF([Revenue YoY %] > 0.10, 1, 0)
VAR MarginScore =
    IF([Profit Margin %] > 0.15, 1, 0)
VAR VolumeScore =
    IF([Total Orders] > 500, 1, 0)
RETURN
    GrowthScore + MarginScore + VolumeScore
```
**Format:** #0  
**Purpose:** 0–3 score per market for expansion prioritisation

---

### Expansion Rating
```dax
Expansion Rating =
SWITCH(
    TRUE(),
    [Expansion Score] = 3, "🟢 Strong Expand",
    [Expansion Score] = 2, "🟡 Consider",
    [Expansion Score] = 1, "🟠 Monitor",
    "🔴 No Action"
)
```
**Format:** Text  
**Purpose:** Human-readable expansion recommendation

---

### Expansion Priority Rank
```dax
Expansion Priority Rank =
RANKX(
    ALL(Dim_Geography[Market]),
    [Expansion Score],
    ,
    DESC,
    DENSE
)
```
**Format:** #0  
**Purpose:** Rank markets by expansion score

---

## 10. Measure Dependencies Map

```
Total Revenue ──────────────────────────────────────────────┐
                                                             ├── Revenue YoY %
Revenue LY ─────────────────────────────────────────────────┘
                                                             
Total Revenue ──┬── Profit Margin %
Total Profit ───┘
                
Total Revenue ──┬── Avg Order Value
Total Orders ───┘
                
Total Orders ───┬── Return Rate %
Returned Orders ┘
                
Revenue YoY % ──┬── Expansion Score ──── Expansion Rating
Profit Margin % ┤                    └── Expansion Priority Rank
Total Orders ───┘
```

---

## 11. DAX Best Practices Applied

| Practice | Applied | Detail |
|----------|---------|--------|
| DIVIDE() instead of / | ✅ | All division uses DIVIDE() with BLANK() fallback |
| BLANK() not 0 for no data | ✅ | Avoids misleading zeros in visuals |
| VAR for readability | ✅ | Complex measures use VAR/RETURN pattern |
| ALL() for context removal | ✅ | Ranking and % of total measures |
| DISTINCTCOUNT for orders | ✅ | Avoids double-counting order line items |
| ABS() for negative denominators | ✅ | Profit YoY % handles negative LY profit |
| Measures in dedicated table | ✅ | All measures in _Measures table |
| No iterators where avoidable | ✅ | AVERAGEX used only where row context needed |

---

## 12. Measure Testing Checklist

- [ ] Total Revenue matches SUM in source Excel manually
- [ ] Total Orders matches DISTINCTCOUNT — not row count
- [ ] Revenue YoY % returns BLANK for earliest year (no LY data)
- [ ] Revenue YTD resets on January 1
- [ ] Profit Margin % returns BLANK when Revenue = 0
- [ ] Return Rate % matches manual count from Returns sheet
- [ ] Expansion Score correctly assigns 0–3 per market
- [ ] Dynamic Title updates when slicers change
- [ ] All measures display correct format in visuals
