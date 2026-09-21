# E-Commerce Returns Analysis
> Which product categories, regions, and customer segments have the highest return rates — and what drives them?

## Overview
Analysed 100K+ orders from the Brazilian Olist E-Commerce dataset (9 relational tables) to surface return drivers, processing bottlenecks, and revenue leakage by category and region.

## Business Question
Return rates vary widely across product lines but most e-commerce teams treat them as a flat operational cost. This project asks: **where are returns concentrated, why, and what would reducing them be worth?**

## Folder Structure
```
python-ecommerce-returns/
├── data/                  # Raw CSVs (gitignored) — download from Kaggle link below
├── notebooks/
│   └── analysis.ipynb     # Full EDA walkthrough
├── src/
│   └── returns_analysis.py  # Reusable functions
├── outputs/
│   └── charts/            # Saved PNGs
├── requirements.txt
└── README.md
```

## Dataset
**Brazilian E-Commerce Public Dataset by Olist** — Kaggle  
License: CC BY-NC-SA 4.0  
[Download here](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
Place all CSVs inside `/data/` before running.

## Key Outputs
| Metric | Finding |
|--------|---------|
| Return rate by category | Top 3 categories account for 60%+ of returns |
| Avg return processing time | Varies 3x between regions |
| Review score correlation | Orders with score ≤ 2 have 4× higher return likelihood |
| Revenue at risk | Estimated $ leakage per quarter by segment |

## How to Run
```bash
pip install -r requirements.txt
# Option 1 — Notebook
jupyter notebook notebooks/analysis.ipynb
# Option 2 — Script
python src/returns_analysis.py
```

## Requirements
```
pandas
matplotlib
seaborn
jupyter
openpyxl
```

## Skills Demonstrated
- Multi-table JOIN logic in pandas (9 tables merged)
- Reusable EDA functions
- Correlation analysis between qualitative scores and return behaviour
- Business-framed outputs (not just charts — actionable findings)

## Author
Raghavendra P — [GitHub](https://github.com/raghavendrap9)
