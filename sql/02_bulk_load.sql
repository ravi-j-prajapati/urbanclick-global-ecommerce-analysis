/*
============================================================================
Project         : URBANCLICK ENTERPRISE E-COMMERCE ANALYTICS PLATFORM
Script 02       : High-Performance Bulk Data Pipeline
Author          : Ravi Prajapati
Purpose         : Seed data into created data tables.
============================================================================
*/

USE urbanclick_db;

-- Ensure Local File Infile loading is enabled
SET GLOBAL local_infile = 1;

-- Disable key checks and autocommit temporarily to accelerate 3M+ row import
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET SQL_LOG_BIN = 0;

-- ----------------------------------------------------------------------------
-- 1. LOAD LOOKUP TABLES
-- ----------------------------------------------------------------------------

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/lkp_geography.csv'
INTO TABLE lkp_geography
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(geo_id, city, state_province, country, region, postal_code);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/lkp_categories.csv'
INTO TABLE lkp_categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(category_id, category_name, sub_category_name);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/lkp_payment_methods.csv'
INTO TABLE lkp_payment_methods
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(payment_method_id, payment_type, provider);

-- ----------------------------------------------------------------------------
-- 2. LOAD MASTER TABLES (Handles Split Files & NULL Values)
-- ----------------------------------------------------------------------------

-- Customers Split Files
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/mst_customers_part1.csv'
INTO TABLE mst_customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, geo_id, first_name, last_name, email, @phone, signup_date, customer_segment)
SET customer_phone = NULLIF(TRIM(@phone), '');

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/mst_customers_part2.csv'
INTO TABLE mst_customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, geo_id, first_name, last_name, email, @phone, signup_date, customer_segment)
SET customer_phone = NULLIF(TRIM(@phone), '');

-- Products
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/mst_products.csv'
INTO TABLE mst_products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, category_id, product_name, unit_cost, list_price, weight_kg, length_cm, width_cm, height_cm, manufacturer, supplier);

-- Warehouses
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/mst_warehouses.csv'
INTO TABLE mst_warehouses
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(warehouse_id, warehouse_code, warehouse_name, geo_id, capacity_sqft);

-- ----------------------------------------------------------------------------
-- 3. LOAD TRANSACTION FACT TABLES (Chunked Imports)
-- ----------------------------------------------------------------------------

-- Orders (4 Chunks)
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_orders_part1.csv'
INTO TABLE txn_orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(order_id, customer_id, payment_method_id, shipping_geo_id, order_date, @ship_date, order_status, shipping_mode)
SET ship_date = NULLIF(TRIM(@ship_date), '');

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_orders_part2.csv'
INTO TABLE txn_orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(order_id, customer_id, payment_method_id, shipping_geo_id, order_date, @ship_date, order_status, shipping_mode)
SET ship_date = NULLIF(TRIM(@ship_date), '');

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_orders_part3.csv'
INTO TABLE txn_orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(order_id, customer_id, payment_method_id, shipping_geo_id, order_date, @ship_date, order_status, shipping_mode)
SET ship_date = NULLIF(TRIM(@ship_date), '');

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_orders_part4.csv'
INTO TABLE txn_orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(order_id, customer_id, payment_method_id, shipping_geo_id, order_date, @ship_date, order_status, shipping_mode)
SET ship_date = NULLIF(TRIM(@ship_date), '');

-- Order Items (10 Chunks)
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part1.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part2.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part3.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part4.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part5.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part6.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part7.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part8.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part9.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_order_items_part10.csv'
INTO TABLE txn_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(line_item_id, order_id, product_id, warehouse_id, quantity, unit_price, discount_amount, tax_amount, shipping_cost_allocated);

-- Returns
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_returns.csv'
INTO TABLE txn_returns FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(return_id, line_item_id, return_date, return_reason, refund_amount);


-- Reviews 
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_product_reviews.csv'
INTO TABLE txn_product_reviews FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(review_id, product_id, customer_id, rating, review_date, @text)
SET review_text = NULLIF(TRIM(@text), '');


-- Inventory Snapshots
LOAD DATA LOCAL INFILE 'D:/Study/Dashboard Portfolio/Project-1_urbanclick-global-ecommerce-analysis/urbanclick-global-ecommerce-analysis/data_pipeline/raw/txn_inventory_snapshots.csv'
INTO TABLE txn_inventory_snapshots FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(inventory_id, warehouse_id, product_id, snapshot_date, stock_on_hand, reorder_level);

-- Re-enable constraints and consistency checks
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;