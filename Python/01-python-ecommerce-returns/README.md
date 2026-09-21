# E-Commerce Returns Analysis
> Which product categories, regions, and customer segments have the highest return rates — and what drives them?

## Overview
Analysed 99,441 real orders from the Brazilian Olist E-Commerce dataset (9 relational tables) to surface return drivers, processing bottlenecks, and revenue leakage by category and region.

## Business Question
Return rates vary widely across product lines but most e-commerce teams treat them as a flat operational cost. This project asks: **where are returns concentrated, why, and what would reducing them be worth?**

## Results (Real Data)
| Metric | Result |
|--------|--------|
| Total orders analysed | 99,441 |
| Total returns flagged | 14,693 |
| Overall return rate | 14.78% |
| Revenue at risk | $4,407,777 |
| Highest return category | Bed & Bath Table (19.12%) |
| Review score ≤2 return rate | 100% |
| Review score ≥4 return rate | 0.1% |

## Key Findings
- **Bed & Bath Table** has the highest return rate at 19.12%
- Orders with review score ≤ 2 have a 100% return rate — perfect correlation
- Orders with review score ≥ 4 have near-zero returns (0.1%)
- $4.4M revenue is at risk from returns across the dataset

## Folder Structure
```
python-ecommerce-returns/
├── data/                  # Raw CSVs (gitignored — download from Kaggle)
├── src/
│   └── returns_analysis.py
├── outputs/
│   └── charts/
│       ├── return_rate_by_category.png
│       ├── review_score_vs_returns.png
│       └── return_rate_by_region.png
├── requirements.txt
├── .gitignore
└── README.md
```

## Dataset
**Brazilian E-Commerce Public Dataset by Olist** — Kaggle
License: CC BY-NC-SA 4.0
[Download here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
Place all CSVs inside `/data/` before running.

## How to Run
```bash
pip install -r requirements.txt
python src/returns_analysis.py --data_dir data --output_dir outputs/charts
```

## Output Charts
- `return_rate_by_category.png` — Return rate % by product category (top 15)
- `review_score_vs_returns.png` — Return rate correlation with review score
- `return_rate_by_region.png` — Return rate heatmap by Brazilian state

## Skills Demonstrated
- Multi-table JOIN logic in pandas (9 tables merged into 119K row master)
- Reusable EDA functions
- Correlation analysis between review scores and return behaviour
- Business-framed outputs with revenue impact quantification

## Author
Raghavendra Pilli — [GitHub](https://github.com/Raghavendra-Pilli)
