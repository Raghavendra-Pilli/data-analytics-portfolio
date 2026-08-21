# SQL Project 2 — Restaurant Menu Profitability & Ordering Patterns
### Problem Statement & Solution Narrative
**Tool:** Microsoft SQL Server | **Level:** Intermediate

---

## The Situation

A restaurant chain with 3 locations has been running for just over a
year. The operations manager, Rajan, and the CFO have noticed something
uncomfortable — the restaurant is busy, but profit margins are tighter
than expected.

The kitchen is prepping the same quantities of every ingredient every
morning regardless of what actually sells. Popular items regularly sell
out by 8pm. Slow-moving items get thrown out at the end of the week,
wasting food cost. The menu has 32 items but nobody knows which ones
are actually making money and which ones are just taking up space on
the board.

The CFO's question is blunt:

> "Which items on our menu are actually profitable and worth keeping?
>  Which ones should we remove? And when exactly are customers ordering
>  so we can staff and prep the kitchen properly?"

---

## The Data We Have

The restaurant's point-of-sale system captures every order placed.
We have been given three CSV files:

**File 1: menu_items.csv**
The full menu — every item, its category, and its price.

**File 2: orders.csv**
Every order placed — order ID, date, and time.

**File 3: order_details.csv**
The bridge between orders and items — which item was ordered
in which order.

Together these three files form a relational structure:

    orders (1) ──→ (many) order_details (many) ──→ (1) menu_items

This is our first multi-table project. Before we can answer any
business question, we need to JOIN these three tables together.

---

## What We Are Trying to Answer

We wrote these questions before opening SQL:

**Question 1 — What sells the most?**
Which individual items and categories are ordered most frequently?
These are the items the kitchen must never run out of ingredients for.

**Question 2 — What makes the most money?**
High volume does not always mean high revenue. A cheap item ordered
100 times might earn less than a premium item ordered 40 times.
We need to look at both volume AND revenue to understand the menu.

**Question 3 — What should we remove?**
Which items are barely ordered? Items with very low order counts
are wasting menu space, confusing customers, and increasing kitchen
complexity for almost no revenue return.

**Question 4 — When are customers ordering?**
Which days of the week are busiest? Which meal period — lunch or
dinner — drives the most revenue? What hour of the day hits peak
order volume? These answers drive staffing and prep decisions.

**Question 5 — Is the business growing?**
Is monthly revenue trending up, flat, or declining? Is average
order value increasing over time or shrinking?

**Question 6 — Which items are Stars vs. which need a review?**
We want to classify every menu item into one of four buckets:
- Star: high volume, high price — protect these
- Workhorse: high volume, low price — volume drivers
- Niche: low volume, high price — premium items
- Review: low volume, low price — candidates for removal

---

## Our Approach — Step by Step

### Step 1: Check all three tables for data quality

With three tables we have more ways for things to go wrong.
We checked:
- Are there null values in key columns like order_id or item_id?
- Are there orphaned order detail rows with no matching order?
- Are there orphaned items with no matching menu entry?
- Are prices all positive and within a sensible range?
- Do dates cover the full expected period?

This is critical with relational data — a single orphaned row
will silently drop records when we JOIN the tables together.

---

### Step 2: Join the three tables into one master view

Rather than rewriting JOIN logic in every query, we created
a SQL VIEW called vw_orders_master. This view joins all three
tables once and presents a flat, analysis-ready table with:

    order_id, order_date, order_year, order_month,
    day_of_week, time_of_day, item_name, category, price

Every analysis query in this project reads from this view —
clean, consistent, and no repeated JOIN code.

---

### Step 3: Analyse the menu

**Volume vs Revenue — the key insight**

Most people assume the most popular item is the most profitable.
This is often wrong. We separated volume (times ordered) from
revenue (price × times ordered) to see if they told the same story.

We ranked every item by both measures and compared the lists.
Items that appear in the top 10 of both lists are true Stars.
Items that rank high on volume but low on revenue are Workhorses
— great for customer satisfaction but not great for margin.

**The four-quadrant menu classification**

We calculated the average order count and average price across
all items. Then we used a CASE statement to put every item into
one of four buckets based on whether it sits above or below
the average on both dimensions.

This is a simplified version of the Boston Consulting Group
matrix applied to a restaurant menu — a framework any CFO
immediately recognises and respects.

---

### Step 4: Analyse ordering patterns

**By day of week:**
We grouped orders by DATENAME(WEEKDAY) and sorted by a CASE
statement to ensure Monday → Sunday order rather than
alphabetical order. We calculated total orders, revenue, and
each day's share of weekly revenue.

**By time of day:**
We created a time_of_day classification during data preparation:
Breakfast (6–11am), Lunch (11am–3pm), Afternoon (3–6pm),
Dinner (6–10pm), Late Night (10pm+). This tells us which
service period drives the most revenue — critical for
kitchen planning and staff scheduling.

**By hour:**
For the staffing KPI we went even more granular — orders
grouped by exact hour of day, with a CASE statement flagging
each hour as Peak, Busy, or Quiet based on whether order
volume is above 130% of average, above average, or below.

---

### Step 5: Measure month-over-month growth

We used the LAG() window function to compare each month's
revenue to the previous month. This automatically calculates
the percentage change without any manual subtraction.

A CASE statement then labels each month as Growth, Decline,
or Flat — turning a number into a signal a manager can act on
immediately in a Monday morning review.

---

### Step 6: Identify revenue concentration risk

We used a running cumulative SUM window function to calculate
what percentage of total revenue comes from just the top 5
items. If 5 items out of 32 generate 40%+ of revenue, the
business has concentration risk — removing or changing those
items would have an outsized impact on total revenue.

---

## What We Found — Key Insights

*(Run the queries and fill in with your actual results)*

1. **[Top category] drives the highest revenue** — accounting
   for approximately [X]% of total revenue despite having
   only [Y] items on the menu. This category should receive
   the most investment in quality and portion consistency.

2. **[Item name] is the single best-performing menu item** —
   it appears in the top 3 for both order volume and total
   revenue, making it a true Star item. Its ingredients must
   be prioritised in daily kitchen prep.

3. **[X] items qualify as Review items** — low volume and
   low price. Removing these would simplify the kitchen
   operation and reduce food waste without meaningfully
   impacting revenue.

4. **Dinner service drives [X]% of total revenue** — yet
   staffing levels are currently equal across lunch and
   dinner. A shift in staffing allocation would reduce
   labour cost during quieter lunch periods.

5. **Peak order hour is [X]pm** — the 60-minute window
   around this hour accounts for [Y]% of daily orders.
   Kitchen prep and full staffing must be complete
   30 minutes before this window opens.

---

## Business Recommendations

**Recommendation 1 — Protect Star items, review low performers**
The [top 3 Star items] should be prominently featured on the
menu and never removed from daily prep. The [X] Review items
should be evaluated for removal at the next quarterly menu
review — this would reduce kitchen SKUs by [Y]% with minimal
revenue impact.

**Recommendation 2 — Shift kitchen prep schedule to match demand**
If Dinner is the dominant service period, full kitchen prep
should be complete by [X]pm. Current equal-split prep
scheduling wastes labour cost during Breakfast and Afternoon
when order volume is lowest.

**Recommendation 3 — Introduce combo deals using attach rate data**
The category attach rate analysis reveals which categories
most often appear in the same order. Build a combo deal
around the most common combination — this increases average
order value without adding menu complexity.

---

## SQL Skills Used in This Project

| Skill | Where used |
|---|---|
| Multi-table JOINs | vw_orders_master view — joins 3 tables |
| GROUP BY + aggregation | All revenue and volume analyses |
| CASE statements | Menu classification, time of day, staffing flags, trend labels |
| Window functions — RANK() | Item ranking within and across categories |
| Window functions — LAG() | Month-over-month revenue growth |
| Window functions — SUM() OVER() | Revenue share %, cumulative concentration |
| CTEs (WITH clause) | Order size analysis, MoM growth, concentration |
| Subqueries | Peak hour threshold comparison |
| CREATE VIEW | Master analysis view, executive summary view |
| DATE functions | YEAR(), MONTH(), DATEPART(), DATENAME(), FORMAT() |
| STRING_AGG | Category combination analysis |
| FOREIGN KEY constraints | Relational integrity between tables |

---

## New SQL concepts introduced in this project vs SQL-1

| Concept | SQL-1 | SQL-2 |
|---|---|---|
| Single table | ✓ | — |
| Multi-table JOINs | — | ✓ NEW |
| RANK() OVER (PARTITION BY) | — | ✓ NEW |
| LAG() for growth | ✓ | ✓ Extended |
| Foreign key relationships | — | ✓ NEW |
| CREATE VIEW | Basic | ✓ Master view |
| STRING_AGG | — | ✓ NEW |
| Business classification matrix | — | ✓ NEW |

---

## How to Explain This in an Interview

**"What was the problem?"**
A restaurant chain did not know which menu items were actually
profitable and which ones were wasting kitchen resources.
The CFO needed a data-driven menu review framework.

**"What data did you use?"**
Three related tables from the restaurant's POS system — menu
items, orders, and order details — joined together using
SQL foreign key relationships into a master analysis view.

**"What did you build?"**
Eleven business analyses covering menu profitability, ordering
patterns by day and hour, month-on-month growth tracking, and
a four-quadrant menu classification framework — Star, Workhorse,
Niche, and Review — applied to every item on the menu.

**"What did you find?"**
The top [X] items generate [Y]% of all revenue. [Z] items
qualify as Review candidates and are strong candidates for
removal. Dinner service is the dominant revenue period but
staffing is split equally — an inefficiency that could be
immediately corrected.

**"What business decision does it support?"**
The menu classification directly supports the next quarterly
menu review. The peak hour and day-of-week analysis feeds
directly into the weekly staffing rota. Both decisions can
be made on Monday morning using these query outputs.

---

*Project by: [Your Name]*
*Dataset: Restaurant Orders Dataset — Maven Analytics (CC BY 4.0)*
*Tool: Microsoft SQL Server Management Studio*
*Portfolio: github.com/[your-username]/data-analytics-portfolio*
