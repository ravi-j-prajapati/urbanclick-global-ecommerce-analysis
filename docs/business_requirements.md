# Business Requirements Document (BRD)
**Project Title:** UrbanClick Enterprise Global E-Commerce Analytics Platform  
**Repository:** `urbanclick-global-ecommerce-analysis`  
**Document ID:** BRD-UC-2026-V1  
**Version:** 1.0.0  
**Date:**  2026-07-31  
**Target Database Engine:** MySQL 8.0 (OLTP Operational Source)  

---

## 1. Executive Summary & Context

UrbanClick is a global e-commerce enterprise operating across multiple regional markets, managing cross-border supply chain operations, multi-channel customer acquisition, dynamic inventory distribution, and reverse logistics.

This project establishes an enterprise data platform designed to centralize, standardize, and analyze transactional, customer, operational, and financial metrics. The underlying operational database architecture follows a **3-tier normalized schema** (Lookup, Master, and Transaction tiers) to ensure transactional integrity, eliminate redundancy, and serve as an extensible source for downstream dimensional modeling, Power BI dashboards, and Tableau exploratory analytics.

---

## 2. Core Business Objectives

* **Fulfillment & Logistics Optimization:** Track warehouse inventory velocity, monitor regional shipping SLAs, and pinpoint supply chain bottlenecks.
* **Financial Integrity & Profitability:** Calculate Net Sales, Gross Margin, Tax Allocations, and Refund Impact across dynamic product categories and currencies.
* **Customer Lifecycle Intelligence:** Measure customer acquisition dynamics, retention rates, order frequency, and Lifetime Value (LTV).
* **Product & Category Performance:** Track category-level margin leakage, unit sales velocity, return rates, and customer sentiment metrics.

---

## 3. Three-Tier Operational Schema Architecture

```text
+-------------------------------------------------------------------+
|                     TIER 1: LOOKUP (lkp_*)                        |
|  [lkp_geography]     [lkp_categories]    [lkp_payment_methods]    |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                     TIER 2: MASTER (mst_*)                        |
|  [mst_customers]      [mst_products]       [mst_warehouses]       |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                  TIER 3: TRANSACTION (txn_*)                      |
|  [txn_orders] ---------> [txn_order_items] ----> [txn_returns]    |
|       |                        |                       |          |
|       v                        v                       v          |
| [txn_product_reviews]  [txn_inventory_snapshots]                |
+-------------------------------------------------------------------+
```
---

### Tier 1: Reference/Lookup Layer (lkp_*)

1. ` lkp_geography `
    - **Purpose:** Unified spatial reference for customers, warehouses, and delivery points.
    - **Primary Key:** `geo_id` (INT)
    - **Attributes:** `city` (VARCHAR(100)), `state_province` (VARCHAR(100)), `country` (VARCHAR(100)), `region` (VARCHAR(50)), `postal_code` (VARCHAR(50))

2. `lkp_categories`
    -   **Purpose:** Multi-level product classification structure.
    -   **Primary Key:** `category_id` (INT)
    -  **Attributes:** `category_name` (VARCHAR(100)), `sub_category_name` (VARCHAR(100))

3. `lkp_payment_methods`
    -   **Purpose:** Supported payment types and processing vendors.
    -   **Primary Key:** `payment_method_id` (INT)
    -  **Attributes:** `payment_type` (VARCHAR(50)), `provider` (VARCHAR(50))

### Tier 2: Master Data Layer (mst_*)

4. `mst_customers`
    - **Purpose:** Centralized customer demographic profiles.
    - **Primary Key:** `customer_id` (INT)
    - **Foreign Key:** `geo_id` -> lkp_geography(`geo_id`)
    - **Attributes:** `first_name` (VARCHAR(100)), `last_name` (VARCHAR(100)), `email` (VARCHAR(100)), `signup_date` (DATE), `customer_phone` (VARCHAR(100)), `customer_segment` (VARCHAR(50))

5. `mst_products`
    - **Purpose:** Product catalog with cost baselines and retail pricing.
    - **Primary Key:** `product_id` (INT)
    - **Foreign key:** `category_id` -> lkp_categories(`category_id`)
    - **Attributes:** `product_name` (VARCHAR(150)), `unit_cost` (DECIMAL(10,2)), `list_price` (DECIMAL(10,2)), `weight_kg` (DECIMAL(6,2)), `length_cm` (DECIMAL(10,2)), `width_cm` (DECIMAL(10,2)), `height_cm` (DECIMAL(10,2)), `manufacturer` (VARCHAR(100)), `supplier` (VARCHAR(100))

6. `mst_warehouses`
    - **Purpose:** Catalog of active global distribution nodes.
    - **Primary Key:** `warehouse_id` (INT)
    - **Foreign key:** `geo_id` -> lkp_geography(`geo_id`)
    - **Attributes:** `warehouse_code` (VARCHAR(20)), `warehouse_name` (VARCHAR(100)), `capacity_sqft` (INT)

### Tier 3: Operational Transaction Layer (txn_*)

7. `txn_orders`
    - **Purpose:** Header-level transactional records for sales orders.
    - **Primary Key:** `order_id` (INT)
    - **Foreign key:**
        - `customer_id` -> mst_customers(`customer_id`)
        - `payment_method_id` -> lkp_payment_methods(`payment_method_id`)
        - `shipping_geo_id` -> lkp_geography(`geo_id`)
    - **Attributes:** `order_date` (DATETIME), `ship_date` (DATETIME), `order_status` (VARCHAR(50)), `shipping_mode` (VARCHAR(50))

8. `txn_order_items`
    - **Purpose:** Line-item transaction breakdown linking orders to items and fulfilling warehouses.
    - **Primary Key:** `line_item_id` (INT)
    - **Foreign key:**
        - `order_id` -> txn_orders(`order_id`)
        - `product_id` -> mst_products(`product_id`)
        - `warehouse_id` -> mst_warehouses(`warehouse_id`)
    - **Attributes:** `quantity` (INT), `unit_price` (DECIMAL(10,2)), `discount_amount` (DECIMAL(10,2)), `tax_amount` (DECIMAL(10,2)), `shipping_cost_allocated` (DECIMAL(10,2))

9. `txn_returns`
    - **Purpose:** Reverse logistics tracking and refund disposition.
    - **Primary Key:** `return_id` (INT)
    - **Foreign key:** `line_item_id` -> txn_order_items(`line_item_id`)
    - **Attributes:** `return_date` (DATETIME), `return_reason` (VARCHAR(100)), `refund_amount` (DECIMAL(10,2))

10. `txn_product_reviews`
    - **Purpose:** Quantitative customer feedback and reviews.
    - **Primary Key:** `review_id` (INT)
    - **Foreign key:**
        - `product_id` -> mst_products(`product_id`)
        - `customer_id` -> mst_customers(`customer_id`)
    - **Attributes:** `rating` (TINYINT), `review_date` (DATETIME), `review_text` (TEXT)

11. `txn_inventory_snapshots`
    - **Purpose:** Periodic warehouse stock level tracking.
    - **Primary Key:** `inventory_id` (INT)
    - **Foreign key:**
        - `warehouse_id` -> mst_warehouses(`warehouse_id`)
        - `product_id` -> mst_products(`product_id`)
    - **Attributes:** `snapshot_date` (DATE), `stock_on_hand` (INT), `reorder_level` (INT)

## 4. Entity Integrity & Business Rules
- **Referential Integrity:** Parent table record deletions (lkp_*, mst_*) are restricted (ON DELETE RESTRICT) when child records exist. Primary Key updates cascade (ON UPDATE CASCADE).
- **Uniqueness Constraints:** mst_customers(email) and mst_warehouses(warehouse_code) must enforce UNIQUE indexes.
- **Check Constraints:**
    - `txn_order_items`.`quantity` > 0
    - `txn_product_reviews`.`rating` BETWEEN 1 AND 5
    - `mst_products`.`list_price` >= mst_products.unit_cost
- **Chronological Integrity:** `order_date` <= `ship_date` and `order_date` <= `return_date`.

## 5. Functional Scope & Analytical Coverage

|    Operational   Area    |                  Primary   Source Tables                       |                   Key   Analytics & Output                  |
|:------------------------:|:--------------------------------------------------------------:|:-----------------------------------------------------------:|
|      Sales & Revenue     |         `txn_orders`, `txn_order_items`, `mst_products`        |       Net Revenue, Gross Margin %, Average Order Value      |
| Supply Chain & Inventory | `txn_order_items`, `mst_warehouses`, `txn_inventory_snapshots` | Stock Turnover Rate, Stockout Occurrences, Outflow   Volume |
|   Customer Intelligence  |      `mst_customers`, `txn_orders`, `txn_product_reviews`      |  Repeat Purchase Rate, Customer LTV, Rating   Distribution  |
|     Reverse Logistics    |        `txn_returns`, `txn_order_items`, `mst_products`        |     Return Rate %, Refund Value, Return Reason Breakdown    |

## 6. Data Governance & Compliance Standard

1. **PII Protection:** Customer names and emails must be masked or anonymized prior to pushing public analytical datasets or dashboard files.
2. **Data Pipeline Consistency:** The Python synthetic engine must guarantee 100% referential consistency across all generated primary and foreign key pairs.


---