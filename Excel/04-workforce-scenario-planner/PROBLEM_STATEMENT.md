# Excel Project 4 — Workforce Headcount & Cost Scenario Planner
### Problem Statement & Solution Narrative
**Tool:** Microsoft Excel (Power Pivot · DAX · What-If Analysis) | **Level:** Advanced / Interview-Focused

---

## The Situation

A 200-person technology company is preparing for its annual budget
cycle. The CFO, Priya, and the CHRO, James, need to answer one
critical question before presenting to the board:

> "What happens to our total people cost if we hire 10% more staff
>  in Q1? What if we freeze headcount completely? What if we grow
>  aggressively by 25%? And what does a 10% cost reduction look like?"

Currently, these scenarios are modelled by duplicating spreadsheets,
manually changing numbers, and emailing versions back and forth.
By the time the board presentation is ready, nobody is sure which
version of the numbers is correct.

The business needs a single workbook that:
1. Shows the current state of the workforce (headcount, cost, grade mix)
2. Lets the CFO change a few input cells and instantly see the
   financial impact of any hiring scenario
3. Compares multiple scenarios side by side in one view

---

## The Data We Have

201 employees across 10 departments, 4 divisions, and 7 grade levels:

- Departments: Engineering, Product, Data & Analytics, Sales,
  Marketing, Customer Success, Finance, HR, Legal, Operations
- Grade levels: Junior (L1) through VP (L7)
- For each employee: base salary, bonus, benefits, total cost,
  tenure, location, status (Active/Contractor/On Leave)
- Total current people cost: approximately £19.2M per year

---

## The Four Scenarios Modelled

**Scenario 1 — Freeze Headcount (Defensive)**
No new hires. Apply a 3% salary increase for retention.
Estimated cost: £17.9M — a reduction vs. current due to
natural attrition modelled out.

**Scenario 2 — Growth +10% (Moderate)**
Hire 20 additional staff at average market salary.
Apply 5% across-the-board salary increase.
Estimated cost: £19.8M — moderate increase.

**Scenario 3 — Rapid Growth +25% (Aggressive)**
Hire 50 additional staff. 5% salary increase.
Estimated cost: £22.8M — significant investment.

**Scenario 4 — Cost Reduction -10% (Defensive)**
Reduce headcount by 10% through natural attrition and
a hiring freeze. 0% salary increase.
Estimated cost: £16.1M — meaningful saving.

---

## How the Scenario Planner Works

### The input cells (yellow)

Six yellow cells drive the entire scenario:

1. **Headcount change %** — how much to grow or shrink the workforce
2. **Salary increase %** — the across-the-board pay rise
3. **Bonus change %** — adjustment to the bonus pool
4. **New hire avg salary** — what new starters cost on average
5. **Benefits rate %** — benefits as a percentage of base salary
6. **Scenario name** — a label for the current run

Change any of these and every output cell recalculates instantly.

### The output cells (blue/green/purple)

Scenario outputs are formula-driven — every number traces back to
the yellow input cells and the baseline from the Workforce Data sheet:

    Scenario Headcount  = Baseline HC × (1 + headcount_change%)
    New Hires           = MAX(0, Scenario HC − Baseline HC)
    Scenario Base Salary = Baseline Salary × (1 + salary_increase%)
                         + New Hires × new_hire_avg_salary
    Scenario Benefits   = Scenario Base Salary × benefits_rate%
    Scenario Total Cost = Salary + Bonus + Benefits

### The variance panel

Every scenario output shows:
- The absolute difference vs. baseline (£ delta)
- The percentage change vs. baseline

This gives the CFO both the magnitude and the direction of change
in a single glance.

### The preset comparison table

Four pre-calculated scenarios are hardcoded as a comparison
reference — showing all four strategies side by side so the
board can compare them in a single table without switching between
scenarios in the input panel.

---

## Excel Features Demonstrated

### What-if analysis
The yellow input cells form a mini parameter table. Every formula
in the output panel references these cells using absolute references
($H$5, $H$6 etc.). This is the foundation of scenario modelling in
Excel — parameterised formulas driven by a small number of
controllable inputs.

### Cross-sheet SUMIF / COUNTIF
Every baseline metric on the Scenario Planner pulls directly from
the Workforce Data sheet using SUMIF and COUNTIF with the headcount
flag as the filter. This ensures scenarios are always calculated
from live, accurate baseline data.

### MINIFS / MAXIFS for salary band analysis
The Level Analysis sheet uses MINIFS and MAXIFS to calculate the
lowest and highest salary within each grade level — functions
available in Excel 2019 and later that replace the older array
formula equivalents. These form the salary band reference that
a compensation review would use.

### Named ranges (manual step after download)
To make the scenario formulas more readable, the six yellow input
cells can be named (Name Box → type a name):
- H5 → HC_Change
- H6 → Salary_Increase
- H8 → New_Hire_Salary
etc.
This turns =B6*(1+H6) into =Baseline_Salary*(1+Salary_Increase)
— much more readable in a board presentation context.

---

## Sheet-by-Sheet Summary

**Sheet 1 — Workforce Data**
Raw employee table — 201 rows, 20 columns. Source of truth
for all calculations. The headcount_flag column (1 = active,
0 = excluded) allows filtering without deleting rows.

**Sheet 2 — Scenario Planner**
The centrepiece. Six yellow input cells, baseline metrics,
scenario outputs, variance panel, and a four-scenario
comparison table. One chart shows total cost by scenario.

**Sheet 3 — Headcount Dashboard**
Six KPI cards (total HC, total cost, avg salary, contractors,
avg tenure, remote workers). Department breakdown table with
headcount, salary, bonus, benefits, total cost, cost per head
and tenure. Two charts: headcount by dept and cost by dept.

**Sheet 4 — Level Analysis**
Grade-level breakdown from L1 Junior through L7 VP.
For each level: headcount, average salary, min salary,
max salary, total cost. Shows the salary band structure
that a compensation benchmarking exercise would reference.

---

## Key Insights

1. **Engineering is the largest cost centre** — accounting for
   approximately 35% of total people cost despite being 22% of
   headcount, driven by senior-skewed grade mix and market-rate
   salaries for engineering talent.

2. **The cost difference between Freeze and Rapid Growth is £4.9M**
   — this is the strategic range the board is choosing within.
   Framed this way, the headcount decision is really a £4.9M
   capital allocation decision, not a people management decision.

3. **Benefits loading at 18% adds approximately £3.5M to the
   total payroll cost** — changing the benefits rate assumption
   by 2 percentage points moves total cost by approximately
   £280k. This is visible immediately in the scenario output.

4. **New hire cost assumption matters significantly at +25% growth**
   — if new hire average salary is £65k rather than £55k, the
   total cost of the Rapid Growth scenario increases by over
   £500k. The scenario planner makes this sensitivity immediately
   visible by changing cell H8.

5. **L3 Senior and L4 Lead represent 45% of total headcount**
   — the largest grade cohort. Any salary increase policy that
   applies to these levels has an outsized P&L impact.

---

## Business Recommendations

1. **Present the Growth +10% scenario as the recommended path**
   — it delivers competitive capacity growth at a cost increase
   of approximately £636k vs. baseline, which is well within
   the business plan parameters. The Rapid Growth option
   requires board approval for the additional £3.5M investment.

2. **Lock in new hire salary benchmarks before approving headcount**
   — the scenario model shows that a £10k difference in average
   new hire salary moves total cost by £200k at +10% growth and
   £500k at +25% growth. Salary benchmarking should precede the
   headcount approval, not follow it.

3. **Use the Scenario Planner for monthly budget variance tracking**
   — the baseline formulas pull live from the Workforce Data sheet.
   Updating the employee table each month and running the same
   scenario inputs gives a rolling view of actual vs. planned
   people cost without rebuilding the model.

---

## How to Explain This in an Interview

**"What was the problem?"**
A 200-person company was preparing its annual budget and needed to
model four different hiring scenarios — but was doing it by copying
spreadsheets and manually changing numbers. By the time the board
presentation was ready, nobody trusted which version was correct.

**"What did you build?"**
A parameterised scenario planner with six yellow input cells that
drive 14 output metrics — headcount, salary, bonus, benefits, total
cost, and variance vs. baseline. Changing one number recalculates
everything instantly. Four preset scenarios are pre-calculated in
a comparison table so the board can see all options at once.

**"How does the what-if modelling work?"**
Every output formula references the yellow input cells using absolute
references. Scenario headcount equals baseline HC multiplied by
one plus the headcount change percentage. Scenario base salary equals
baseline salary multiplied by one plus the salary increase, plus
new hires multiplied by the new hire average salary assumption.
All six inputs are variable — everything else is derived.

**"What Excel skills did this demonstrate?"**
SUMIF and COUNTIF with a headcount flag filter for live baseline
calculations. MINIFS and MAXIFS for salary band analysis. Absolute
cell references for parameterised formula design. Cross-sheet
formulas linking the scenario planner to the source data. Named
ranges for formula readability. The what-if pattern itself — a
small number of controlled inputs driving a large number of outputs.

---

*Project by: [Your Name]*
*Dataset: Synthetic workforce data — own work (201 employees)*
*Tool: Microsoft Excel*
*Portfolio: github.com/[your-username]/data-analytics-portfolio*
