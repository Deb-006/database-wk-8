# database-wk-8
Week 8 Database Assignment
Database Management System (E-Commerce Store)

📌 Overview

This project implements a relational database management system (RDBMS) for an E-Commerce Store using MySQL. The system is designed to handle customers, orders, products, categories, and payments. It follows proper database design principles, normalization, and relationship constraints.



🎯 Objectives

Apply good database design practices.

Implement relationships (One-to-One, One-to-Many, Many-to-Many).

Use constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL).

Provide a scalable structure for real-world e-commerce operations.



🗂 Database Schema

1. Customers Table

Stores customer details.

Primary Key: customer_id

Constraints: email is UNIQUE.


2. Customer Profiles Table

One-to-One relationship with customers.

Primary Key & Foreign Key: customer_id

Ensures each customer has at most one profile.


3. Orders Table

One-to-Many relationship with customers.

Each order belongs to a customer.

Foreign Key: customer_id


4. Products Table

Stores product information.

Primary Key: product_id

Includes price, stock, and vendor.


5. Categories Table

Defines product categories.

Primary Key: category_id


6. Product Categories (Junction Table)

Implements a Many-to-Many relationship between products and categories.

Composite Primary Key: (product_id, category_id)

Both are Foreign Keys.


7. Order Items Table

One-to-Many relationship with orders and products.

Composite Primary Key: (order_id, product_id)

Stores product quantities and price per order.


8. Payments Table

One-to-One relationship with orders.

Primary Key & Foreign Key: order_id

Stores payment details.



🔗 Relationships Summary

One-to-One:

Customers ↔ Customer Profiles

Orders ↔ Payments


One-to-Many:

Customers ↔ Orders

Orders ↔ Order Items

Products ↔ Order Items


Many-to-Many:

Products ↔ Categories (via product_categories)



✅ Constraints Used

PRIMARY KEY → Ensures entity uniqueness.

FOREIGN KEY → Maintains referential integrity.

NOT NULL → Prevents missing required data.

UNIQUE → Prevents duplicate values (e.g., customer email).



🛠 Example Workflow

1. A customer registers → entry in customers and optional customer_profiles.


2. Customer places an order → stored in orders.


3. Products added to the order → stored in order_items.


4. Order payment is processed → stored in payments.




📂 Deliverables

answers.sql → Contains all CREATE DATABASE and CREATE TABLE statements with constraints.

README (this file) → Explains schema design, relationships, and constraints.




🚀 Conclusion

This relational database system demonstrates:

Correct normalization and elimination of redundancy.

Use of all major relationship types.

Strong foundation for extending into a fully functional e-commerce application.
