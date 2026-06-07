-- CREATE DATABASE Joins;
-- USE Joins;


-- =========================================
-- CUSTOMERS
-- =========================================

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE,
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers(customer_name,email,phone,city) VALUES
('Anil','anil@gmail.com','9876543210','Chittoor'),
('Rahul','rahul@gmail.com','9876543211','Bangalore'),
('Sneha','sneha@gmail.com','9876543212','Hyderabad'),
('Kiran','kiran@gmail.com','9876543213','Chennai'),
('Pooja','pooja@gmail.com','9876543214','Mumbai'),
('Arjun','arjun@gmail.com','9876543215','Delhi'),
('Meena','meena@gmail.com','9876543216','Pune'),
('Vikram','vikram@gmail.com','9876543217','Kolkata'),
('Divya','divya@gmail.com','9876543218','Jaipur'),
('Ravi','ravi@gmail.com','9876543219','Ahmedabad'),
('Suresh','suresh@gmail.com','9876543220','Chennai'),
('Lavanya','lavanya@gmail.com','9876543221','Bangalore');

-- =========================================
-- EMPLOYEES
-- =========================================

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    designation VARCHAR(50),
    salary DECIMAL(10,2),
    manager_id INT,

    FOREIGN KEY (manager_id)
    REFERENCES employees(employee_id)
    ON DELETE SET NULL
);

INSERT INTO employees(employee_name,designation,salary,manager_id) VALUES
('Raj','Manager',90000,NULL),
('Kumar','Sales Executive',50000,1),
('Priya','Sales Executive',52000,1),
('Amit','Support Engineer',45000,2),
('John','Support Engineer',43000,2),
('Sara','HR',48000,3);

-- =========================================
-- CATEGORIES
-- =========================================

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO categories(category_name) VALUES
('Electronics'),
('Accessories'),
('Home Appliances'),
('Gaming'),
('Books');

-- =========================================
-- PRODUCTS
-- =========================================

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,

    FOREIGN KEY (category_id)
    REFERENCES categories(category_id)
    ON DELETE CASCADE
);

INSERT INTO products(product_name,category_id,price,stock_quantity) VALUES
('Laptop',1,65000,10),
('Phone',1,30000,20),
('Tablet',1,22000,15),
('Headphones',2,2500,50),
('Keyboard',2,1800,40),
('Mouse',2,1200,60),
('Microwave',3,15000,8),
('Washing Machine',3,28000,5),
('Gaming Mouse',4,2200,25),
('Gaming Keyboard',4,3500,20),
('Python Book',5,700,100),
('SQL Mastery Book',5,900,80);

-- =========================================
-- ORDERS
-- =========================================

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) DEFAULT 'Pending',

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
    ON DELETE CASCADE,

    FOREIGN KEY (employee_id)
    REFERENCES employees(employee_id)
    ON DELETE SET NULL
);

INSERT INTO orders(customer_id,employee_id,order_date,order_status) VALUES
(1,2,'2026-05-01','Delivered'),
(2,3,'2026-05-02','Pending'),
(3,2,'2026-05-03','Shipped'),
(4,4,'2026-05-04','Cancelled'),
(5,5,'2026-05-05','Delivered'),
(1,3,'2026-05-06','Delivered'),
(8,2,'2026-05-07','Pending'),
(10,6,'2026-05-08','Delivered'),
(2,3,'2026-05-09','Delivered'),
(6,4,'2026-05-10','Shipped');

-- =========================================
-- ORDER ITEMS
-- =========================================

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0),
    price_each DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE,

    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
    ON DELETE CASCADE
);

INSERT INTO order_items(order_id,product_id,quantity,price_each) VALUES
(1,1,1,65000),
(1,4,2,2500),
(2,2,1,30000),
(3,3,3,22000),
(4,1,1,65000),
(5,5,2,1800),
(6,6,1,1200),
(7,7,1,15000),
(8,8,1,28000),
(9,11,2,700),
(10,9,1,2200),
(10,10,1,3500);

-- =========================================
-- PAYMENTS
-- =========================================

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_mode VARCHAR(30),
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE,
    payment_status VARCHAR(30) DEFAULT 'Paid',

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE
);

INSERT INTO payments(order_id,payment_mode,amount,payment_date,payment_status) VALUES
(1,'UPI',70000,'2026-05-01','Paid'),
(2,'CARD',30000,'2026-05-02','Pending'),
(3,'CASH',66000,'2026-05-03','Paid'),
(4,'UPI',65000,'2026-05-04','Refunded'),
(5,'CARD',3600,'2026-05-05','Paid'),
(6,'UPI',1200,'2026-05-06','Paid'),
(8,'NET BANKING',28000,'2026-05-08','Paid'),
(9,'UPI',1400,'2026-05-09','Paid');

-- =========================================
-- SHIPMENTS
-- =========================================

CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    shipment_status VARCHAR(30) DEFAULT 'Processing',
    tracking_number VARCHAR(100) UNIQUE,
    shipped_date DATE,
    delivery_date DATE,

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE
);

INSERT INTO shipments(order_id,shipment_status,tracking_number,shipped_date,delivery_date) VALUES
(1,'Delivered','TRK1001','2026-05-02','2026-05-05'),
(2,'Pending','TRK1002','2026-05-03',NULL),
(3,'Shipped','TRK1003','2026-05-04',NULL),
(4,'Cancelled','TRK1004',NULL,NULL),
(5,'Delivered','TRK1005','2026-05-06','2026-05-09'),
(8,'Delivered','TRK1008','2026-05-09','2026-05-12');

-- =========================================
-- REVIEWS
-- =========================================

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK(rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE,

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
    ON DELETE CASCADE,

    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
    ON DELETE CASCADE
);

INSERT INTO reviews(customer_id,product_id,rating,review_text,review_date) VALUES
(1,1,5,'Excellent laptop','2026-05-10'),
(2,2,4,'Good phone','2026-05-11'),
(3,3,5,'Very useful tablet','2026-05-12'),
(4,4,3,'Average sound quality','2026-05-13'),
(5,1,4,'Worth the money','2026-05-14'),
(6,8,5,'Very efficient washing machine','2026-05-15'),
(1,11,5,'Best book for Python','2026-05-16'),
(2,12,4,'Good SQL concepts','2026-05-17');

-- =========================================
-- INDEXES
-- =========================================

CREATE INDEX idx_customer_name
ON customers(customer_name);

CREATE INDEX idx_product_name
ON products(product_name);

CREATE INDEX idx_order_date
ON orders(order_date);

CREATE INDEX idx_payment_mode
ON payments(payment_mode);



-- IMP* :  JOIN = INNER JOIN


-- Show all customers
SELECT * FROM customers;

-- Show all employees
SELECT * FROM employees;

-- Show all categories
SELECT * FROM categories;

-- Show all products
SELECT * FROM products;

-- Show all orders
SELECT * FROM orders;

-- Show all order items
SELECT * FROM order_items;

-- Show all payments
SELECT * FROM payments;

-- Show all shipments
SELECT * FROM shipments;

-- Show all reviews
SELECT * FROM reviews;


-- 1. Show all customers with their orders
SELECT c.customer_name, o.order_id
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;



-- 2. Display customer name and order date
SELECT c.customer_name, o.order_date
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;




-- 3. Show all products with their category names
SELECT p.product_name, c.category_name
FROM products p
JOIN categories c
ON p.category_id = c.category_id;




-- 4. List all employees with their manager names
SELECT e.employee_name AS employee,
       m.employee_name AS manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.employee_id;



-- 5. Display all order IDs with shipment status
SELECT o.order_id, s.shipment_status
FROM orders o
LEFT JOIN shipments s
ON o.order_id = s.order_id;


-- 6. Show payment mode used for each customer order
SELECT c.customer_name, p.payment_mode
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id;


-- 7. List products ordered in each order
SELECT o.order_id, p.product_name
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id;

-- 8. Display order ID, product name, and quantity
SELECT o.order_id, p.product_name, oi.quantity
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id;

-- 9. Show all customers who placed orders
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

-- 10. Find all customers who never placed any order
SELECT c.customer_name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 11. Find orders that do not have payments
SELECT o.order_id
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;

-- 12. Find orders that do not have shipments
SELECT o.order_id
FROM orders o
LEFT JOIN shipments s
ON o.order_id = s.order_id
WHERE s.shipment_id IS NULL;

-- 13. Find products that were never ordered
SELECT p.product_name
FROM products p
LEFT JOIN order_items oi
ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- 14. Find customers who never gave reviews
SELECT c.customer_name
FROM customers c
LEFT JOIN reviews r
ON c.customer_id = r.customer_id
WHERE r.review_id IS NULL;

-- 15. Find employees who never handled orders
SELECT e.employee_name
FROM employees e
LEFT JOIN orders o
ON e.employee_id = o.employee_id
WHERE o.order_id IS NULL;

-- 16. Find categories with no products
SELECT c.category_name
FROM categories c
LEFT JOIN products p
ON c.category_id = p.category_id
WHERE p.product_id IS NULL;

-- 17. Find products without reviews
SELECT p.product_name
FROM products p
LEFT JOIN reviews r
ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- 18. Find orders that were cancelled but still have payments
SELECT o.order_id
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'Cancelled';

-- 19. Find customers whose orders are still pending shipment
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN shipments s
ON o.order_id = s.order_id
WHERE s.shipment_status = 'Pending';

-- 20. Find products that are in stock but never sold
SELECT p.product_name
FROM products p
LEFT JOIN order_items oi
ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
AND p.stock_quantity > 0;

-- 21. Find total amount spent by each customer
SELECT c.customer_name,
       SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name;

-- 22. Find total orders placed by each customer
SELECT c.customer_name,
       COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

-- 23. Find total revenue generated by each product
SELECT p.product_name,
       SUM(oi.quantity * oi.price_each) AS revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_name;

-- 24. Find total revenue generated by each category
SELECT c.category_name,
       SUM(oi.quantity * oi.price_each) AS revenue
FROM categories c
JOIN products p
ON c.category_id = p.category_id
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY c.category_name;

-- 25. Find average rating for each product
SELECT p.product_name,
       AVG(r.rating) AS avg_rating
FROM products p
JOIN reviews r
ON p.product_id = r.product_id
GROUP BY p.product_name;

-- 26. Find highest selling product based on quantity sold
SELECT p.product_name,
       SUM(oi.quantity) AS total_quantity
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 1;

-- 27. Find top 5 customers by total spending
SELECT c.customer_name,
       SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- 28. Find employee handling the highest number of orders
SELECT e.employee_name,
       COUNT(o.order_id) AS total_orders
FROM employees e
JOIN orders o
ON e.employee_id = o.employee_id
GROUP BY e.employee_name
ORDER BY total_orders DESC
LIMIT 1;

-- 29. Find total sales handled by each employee
SELECT e.employee_name,
       SUM(oi.quantity * oi.price_each) AS total_sales
FROM employees e
JOIN orders o
ON e.employee_id = o.employee_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY e.employee_name;

-- 30. Find average order value for each customer
SELECT c.customer_name,
       AVG(order_total.total_amount) AS avg_order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN (
    SELECT order_id,
           SUM(quantity * price_each) AS total_amount
    FROM order_items
    GROUP BY order_id
) order_total
ON o.order_id = order_total.order_id
GROUP BY c.customer_name;

-- 31. Display customer name, product name, quantity, and shipment status
SELECT c.customer_name,
       p.product_name,
       oi.quantity,
       s.shipment_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN shipments s
ON o.order_id = s.order_id;

-- 32. Show customer name with payment mode and shipment status
SELECT c.customer_name,
       pay.payment_mode,
       s.shipment_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
LEFT JOIN payments pay
ON o.order_id = pay.order_id
LEFT JOIN shipments s
ON o.order_id = s.order_id;

-- 33. Find all products purchased by customer 'Anil'
SELECT p.product_name
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
WHERE c.customer_name = 'Anil';

-- 34. Display all orders with total order amount
SELECT o.order_id,
       SUM(oi.quantity * oi.price_each) AS total_amount
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- 35. Show category-wise product sales
SELECT c.category_name,
       SUM(oi.quantity) AS total_sales
FROM categories c
JOIN products p
ON c.category_id = p.category_id
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY c.category_name;

-- 36. Find city-wise total revenue
SELECT c.city,
       SUM(oi.quantity * oi.price_each) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.city;

-- 37. Find which manager supervises employees generating highest sales
SELECT m.employee_name AS manager,
       SUM(oi.quantity * oi.price_each) AS sales
FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id
JOIN orders o
ON e.employee_id = o.employee_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY m.employee_name
ORDER BY sales DESC;

-- 38. Display customer reviews along with product category
SELECT c.customer_name,
       p.product_name,
       cat.category_name,
       r.rating
FROM reviews r
JOIN customers c
ON r.customer_id = c.customer_id
JOIN products p
ON r.product_id = p.product_id
JOIN categories cat
ON p.category_id = cat.category_id;

-- 39. Find customers who purchased Electronics products
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
JOIN categories cat
ON p.category_id = cat.category_id
WHERE cat.category_name = 'Electronics';

-- 40. Find customers who purchased products from more than one category
SELECT c.customer_name,
       COUNT(DISTINCT p.category_id) AS categories_bought
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY c.customer_name
HAVING COUNT(DISTINCT p.category_id) > 1;

-- 41. Find monthly revenue trend
SELECT MONTH(o.order_date) AS month,
       SUM(oi.quantity * oi.price_each) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY MONTH(o.order_date);

-- 42. Find daily order count trend
SELECT order_date,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_date;

-- 43. Find repeat customers
SELECT c.customer_name,
       COUNT(o.order_id) AS orders_count
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 1;

-- 44. Find customer retention by counting repeat purchases
SELECT c.customer_name,
       COUNT(DISTINCT oi.product_id) AS unique_products
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_name;

-- 45. Find percentage contribution of each category to total sales
SELECT c.category_name,
       ROUND(
           SUM(oi.quantity * oi.price_each) * 100 /
           (SELECT SUM(quantity * price_each) FROM order_items),
           2
       ) AS percentage_contribution
FROM categories c
JOIN products p
ON c.category_id = p.category_id
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY c.category_name;

-- 46. Find top-rated products with minimum 2 reviews
SELECT p.product_name,
       AVG(r.rating) AS avg_rating,
       COUNT(r.review_id) AS total_reviews
FROM products p
JOIN reviews r
ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING COUNT(r.review_id) >= 2;

-- 47. Find products generating revenue but having low ratings
SELECT p.product_name,
       SUM(oi.quantity * oi.price_each) AS revenue,
       AVG(r.rating) AS avg_rating
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN reviews r
ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING AVG(r.rating) < 4;

-- 48. Find shipment delay analysis
SELECT order_id,
       DATEDIFF(delivery_date, shipped_date) AS delivery_days
FROM shipments
WHERE delivery_date IS NOT NULL;

-- 49. Find average delivery time per shipment status
SELECT shipment_status,
       AVG(DATEDIFF(delivery_date, shipped_date)) AS avg_delivery_days
FROM shipments
WHERE delivery_date IS NOT NULL
GROUP BY shipment_status;

-- 50. Create complete sales analytics report
SELECT c.customer_name,
       o.order_id,
       p.product_name,
       cat.category_name,
       oi.quantity,
       (oi.quantity * oi.price_each) AS total_amount,
       pay.payment_status,
       s.shipment_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
JOIN categories cat
ON p.category_id = cat.category_id
LEFT JOIN payments pay
ON o.order_id = pay.order_id
LEFT JOIN shipments s
ON o.order_id = s.order_id;