/* 
============================================================================
Projet          : URBANCLICK ENTERPRISE E-COMMERCE ANALYTICS PLATFORM
Script 01       : Physical Schema DDL, Constraints, and Strategic Indexes
Target Database : MySQL 8.0+
Author          : Ravi Prajapati
Purpose:        : Creation of database and tables
============================================================================
*/

DROP DATABASE IF EXISTS urbanclick_db;
CREATE DATABASE urbanclick_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE urbanclick_db;

-- ----------------------------------------------------------------------------
-- 1. TIER 1: LOOKUP TABLES (lkp_*)
-- ----------------------------------------------------------------------------

CREATE TABLE lkp_geography (
    geo_id INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    postal_code VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE lkp_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    sub_category_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE lkp_payment_methods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_type VARCHAR(50) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. TIER 2: MASTER ENTITY TABLES (mst_*)
-- ----------------------------------------------------------------------------

CREATE TABLE mst_customers (
    customer_id INT PRIMARY KEY,
    geo_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(50) NULL,
    signup_date DATE NOT NULL,
    customer_segment VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cust_geo FOREIGN KEY (geo_id) REFERENCES lkp_geography(geo_id)
) ENGINE=InnoDB;

CREATE TABLE mst_products (
    product_id INT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    list_price DECIMAL(10,2) NOT NULL,
    weight_kg DECIMAL(6,2) NOT NULL,
    length_cm DECIMAL(10,2) NOT NULL,
    width_cm DECIMAL(10,2) NOT NULL,
    height_cm DECIMAL(10,2) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    supplier VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prod_cat FOREIGN KEY (category_id) REFERENCES lkp_categories(category_id),
    CONSTRAINT chk_price_cost CHECK (list_price >= unit_cost)
) ENGINE=InnoDB;

CREATE TABLE mst_warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_code VARCHAR(20) UNIQUE NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL,
    geo_id INT NOT NULL,
    capacity_sqft INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wh_geo FOREIGN KEY (geo_id) REFERENCES lkp_geography(geo_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. TIER 3: TRANSACTIONAL FACT TABLES (txn_*)
-- ----------------------------------------------------------------------------

CREATE TABLE txn_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    payment_method_id INT NOT NULL,
    shipping_geo_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    ship_date DATETIME NULL,
    order_status VARCHAR(50) NOT NULL,
    shipping_mode VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ord_cust FOREIGN KEY (customer_id) REFERENCES mst_customers(customer_id),
    CONSTRAINT fk_ord_pm FOREIGN KEY (payment_method_id) REFERENCES lkp_payment_methods(payment_method_id),
    CONSTRAINT fk_ord_geo FOREIGN KEY (shipping_geo_id) REFERENCES lkp_geography(geo_id)
) ENGINE=InnoDB;

CREATE TABLE txn_order_items (
    line_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_cost_allocated DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_item_ord FOREIGN KEY (order_id) REFERENCES txn_orders(order_id),
    CONSTRAINT fk_item_prod FOREIGN KEY (product_id) REFERENCES mst_products(product_id),
    CONSTRAINT fk_item_wh FOREIGN KEY (warehouse_id) REFERENCES mst_warehouses(warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE txn_returns (
    return_id INT PRIMARY KEY,
    line_item_id INT NOT NULL,
    return_date DATETIME NOT NULL,
    return_reason VARCHAR(100) NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ret_item FOREIGN KEY (line_item_id) REFERENCES txn_order_items(line_item_id)
) ENGINE=InnoDB;

CREATE TABLE txn_product_reviews (
    review_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating TINYINT NOT NULL,
    review_date DATETIME NOT NULL,
    review_text TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rev_prod FOREIGN KEY (product_id) REFERENCES mst_products(product_id),
    CONSTRAINT fk_rev_cust FOREIGN KEY (customer_id) REFERENCES mst_customers(customer_id),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE txn_inventory_snapshots (
    inventory_id INT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    snapshot_date DATE NOT NULL,
    stock_on_hand INT NOT NULL,
    reorder_level INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inv_wh FOREIGN KEY (warehouse_id) REFERENCES mst_warehouses(warehouse_id),
    CONSTRAINT fk_inv_prod FOREIGN KEY (product_id) REFERENCES mst_products(product_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. PERFORMANCE INDEXES FOR HIGH-VOLUME ANALYTICS
-- ----------------------------------------------------------------------------

CREATE INDEX idx_orders_customer_date ON txn_orders(customer_id, order_date);
CREATE INDEX idx_orders_status_date ON txn_orders(order_status, order_date);
CREATE INDEX idx_order_items_order_prod ON txn_order_items(order_id, product_id);
CREATE INDEX idx_order_items_wh ON txn_order_items(warehouse_id);
CREATE INDEX idx_returns_line_item ON txn_returns(line_item_id);
CREATE INDEX idx_reviews_product_rating ON txn_product_reviews(product_id, rating);
CREATE INDEX idx_inv_wh_date ON txn_inventory_snapshots(warehouse_id, snapshot_date);