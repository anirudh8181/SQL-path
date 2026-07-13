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


/*
How and when to use Join??

1. What data is required?

Example:

customer name
payment mode

2. Which tables contain it?

Example:
customers
payments

3. How are tables connected?

Example:
customers.customer_id = orders.customer_id

orders.order_id = payments.order_id
The Universal JOIN Formula

Almost every JOIN question follows this pattern:

SELECT needed_columns
FROM first_table
JOIN second_table
ON relation
JOIN third_table
ON relation
WHERE condition;

*/

/*

===========================================================
HOW TO IDENTIFY WHICH JOIN TO USE
===========================================================

CORE IDEA:
-----------
Ask yourself:

"Should unmatched rows appear in the result?"

IF NO:
-------
Use INNER JOIN

IF YES:
--------
Use LEFT JOIN


===========================================================
1. INNER JOIN
===========================================================

Meaning:
--------
Returns ONLY matching rows from both tables.

Use When:
----------
- You only need related data
- Missing records are not important

Common Question Patterns:
-------------------------
- Show customer orders
- Find purchased products
- Show payments for orders
- Display shipment details

Example:
---------
SELECT *
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

Result:
--------
Only customers having orders will appear.


===========================================================
2. LEFT JOIN
===========================================================

Meaning:
--------
Returns:
- ALL rows from LEFT table
- Matching rows from RIGHT table
- NULL for missing matches

Use When:
----------
- Need all records from left table
- Need missing/nonmatching data
- Need NULL analysis

Common Question Patterns:
-------------------------
- Find customers without orders
- Find products never sold
- Find orders without payments
- Find employees without orders
- Include all customers

Example:
---------
SELECT *
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;

Result:
--------
All customers appear.
Customers without orders get NULL values.


===========================================================
3. RIGHT JOIN
===========================================================

Meaning:
--------
Opposite of LEFT JOIN.

Returns:
- ALL rows from RIGHT table
- Matching rows from LEFT table

Rarely used in industry.

Usually rewritten as LEFT JOIN.


===========================================================
4. FULL OUTER JOIN
===========================================================

Meaning:
--------
Returns:
- Matching rows
- Nonmatching left rows
- Nonmatching right rows

Used in:
---------
- PostgreSQL
- Snowflake
- BigQuery

Not directly supported in MySQL.


===========================================================
5. CROSS JOIN
===========================================================

Meaning:
--------
Creates every possible combination.

Example:
---------
3 customers × 4 products = 12 rows

Used rarely.


===========================================================
QUICK DECISION TABLE
===========================================================

Question Type                           JOIN Type
---------------------------------------------------------
Show matching data                      INNER JOIN
Find products purchased                 INNER JOIN
Show payments for orders                INNER JOIN
Find customers without orders           LEFT JOIN
Find products never sold                LEFT JOIN
Find orders without shipment            LEFT JOIN
Include all customers                   LEFT JOIN


===========================================================
MOST IMPORTANT RULE
===========================================================

Need only matching rows?
------------------------
INNER JOIN

Need missing/unmatched rows too?
--------------------------------
LEFT JOIN

*/



-- 1. Show all customers with their orders

-- 2. Display customer name and order date

-- 3. Show all products with their category names

-- 4. List all employees with their manager names

-- 5. Display all order IDs with shipment 

SELECT * FROM shipments;
SELECT * FROM orders;


SELECT 
    o.order_id, s.shipment_id, s.shipment_status
FROM
    orders o
       LEFT  JOIN
    shipments s ON o.order_id = s.order_id;
    
SELECT *
FROM
    orders o
       LEFT  JOIN
    shipments s ON o.order_id = s.order_id;    


-- 6. Show payment mode used for each customer order

-- 7. List products ordered in each order


SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;

SELECT o.order_id , p.product_id, p.product_name
FROM orders o 
JOIN order_items oi 
ON o.order_id=oi.order_id
JOIN products p
ON oi.product_id = p.product_id;



-- 8. Display order ID, product name, and quantity

SELECT o.order_id, p.product_name , oi.quantity
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
JOIN products p
ON oi.order_id =p.product_id;

-- 9. Show all customers who placed orders

SELECT c.customer_id, c.customer_name, o.order_id, o.order_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;


-- 10. Find all customers who never placed any order

-- 11. Find orders that do not have payments

-- 12. Find orders that do not have shipments

-- 13. Find products that were never ordered

-- 14. Find customers who never gave reviews

SELECT * FROM customers;
SELECT * FROM reviews;

SELECT c.customer_name
FROM customers c
LEFT JOIN reviews r
ON c.customer_id=r.customer_id
WHERE r.review_id IS NULL; 

-- 15. Find employees who never handled orders


-- 16. Find categories with no products

-- 17. Find products without reviews

-- 18. Find orders that were cancelled but still have payments

-- 19. Find customers whose orders are still pending shipment

-- 20. Find products that are in stock but never sold

-- 21. Find total amount spent by each customer
SELECT c.customer_name, SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c 
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY c.customer_name;

-- 22. Find total orders placed by each customer

SELECT c.customer_id, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN  orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id;


-- 23. Find total revenue generated by each product



-- 24. Find total revenue generated by each category

-- 25. Find average rating for each product

-- 26. Find highest selling product based on quantity sold

-- 27. Find top 5 customers by total spending

-- 28. Find employee handling the highest number of orders

-- 29. Find total sales handled by each employee

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



-- 33. Find all products purchased by customer 'Anil'

SELECT p.product_id, p.product_name , c.customer_name
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
JOIN orders o
ON oi.order_id = o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
WHERE c.customer_name ='Anil';

-- 34. Display all orders with total order amount

SELECT o.order_id,
       SUM(oi.quantity * oi.price_each) AS total_amount
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.order_id;


-- 35. Show category-wise product sales 

SELECT c.category_name, SUM(oi.quantity*oi.price_each) AS product_sales, SUM(oi.quantity) AS total_sales
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
JOIN categories c
ON p.category_id=c.category_id
GROUP BY c.category_name;

-- 36. Find city-wise total revenue



-- 37. Find which manager supervises employees generating highest sales

-- 38. Display customer reviews along with product category

-- 39. Find customers who purchased Electronics products

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



-- 42. Find daily order count trend

-- 43. Find repeat customers


-- 44. Find customer retention by counting repeat purchases


SELECT o.customer_id,count(oi.product_id) AS repeat_purchase
FROM orders o
JOIN  order_items oi
ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY repeat_purchase DESC;


SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1;



-- 45. Find percentage contribution of each category to total sales

-- 46. Find top-rated products with minimum 2 reviews

-- 47. Find products generating revenue but having low ratings

-- 48. Find shipment delay analysis using shipped_date and delivery_date

-- 49. Find average delivery time per shipment status

-- 50. Create a complete sales analytics report using all major tables