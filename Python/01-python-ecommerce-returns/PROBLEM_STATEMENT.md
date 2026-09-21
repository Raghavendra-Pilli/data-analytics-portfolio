# Problem Statement — E-Commerce Returns Analysis

## Business Context
An e-commerce business operating across multiple Brazilian states is experiencing
high return rates across certain product categories. Returns directly impact revenue,
logistics costs, and customer satisfaction — but the team lacks visibility into
where returns are concentrated and what is driving them.

## Business Question
**Which product categories, regions, and customer segments have the highest return
rates — and what is driving them?**

## Objectives
1. Quantify the overall return rate across 99,441 orders
2. Identify which product categories have the highest return rates
3. Understand the relationship between review scores and return behaviour
4. Map return rates by customer region (Brazilian states)
5. Estimate total revenue at risk from returns

## Scope
- Dataset: Brazilian E-Commerce Public Dataset by Olist (Kaggle)
- Period: 2016–2018
- Orders: 99,441
- Tables: 9 relational tables merged into a single master dataset

## Success Criteria
- Return rate quantified at category, region, and review score level
- Revenue at risk estimated in dollar terms
- Actionable insights that a category manager or ops team could act on
- 3 visual outputs (charts) ready for stakeholder presentation

## Key Findings
| Metric | Result |
|--------|--------|
| Overall return rate | 14.78% |
| Total returns flagged | 14,693 orders |
| Revenue at risk | $4,407,777 |
| Highest return category | Bed & Bath Table (19.12%) |
| Review score ≤ 2 → return rate | 100% |
| Review score ≥ 4 → return rate | 0.1% |

## Tools & Techniques
- Python (pandas, matplotlib, seaborn)
- 9-table merge pipeline
- EDA and correlation analysis
- Reusable functions for category, region, and review analysis
