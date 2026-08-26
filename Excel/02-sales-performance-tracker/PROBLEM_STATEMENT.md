# Excel Project 2 — Sales Team Performance Tracker
### Problem Statement & Solution Narrative
**Tool:** Microsoft Excel | **Level:** Intermediate

---

## The Situation

A B2B software company has 12 sales representatives spread across
four regions — North, South, East, and West. Each rep carries an
annual quota based on their segment: Enterprise (£1.2M), Mid-Market
(£800k), or SMB (£500k).

The Sales Director, James, runs a weekly pipeline meeting but has
no single view of how each rep is tracking against quota. He knows
who closed a deal last week, but not who is at 120% attainment vs.
who is at 60% and falling behind. By the time the monthly report
is manually compiled, the decisions are already overdue.

Three specific problems:

1. **No rep ranking** — James cannot see at a glance who the top
   and bottom performers are without manually sorting a spreadsheet
2. **No quota attainment tracking** — each deal is recorded but
   never compared against the rep's individual target
3. **No lookup tool** — when a manager asks "what is Anjali's win
   rate and current attainment?", it takes 5 minutes of filtering
   to find the answer

---

## The Data We Have

- **Sales Data sheet:** Every deal in 2024 — Deal ID, Rep, Region,
  Segment, Month, Product, Deal Value, Quota, Stage (Won/Lost),
  Days to Close, Lead Source. ~600+ rows.
- **Rep Lookup sheet:** Reference table — Rep ID, Name, Region,
  Segment, Annual Quota, Manager, Join Year

12 reps · 4 regions · 3 segments · 6 products · 12 months

---

## What We Built — Sheet by Sheet

### Sheet 1: Sales Data
The raw transaction log. Every deal recorded with Win/Loss flag.
This is the single source of truth all other sheets pull from.

### Sheet 2: Rep Lookup
A reference table mapping Rep IDs to their profile. This sheet
exists specifically to demonstrate INDEX/MATCH — all lookup
formulas in the workbook use it as the source.

### Sheet 3: Rep Performance Dashboard
The main output sheet. For each of the 12 reps:

- **Total Revenue** — SUMIFS filtering by Rep ID and Win flag
- **Annual Quota** — INDEX/MATCH pulling from the Rep Lookup table
- **Attainment %** — Revenue ÷ Quota
- **Rank** — RANK() function ranking all 12 reps by revenue
- **Deals Won / Lost** — COUNTIFS
- **Win Rate** — Won ÷ (Won + Lost)
- **Avg Deal Size** — Revenue ÷ Deals Won

A grand total row at the bottom shows portfolio-level metrics.

### Sheet 4: Region Summary
Revenue, quota, attainment, win rate and rank by region.
Shows which of the four regions is strongest and which needs
management attention. Uses SUMIFS and COUNTIFS filtered by region.

### Sheet 5: Monthly Trend
Month-by-month revenue vs. quota showing attainment percentage
and month-over-month growth for each month of 2024.
The MoM growth formula uses a simple prior-row reference with
IFERROR to handle the blank January comparison gracefully.

### Sheet 6: Rep Finder (Lookup Tool)
The most technically interesting sheet. A single yellow input
cell at the top accepts any Rep ID. All fields below update
automatically using INDEX/MATCH:

    Rep Name    → INDEX(Name column, MATCH(Rep ID, ID column, 0))
    Region      → same pattern
    Quota       → same pattern
    Revenue     → SUMIFS filtered by Rep ID and Win=1
    Win Rate    → COUNTIFS Won ÷ (Won + Lost)
    Attainment  → Revenue ÷ Quota from lookup

Change the Rep ID from R001 to R006 and the entire profile
updates instantly. This is the practical value of INDEX/MATCH
over VLOOKUP — it works with any column order and is not
limited to left-to-right lookups.

---

## New Excel Concepts vs EX-1

| Concept | EX-1 | EX-2 |
|---|---|---|
| SUMIFS | ✓ | ✓ Extended |
| COUNTIFS | ✓ | ✓ Extended |
| IF/IFERROR | ✓ | ✓ |
| INDEX/MATCH | — | ✓ NEW |
| RANK() | — | ✓ NEW |
| Cross-sheet lookup | Basic | ✓ Advanced |
| MoM growth formula | — | ✓ NEW |
| Dynamic rep profile | — | ✓ NEW |

---

## Key Insights

1. **Anjali Mehta (R006) and Sanjay Iyer (R012) are the top two
   performers** — both exceeding 120% quota attainment. Both are
   in Enterprise segment which carries the highest quota but also
   the highest deal values.

2. **Deepa Kumar (R011) and Kiran Desai (R007) are the bottom two**
   — both under 85% attainment. Both are in SMB and Mid-Market
   segments. The sales director should review whether territory
   sizing or lead quality is the root cause.

3. **North and West regions lead on revenue** — driven by the
   higher concentration of Enterprise reps in those regions.
   South lags despite having the same number of reps — a quota
   or territory allocation issue worth investigating.

4. **Win rate varies significantly across reps** — from ~65% for
   top performers to ~55% for bottom performers. The 10 percentage
   point gap in win rate, compounded across hundreds of deals,
   explains most of the revenue difference between top and bottom.

5. **Q4 revenue spikes** — October through December consistently
   shows higher closed revenue as reps push to hit annual targets.
   This is visible in the monthly trend sheet.

---

## Business Recommendations

1. **Pair bottom-quartile reps with top performers for deal coaching**
   — the win rate gap (65% vs 55%) suggests a skills and approach
   difference, not a pipeline volume problem. Structured shadowing
   of Anjali Mehta's deal approach would be the highest-ROI
   intervention for Deepa Kumar and Kiran Desai.

2. **Review South region territory and quota allocation** — South
   has the same headcount as other regions but consistently lower
   revenue. Either the territory is smaller, the leads are weaker,
   or the quota needs recalibrating to reflect market reality.

3. **Use the Rep Finder tool for weekly 1-1 meetings** — the Sales
   Director can open the Rep Finder, type the rep's ID before each
   meeting, and instantly see their attainment, win rate, and rank
   without any manual preparation.

---

## How to Explain This in an Interview

**"What was the problem?"**
A sales director had 12 reps across 4 regions with no way to see
quota attainment, deal win rates, or rep rankings without manually
filtering a spreadsheet. Decisions were always made on stale data.

**"What Excel features did you use?"**
INDEX/MATCH for the rep lookup tool — pulling rep profiles from
a reference table dynamically. SUMIFS and COUNTIFS for revenue
and deal counts filtered by multiple criteria simultaneously.
RANK() to automatically order all 12 reps by revenue with no
manual sorting. IFERROR throughout to handle edge cases cleanly.

**"Why INDEX/MATCH instead of VLOOKUP?"**
VLOOKUP only works when the lookup column is the leftmost column
in the range, and it breaks if columns are inserted. INDEX/MATCH
works with any column order, is more flexible, and is the industry
standard in professional financial models. In this workbook, the
Rep Finder uses INDEX/MATCH to pull data from a reference table
regardless of column position.

**"What did you find?"**
Two reps are at 120%+ attainment while two are below 85%.
The performance gap is driven primarily by win rate difference
— top performers close 10 percentage points more of their deals
than bottom performers. That gap, compounded across hundreds of
deals, explains most of the revenue difference.

---

*Project by: [Your Name]*
*Dataset: Synthetic B2B sales data — own work*
*Tool: Microsoft Excel*
*Portfolio: github.com/[your-username]/data-analytics-portfolio*
