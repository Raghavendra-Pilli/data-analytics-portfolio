# Data Directory

This folder is gitignored. Download the dataset manually and place it here.

## Dataset Required
**Brazilian E-Commerce Public Dataset by Olist**
- Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
- License: CC BY-NC-SA 4.0

## Files Expected in this folder
```
olist_orders_dataset.csv
olist_order_items_dataset.csv
olist_products_dataset.csv
olist_customers_dataset.csv
olist_order_reviews_dataset.csv
olist_order_payments_dataset.csv
olist_sellers_dataset.csv
olist_geolocation_dataset.csv
product_category_name_translation.csv
```

## Steps
1. Go to the Kaggle link above (free account required)
2. Click Download
3. Unzip and place all CSVs into this `/data/` folder
4. Run: `python src/returns_analysis.py`
