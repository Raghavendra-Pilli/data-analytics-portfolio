# Excel-2: Sales Team Performance Tracker

> **Business question:** Who are the top-performing reps, which regions are falling behind quota, and what is each rep's win rate and attainment — instantly, without manual filtering?

---

## Business scenario

A B2B software company has 12 sales reps across 4 regions carrying annual quotas of £500k–£1.2M depending on segment. The Sales Director has no single view of rep attainment, win rates, or rankings. This workbook delivers a dynamic performance tracker with an interactive rep lookup tool — all updating automatically from raw deal data.

---

## Stakeholder

**Sales Director / VP Revenue** — weekly pipeline meetings, quarterly business reviews, rep coaching decisions.

---

## Dataset

| Field | Detail |
|---|---|
| Source | Synthetic B2B sales data — own work |
| Deals | ~600+ transactions across 2024 |
| Reps | 12 sales representatives |
| Regions | 4 (North, South, East, West) |
| Segments | Enterprise / Mid-Market / SMB |
| Products | 6 software products |

---

## Workbook structure

| Sheet | Purpose |
|---|---|
| Sales Data | Raw deal log — source of truth |
| Rep Lookup | Reference table for INDEX/MATCH |
| Rep Performance | Full rep ranking and KPIs |
| Region Summary | Revenue and attainment by region |
| Monthly Trend | MoM revenue vs quota |
| Rep Finder | Interactive lookup — type Rep ID, see full profile |

---

## Excel skills demonstrated

| Skill | Where |
|---|---|
| INDEX/MATCH | Rep Finder — dynamic profile lookup |
| SUMIFS (multi-criteria) | Revenue by rep, region, month |
| COUNTIFS (multi-criteria) | Deals won/lost by rep and region |
| RANK() | Rep ranking by revenue — auto-updates |
| IFERROR | All division formulas — clean error handling |
| MoM growth formula | Monthly Trend — prior row reference |
| Cross-sheet formulas | All summary sheets reference Sales Data |
| Dynamic input cell | Rep Finder — one cell drives 10 outputs |

---

## KPIs defined

| KPI | Formula logic |
|---|---|
| Total Revenue | SUMIFS by Rep ID + Win flag |
| Quota Attainment % | Revenue ÷ Annual Quota |
| Rep Rank | RANK() by revenue among all reps |
| Win Rate % | Deals Won ÷ (Won + Lost) |
| Avg Deal Size | Revenue ÷ Deals Won |
| MoM Growth % | (Current month − Prior month) ÷ Prior month |

---

## How to use the Rep Finder

1. Go to **Rep Finder** sheet
2. Change the yellow cell (B3) to any Rep ID (R001–R012)
3. All 10 profile fields update automatically
4. Use before every 1-1 meeting for instant rep profile

---

## Interview questions

**Q: Why INDEX/MATCH instead of VLOOKUP?**
> VLOOKUP requires the lookup column to be leftmost and breaks when columns are inserted. INDEX/MATCH works in any direction, with any column order, and is the standard in professional financial models. The Rep Finder uses INDEX/MATCH so the reference table columns can be reorganised without breaking any formulas.

**Q: How does the Rep Finder work?**
> One yellow input cell (B3) holds the Rep ID. Every field below uses INDEX(column, MATCH($B$3, ID column, 0)) to return that rep's value from the lookup table. Revenue and win rate use SUMIFS and COUNTIFS filtered by $B$3. Changing one cell drives ten outputs instantly.

---

## Resume bullet points

- Built a 6-sheet Excel sales performance tracker for a 12-rep B2B team using INDEX/MATCH, SUMIFS, COUNTIFS, and RANK() — delivering automatic quota attainment, win rate, and rep ranking without manual filtering or pivot table refresh
- Designed an interactive Rep Finder tool using a single dynamic input cell driving 10 profile outputs via INDEX/MATCH, enabling the Sales Director to pull any rep's full performance profile instantly before weekly 1-1 coaching meetings
