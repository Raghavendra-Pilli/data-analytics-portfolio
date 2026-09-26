# Semantic Model Design — Regional Sales Performance Dashboard

## Document Control

| Item | Detail |
|------|--------|
| Version | 1.0 |
| Status | Draft |
| Author | Raghavendra Pilli |
| Last Updated | 2026 |

---

## 1. Model Overview

| Item | Decision | Reason |
|------|----------|--------|
| Model Type | Star Schema | Best for BI performance and DAX simplicity |
| Storage Mode | Import | Dataset is static (~10K rows), no DirectQuery needed |
| Date Table | Calculated (DAX) | Full time intelligence support |
| Relationships | Single direction | Avoids ambiguity, better performance |
| RLS | Not in scope | No user-based security required for this project |

---

## 2. Star Schema Diagram

```
                        Dim_Date
                            │
                            │ (Many-to-One)
                            │
Dim_ShipMode ──────── Fact_Orders ──────── Dim_Customer
                            │
                    ┌───────┴───────┐
                    │               │
              Dim_Product     Dim_Geography
                    
                    
Fact_Returns ──────── Fact_Orders
             (via Order ID)
```

---

## 3. Table Definitions

### 3.1 Fact_Orders (Fact Table)

**Source:** Orders sheet from Global Superstore dataset
**Grain:** One row per order line item (Order ID + Product ID)

| Column | Data Type | Description | Notes |
|--------|-----------|-------------|-------|
| Order Key | Integer | Surrogate key | Auto-generated in Power Query |
| Order ID | Text | Natural order key | e.g. CA-2014-152156 |
| Date Key | Integer | FK to Dim_Date | Format YYYYMMDD |
| Ship Date Key | Integer | FK to Dim_Date (ship) | Format YYYYMMDD |
| Customer Key | Integer | FK to Dim_Customer | Surrogate key |
| Product Key | Integer | FK to Dim_Product | Surrogate key |
| Geography Key | Integer | FK to Dim_Geography | Surrogate key |
| Ship Mode Key | Integer | FK to Dim_ShipMode | Surrogate key |
| Sales | Decimal | Order line revenue | USD |
| Quantity | Integer | Units ordered | |
| Discount | Decimal | Discount rate applied | 0.0 to 1.0 |
| Profit | Decimal | Order line profit | USD, can be negative |
| Shipping Cost | Decimal | Shipping cost | USD |

**Columns removed in Power Query (not needed in model):**
- Customer Name (in Dim_Customer)
- Customer Segment (in Dim_Customer)
- Country/City/State/Region/Market (in Dim_Geography)
- Category/Sub-Category/Product Name (in Dim_Product)
- Ship Mode (in Dim_ShipMode)
- Order Date (replaced by Date Key)

---

### 3.2 Dim_Customer (Dimension Table)

**Source:** Derived from Orders sheet (distinct customers)
**Grain:** One row per unique Customer ID

| Column | Data Type | Description |
|--------|-----------|-------------|
| Customer Key | Integer | Surrogate key (PK) |
| Customer ID | Text | Natural key |
| Customer Name | Text | Full name |
| Segment | Text | Consumer / Corporate / Home Office |

---

### 3.3 Dim_Product (Dimension Table)

**Source:** Derived from Orders sheet (distinct products)
**Grain:** One row per unique Product ID

| Column | Data Type | Description |
|--------|-----------|-------------|
| Product Key | Integer | Surrogate key (PK) |
| Product ID | Text | Natural key |
| Product Name | Text | Full product name |
| Category | Text | Furniture / Office Supplies / Technology |
| Sub-Category | Text | e.g. Chairs, Phones, Binders |

---

### 3.4 Dim_Geography (Dimension Table)

**Source:** Derived from Orders sheet (distinct location combinations)
**Grain:** One row per unique Country + State + City + Region + Market combination

| Column | Data Type | Description |
|--------|-----------|-------------|
| Geography Key | Integer | Surrogate key (PK) |
| Market | Text | US / EU / APAC / LATAM / Africa / EMEA / Canada |
| Region | Text | Central / East / West / South / etc. |
| Country | Text | Country name |
| State | Text | State or province |
| City | Text | City name |

---

### 3.5 Dim_Date (Dimension Table)

**Source:** DAX calculated table — generated programmatically
**Grain:** One row per calendar date (2011-01-01 to 2014-12-31)

| Column | Data Type | Description |
|--------|-----------|-------------|
| Date | Date | Full date (PK) |
| Date Key | Integer | YYYYMMDD format |
| Year | Integer | Calendar year |
| Quarter | Integer | 1–4 |
| Quarter Label | Text | Q1 / Q2 / Q3 / Q4 |
| Month Number | Integer | 1–12 |
| Month Name | Text | January–December |
| Month Short | Text | Jan–Dec |
| Week Number | Integer | ISO week number |
| Day of Week | Integer | 1 (Mon) – 7 (Sun) |
| Day Name | Text | Monday–Sunday |
| Year-Month | Text | 2014-Jan (for sorting) |
| Year-Quarter | Text | 2014-Q1 |
| Is Weekend | Boolean | TRUE if Sat/Sun |
| Is Last Day of Month | Boolean | TRUE if last day |

**DAX to generate Dim_Date:**
```dax
Dim_Date =
VAR MinDate = MIN(Fact_Orders[Order Date])
VAR MaxDate = MAX(Fact_Orders[Order Date])
RETURN
ADDCOLUMNS(
    CALENDAR(MinDate, MaxDate),
    "Date Key",        VALUE(FORMAT([Date], "YYYYMMDD")),
    "Year",            YEAR([Date]),
    "Quarter",         QUARTER([Date]),
    "Quarter Label",   "Q" & QUARTER([Date]),
    "Month Number",    MONTH([Date]),
    "Month Name",      FORMAT([Date], "MMMM"),
    "Month Short",     FORMAT([Date], "MMM"),
    "Week Number",     WEEKNUM([Date], 2),
    "Day of Week",     WEEKDAY([Date], 2),
    "Day Name",        FORMAT([Date], "DDDD"),
    "Year-Month",      FORMAT([Date], "YYYY-MMM"),
    "Year-Quarter",    FORMAT([Date], "YYYY") & "-Q" & QUARTER([Date]),
    "Is Weekend",      WEEKDAY([Date], 2) >= 6,
    "Is Last Day",     [Date] = EOMONTH([Date], 0)
)
```

---

### 3.6 Dim_ShipMode (Dimension Table)

**Source:** Derived from Orders sheet (distinct ship modes)
**Grain:** One row per shipping mode

| Column | Data Type | Description |
|--------|-----------|-------------|
| Ship Mode Key | Integer | Surrogate key (PK) |
| Ship Mode | Text | First Class / Second Class / Standard Class / Same Day |

---

### 3.7 Fact_Returns (Fact Table)

**Source:** Returns sheet from Global Superstore dataset
**Grain:** One row per returned order

| Column | Data Type | Description |
|--------|-----------|-------------|
| Order ID | Text | FK to Fact_Orders[Order ID] |
| Returned | Text | "Yes" (all rows) |
| Is Returned | Integer | 1 (calculated column for aggregation) |

---

## 4. Relationships

| # | From Table | From Column | To Table | To Column | Cardinality | Direction | Active |
|---|-----------|-------------|----------|-----------|-------------|-----------|--------|
| 1 | Fact_Orders | Date Key | Dim_Date | Date Key | Many-to-One | Single → | ✅ Yes |
| 2 | Fact_Orders | Ship Date Key | Dim_Date | Date Key | Many-to-One | Single → | ❌ No (inactive) |
| 3 | Fact_Orders | Customer Key | Dim_Customer | Customer Key | Many-to-One | Single → | ✅ Yes |
| 4 | Fact_Orders | Product Key | Dim_Product | Product Key | Many-to-One | Single → | ✅ Yes |
| 5 | Fact_Orders | Geography Key | Dim_Geography | Geography Key | Many-to-One | Single → | ✅ Yes |
| 6 | Fact_Orders | Ship Mode Key | Dim_ShipMode | Ship Mode Key | Many-to-One | Single → | ✅ Yes |
| 7 | Fact_Returns | Order ID | Fact_Orders | Order ID | Many-to-One | Single → | ✅ Yes |

**Note on Relationship 2 (Ship Date):**
Inactive by default. Use USERELATIONSHIP() in DAX when calculating
shipping lead time or ship-date-based measures.

---

## 5. Power Query Transformations

### 5.1 Orders Table → Fact_Orders

```
Step 1: Remove unnecessary columns
  → Keep: Order ID, Order Date, Ship Date, Ship Mode, Customer ID,
           Product ID, Sales, Quantity, Discount, Profit, Shipping Cost,
           Country, State, City, Region, Market, Segment,
           Customer Name, Category, Sub-Category, Product Name

Step 2: Change data types
  → Order Date: Date
  → Ship Date: Date
  → Sales: Decimal Number
  → Profit: Decimal Number
  → Discount: Decimal Number
  → Shipping Cost: Decimal Number
  → Quantity: Whole Number

Step 3: Add Date Key column
  → Date Key = Date.Year([Order Date])*10000
              + Date.Month([Order Date])*100
              + Date.Day([Order Date])

Step 4: Add Ship Date Key column
  → Same formula using [Ship Date]

Step 5: Add surrogate keys (merge with dimension queries)
  → Customer Key: merge with Dim_Customer on Customer ID
  → Product Key: merge with Dim_Product on Product ID
  → Geography Key: merge with Dim_Geography on Country+State+City
  → Ship Mode Key: merge with Dim_ShipMode on Ship Mode

Step 6: Remove source columns after key merges
  → Remove: Customer ID, Product ID, Country, State, City,
             Region, Market, Segment, Customer Name,
             Category, Sub-Category, Product Name, Ship Mode
```

### 5.2 Dim_Customer

```
Step 1: Reference Orders query
Step 2: Select columns: Customer ID, Customer Name, Segment
Step 3: Remove duplicates on Customer ID
Step 4: Add index column → Customer Key (starting from 1)
Step 5: Reorder: Customer Key first
```

### 5.3 Dim_Product

```
Step 1: Reference Orders query
Step 2: Select columns: Product ID, Product Name, Category, Sub-Category
Step 3: Remove duplicates on Product ID
Step 4: Add index column → Product Key (starting from 1)
Step 5: Reorder: Product Key first
```

### 5.4 Dim_Geography

```
Step 1: Reference Orders query
Step 2: Select columns: Country, State, City, Region, Market
Step 3: Remove duplicates on all 5 columns combined
Step 4: Add index column → Geography Key (starting from 1)
Step 5: Reorder: Geography Key first
```

### 5.5 Dim_ShipMode

```
Step 1: Reference Orders query
Step 2: Select column: Ship Mode
Step 3: Remove duplicates
Step 4: Add index column → Ship Mode Key (starting from 1)
Step 5: Reorder: Ship Mode Key first
```

### 5.6 Fact_Returns

```
Step 1: Load Returns sheet
Step 2: Add calculated column: Is Returned = 1
Step 3: Keep columns: Order ID, Returned, Is Returned
```

---

## 6. Calculated Columns

| Table | Column | DAX | Purpose |
|-------|--------|-----|---------|
| Fact_Orders | Profit Flag | IF([Profit] < 0, "Loss", "Profit") | Loss flagging |
| Fact_Orders | Discount Band | SWITCH(TRUE(), [Discount]=0, "No Discount", [Discount]<=0.2, "Low", [Discount]<=0.4, "Medium", "High") | Discount grouping |
| Dim_Geography | Region-Market | [Region] & " - " & [Market] | Concatenated label |
| Dim_Date | Year-Month Sort | [Year]*100 + [Month Number] | Correct sort order |

---

## 7. Model Optimisation

| Technique | Applied To | Detail |
|-----------|-----------|--------|
| Remove unused columns | All tables | Done in Power Query before load |
| Import mode | All tables | Static dataset, no DirectQuery |
| Integer surrogate keys | All relationships | Faster join than text keys |
| Single-direction relationships | All | Avoids ambiguity and circular dependencies |
| Date table marked official | Dim_Date | Required for time intelligence functions |
| Summarisation set to None | Key columns | Prevent implicit measures |
| Hide FK columns from report view | Fact_Orders | Cleaner field list for report authors |

---

## 8. Model Validation Checklist

- [ ] All relationships show correct cardinality in Model view
- [ ] Dim_Date marked as Date Table on Date column
- [ ] No circular relationships
- [ ] Inactive Ship Date relationship confirmed inactive
- [ ] All fact table FK columns hidden from report view
- [ ] Surrogate keys set to "Don't summarise"
- [ ] Row counts match source after transformations
- [ ] Returns joined correctly — verify DISTINCTCOUNT(Order ID) matches Returns sheet
