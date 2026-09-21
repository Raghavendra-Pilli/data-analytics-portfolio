"""
E-Commerce Returns Analysis
===========================
Analyses return rates, processing times, and revenue leakage
from the Brazilian Olist E-Commerce dataset.

Usage:
    python returns_analysis.py --data_dir ../data --output_dir ../outputs/charts
"""

import os
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings("ignore")

# ── Style ──────────────────────────────────────────────────────────────────
sns.set_theme(style="whitegrid", palette="muted")
plt.rcParams.update({"figure.dpi": 130, "figure.figsize": (10, 5)})


# ── Data Loading ───────────────────────────────────────────────────────────
def load_data(data_dir: str) -> dict:
    """Load all Olist CSVs into a dict of DataFrames."""
    files = {
        "orders":        "olist_orders_dataset.csv",
        "order_items":   "olist_order_items_dataset.csv",
        "products":      "olist_products_dataset.csv",
        "customers":     "olist_customers_dataset.csv",
        "reviews":       "olist_order_reviews_dataset.csv",
        "category_name": "product_category_name_translation.csv",
        "sellers":       "olist_sellers_dataset.csv",
        "payments":      "olist_order_payments_dataset.csv",
        "geolocation":   "olist_geolocation_dataset.csv",
    }
    dfs = {}
    for key, fname in files.items():
        path = os.path.join(data_dir, fname)
        if os.path.exists(path):
            dfs[key] = pd.read_csv(path)
            print(f"  Loaded {key}: {dfs[key].shape}")
        else:
            print(f"  WARNING: {fname} not found — skipping")
    return dfs


# ── Data Preparation ───────────────────────────────────────────────────────
def build_master(dfs: dict) -> pd.DataFrame:
    """Merge tables into a single analysis-ready DataFrame."""
    df = (
        dfs["orders"]
        .merge(dfs["order_items"],   on="order_id",   how="left")
        .merge(dfs["products"],      on="product_id", how="left")
        .merge(dfs["customers"],     on="customer_id", how="left")
        .merge(dfs["reviews"],       on="order_id",   how="left")
        .merge(dfs["category_name"], on="product_category_name", how="left")
        .merge(dfs["payments"],      on="order_id",   how="left")
    )

    # Parse dates
    date_cols = [
        "order_purchase_timestamp",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ]
    for col in date_cols:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors="coerce")

    # Flag returns — orders with status 'canceled' or review score <= 2
    df["is_return"] = (
        (df["order_status"] == "canceled") |
        (df["review_score"] <= 2)
    ).astype(int)

    # Delivery delay in days
    df["delivery_delay_days"] = (
        df["order_delivered_customer_date"] -
        df["order_estimated_delivery_date"]
    ).dt.days

    return df


# ── Analysis Functions ─────────────────────────────────────────────────────
def return_rate_by_category(df: pd.DataFrame, top_n: int = 15) -> pd.DataFrame:
    """Return rate % per product category, top N by volume."""
    cat_col = "product_category_name_english"
    if cat_col not in df.columns:
        cat_col = "product_category_name"

    summary = (
        df.groupby(cat_col)["is_return"]
        .agg(total="count", returns="sum")
        .assign(return_rate=lambda x: (x["returns"] / x["total"] * 100).round(2))
        .sort_values("total", ascending=False)
        .head(top_n)
        .reset_index()
    )
    return summary


def return_rate_by_region(df: pd.DataFrame) -> pd.DataFrame:
    """Return rate % per customer state."""
    summary = (
        df.groupby("customer_state")["is_return"]
        .agg(total="count", returns="sum")
        .assign(return_rate=lambda x: (x["returns"] / x["total"] * 100).round(2))
        .sort_values("return_rate", ascending=False)
        .reset_index()
    )
    return summary


def review_score_correlation(df: pd.DataFrame) -> pd.DataFrame:
    """Average return rate per review score bucket."""
    return (
        df.groupby("review_score")["is_return"]
        .agg(total="count", returns="sum")
        .assign(return_rate=lambda x: (x["returns"] / x["total"] * 100).round(2))
        .reset_index()
    )


def revenue_at_risk(df: pd.DataFrame) -> float:
    """Estimate total revenue at risk from returns."""
    return df.loc[df["is_return"] == 1, "payment_value"].sum()


def avg_processing_time_by_region(df: pd.DataFrame) -> pd.DataFrame:
    """Average delivery delay by state."""
    return (
        df.groupby("customer_state")["delivery_delay_days"]
        .mean()
        .round(1)
        .sort_values(ascending=False)
        .reset_index()
        .rename(columns={"delivery_delay_days": "avg_delay_days"})
    )


# ── Plotting ───────────────────────────────────────────────────────────────
def plot_return_rate_by_category(summary: pd.DataFrame, output_dir: str):
    fig, ax = plt.subplots()
    sns.barplot(data=summary, x="return_rate", y="product_category_name_english"
                if "product_category_name_english" in summary.columns
                else "product_category_name",
                palette="Blues_r", ax=ax)
    ax.set_title("Return Rate by Product Category (Top 15 by Volume)", fontweight="bold")
    ax.set_xlabel("Return Rate (%)")
    ax.set_ylabel("")
    plt.tight_layout()
    path = os.path.join(output_dir, "return_rate_by_category.png")
    fig.savefig(path)
    print(f"  Saved: {path}")
    plt.close()


def plot_review_correlation(summary: pd.DataFrame, output_dir: str):
    fig, ax = plt.subplots()
    sns.barplot(data=summary, x="review_score", y="return_rate",
                palette="RdYlGn", ax=ax)
    ax.set_title("Return Rate by Review Score", fontweight="bold")
    ax.set_xlabel("Review Score (1–5)")
    ax.set_ylabel("Return Rate (%)")
    plt.tight_layout()
    path = os.path.join(output_dir, "review_score_vs_returns.png")
    fig.savefig(path)
    print(f"  Saved: {path}")
    plt.close()


def plot_region_heatmap(region_df: pd.DataFrame, output_dir: str):
    fig, ax = plt.subplots(figsize=(8, 8))
    pivot = region_df.set_index("customer_state")[["return_rate"]]
    sns.heatmap(pivot, annot=True, fmt=".1f", cmap="YlOrRd",
                linewidths=0.5, ax=ax)
    ax.set_title("Return Rate by Customer State (%)", fontweight="bold")
    plt.tight_layout()
    path = os.path.join(output_dir, "return_rate_by_region.png")
    fig.savefig(path)
    print(f"  Saved: {path}")
    plt.close()


# ── Summary Report ─────────────────────────────────────────────────────────
def print_summary(df: pd.DataFrame, cat_df: pd.DataFrame,
                  review_df: pd.DataFrame):
    total_orders   = len(df["order_id"].unique())
    total_returns  = df.groupby("order_id")["is_return"].max().sum()
    overall_rate   = total_returns / total_orders * 100
    rev_at_risk    = revenue_at_risk(df)
    top_cat        = cat_df.iloc[0]

    print("\n" + "=" * 55)
    print("  E-COMMERCE RETURNS — SUMMARY")
    print("=" * 55)
    print(f"  Total orders analysed : {total_orders:,}")
    print(f"  Total returns flagged : {int(total_returns):,}")
    print(f"  Overall return rate   : {overall_rate:.2f}%")
    print(f"  Revenue at risk       : ${rev_at_risk:,.2f}")
    cat_col = "product_category_name_english" if "product_category_name_english" in cat_df.columns else "product_category_name"
    print(f"  Highest return cat    : {top_cat[cat_col]} ({top_cat['return_rate']}%)")
    low_score = review_df[review_df["review_score"] <= 2]["return_rate"].mean()
    high_score = review_df[review_df["review_score"] >= 4]["return_rate"].mean()
    print(f"  Avg return rate score ≤2 : {low_score:.1f}%")
    print(f"  Avg return rate score ≥4 : {high_score:.1f}%")
    print("=" * 55 + "\n")


# ── Main ───────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="E-Commerce Returns Analysis")
    parser.add_argument("--data_dir",   default="../data",          help="Path to CSV files")
    parser.add_argument("--output_dir", default="../outputs/charts", help="Path to save charts")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    print("\n[1/5] Loading data...")
    dfs = load_data(args.data_dir)

    print("\n[2/5] Building master dataset...")
    df = build_master(dfs)
    print(f"  Master shape: {df.shape}")

    print("\n[3/5] Running analysis...")
    cat_df    = return_rate_by_category(df)
    region_df = return_rate_by_region(df)
    review_df = review_score_correlation(df)

    print("\n[4/5] Saving charts...")
    plot_return_rate_by_category(cat_df, args.output_dir)
    plot_review_correlation(review_df, args.output_dir)
    plot_region_heatmap(region_df, args.output_dir)

    print("\n[5/5] Summary:")
    print_summary(df, cat_df, review_df)


if __name__ == "__main__":
    main()
