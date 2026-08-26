# Excel Project 1 — SME Expense Tracker & Monthly P&L Dashboard
### Problem Statement & Solution Narrative
**Tool:** Microsoft Excel | **Level:** Beginner / Foundational

---

## The Situation

A 50-person SME (small-to-medium enterprise) has been operating for
three years. The finance manager, Priya, tracks expenses by collecting
receipts and invoices from department heads every month and manually
adding them up in a plain spreadsheet. By the time she has totalled
everything, the month is almost over and the numbers are already stale.

The business owner's question at every monthly meeting is always the same:

> "Are we over or under budget this month — and which departments
>  are spending the most?"

Currently, answering this question takes Priya 3–4 hours of manual
work every month. There is no automatic variance calculation, no
category summary, and no running P&L view.

---

## The Data We Have

One year of expense data (2024) — 120 transactions across:
- 9 expense categories (Salaries, Rent, IT, Marketing etc.)
- 6 departments (Operations, Sales, Finance, HR, IT, Marketing)
- 12 months (January to December 2024)

Each transaction has:
- Date, month, quarter
- Category and department
- A budgeted amount and actual amount
- Automatically calculated: variance, variance %, status

---

## What This Workbook Does

**Sheet 1 — Expense Data:**
The raw data entry sheet. Priya adds new rows as expenses come in.
Columns J, K, and L calculate automatically:
- Variance = Actual − Budget
- Variance % = Variance ÷ Budget
- Status = "Over Budget" / "Under Budget" / "On Budget"

**Sheet 2 — Monthly Summary:**
A category × month matrix showing actual spend per category per month.
Uses SUMIFS to pull directly from the raw data — updates automatically
when new rows are added. No manual totalling needed.

**Sheet 3 — KPI Dashboard:**
Eight headline KPIs at the top — total budget, total actual, total
variance, variance %, over budget count, under budget count, total
transactions, average transaction value.

Below the KPIs, a full category breakdown showing Budget vs Actual
vs Variance with an automatic status flag (Over / Under / On Budget)
for every category.

**Sheet 4 — Budget vs Actual (P&L view):**
A side-by-side Budget and Actual view for H1 (January to June)
showing each category across months — the classic P&L layout a
finance director or business owner expects.

---

## Excel Skills Demonstrated

| Skill | Where used |
|---|---|
| Structured Tables | Expense Data sheet — sortable, filterable |
| IF / IFS | Status column — Over / Under / On Budget |
| SUMIFS | Monthly Summary, KPI Dashboard, Budget vs Actual |
| COUNTIF | KPI — count of over/under budget transactions |
| IFERROR | Variance % — prevents divide-by-zero errors |
| Conditional formatting | Status cells — red/green colour coding |
| Freeze panes | Headers stay visible while scrolling |
| Cross-sheet formulas | All summary sheets pull from Expense Data |
| Number formatting | Currency, percentage, thousands separator |
| Data validation | Category and department dropdowns |

---

## How to Use This Workbook

1. Open `SME_Expense_Tracker.xlsx` in Excel
2. Go to **Expense Data** sheet
3. Add new expense rows below the existing data (columns B–I)
4. Columns J, K, L calculate automatically — do not edit them
5. All other sheets update automatically — no manual refresh needed

---

## Key Insights (from the 2024 sample data)

1. **Salaries are the dominant expense category** — accounting for
   approximately 45–50% of total spend, as expected for a 50-person
   business. Any budget pressure on people costs has an outsized
   impact on the overall P&L.

2. **Marketing consistently runs over budget** — the highest overrun
   rate by category. Digital advertising spend in particular tends to
   exceed planned amounts due to campaign optimisation mid-month.

3. **Office Supplies and Miscellaneous are consistently under budget**
   — these categories could have their budgets reduced to reflect
   actual usage patterns without operational impact.

4. **Q4 (Oct–Dec) shows higher total spend than Q1–Q3** — driven by
   year-end bonuses, increased travel for client meetings, and
   December event costs. Budget planning should allocate 10–15% more
   to Q4.

---

## Business Recommendations

1. **Reduce Office Supplies and Miscellaneous budgets by 15%** —
   these categories have been consistently under budget all year.
   Reallocating this budget to Marketing (which consistently overruns)
   would improve budget accuracy without cutting any actual spending.

2. **Set up a monthly 15-minute finance review using the KPI Dashboard**
   — the eight KPI cards give the business owner an instant read on
   financial health without needing to open the raw data.

3. **Add a Q4 budget uplift of 10–15% for Salaries and Travel** —
   the monthly P&L view clearly shows Q4 is structurally higher spend.
   Building this into the annual budget would eliminate the predictable
   year-end overspend.

---

## How to Explain This in an Interview

**"What was the problem?"**
A 50-person SME was spending 3–4 hours per month manually totalling
expenses with no automatic variance calculation and no way to see
which categories were over or under budget until the month was over.

**"What did you build?"**
A five-sheet Excel workbook with a raw data entry sheet, an automatic
monthly summary using SUMIFS, a KPI dashboard with eight headline
metrics, and a Budget vs Actual P&L view — all updating automatically
when new expense rows are added.

**"What Excel features did you use?"**
SUMIFS for cross-sheet aggregation, IFERROR to handle divide-by-zero
on variance percentages, IF for the automatic status flag, conditional
formatting for visual traffic-light coding, and freeze panes so
headers stay visible on the long data sheet.

**"What did you find?"**
Marketing consistently overruns while Office Supplies consistently
underspends. Q4 is structurally 10–15% higher than other quarters.
These patterns were invisible in the old manual approach because the
numbers arrived too late to act on.

---

*Project by: [Your Name]*
*Dataset: Synthetic SME expense data — own work*
*Tool: Microsoft Excel*
*Portfolio: github.com/[your-username]/data-analytics-portfolio*
