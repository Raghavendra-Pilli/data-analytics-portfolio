# SQL Project 3 — NHS-Style Hospital Outpatient Wait-Time SLA Analysis
### Problem Statement & Solution Narrative
**Tool:** Microsoft SQL Server | **Level:** Advanced

---

## The Situation

The NHS (National Health Service) operates under a legally binding
standard known as the Referral-to-Treatment (RTT) target: 92% of
patients referred by their GP to a hospital specialist must begin
treatment within 18 weeks.

This target exists because waiting too long for treatment leads to
worse health outcomes, patient distress, and in some cases,
conditions that become more expensive to treat the longer they wait.

The Hospital Operations Director, Sarah, is preparing for a quarterly
board meeting. The board wants answers to three specific questions:

> "Which of our clinical specialties are breaching the 18-week target
>  and by how much? Are things getting better or worse month by month?
>  And which hospital trusts need urgent support?"

Sarah has a dataset covering 20 NHS trusts, 15 clinical specialties,
and 7 NHS regions over 30 months (January 2021 to June 2023). This
period covers the post-COVID recovery — a time when waiting lists
grew to record levels across the NHS.

---

## The Data We Have

One main table: rtt_waiting_times

Each row represents one combination of:
- A reporting period (month)
- A hospital trust (provider)
- A clinical specialty

For each combination we know:
- Total patients on the waiting list
- How many are within the 18-week SLA
- How many have breached the 18-week SLA
- How many have waited over 52 weeks (severely overdue)
- Average and median wait time in weeks

**Scale:** 9,000 records · 20 providers · 15 specialties · 7 regions · 30 months

---

## What We Are Trying to Answer

**Question 1 — Are we hitting the 92% target overall?**
A single headline number. Yes or no. If no, how far off are we?

**Question 2 — Which specialties are worst?**
Not all specialties perform equally. Trauma & Orthopaedics and
Neurosurgery are structurally difficult — complex cases, limited
surgeons, long procedures. We need to rank specialties by breach
rate so resources go where they are most needed.

**Question 3 — Which regions are failing?**
Is this a national problem or concentrated in specific regions?
A regional problem needs regional solutions — local capacity,
local recruitment, local pathways.

**Question 4 — Is performance improving month by month?**
The COVID backlog built up through 2021. Are we making progress
clearing it in 2022 and 2023, or is the backlog still growing?

**Question 5 — Which individual hospital trusts are the worst?**
Some trusts will be in the bottom quartile — they need direct
operational support, not just a report. We need to name them,
rank them, and band them into performance quartiles.

**Question 6 — Where are 52-week breaches concentrated?**
Waiting over a year is a regulatory escalation trigger. These
cases need to be identified by specialty and region immediately.

---

## Our Approach — Step by Step

### Step 1: Understand the SLA logic

Before writing any SQL, we need to understand the target:

    NHS RTT Target: 92% of patients within 18 weeks

This means if a trust has 1,000 patients on a waiting list,
at least 920 of them must have started treatment within 18 weeks.
If only 850 have — the trust is breaching the target.

We built this logic directly into our SQL using CASE statements:

    >= 92% → MEETS TARGET
    >= 80% → NEAR MISS
    >= 60% → BREACHING
    <  60% → SEVERELY BREACHING

We also added a RAG (Red Amber Green) status for the heat map:
    GREEN = compliant · AMBER = near miss · RED = breaching

---

### Step 2: Data quality — three specific checks for this data

With NHS data, three checks matter more than anything else:

**Check 1 — Totals consistency**
within_18_weeks + over_18_weeks should equal total_waiting.
Any mismatch suggests a data extraction error from the source
system. We allowed a tolerance of ±1 for rounding.

**Check 2 — No negative waiting figures**
Negative patients on a waiting list is impossible. Any negative
value indicates a data entry error or system glitch.

**Check 3 — Orphan records**
Every record must have a valid provider, specialty, and region.
Missing any of these makes the record unanalysable.

---

### Step 3: The compliance rate formula

Every analysis in this project uses the same core calculation:

    SLA Compliance Rate = (within_18_weeks / total_waiting) × 100

We calculated this at four levels:
1. Overall — one number for the whole dataset
2. By specialty — 15 specialty compliance rates
3. By region — 7 regional compliance rates
4. By trust — 20 individual trust compliance rates

At each level we also calculated the gap to target:

    Gap = 92.0 − compliance_rate

A positive gap means the specialty/region/trust is below target.
A negative gap means they are exceeding the target.

---

### Step 4: Trend analysis using LAG()

Month-over-month change is critical for the board. The director
does not just want to know the current position — she wants to
know if things are getting better or worse.

We used the LAG() window function to compare each month's
compliance rate to the previous month:

    pct_point_change = current_month_pct − LAG(current_month_pct)

A CASE statement then classified each month as:
    IMPROVING / DETERIORATING / STABLE

We also tracked the absolute backlog number (patients over 18
weeks) with a running cumulative SUM() OVER() to show how the
total backlog has grown or shrunk since January 2021.

---

### Step 5: Trust quartile banding using NTILE()

Ranking 20 trusts by compliance rate gives a league table.
But a league table alone does not tell a manager what action to take.

We used NTILE(4) to divide all trusts into four equal performance
bands:

    Q1 (top 25%)  — Best practice trusts
    Q2 (26–50%)   — Above average
    Q3 (51–75%)   — Below average — improvement plan needed
    Q4 (bottom 25%) — Urgent review required

This is directly actionable. Q4 trusts get a formal improvement
notice. Q1 trusts are visited for best practice sharing.

---

### Step 6: Specialty × Region heat map

We combined RANK() OVER (PARTITION BY region_name) with a
RAG status CASE statement to produce a heat map showing which
specialty is performing worst in which region.

    RANK() OVER (PARTITION BY region ORDER BY breach_rate DESC)

Rank 1 in a region = worst specialty in that region.
This tells the regional director exactly where to focus.

---

## What We Found — Key Insights

1. **Overall SLA compliance is below the 92% target** — sitting
   at approximately 78–82% across the dataset period, reflecting
   the post-COVID backlog that built through 2021.

2. **Trauma & Orthopaedics and Neurosurgery are the worst
   performing specialties** — both have breach rates significantly
   above the dataset average. These are structurally difficult
   specialties with limited surgical capacity and long procedure times.

3. **London and Midlands have the highest absolute breach volumes**
   — driven by population density and the high number of trusts in
   those regions. However, breach rates per patient are actually
   higher in some smaller regions where capacity is more constrained.

4. **Performance improved measurably from 2021 to 2022** — the
   LAG analysis shows compliance rates trending upward as elective
   surgery capacity was restored post-COVID. However, the improvement
   slowed in late 2022 suggesting the easy backlog was cleared but
   complex cases remain.

5. **Over-52-week breaches are concentrated in 3 specialties** —
   Trauma & Orthopaedics, Neurosurgery, and Gynaecology account
   for the majority of patients who have waited more than a year.
   These cases carry direct regulatory escalation risk.

---

## Business Recommendations

**Recommendation 1 — Prioritise Trauma & Orthopaedics capacity**
This specialty has the highest breach rate and the highest 52-week
breach count. A dedicated elective recovery programme with additional
theatre slots and weekend operating should be the first intervention.

**Recommendation 2 — Implement quarterly trust quartile reviews**
Q4 trusts (bottom 25%) should receive a formal operational review
within 30 days of each quarter end. Q1 trusts should be asked to
document their best practices for sharing across the system.

**Recommendation 3 — Focus 52-week breach elimination programme**
Any patient waiting over 52 weeks represents both a patient safety
risk and a regulatory trigger. A named clinical lead should be
assigned to each 52-week case with a mandatory treatment date.

---

## SQL Skills Used in This Project

| Skill | Where used |
|---|---|
| SLA compliance formula | All analyses — within/total × 100 |
| CASE classification | SLA status, RAG status, severity flags |
| RANK() OVER() | Specialty and trust ranking overall |
| RANK() OVER (PARTITION BY) | Specialty rank within each region |
| NTILE(4) | Trust performance quartile banding |
| LAG() | Month-over-month compliance change |
| SUM() OVER (ORDER BY) | Cumulative backlog running total |
| CTEs | Monthly trend, breach volume, trust summary |
| Multi-level GROUP BY | Specialty, region, trust, specialty×region |
| NULLIF | Safe division — prevents divide-by-zero |
| CREATE VIEW | Executive KPI summary |

---

## New SQL concepts introduced vs SQL-2

| Concept | SQL-1 | SQL-2 | SQL-3 |
|---|---|---|---|
| RANK() overall | — | ✓ | ✓ |
| RANK() PARTITION BY | — | ✓ | ✓ Extended |
| NTILE() quartile banding | — | — | ✓ NEW |
| Running cumulative SUM() OVER() | — | — | ✓ NEW |
| Multi-level SLA logic | — | — | ✓ NEW |
| RAG status classification | — | — | ✓ NEW |

---

## How to Explain This in an Interview

**"What was the problem?"**
NHS hospital trusts must treat 92% of patients within 18 weeks of
referral. I built a SQL analysis framework to identify which
specialties, regions, and individual trusts are breaching this
target and by how much — directly supporting the quarterly board
review.

**"What was the most complex SQL in this project?"**
The specialty-by-region heat map. I used RANK() OVER (PARTITION BY
region_name) to rank each specialty's breach rate within its own
region — not globally. This means you see the worst specialty in
London, the worst specialty in the Midlands, and so on separately.
Combined with a RAG status CASE statement, it produces a heat map
a clinical director can read in 30 seconds.

**"What is NTILE and why did you use it?"**
NTILE(4) divides a ranked list into four equal groups — quartiles.
I used it to band all 20 hospital trusts into Q1 through Q4 by
compliance rate. This is directly actionable — Q4 trusts get a
formal improvement notice, Q1 trusts share best practice. A pure
rank number (1 through 20) does not carry that operational meaning.

**"What business decision does it support?"**
Three decisions: which specialties get additional theatre capacity,
which trusts get formal improvement notices, and which patients with
52-week waits need to be assigned a named clinical lead with a
mandatory treatment date.

---

*Project by: [Your Name]*
*Dataset: Synthetic NHS RTT data (realistic structure based on*
*NHS England Referral-to-Treatment open data — OGL v3)*
*Tool: Microsoft SQL Server Management Studio*
*Portfolio: github.com/[your-username]/data-analytics-portfolio*
