# Excel-4: Workforce Headcount & Cost Scenario Planner

> **Business question:** What happens to our total people cost under different hiring scenarios — and which strategy should we present to the board?

---

## Business scenario

A 200-person technology company needs to model four workforce scenarios before its annual board presentation — headcount freeze, moderate growth (+10%), rapid growth (+25%), and cost reduction (-10%). Currently scenarios are modelled by duplicating spreadsheets manually. This workbook replaces that process with a parameterised scenario planner — change six input cells, every output recalculates instantly.

---

## Stakeholder

**CFO / CHRO / Finance Business Partner** — annual budget cycle, board presentation, headcount approval decisions.

---

## Dataset

| Field | Detail |
|---|---|
| Source | Synthetic workforce data — own work |
| Employees | 201 active employees |
| Departments | 10 across 4 divisions |
| Grade levels | L1 Junior → L7 VP |
| Total cost | ~£19.2M annual people cost |
| Fields | 20 per employee: salary, bonus, benefits, tenure, location, status |

---

## Workbook structure

| Sheet | Purpose |
|---|---|
| Workforce Data | 201-employee source table — live baseline |
| Scenario Planner | 6 yellow inputs → 14 scenario outputs + 4-scenario comparison |
| Headcount Dashboard | 6 KPI cards + department breakdown + 2 charts |
| Level Analysis | Grade L1–L7 salary bands with MINIFS/MAXIFS |

---

## Excel skills demonstrated

| Skill | Where |
|---|---|
| What-if / scenario modelling | Scenario Planner — 6 inputs drive 14 outputs |
| Absolute cell references | All scenario formulas use $H$5 etc. |
| SUMIF / COUNTIF (multi-sheet) | Baseline metrics from Workforce Data |
| AVERAGEIF | Avg tenure, avg salary by department |
| MINIFS / MAXIFS | Salary band min/max by grade level |
| Cross-sheet formulas | Scenario Planner → Workforce Data |
| Variance calculations | Absolute £ delta + % change vs baseline |
| Named ranges (manual) | Rename yellow cells for formula readability |
| KPI card layout | 6 colour-coded cards with accent borders |
| Bar charts (2) | Headcount by dept, cost by dept |
| Scenario comparison table | 4 strategies side-by-side |
| Headcount flag filter | COUNTIF/SUMIF using column T (HC flag) |

---

## The four scenarios

| Scenario | HC Change | Cost | vs Baseline |
|---|---|---|---|
| Freeze Headcount | 0% | £17.9M | −£1.3M |
| Growth +10% | +10% | £19.8M | +£636k |
| Rapid Growth +25% | +25% | £22.8M | +£3.6M |
| Cost Reduction −10% | −10% | £16.1M | −£3.1M |

---

## How to use the scenario planner

1. Open **Scenario Planner** sheet
2. Change any yellow cell (B8–B10 column range):
   - **H5** — Headcount change % (e.g. 0.10 = +10%)
   - **H6** — Salary increase % (e.g. 0.05 = +5%)
   - **H7** — Bonus change %
   - **H8** — New hire average salary (£)
   - **H9** — Benefits rate %
   - **H10** — Scenario name (label)
3. All 14 output metrics and variance cells recalculate instantly
4. The summary bar at the bottom shows a one-line scenario description

---

## KPIs defined

| KPI | Formula logic |
|---|---|
| Scenario headcount | Baseline HC × (1 + HC_change%) |
| New hires | MAX(0, Scenario HC − Baseline HC) |
| Scenario base salary | Baseline salary × (1+salary_increase%) + New hires × avg_salary |
| Scenario benefits | Scenario salary × benefits_rate% |
| Scenario total cost | Salary + Bonus + Benefits |
| Cost delta | Scenario total − Baseline total |
| Cost delta % | Delta ÷ Baseline total |

---

## Interview questions

**Q: How does the scenario planner work technically?**
> Six yellow input cells use absolute references ($H$5 through $H$10). Every output formula references these cells directly. Scenario headcount = B5*(1+$H$5) where B5 is the baseline from a COUNTIF on the Workforce Data sheet. Changing one yellow cell cascades through all 14 output formulas instantly — no macros, no VBA, just well-structured formula dependencies.

**Q: Why MINIFS/MAXIFS instead of MIN/MAX with IF?**
> MINIFS and MAXIFS are available in Excel 2019+ and are cleaner than the legacy MIN(IF(condition, range)) array formula approach which requires Ctrl+Shift+Enter. They're also more readable and maintainable — important in a finance workbook that multiple people will use.

**Q: What would you add with more time?**
> A Monte Carlo sensitivity analysis using Excel's Data Table (What-If → Data Table) to show the range of possible total costs given uncertainty in new hire salary assumptions. Also a rolling 12-month cost trend connecting to monthly payroll exports so the baseline stays current without manual updates.

---

## Resume bullet points

- Designed a parameterised Excel workforce scenario planner for a 200-person company modelling four hiring strategies — connecting six yellow input cells to 14 scenario output metrics via absolute-reference SUMIF formulas, eliminating a manual spreadsheet-duplication process used by the CFO and CHRO
- Built a grade-level salary band analysis using MINIFS/MAXIFS across 7 levels (L1 Junior to L7 VP) and a department headcount dashboard with AVERAGEIF tenure analysis and two bar charts — providing the compensation benchmarking reference for the annual budget cycle
