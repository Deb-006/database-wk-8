-- ===========================================
-- E-COMMERCE STORE DATABASE SCHEMA
-- Deliverable: CREATE DATABASE + CREATE TABLEs + Relationship constraints
-- Engine: MySQL (InnoDB)
-- ===========================================

-- Drop database if it exists (safe to re-run)
DROP DATABASE IF EXISTS ecommerce_store;
CREATE DATABASE ecommerce_store CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_store;

-- =========================
-- NOTES ON RELATIONSHIPS:
-- - One-to-One: customers -> customer_profiles (same PK)
-- - One-to-Many: customers -> orders ; products -> order_items
-- - Many-to-Many: products <-> categories via product_categories
-- =========================

-- -------------------------
-- Users / Customers
-- -------------------------
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(30),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- other fields (e.g., status) could be added
    INDEX (email)
) ENGINE=InnoDB;

-- -------------------------
-- One-to-One: Customer Profile
-- (stores optional extended profile data; PK = FK to customers to enforce one-to-one)
-- -------------------------
DROP TABLE IF EXISTS customer_profiles;
CREATE TABLE customer_profiles (
    customer_id INT PRIMARY KEY,
    birthday DATE,
    gender ENUM('male','female','other') DEFAULT NULL,
    preferred_language VARCHAR(10) DEFAULT 'en',
    marketing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -------------------------
-- Addresses (One-to-Many: a customer can have many addresses)
-- -------------------------
DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    label VARCHAR(50), -- e.g., 'Home', 'Office'
    line1 VARCHAR(255) NOT NULL,
    line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(30),
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES customers(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -------------------------
-- Products table
-- -------------------------
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,         -- stock-keeping unit
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) DEFAULT NULL,
    vendor VARCHAR(150),
    stock_quantity INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX (sku),
    FULLTEXT KEY ft_name_description (name, description)
) ENGINE=InnoDB;

-- -------------------------
-- Categories (Many-to-Many with Products)
-- -------------------------
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description VARCHAR(255),
    parent_id INT DEFAULT NULL, -- for category hierarchy (self-referencing)
    FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Junction table: product_categories (Many-to-Many)
DROP TABLE IF EXISTS product_categories;
CREATE TABLE product_categories (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -------------------------
-- Inventory movements (example for inventory tracking)
-- -------------------------
DROP TABLE IF EXISTS inventory_transactions;
CREATE TABLE inventory_transactions (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    change INT NOT NULL, -- positive or negative
    reason VARCHAR(100),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -------------------------
-- Orders (One-to-Many: customer -> orders)
-- -------------------------
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_status ENUM('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipped_date DATETIME DEFAULT NULL,
    billing_address_id INT DEFAULT NULL,
    shipping_address_id INT DEFAULT NULL,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    payment_status ENUM('unpaid','paid','refunded') NOT NULL DEFAULT 'unpaid',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -------------------------
-- OrderItems (Many-to-Many via this line-level table)
-- Each row is product purchased on an order: composite primary key (order_id, product_id)
-- -------------------------
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL, -- price at time of order
    discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------
-- Payments (One-to-Many: order -> payments)
-- -------------------------
DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('card','paypal','bank_transfer','cash_on_delivery') NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    transaction_reference VARCHAR(255) UNIQUE,
    status ENUM('initiated','completed','failed','refunded') NOT NULL DEFAULT 'initiated',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -------------------------
-- Product Reviews (One-to-Many: product -> reviews)
-- -------------------------
DROP TABLE IF EXISTS product_reviews;
CREATE TABLE product_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT DEFAULT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    body TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -------------------------
-- Suppliers (example entity)
-- -------------------------
DROP TABLE IF EXISTS suppliers;
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(150),
    phone VARCHAR(50),
    email VARCHAR(255) UNIQUE,
    address VARCHAR(255)
) ENGINE=InnoDB;

-- Supplier-Product relationship (One-to-Many: supplier -> products)
ALTER TABLE products
    ADD COLUMN supplier_id INT DEFAULT NULL,
    ADD FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL;

-- -------------------------
-- Audit / Activity log (simple example)
-- -------------------------
DROP TABLE IF EXISTS activity_logs;
CREATE TABLE activity_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    actor_type ENUM('customer','admin','system') NOT NULL,
    actor_id INT DEFAULT NULL,
    action VARCHAR(100) NOT NULL,
    details JSON,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================
-- Example Indexes & Views (optional helpers)
-- =========================

-- Index to speed up product lookups by active + price
CREATE INDEX idx_products_active_price ON products (active, price);

-- A simple view to show order totals (calculated)
DROP VIEW IF EXISTS vw_order_summary;
CREATE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(oi.unit_price * oi.quantity - oi.discount) AS computed_items_total,
    o.shipping_cost,
    o.tax_amount,
    o.total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.customer_id, o.order_date, o.shipping_cost, o.tax_amount, o.total;

-- =========================
-- SAMPLE DATA (optional, uncomment to insert)
-- =========================
/*
-- Example customers
INSERT INTO customers (email, password_hash, first_name, last_name, phone)
VALUES
('alice@example.com', 'hash_xxx', 'Alice', 'Brown', '08012345678'),
('bob@example.com', 'hash_yyy', 'Bob', 'Smith', '08098765432');

-- Example categories
INSERT INTO categories (name, slug) VALUES ('Electronics', 'electronics'), ('Accessories', 'accessories');

-- Example products
INSERT INTO suppliers (name) VALUES ('Acme Supplies');
INSERT INTO products (sku, name, description, price, stock_quantity, supplier_id)
VALUES ('SKU-001','Laptop A','Powerful laptop', 1500.00, 10, 1),
       ('SKU-002','Wireless Mouse','Ergonomic mouse', 25.00, 200, 1);

-- Link products to categories
INSERT INTO product_categories (product_id, category_id) VALUES (1,1), (2,2);
*/

-- ===========================================
-- End of schema
-- ===========================================