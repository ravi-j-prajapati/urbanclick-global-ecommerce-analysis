/*
============================================================================
Project         : URBANCLICK ENTERPRISE E-COMMERCE ANALYTICS PLATFORM
Script 03       : Automated Data Validation & Quality Verification
Author          : Ravi Prajapati
Purpose         : Validation of imported data
============================================================================
*/

USE urbanclick_db;

-- 1. Record Count Sanity Audit
SELECT 'lkp_geography' AS table_name, COUNT(*) AS total_rows FROM lkp_geography
UNION ALL
SELECT 'lkp_categories', COUNT(*) FROM lkp_categories
UNION ALL
SELECT 'lkp_payment_methods', COUNT(*) FROM lkp_payment_methods
UNION ALL
SELECT 'mst_customers', COUNT(*) FROM mst_customers
UNION ALL
SELECT 'mst_products', COUNT(*) FROM mst_products
UNION ALL
SELECT 'mst_warehouses', COUNT(*) FROM mst_warehouses
UNION ALL
SELECT 'txn_orders', COUNT(*) FROM txn_orders
UNION ALL
SELECT 'txn_order_items', COUNT(*) FROM txn_order_items
UNION ALL
SELECT 'txn_returns', COUNT(*) FROM txn_returns
UNION ALL
SELECT 'txn_product_reviews', COUNT(*) FROM txn_product_reviews
UNION ALL
SELECT 'txn_inventory_snapshots', COUNT(*) FROM txn_inventory_snapshots;

-- 2. Referential Integrity & Orphan Record Audit (Must return 0 for all)
SELECT 
    (SELECT COUNT(*) FROM txn_orders o LEFT JOIN mst_customers c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL) AS orphan_orders_customers,
    (SELECT COUNT(*) FROM txn_order_items i LEFT JOIN txn_orders o ON i.order_id = o.order_id WHERE o.order_id IS NULL) AS orphan_items_orders,
    (SELECT COUNT(*) FROM txn_returns r LEFT JOIN txn_order_items i ON r.line_item_id = i.line_item_id WHERE i.line_item_id IS NULL) AS orphan_returns_items;

-- 3. Top-level Financial Metrics Quick Summary

SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity * unit_price) AS gross_sales_usd,
    SUM(discount_amount) AS total_discounts_usd,
    SUM(quantity * unit_price - discount_amount) AS net_sales_usd
FROM txn_order_items;