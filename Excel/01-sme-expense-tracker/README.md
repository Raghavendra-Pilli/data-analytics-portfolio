# Excel-1: SME Expense Tracker & Monthly P&L Dashboard

> **Business question:** Where is the business spending money, is it tracking to budget this quarter, and which categories are over or under budget?

---

## Business scenario

A 50-person SME tracks expenses manually — collecting receipts from departments and totalling them each month. There is no automatic variance calculation, no category summary view, and no running P&L. The finance manager spends 3–4 hours per month on work that should take 15 minutes. This workbook replaces the manual process with a fully automated, formula-driven expense tracker and P&L dashboard.

---

## Stakeholder

**Business Owner / Finance Manager** — monthly financial review, budget management, department cost control.

---

## Dataset

| Field | Detail |
|---|---|
| Source | Self-generated — own work |
| Transactions | 120 expense records across 2024 |
| Categories | 9 expense categories |
| Departments | 6 departments |
| Period | January–December 2024 |

---

## Workbook structure

| Sheet | Purpose |
|---|---|
| Expense Data | Raw data entry — add new rows here |
| Monthly Summary | Auto-updating category × month matrix |
| KPI Dashboard | 8 headline KPIs + full category breakdown |
| Budget vs Actual | H1 P&L view side-by-side per month |
| Instructions | Step-by-step guide for non-technical users |

---

## Excel skills demonstrated

| Skill | Where |
|---|---|
| IF statement | Status column — Over/Under/On Budget |
| SUMIFS | Monthly summary, KPI dashboard, Budget vs Actual |
| COUNTIF | KPI — count over/under budget transactions |
| IFERROR | Variance % — prevents divide-by-zero |
| Cross-sheet formulas | All summary sheets reference Expense Data |
| Conditional formatting | Red/green status colour coding |
| Freeze panes | Headers stay visible while scrolling |
| Number formatting | Currency, percentage, thousands |
| Data validation | Category/department dropdown lists |
| Structured layout | Consistent section headers and colour coding |

---

## KPIs

| KPI | Formula logic |
|---|---|
| Total Budget | SUMIF all budget amounts |
| Total Actual | SUMIF all actual amounts |
| Total Variance | Total Actual − Total Budget |
| Variance % | Total Variance ÷ Total Budget |
| Over Budget Items | COUNTIF status = "Over Budget" |
| Under Budget Items | COUNTIF status = "Under Budget" |
| Total Transactions | COUNTA of all rows |
| Avg Transaction Value | Total Actual ÷ Total Transactions |

---

## How to use

1. Open `SME_Expense_Tracker.xlsx` in Excel
2. Go to Expense Data sheet
3. Add new rows below existing data — fill columns B to I only
4. All formulas and summaries update automatically

---

## Resume bullet points

- Built a 5-sheet Excel expense tracking workbook for a 50-person SME using SUMIFS, IF, IFERROR, and cross-sheet formulas to automate monthly variance reporting — eliminating 3–4 hours of manual monthly work
- Designed a KPI dashboard and Budget vs Actual P&L view that updates automatically as new expense rows are added, providing the finance manager with real-time category-level budget status across 9 cost categories and 6 departments
