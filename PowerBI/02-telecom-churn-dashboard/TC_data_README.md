# Data Directory

This folder is gitignored. Download the dataset manually and place it here.

## Dataset Required
**IBM Telco Customer Churn**
- Source: https://www.kaggle.com/datasets/blastchar/telco-customer-churn
- License: CC0 — Public Domain
- Size: ~1MB, 7,043 rows, 21 columns

## Files Expected
```
data/
└── WA_Fn-UseC_-Telco-Customer-Churn.csv
```

## Important Note
The `TotalCharges` column is stored as **text** in the source file.
Some rows have blank TotalCharges where tenure = 0.
This is handled automatically in Power Query — see SEMANTIC_MODEL.md.

## Steps
1. Go to Kaggle link above (free account required)
2. Download the CSV file
3. Place in this `/data/` folder
4. Open reports/telecom_churn.pbix in Power BI Desktop
5. Update data source path if prompted and click Refresh
