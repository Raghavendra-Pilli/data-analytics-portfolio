# Data Download Instructions

## Dataset: Restaurant Orders

**Source:** https://mavenanalytics.io/data-playground
**License:** CC BY 4.0 — free for portfolio use
**Files needed:** menu_items.csv · orders.csv · order_details.csv

## Steps

1. Go to Maven Analytics Data Playground (link above)
2. Search for "Restaurant Orders"
3. Download the zip file — extract to this data/ folder
4. You will get 3 CSV files:
   - menu_items.csv
   - orders.csv
   - order_details.csv

## Import order in SSMS

Import in this exact order to satisfy foreign key constraints:

1. menu_items.csv     → menu_items table
2. orders.csv         → orders table
3. order_details.csv  → order_details table

## Expected file sizes

| File | Approx rows |
|---|---|
| menu_items.csv | ~32 rows |
| orders.csv | ~5,300 rows |
| order_details.csv | ~12,000 rows |

## .gitignore note

CSV files are excluded from the repo.
Re-download from the source URL above.
