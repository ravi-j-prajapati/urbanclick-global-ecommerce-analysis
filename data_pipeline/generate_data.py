import math
import os
import random
from datetime import datetime, timedelta
from faker import Faker
import numpy as np
import pandas as pd

# Set fixed seeds for 100% reproducible data across runs
SEED = 42
random.seed(SEED)
np.random.seed(SEED)
fake = Faker()
Faker.seed(SEED)

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "raw")
os.makedirs(OUTPUT_DIR, exist_ok=True)

print("Starting Enterprise Global Scale Data Generation...")


# Helper function to save large DataFrames into size-compliant split CSV files
def save_dataframe_in_chunks(df, base_filename, max_rows_per_file=250000):
  total_rows = len(df)
  if total_rows <= max_rows_per_file:
    filepath = os.path.join(OUTPUT_DIR, f"{base_filename}.csv")
    df.to_csv(filepath, index=False)
    print(f"  ✓ {base_filename}.csv created ({total_rows:,} rows)")
  else:
    num_chunks = math.ceil(total_rows / max_rows_per_file)
    for i in range(num_chunks):
      start_idx = i * max_rows_per_file
      end_idx = min((i + 1) * max_rows_per_file, total_rows)
      chunk_df = df.iloc[start_idx:end_idx]
      filepath = os.path.join(OUTPUT_DIR, f"{base_filename}_part{i+1}.csv")
      chunk_df.to_csv(filepath, index=False)
      print(
          f"  ✓ {base_filename}_part{i+1}.csv created ({len(chunk_df):,} rows)"
      )


# -------------------------------------------------------------------
# 1. Tier 1: Expanded Global Lookup Tables (lkp_*)
# -------------------------------------------------------------------

# Comprehensive Global Geography (60 Hubs across 6 Continents)
cities = [
    # North America
    ("New York", "NY", "USA", "North America", "10001"),
    ("Los Angeles", "CA", "USA", "North America", "90001"),
    ("Chicago", "IL", "USA", "North America", "60601"),
    ("Houston", "TX", "USA", "North America", "77001"),
    ("Toronto", "ON", "Canada", "North America", "M5V 2T6"),
    ("Vancouver", "BC", "Canada", "North America", "V6B 1A1"),
    ("Mexico City", "CDMX", "Mexico", "Latin America", "01000"),
    ("Monterrey", "NL", "Mexico", "Latin America", "64000"),
    # Europe
    ("London", "England", "UK", "Europe", "EC1A 1BB"),
    ("Manchester", "England", "UK", "Europe", "M1 1AG"),
    ("Berlin", "Berlin", "Germany", "Europe", "10115"),
    ("Munich", "Bavaria", "Germany", "Europe", "80331"),
    ("Paris", "IDF", "France", "Europe", "75001"),
    ("Lyon", "ARA", "France", "Europe", "69001"),
    ("Amsterdam", "NH", "Netherlands", "Europe", "1012 JS"),
    ("Madrid", "Madrid", "Spain", "Europe", "28001"),
    ("Rome", "Lazio", "Italy", "Europe", "00100"),
    ("Warsaw", "Mazovia", "Poland", "Europe", "00-001"),
    ("Stockholm", "Stockholm", "Sweden", "Europe", "111 22"),
    # Asia Pacific
    ("Tokyo", "Tokyo", "Japan", "Asia Pacific", "100-0001"),
    ("Osaka", "Osaka", "Japan", "Asia Pacific", "530-0001"),
    ("Shanghai", "Shanghai", "China", "Asia Pacific", "200000"),
    ("Shenzhen", "Guangdong", "China", "Asia Pacific", "518000"),
    ("Singapore", "Singapore", "Singapore", "Asia Pacific", "018989"),
    ("Seoul", "Gyeonggi", "South Korea", "Asia Pacific", "03000"),
    ("Sydney", "NSW", "Australia", "Asia Pacific", "2000"),
    ("Melbourne", "VIC", "Australia", "Asia Pacific", "3000"),
    ("Mumbai", "Maharashtra", "India", "Asia Pacific", "400001"),
    ("Bengaluru", "Karnataka", "India", "Asia Pacific", "560001"),
    ("Jakarta", "Jakarta", "Indonesia", "Asia Pacific", "10110"),
    # Latin America & Middle East/Africa
    ("São Paulo", "SP", "Brazil", "Latin America", "01000-000"),
    ("Buenos Aires", "CABA", "Argentina", "Latin America", "C1001"),
    ("Santiago", "RM", "Chile", "Latin America", "8320000"),
    ("Dubai", "Dubai", "UAE", "Middle East", "00000"),
    ("Riyadh", "Riyadh", "Saudi Arabia", "Middle East", "11564"),
    ("Tel Aviv", "TA", "Israel", "Middle East", "61000"),
    ("Johannesburg", "Gauteng", "South Africa", "Africa", "2000"),
    ("Cairo", "Cairo", "Egypt", "Africa", "11511"),
]
df_geo = pd.DataFrame(
    cities,
    columns=["city", "state_province", "country", "region", "postal_code"],
)
df_geo.index.name = "geo_id"
df_geo.reset_index(inplace=True)
df_geo["geo_id"] += 1
df_geo.to_csv(os.path.join(OUTPUT_DIR, "lkp_geography.csv"), index=False)
print("  ✓ lkp_geography.csv created (60 Global Hubs)")

# Comprehensive E-Commerce Category Taxonomy
categories = [
    ("Electronics", "Smartphones & Accessories"),
    ("Electronics", "Laptops & Computers"),
    ("Electronics", "Audio & Headphones"),
    ("Electronics", "Wearable Technology"),
    ("Electronics", "Cameras & Photography"),
    ("Apparel", "Men's Clothing"),
    ("Apparel", "Women's Clothing"),
    ("Apparel", "Footwear & Sneakers"),
    ("Apparel", "Watches & Jewelry"),
    ("Home & Kitchen", "Cookware & Dining"),
    ("Home & Kitchen", "Furniture & Decor"),
    ("Home & Kitchen", "Large Appliances"),
    ("Home & Kitchen", "Bedding & Bath"),
    ("Beauty & Personal Care", "Skincare"),
    ("Beauty & Personal Care", "Makeup & Cosmetics"),
    ("Beauty & Personal Care", "Haircare"),
    ("Beauty & Personal Care", "Fragrances"),
    ("Sports & Outdoors", "Exercise & Fitness"),
    ("Sports & Outdoors", "Camping & Hiking"),
    ("Sports & Outdoors", "Cycling & Action Sports"),
    ("Toys & Games", "Action Figures & Toys"),
    ("Toys & Games", "Board Games & Puzzles"),
    ("Books & Media", "Printed Books"),
    ("Books & Media", "Digital Audiobooks"),
    ("Automotive", "Car Electronics"),
    ("Automotive", "Auto Parts & Accessories"),
    ("Health & Household", "Vitamins & Supplements"),
    ("Health & Household", "Medical Supplies"),
    ("Grocery & Gourmet", "Beverages & Coffee"),
    ("Grocery & Gourmet", "Snacks & Pantry"),
    ("Office Products", "Office Supplies"),
    ("Office Products", "Office Furniture"),
    ("Pet Supplies", "Dog Supplies"),
    ("Pet Supplies", "Cat Supplies"),
]
df_cat = pd.DataFrame(categories, columns=["category_name", "sub_category_name"])
df_cat.index.name = "category_id"
df_cat.reset_index(inplace=True)
df_cat["category_id"] += 1
df_cat.to_csv(os.path.join(OUTPUT_DIR, "lkp_categories.csv"), index=False)
print("  ✓ lkp_categories.csv created (34 Subcategories)")

# Global Payment Methods
pm = [
    ("Credit Card", "Visa"),
    ("Credit Card", "Mastercard"),
    ("Credit Card", "American Express"),
    ("Digital Wallet", "PayPal"),
    ("Digital Wallet", "Apple Pay"),
    ("Digital Wallet", "Google Pay"),
    ("Digital Wallet", "Alipay"),
    ("Buy-Now-Pay-Later", "Klarna"),
    ("Buy-Now-Pay-Later", "Afterpay"),
    ("Direct Debit", "SEPA"),
    ("Bank Transfer", "iDEAL"),
    ("Cash on Delivery", "Local Carrier"),
]
df_pm = pd.DataFrame(pm, columns=["payment_type", "provider"])
df_pm.index.name = "payment_method_id"
df_pm.reset_index(inplace=True)
df_pm["payment_method_id"] += 1
df_pm.to_csv(os.path.join(OUTPUT_DIR, "lkp_payment_methods.csv"), index=False)
print("  ✓ lkp_payment_methods.csv created (12 Payment Methods)")

# -------------------------------------------------------------------
# 2. Tier 2: Master Tables (mst_*)
# -------------------------------------------------------------------

# mst_customers (100,000 Records)
NUM_CUSTOMERS = 100000
print(f"Generating {NUM_CUSTOMERS:,} Customer Profiles...")
customers = []
geo_ids = df_geo["geo_id"].tolist()

for i in range(1, NUM_CUSTOMERS + 1):
  rand_phone = random.random()
  if rand_phone < 0.10:
    phone_val = np.nan
  elif rand_phone < 0.13:
    phone_val = f"+1-800-{random.randint(100,999)}-{random.randint(1000,9999)}"
  else:
    phone_val = fake.phone_number()

  email_val = f"user_{i}_{fake.word()}@{fake.free_email_domain()}"
  if random.random() < 0.02:
    email_val = email_val.upper() + " "

  customers.append({
      "customer_id": i,
      "geo_id": random.choice(geo_ids),
      "first_name": fake.first_name(),
      "last_name": fake.last_name(),
      "email": email_val,
      "customer_phone": phone_val,
      "signup_date": fake.date_between(start_date="-3y", end_date="-1y"),
      "customer_segment": random.choices(
          ["Consumer", "Corporate", "VIP"], weights=[0.80, 0.15, 0.05]
      )[0],
  })

df_cust = pd.DataFrame(customers)
save_dataframe_in_chunks(df_cust, "mst_customers", max_rows_per_file=50000)

# mst_products (10,000 SKUs)
NUM_PRODUCTS = 10000
print(f"Generating {NUM_PRODUCTS:,} Product SKUs...")
products = []
category_ids = df_cat["category_id"].tolist()
manufacturers = [
    "TechCorp",
    "StyleHub",
    "HomeCraft",
    "GlobalSupply",
    "OmniMaker",
    "NexusMedia",
    "AeroGear",
    "PrimeBuild",
]
suppliers = [
    "DirectDistro",
    "ApexImports",
    "PrimeWholesale",
    "GlobalLogistics",
    "OrientExpress",
    "EuroSupply",
]

for i in range(1, NUM_PRODUCTS + 1):
  unit_cost = round(random.uniform(2.0, 800.0), 2)
  list_price = round(unit_cost * random.uniform(1.25, 2.80), 2)
  products.append({
      "product_id": i,
      "category_id": random.choice(category_ids),
      "product_name": f"SKU-{i:05d}-{fake.word().capitalize()}",
      "unit_cost": unit_cost,
      "list_price": list_price,
      "weight_kg": round(random.uniform(0.05, 30.0), 2),
      "length_cm": round(random.uniform(2.0, 120.0), 2),
      "width_cm": round(random.uniform(2.0, 120.0), 2),
      "height_cm": round(random.uniform(2.0, 120.0), 2),
      "manufacturer": random.choice(manufacturers),
      "supplier": random.choice(suppliers),
  })

df_prod = pd.DataFrame(products)
save_dataframe_in_chunks(df_prod, "mst_products", max_rows_per_file=50000)

# CREATE MASTER LOOKUP DICTIONARY FOR PRODUCT LIST PRICES
# Maps product_id -> list_price to ensure 100% pricing alignment
products_lookup = {p["product_id"]: p["list_price"] for p in products}

# mst_warehouses (20 Global Warehouses)
warehouses = [
    (1, "WH-US-EAST1", "US East NJ Hub", 1, 350000),
    (2, "WH-US-WEST1", "US West CA Hub", 2, 400000),
    (3, "WH-US-CENT1", "US Central TX Hub", 4, 300000),
    (4, "WH-CA-TOR1", "Canada Ontario Hub", 5, 200000),
    (5, "WH-MX-CDMX", "Mexico Regional Node", 7, 180000),
    (6, "WH-UK-LON1", "UK London Hub", 9, 250000),
    (7, "WH-DE-BER1", "Germany Berlin Hub", 11, 280000),
    (8, "WH-FR-PAR1", "France Paris Node", 13, 200000),
    (9, "WH-ES-MAD1", "Spain Madrid Node", 16, 170000),
    (10, "WH-JP-TYO1", "Japan Tokyo Central", 20, 300000),
    (11, "WH-CN-SHG1", "China Shanghai Hub", 22, 500000),
    (12, "WH-CN-SZN1", "China Shenzhen Mega-Hub", 23, 600000),
    (13, "WH-SG-SIN1", "Singapore APAC Node", 24, 220000),
    (14, "WH-KR-SEL1", "South Korea Hub", 25, 190000),
    (15, "WH-AU-SYD1", "Australia Sydney Node", 26, 210000),
    (16, "WH-IN-BOM1", "India Mumbai Hub", 28, 350000),
    (17, "WH-BR-SAO1", "Brazil Sao Paulo Hub", 31, 250000),
    (18, "WH-AE-DXB1", "UAE Dubai Hub", 34, 280000),
    (19, "WH-ZA-JNB1", "South Africa JNB Node", 37, 150000),
    (20, "WH-EG-CAI1", "Egypt Cairo Node", 38, 140000),
]
df_wh = pd.DataFrame(
    warehouses,
    columns=[
        "warehouse_id",
        "warehouse_code",
        "warehouse_name",
        "geo_id",
        "capacity_sqft",
    ],
)
df_wh.to_csv(os.path.join(OUTPUT_DIR, "mst_warehouses.csv"), index=False)
print("  ✓ mst_warehouses.csv created (20 Global Distribution Centers)")

# -------------------------------------------------------------------
# 3. Tier 3: High-Volume Transaction Tables (txn_*)
# -------------------------------------------------------------------

NUM_ORDERS = 1000000  # 1,000,000 Orders Benchmark
BATCH_SIZE = 100000  # Batch processing size
print(
    f"\nGenerating {NUM_ORDERS:,} Orders & Transaction Line Items in"
    " Batches..."
)

statuses = ["Delivered", "Shipped", "Pending", "Cancelled"]
status_weights = [0.82, 0.08, 0.05, 0.05]
shipping_modes = ["Standard", "Express", "Overnight", "Economy"]

customer_ids = df_cust["customer_id"].tolist()
payment_method_ids = df_pm["payment_method_id"].tolist()
warehouse_ids = df_wh["warehouse_id"].tolist()

orders_accumulator = []
order_items_accumulator = []
returns_accumulator = []
reviews_accumulator = []

line_item_id_counter = 1
return_id_counter = 1
review_id_counter = 1

start_date_range = datetime(2023, 1, 1)
end_date_range = datetime(2026, 7, 31)
total_seconds = int((end_date_range - start_date_range).total_seconds())

for order_id in range(1, NUM_ORDERS + 1):
  # Random timestamp distribution across 3.5 years
  random_second = random.randint(0, total_seconds)
  order_dt = start_date_range + timedelta(seconds=random_second)
  status = random.choices(statuses, weights=status_weights)[0]

  # Shipping Date Logic & Anomalies
  if status == "Delivered":
    ship_dt = order_dt + timedelta(days=random.randint(1, 4))
  elif status == "Shipped":
    if random.random() < 0.01:
      ship_dt = None  # Anomaly: Logging timeout
    else:
      ship_dt = order_dt + timedelta(days=random.randint(1, 3))
  else:
    ship_dt = None

  cust_id = random.choice(customer_ids)
  orders_accumulator.append({
      "order_id": order_id,
      "customer_id": cust_id,
      "payment_method_id": random.choice(payment_method_ids),
      "shipping_geo_id": random.choice(geo_ids),
      "order_date": order_dt.strftime("%Y-%m-%d %H:%M:%S"),
      "ship_date": ship_dt.strftime("%Y-%m-%d %H:%M:%S") if ship_dt else np.nan,
      "order_status": status,
      "shipping_mode": random.choice(shipping_modes),
  })

  # Generate 1 to 4 Line Items per order (Average 2.5 items/order -> ~2.5M line items total)
  num_items = random.randint(1, 4)
  selected_prod_ids = random.sample(range(1, NUM_PRODUCTS + 1), num_items)

  for prod_id in selected_prod_ids:
    # PULL ACTUAL LIST PRICE FROM PRODUCTS LOOKUP DICTIONARY
    unit_price = products_lookup[prod_id]
    qty = random.randint(1, 4)

    if random.random() < 0.65:
      discount = 0.00
    else:
      discount = round(unit_price * qty * random.uniform(0.05, 0.15), 2)

    tax = round((unit_price * qty - discount) * 0.08, 2)
    allocated_shipping = round(random.uniform(2.5, 12.0), 2)

    order_items_accumulator.append({
        "line_item_id": line_item_id_counter,
        "order_id": order_id,
        "product_id": prod_id,
        "warehouse_id": random.choice(warehouse_ids),
        "quantity": qty,
        "unit_price": unit_price,
        "discount_amount": discount,
        "tax_amount": tax,
        "shipping_cost_allocated": allocated_shipping,
    })

    # Reverse Logistics (8% Return Rate on Delivered items)
    if status == "Delivered" and random.random() < 0.08:
      ret_dt = order_dt + timedelta(days=random.randint(3, 21))
      returns_accumulator.append({
          "return_id": return_id_counter,
          "line_item_id": line_item_id_counter,
          "return_date": ret_dt.strftime("%Y-%m-%d %H:%M:%S"),
          "return_reason": random.choice(
              ["Defective", "Wrong Item", "Late Delivery", "Buyer Remorse"]
          ),
          "refund_amount": round((qty * unit_price) - discount, 2),
      })
      return_id_counter += 1

    # Product Reviews (10% of Delivered purchases leave reviews)
    if status == "Delivered" and random.random() < 0.10:
      rev_dt = order_dt + timedelta(days=random.randint(2, 25))
      reviews_accumulator.append({
          "review_id": review_id_counter,
          "product_id": prod_id,
          "customer_id": cust_id,
          "rating": random.choices(
              [1, 2, 3, 4, 5], weights=[0.05, 0.05, 0.15, 0.35, 0.40]
          )[0],
          "review_date": rev_dt.strftime("%Y-%m-%d %H:%M:%S"),
          "review_text": (
              np.nan if random.random() < 0.15 else fake.sentence()
          ),
      })
      review_id_counter += 1

    line_item_id_counter += 1

  # Print Batch Progress
  if order_id % BATCH_SIZE == 0:
    print(
        f"  ... Processed {order_id:,} / {NUM_ORDERS:,} orders"
        f" ({len(order_items_accumulator):,} line items generated)"
    )

# Export High Volume Transaction Data into GitHub-Compliant Chunks
print("\nSaving Transaction Datasets to Chunked CSV Files...")
df_orders = pd.DataFrame(orders_accumulator)
save_dataframe_in_chunks(df_orders, "txn_orders", max_rows_per_file=250000)
del orders_accumulator, df_orders  # Free RAM

df_order_items = pd.DataFrame(order_items_accumulator)
save_dataframe_in_chunks(
    df_order_items, "txn_order_items", max_rows_per_file=250000
)
del order_items_accumulator, df_order_items  # Free RAM

df_returns = pd.DataFrame(returns_accumulator)
save_dataframe_in_chunks(df_returns, "txn_returns", max_rows_per_file=250000)
del returns_accumulator, df_returns  # Free RAM

df_reviews = pd.DataFrame(reviews_accumulator)
save_dataframe_in_chunks(
    df_reviews, "txn_product_reviews", max_rows_per_file=250000
)
del reviews_accumulator, df_reviews  # Free RAM

# Inventory Snapshots (20 WHs x 1,000 sampled SKUs x 12 Months = 240,000 rows)
print("Generating Inventory Snapshots...")
inventory = []
inv_id = 1
dates = pd.date_range(start="2024-01-01", periods=12, freq="MS")
sampled_products = random.sample(range(1, NUM_PRODUCTS + 1), 1000)

for dt in dates:
  for wh_id in warehouse_ids:
    for prod_id in sampled_products:
      inventory.append({
          "inventory_id": inv_id,
          "warehouse_id": wh_id,
          "product_id": prod_id,
          "snapshot_date": dt.strftime("%Y-%m-%d"),
          "stock_on_hand": random.randint(5, 600),
          "reorder_level": 50,
      })
      inv_id += 1

df_inv = pd.DataFrame(inventory)
save_dataframe_in_chunks(
    df_inv, "txn_inventory_snapshots", max_rows_per_file=250000
)

print("\nSUCCESS! Enterprise Data Pipeline Execution Complete.")