CREATE DATABASE schedulers;
USE schedulers;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    registration_date DATE,
    customer_segment VARCHAR(20),
    status VARCHAR(20)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    launch_date DATE,
    is_active BOOLEAN
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    order_status VARCHAR(20),
    payment_method VARCHAR(20),
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),

    FOREIGN KEY(customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    discount_pct DECIMAL(5,2),

    FOREIGN KEY(order_id)
    REFERENCES orders(order_id),

    FOREIGN KEY(product_id)
    REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_date DATETIME,
    payment_amount DECIMAL(12,2),
    payment_status VARCHAR(20),

    FOREIGN KEY(order_id)
    REFERENCES orders(order_id)
);


-- Warehouse Tables

CREATE TABLE sales_staging (
    staging_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT,
    customer_id INT,
    product_id INT,

    quantity INT,
    unit_price DECIMAL(10,2),
    discount_pct DECIMAL(5,2),

    revenue DECIMAL(12,2),

    load_timestamp DATETIME
);


CREATE TABLE sales_fact (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,

    order_id INT,
    customer_id INT,
    product_id INT,

    quantity INT,

    gross_revenue DECIMAL(12,2),
    net_revenue DECIMAL(12,2),

    order_date DATETIME,

    load_date DATETIME
);


CREATE TABLE daily_sales_summary (
    summary_date DATE PRIMARY KEY,

    total_orders INT,
    total_quantity INT,

    gross_revenue DECIMAL(12,2),
    net_revenue DECIMAL(12,2)
);


CREATE TABLE customer_summary (
    customer_id INT PRIMARY KEY,

    total_orders INT,
    total_spent DECIMAL(12,2),

    last_order_date DATETIME
);

CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,

    process_name VARCHAR(100),

    execution_time DATETIME,

    records_processed INT,

    status VARCHAR(20),

    comments VARCHAR(500)
);


INSERT INTO customers
(first_name,last_name,email,city,state,registration_date,customer_segment,status)
VALUES
('Rahul','Sharma','rahul.sharma@mail.com','Bangalore','KA','2025-01-15','Gold','Active'),
('Priya','Reddy','priya.reddy@mail.com','Hyderabad','TS','2025-02-10','Silver','Active'),
('Arjun','Nair','arjun.nair@mail.com','Chennai','TN','2025-03-05','Gold','Active'),
('Sneha','Patel','sneha.patel@mail.com','Mumbai','MH','2025-01-20','Bronze','Active'),
('Kiran','Kumar','kiran.kumar@mail.com','Pune','MH','2025-04-12','Silver','Active'),
('Ananya','Iyer','ananya.iyer@mail.com','Chennai','TN','2025-02-25','Gold','Active'),
('Vikram','Singh','vikram.singh@mail.com','Bangalore','KA','2025-03-18','Bronze','Active'),
('Meera','Joshi','meera.joshi@mail.com','Mumbai','MH','2025-04-01','Silver','Active'),
('Rohit','Verma','rohit.verma@mail.com','Hyderabad','TS','2025-05-10','Gold','Active'),
('Pooja','Gupta','pooja.gupta@mail.com','Pune','MH','2025-05-15','Bronze','Active');


INSERT INTO products
(product_name,category,brand,unit_price,cost_price,launch_date,is_active)
VALUES
('Laptop Pro 15','Electronics','Dell',75000,65000,'2024-01-01',1),
('Wireless Mouse','Electronics','Logitech',1200,700,'2024-02-01',1),
('Mechanical Keyboard','Electronics','Keychron',4500,3000,'2024-03-01',1),
('27 Inch Monitor','Electronics','Samsung',18000,14000,'2024-01-15',1),
('USB-C Hub','Accessories','Anker',2500,1500,'2024-04-01',1),
('Office Chair','Furniture','Ikea',12000,8500,'2024-02-15',1),
('Standing Desk','Furniture','Ikea',25000,18000,'2024-03-10',1),
('Noise Cancelling Headphones','Electronics','Sony',22000,17000,'2024-01-20',1),
('Webcam HD','Electronics','Logitech',5000,3500,'2024-04-05',1),
('External SSD 1TB','Storage','Samsung',8500,6500,'2024-05-01',1);

INSERT INTO orders
(customer_id,order_date,order_status,payment_method,shipping_city,shipping_state)
VALUES
(1,'2025-05-01 10:15:00','Delivered','Credit Card','Bangalore','KA'),
(2,'2025-05-02 11:00:00','Delivered','UPI','Hyderabad','TS'),
(3,'2025-05-03 09:30:00','Delivered','Debit Card','Chennai','TN'),
(4,'2025-05-04 14:20:00','Delivered','UPI','Mumbai','MH'),
(5,'2025-05-05 16:45:00','Delivered','Net Banking','Pune','MH'),
(6,'2025-05-06 12:10:00','Delivered','Credit Card','Chennai','TN'),
(7,'2025-05-07 18:30:00','Processing','UPI','Bangalore','KA'),
(8,'2025-05-08 13:15:00','Delivered','Credit Card','Mumbai','MH'),
(9,'2025-05-09 15:00:00','Shipped','UPI','Hyderabad','TS'),
(10,'2025-05-10 17:20:00','Delivered','Debit Card','Pune','MH');

INSERT INTO order_items
(order_id,product_id,quantity,unit_price,discount_pct)
VALUES
(1,1,1,75000,10),
(1,2,2,1200,0),
(2,3,1,4500,5),
(3,4,1,18000,0),
(4,5,2,2500,10),
(5,6,1,12000,0),
(6,7,1,25000,15),
(7,8,1,22000,5),
(8,9,2,5000,0),
(10,10,1,8500,0);


INSERT INTO payments
(order_id,payment_date,payment_amount,payment_status)
VALUES
(1,'2025-05-01 10:20:00',69900,'Success'),
(2,'2025-05-02 11:05:00',4275,'Success'),
(3,'2025-05-03 09:35:00',18000,'Success'),
(4,'2025-05-04 14:25:00',4500,'Success'),
(5,'2025-05-05 16:50:00',12000,'Success'),
(6,'2025-05-06 12:15:00',21250,'Success'),
(7,'2025-05-07 18:35:00',20900,'Pending'),
(8,'2025-05-08 13:20:00',10000,'Success'),
(9,'2025-05-09 15:05:00',22000,'Pending'),
(10,'2025-05-10 17:25:00',8500,'Success');

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT *FROM order_items;
SELECT *FROM payments;


-- ETL Goal

/*
 OLTP (Online Transaction Processing) database, is a system designed to execute and manage day-to-day, real-time business transactions
 
 Core Characteristics:
 1.Real-Time Processing: Designed to instantly record business interactions as they happen (e.g., a customer purchasing an item or transferring money)
 2.ACID Compliance: Guarantees strict data integrity using Atomicity, Consistency, Isolation, and Durability.
 3.High Concurrency: Manages thousands of simultaneous users without data conflicts.
 4.Simple Queries: Targets small, specific rows of data rather than heavy aggregations or historical scans.
 
 
 
 
Incremental Loading
Full Load vs Incremental Load
Change Data Capture (CDC)
Watermarks
Slowly Changing Dimensions (SCD)
Staging Tables
Fact & Dimension Tables
 */


