# SQL Project 4 — Procurement Spend Analysis: Vendor Performance & Contract Risk
### Problem Statement & Solution Narrative
**Tool:** Microsoft SQL Server | **Level:** Advanced / Interview-Focused

---

## The Situation

A mid-sized organisation spends approximately £15–20 million per year
across 20 vendors and 8 internal departments — covering IT services,
consulting, construction, logistics, facilities, and more.

The Chief Procurement Officer (CPO), Michael, has identified three
persistent problems in the annual procurement review:

1. Some vendors consistently deliver over budget. The organisation
   keeps renewing their contracts anyway because switching feels risky.

2. Some vendors are habitually late on delivery. No one has formally
   tracked this across contracts — it only becomes visible when a
   project director complains.

3. The organisation has no formal vendor risk register. Decisions
   about which vendors to renew, which to challenge, and which to
   replace are made on gut feel rather than data.

The Finance Director has added a fourth concern:

4. "I suspect we're dangerously concentrated — a handful of vendors
   represent most of our spend. If one of them fails, we have a
   serious continuity problem."

The question Michael needs answered before the next vendor review meeting:

> "Show me, using our contract data, which vendors are genuinely
>  risky, which ones are reliable, and where our spend concentration
>  puts us at risk."

---

## The Data We Have

One table: procurement_contracts

406 contracts across 4 years (2020–2023)
20 vendors across 8 categories
8 internal departments

For each contract we know:
- The vendor, category, and department
- Planned and actual contract dates
- Budget and actual spend
- Whether it overran cost and/or was delivered late
- A pre-calculated risk score (overrun + late + variance magnitude)

---

## What We Are Trying to Answer

**Question 1 — Where is the money going?**
Which vendors receive the most spend, and what percentage of total
procurement spend is concentrated in the top 3–5 vendors?

**Question 2 — Who consistently overruns cost?**
Which vendors have the highest overrun rates? What is their average
cost overrun percentage across all contracts?

**Question 3 — Who is habitually late?**
Which vendors miss delivery dates most often? What is their average
delay in days?

**Question 4 — Is our spend concentration dangerous?**
Do the top 3 vendors represent more than 50% of total spend?
If yes, that is a single point of failure risk.

**Question 5 — How has spend per vendor changed year over year?**
Are we spending more or less with each vendor each year? Growing
spend with a high-risk vendor is a red flag.

**Question 6 — Which vendors are back-to-back renewing?**
Are any vendors being renewed without a meaningful break — suggesting
dependency rather than competitive procurement?

**Question 7 — What is the composite risk tier of every vendor?**
Combine cost overrun rate, late delivery rate, average variance,
and total spend into a single Risk Exposure Index that drives the
vendor review schedule.

---

## Our Approach — Step by Step

### Step 1: Build a composite risk score

Before any analysis, we added a risk_score column during data
preparation. This is not just one metric — it combines four signals:

    risk_score =
        (is_overrun × 40)           ← cost overrun is weighted highest
      + (is_late    × 30)           ← late delivery second
      + (cost_variance_pct band × 0–20) ← severity of overrun
      + (delay_days band × 0–10)    ← severity of lateness

A vendor that is both over budget AND late on most contracts will
have a high risk score. A vendor that delivers under budget and
on time will score near zero.

---

### Step 2: Pareto analysis — the 80/20 rule applied to spend

We used a running cumulative SUM() OVER() to identify which vendors
together account for 80% of total spend. This is the Pareto principle
applied to procurement — typically 20% of vendors account for 80%
of spend.

The SQL implementation:

    SUM(total_spend) OVER (
        ORDER BY total_spend DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) * 100.0 / SUM(total_spend) OVER ()

The cumulative percentage column shows exactly at which vendor you
cross the 80% threshold. Everything above that line is "Pareto
critical" — these vendors need the most active management.

---

### Step 3: YoY spend trend using LAG() with PARTITION BY

For the year-over-year analysis we partitioned by vendor before
applying LAG(). This is different from the SQL-3 LAG() usage where
we partitioned by nothing (one time series).

Here each vendor has its own independent time series:

    LAG(annual_spend) OVER (
        PARTITION BY vendor_code
        ORDER BY contract_year
    )

This gives us the previous year's spend for THAT specific vendor —
not the previous year overall. The result shows us which vendors
are growing in spend and whether that growth is correlated with
high risk scores.

---

### Step 4: LEAD() for contract renewal pattern detection

We used LEAD() — the forward-looking equivalent of LAG() — to see
what date the NEXT contract with the same vendor started:

    LEAD(contract_start) OVER (
        PARTITION BY vendor_code
        ORDER BY contract_start
    )

By calculating the gap between one contract's actual_end and the
next contract's start date, we can identify back-to-back renewals.
A gap of 7 days or less between contracts suggests the organisation
is dependent on this vendor and is not running a competitive
procurement process.

---

### Step 5: Risk Exposure Index — combining risk and spend

A vendor can be high risk but low spend — that's manageable.
A vendor can be high spend but low risk — that's fine.
The most dangerous vendor is HIGH RISK + HIGH SPEND.

We created a Risk Exposure Index:

    Risk Exposure Index = total_spend × avg_risk_score

This single number captures both dimensions. We then used NTILE(3)
to band all vendors into three tiers:
- CRITICAL: quarterly executive review
- ELEVATED: bi-annual review
- STANDARD: annual review

This directly drives the vendor review calendar. The CPO knows
exactly when to review each vendor and why.

---

## What We Found — Key Insights

1. **Spend is concentrated in approximately 4–5 vendors** who
   together account for over 70% of total procurement spend.
   This represents a significant concentration risk — a failure
   or dispute with any one of these vendors would have immediate
   operational impact.

2. **Three vendors have overrun rates above 50%** — meaning more
   than half of their contracts cost more than budgeted. Despite
   this, the organisation has continued to renew contracts with
   all three. The data now provides the evidence to challenge
   this pattern formally.

3. **IT Services vendors have the highest average late delivery
   rate** — driven by scope changes and dependency on third-party
   integrations. Fixed-price contracts with milestone-based payment
   would reduce this risk.

4. **Two vendors show back-to-back renewal patterns** with gaps
   of less than 7 days between contracts — indicating vendor
   dependency rather than competitive procurement. These should
   be subject to mandatory market testing at the next renewal.

5. **The Risk Exposure Index reveals a clear Tier 1 group** of
   3–4 vendors that combine high spend with above-average risk
   scores. These vendors should move to quarterly executive review
   immediately.

---

## Business Recommendations

**Recommendation 1 — Introduce penalty clauses for the top 3 overrunners**
The three vendors with overrun rates above 50% should have cost-control
clauses added at the next contract renewal — including capped time and
materials rates and a milestone-based payment schedule that withholds
final payment until delivery is confirmed.

**Recommendation 2 — Run competitive procurement for back-to-back vendors**
Any vendor with a gap of less than 30 days between contract end and
renewal start should be subject to a mandatory 3-quote competitive
process before the next contract is signed. This breaks the dependency
pattern and restores market discipline.

**Recommendation 3 — Implement the vendor risk register as a live process**
The Risk Exposure Index and NTILE tier output should be refreshed
quarterly and presented to the CPO and Finance Director. Tier 1
vendors enter a formal quarterly review. Tier 3 vendors are reviewed
annually. This replaces gut-feel vendor management with a structured,
data-driven process.

---

## SQL Skills Used in This Project

| Skill | Where used |
|---|---|
| RANK() | Spend ranking, overrun ranking, delivery ranking |
| PERCENT_RANK() | Spend percentile per vendor |
| ROW_NUMBER() | Contract sequence per vendor |
| LAG() PARTITION BY vendor | YoY spend change per vendor |
| LEAD() PARTITION BY vendor | Days between consecutive contracts |
| SUM() OVER() running total | Pareto cumulative spend % |
| NTILE(3) | Vendor risk tier banding |
| Composite risk score | Weighted formula in UPDATE |
| CTEs (multiple) | Vendor totals, risk register, Pareto ranked |
| NULLIF | Safe division throughout |
| CASE multi-level | Risk flags, delivery flags, budget status |
| CREATE VIEW | Executive KPI summary |

---

## Complete Window Function Reference — all 4 SQL projects combined

| Function | SQL-1 | SQL-2 | SQL-3 | SQL-4 |
|---|---|---|---|---|
| SUM() OVER() | ✓ | ✓ | ✓ cumulative | ✓ Pareto running total |
| LAG() | ✓ YoY | ✓ MoM | ✓ MoM SLA | ✓ YoY PARTITION BY vendor |
| LEAD() | — | — | — | ✓ NEW next contract date |
| RANK() | — | ✓ | ✓ | ✓ multiple |
| RANK() PARTITION BY | — | ✓ | ✓ region | — |
| ROW_NUMBER() | — | — | — | ✓ NEW contract sequence |
| NTILE() | — | — | ✓ 4 | ✓ 3 |
| PERCENT_RANK() | — | — | — | ✓ NEW |

---

## How to Explain This in an Interview

**"What was the problem?"**
The organisation had no formal way to identify which vendors were
high-risk and no evidence base to challenge poor performers at
contract renewal. Everything was managed on gut feel. I built a
SQL-based vendor risk framework that combines cost overrun rate,
late delivery rate, and total spend into a Risk Exposure Index —
with NTILE banding that drives the vendor review schedule directly.

**"What is LEAD() and how did you use it?"**
LEAD() looks forward in a window rather than backward like LAG().
I used LEAD(contract_start) partitioned by vendor to find when
the next contract with the same vendor started. By calculating the
gap between one contract's end date and the next contract's start,
I could identify back-to-back renewals — a signal of vendor
dependency rather than competitive procurement.

**"What is the Risk Exposure Index?"**
It's a composite metric I designed: total_spend × avg_risk_score.
A vendor scoring high on risk but with low spend is manageable.
A vendor scoring high on risk with high spend is the dangerous
combination. Multiplying spend by risk score surfaces exactly
those vendors. NTILE(3) then bands them into three review tiers
so the CPO has a clear action list, not just a ranked table.

**"What is PERCENT_RANK() and why did you use it?"**
PERCENT_RANK() returns a value between 0 and 1 showing where a
row sits in the overall distribution — 0 is the lowest, 1 is the
highest. I used it on vendor spend so the CPO can see at a glance
that a vendor in the 95th percentile of spend deserves proportionally
more oversight than one at the 20th percentile.

---

*Project by: [Your Name]*
*Dataset: Synthetic procurement contracts data (realistic business structure)*
*Tool: Microsoft SQL Server Management Studio*
*Portfolio: github.com/[your-username]/data-analytics-portfolio*
