/* ============================================================================
   SQL JOIN INTERVIEW QUESTIONS + ANSWERS  -  Junior Data Engineer
   Schema (see Joins_Practise.sql):
     customers, categories, products, orders, order_items,
     payments(1:1 order), shipments(1:1 order), reviews
   Dialect: MySQL 8+
   Revenue = order_items.quantity * order_items.price_each
   Questions state the business need; the answer shows a recommended approach.
   ============================================================================ */


/* ============================================================================
   SECTION 1 - BASIC JOINS  (Q1 - Q15)
   ============================================================================ */

-- Question 1
-- Show each customer together with the orders they have placed.

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;

------------------------------------------------------------

-- Question 2
-- For every order, display the order id, order date, customer name and city.

SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

------------------------------------------------------------

-- Question 3
-- Show each product together with the name of the category it belongs to.

SELECT
    p.product_name,
    cat.category_name
FROM products p
INNER JOIN categories cat
    ON p.category_id = cat.category_id;

------------------------------------------------------------

-- Question 4
-- For a regional grouping analysis, list pairs of customers who live in the
-- same city.

SELECT
    c1.customer_name AS customer_1,
    c2.customer_name AS customer_2,
    c1.city
FROM customers c1
INNER JOIN customers c2
    ON c1.city = c2.city
   AND c1.customer_id < c2.customer_id;

------------------------------------------------------------

-- Question 5
-- Display each order with its shipment status. Include orders that have not
-- been shipped yet.

SELECT
    o.order_id,
    o.order_status,
    s.shipment_status
FROM orders o
LEFT JOIN shipments s
    ON o.order_id = s.order_id;

------------------------------------------------------------

-- Question 6
-- Show the payment mode used for each order. Include orders that have no
-- payment recorded.

SELECT
    o.order_id,
    pay.payment_mode
FROM orders o
LEFT JOIN payments pay
    ON o.order_id = pay.order_id;

------------------------------------------------------------

-- Question 7
-- Produce a list of all customers and their orders. Customers who have not
-- placed any order should still appear.

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

------------------------------------------------------------

-- Question 8
-- For each order line, display the order id, product name and quantity.

SELECT
    oi.order_id,
    p.product_name,
    oi.quantity
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id;

------------------------------------------------------------

-- Question 9
-- Show each product with its category name, price and stock quantity.

SELECT
    p.product_name,
    cat.category_name,
    p.price,
    p.stock_quantity
FROM products p
INNER JOIN categories cat
    ON p.category_id = cat.category_id;

------------------------------------------------------------

-- Question 10
-- The marketing team needs a re-engagement list: find all customers who have
-- never placed an order.

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

------------------------------------------------------------

-- Question 11
-- List every category along with the products in it. Categories that contain
-- no products should still appear.

SELECT
    cat.category_name,
    p.product_name
FROM categories cat
LEFT JOIN products p
    ON cat.category_id = p.category_id;

------------------------------------------------------------

-- Question 12
-- To plan a full catalog mailing, generate every possible pairing of a
-- customer with a product.

SELECT
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name
FROM customers c
CROSS JOIN products p;

------------------------------------------------------------

-- Question 13
-- Show each product along with the reviews it has received. Include products
-- that have no reviews.

SELECT
    p.product_name,
    r.rating,
    r.review_text
FROM products p
LEFT JOIN reviews r
    ON p.product_id = r.product_id;

------------------------------------------------------------

-- Question 14
-- List all orders placed by customers located in 'Chennai'.

SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.city = 'Chennai';

------------------------------------------------------------

-- Question 15
-- Show each review with the customer name, the product name and the rating.

SELECT
    c.customer_name,
    p.product_name,
    r.rating,
    r.review_text
FROM reviews r
INNER JOIN customers c
    ON r.customer_id = c.customer_id
INNER JOIN products p
    ON r.product_id = p.product_id;


/* ============================================================================
   SECTION 2 - BUSINESS-ORIENTED JOIN QUERIES  (Q16 - Q35)
   ============================================================================ */

-- Question 16
-- Report the total number of orders placed by every customer, including
-- customers who have placed none.

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

------------------------------------------------------------

-- Question 17
-- Calculate the total amount spent by each customer.

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;

------------------------------------------------------------

-- Question 18
-- Calculate the total revenue generated by each product.

SELECT
    p.product_name,
    SUM(oi.quantity * oi.price_each) AS product_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name;

------------------------------------------------------------

-- Question 19
-- Calculate the total revenue generated by each category.

SELECT
    cat.category_name,
    SUM(oi.quantity * oi.price_each) AS category_revenue
FROM categories cat
INNER JOIN products p
    ON cat.category_id = p.category_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY cat.category_name;

------------------------------------------------------------

-- Question 20
-- Identify the top 5 customers by total spending.

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

------------------------------------------------------------

-- Question 21
-- Identify the best-selling product measured by total quantity sold.

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 1;

------------------------------------------------------------

-- Question 22
-- Calculate the average rating for each product.

SELECT
    p.product_name,
    AVG(r.rating) AS avg_rating
FROM products p
INNER JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY p.product_name;

------------------------------------------------------------

-- Question 23
-- The inventory team wants a dead-stock report: list all products that have
-- never been sold.

SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

------------------------------------------------------------

-- Question 24
-- Find categories that currently have no products.

SELECT
    cat.category_name
FROM categories cat
LEFT JOIN products p
    ON cat.category_id = p.category_id
WHERE p.product_id IS NULL;

------------------------------------------------------------

-- Question 25
-- Find customers who have never written a review.

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN reviews r
    ON c.customer_id = r.customer_id
WHERE r.review_id IS NULL;

------------------------------------------------------------

-- Question 26
-- Find products that have never received a review.

SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN reviews r
    ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

------------------------------------------------------------

-- Question 27
-- Find orders that have no payment recorded.

SELECT
    o.order_id,
    o.order_status
FROM orders o
LEFT JOIN payments pay
    ON o.order_id = pay.order_id
WHERE pay.payment_id IS NULL;

------------------------------------------------------------

-- Question 28
-- Find orders that have not been shipped.

SELECT
    o.order_id,
    o.order_status
FROM orders o
LEFT JOIN shipments s
    ON o.order_id = s.order_id
WHERE s.shipment_id IS NULL;

------------------------------------------------------------

-- Question 29
-- Calculate the total revenue generated for each order status.

SELECT
    o.order_status,
    SUM(oi.quantity * oi.price_each) AS total_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status;

------------------------------------------------------------

-- Question 30
-- Identify the city that has generated the highest total revenue.

SELECT
    c.city,
    SUM(oi.quantity * oi.price_each) AS city_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY city_revenue DESC
LIMIT 1;

------------------------------------------------------------

-- Question 31
-- Calculate the total revenue generated in each city.

SELECT
    c.city,
    SUM(oi.quantity * oi.price_each) AS city_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.city;

------------------------------------------------------------

-- Question 32
-- Calculate the total amount collected through each payment mode.

SELECT
    pay.payment_mode,
    SUM(pay.amount) AS total_collected
FROM payments pay
GROUP BY pay.payment_mode;

------------------------------------------------------------

-- Question 33
-- List the customers who have purchased products from the 'Electronics'
-- category.

SELECT DISTINCT
    c.customer_name
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
INNER JOIN categories cat
    ON p.category_id = cat.category_id
WHERE cat.category_name = 'Electronics';

------------------------------------------------------------

-- Question 34
-- Find products that are in stock but have never been sold.

SELECT
    p.product_name,
    p.stock_quantity
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
  AND p.stock_quantity > 0;

------------------------------------------------------------

-- Question 35
-- Find cancelled orders that still have a payment recorded against them.

SELECT
    o.order_id,
    o.order_status,
    pay.payment_status,
    pay.amount
FROM orders o
INNER JOIN payments pay
    ON o.order_id = pay.order_id
WHERE o.order_status = 'Cancelled';


/* ============================================================================
   SECTION 3 - JOIN + SQL CONCEPTS  (Q36 - Q50)
   ============================================================================ */

-- Question 36
-- Find repeat customers: those who have placed more than one order.

SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1;

------------------------------------------------------------

-- Question 37
-- Find customers who have purchased products from more than one category.

SELECT
    c.customer_name,
    COUNT(DISTINCT p.category_id) AS categories_bought
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT p.category_id) > 1;

------------------------------------------------------------

-- Question 38
-- Rank customers by their total spend, from highest to lowest.

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

------------------------------------------------------------

-- Question 39
-- Classify every customer as 'Active' if they have placed at least one order,
-- otherwise 'Inactive'.

SELECT
    c.customer_id,
    c.customer_name,
    CASE
        WHEN COUNT(o.order_id) > 0 THEN 'Active'
        ELSE 'Inactive'
    END AS customer_status
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

------------------------------------------------------------

-- Question 40
-- Show each order with its customer name and payment status. When an order has
-- no payment, display 'No Payment'.

SELECT
    o.order_id,
    c.customer_name,
    COALESCE(pay.payment_status, 'No Payment') AS payment_status
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN payments pay
    ON o.order_id = pay.order_id;

------------------------------------------------------------

-- Question 41
-- Report the total amount spent by every customer, showing 0 for customers
-- who have spent nothing.

SELECT
    c.customer_id,
    c.customer_name,
    IFNULL(SUM(oi.quantity * oi.price_each), 0) AS total_spent
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;

------------------------------------------------------------

-- Question 42
-- Produce a report of every customer with the date of their most recent order.
-- Customers with no orders should show 'No Orders'.

SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(CAST(MAX(o.order_date) AS CHAR), 'No Orders') AS last_order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

------------------------------------------------------------

-- Question 43
-- List the customer name, order id and order status for all orders placed in
-- May 2026.

SELECT
    c.customer_name,
    o.order_id,
    o.order_status
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_date BETWEEN '2026-05-01' AND '2026-05-31';

------------------------------------------------------------

-- Question 44
-- Calculate the average order value for each customer.

SELECT
    c.customer_name,
    AVG(order_total.total_amount) AS avg_order_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN (
    SELECT
        order_id,
        SUM(quantity * price_each) AS total_amount
    FROM order_items
    GROUP BY order_id
) order_total
    ON o.order_id = order_total.order_id
GROUP BY c.customer_id, c.customer_name;

------------------------------------------------------------

-- Question 45
-- Report the monthly revenue trend (revenue grouped by order month).

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(oi.quantity * oi.price_each)   AS revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

------------------------------------------------------------

-- Question 46
-- Report the top 2 categories by total revenue.

SELECT
    cat.category_name,
    SUM(oi.quantity * oi.price_each) AS category_revenue
FROM categories cat
INNER JOIN products p
    ON cat.category_id = p.category_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY cat.category_name
ORDER BY category_revenue DESC
LIMIT 2;

------------------------------------------------------------

-- Question 47
-- For each payment status, report the number of payments and the total amount
-- collected.

SELECT
    pay.payment_status,
    COUNT(*)         AS num_payments,
    SUM(pay.amount)  AS total_amount
FROM payments pay
GROUP BY pay.payment_status;

------------------------------------------------------------

-- Question 48
-- Find products that generated revenue but have an average rating below 4.

SELECT
    p.product_name,
    SUM(oi.quantity * oi.price_each) AS revenue,
    AVG(r.rating)                    AS avg_rating
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN reviews r
    ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING AVG(r.rating) < 4;

------------------------------------------------------------

-- Question 49
-- For each order, label its total value as 'High' when it is 50000 or more,
-- otherwise 'Low'.

SELECT
    order_id,
    order_value,
    CASE
        WHEN order_value >= 50000 THEN 'High'
        ELSE 'Low'
    END AS value_category
FROM (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.price_each) AS order_value
    FROM order_items oi
    GROUP BY oi.order_id
) t;

------------------------------------------------------------

-- Question 50
-- Calculate the percentage contribution of each category to the total revenue.

SELECT
    cat.category_name,
    ROUND(
        SUM(oi.quantity * oi.price_each) * 100.0 /
        (SELECT SUM(quantity * price_each) FROM order_items),
        2
    ) AS pct_of_total_revenue
FROM categories cat
INNER JOIN products p
    ON cat.category_id = p.category_id
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY cat.category_name;


/* ============================================================================
   SECTION 4 - ADVANCED JUNIOR-LEVEL JOIN QUESTIONS  (Q51 - Q60)
   ============================================================================ */

-- Question 51
-- Build a complete sales report showing customer name, order id, product name,
-- category name, quantity, line total, payment status and shipment status.

SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    cat.category_name,
    oi.quantity,
    (oi.quantity * oi.price_each) AS line_total,
    pay.payment_status,
    s.shipment_status
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
INNER JOIN categories cat
    ON p.category_id = cat.category_id
LEFT JOIN payments pay
    ON o.order_id = pay.order_id
LEFT JOIN shipments s
    ON o.order_id = s.order_id;

------------------------------------------------------------

-- Question 52
-- Find customers whose total spend is greater than the average total spend
-- across all customers.

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(oi.quantity * oi.price_each) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(oi2.quantity * oi2.price_each) AS customer_total
        FROM orders o2
        INNER JOIN order_items oi2
            ON o2.order_id = oi2.order_id
        GROUP BY o2.customer_id
    ) avg_tbl
);

------------------------------------------------------------

-- Question 53
-- Report the total revenue per category and return only categories whose
-- revenue is above 50000.

WITH category_revenue AS (
    SELECT
        cat.category_name,
        SUM(oi.quantity * oi.price_each) AS total_revenue
    FROM categories cat
    INNER JOIN products p
        ON cat.category_id = p.category_id
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY cat.category_name
)
SELECT
    category_name,
    total_revenue
FROM category_revenue
WHERE total_revenue > 50000;

------------------------------------------------------------

-- Question 54
-- List the products that have been ordered at least once.

SELECT
    p.product_id,
    p.product_name
FROM products p
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);

------------------------------------------------------------

-- Question 55
-- Find customers who have placed at least one order but have never written a
-- review.

SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM reviews r
    WHERE r.customer_id = c.customer_id
);

------------------------------------------------------------

-- Question 56
-- Identify a fulfilment gap: find orders that have been paid but have not yet
-- been shipped.

SELECT
    o.order_id,
    c.customer_name,
    pay.payment_status
FROM orders o
INNER JOIN payments pay
    ON o.order_id = pay.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN shipments s
    ON o.order_id = s.order_id
WHERE pay.payment_status = 'Paid'
  AND s.shipment_id IS NULL;

------------------------------------------------------------

-- Question 57
-- Find products that have been reviewed but have never been ordered.

SELECT
    p.product_id,
    p.product_name
FROM products p
WHERE EXISTS (
    SELECT 1
    FROM reviews r
    WHERE r.product_id = p.product_id
)
AND NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);

------------------------------------------------------------

-- Question 58
-- Calculate the total revenue per customer, making sure the amount is not
-- inflated by the one-to-many relationship between orders and order items.
-- (Joining down to the order_items grain and summing quantity * price_each
--  keeps every line counted once, avoiding fan-out double counting.)

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.price_each) AS total_revenue
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;

------------------------------------------------------------

-- Question 59
-- For every shipped-and-delivered order, calculate the number of days taken to
-- deliver it.

SELECT
    s.order_id,
    c.customer_name,
    s.shipped_date,
    s.delivery_date,
    DATEDIFF(s.delivery_date, s.shipped_date) AS delivery_days
FROM shipments s
INNER JOIN orders o
    ON s.order_id = o.order_id
INNER JOIN customers c
    ON o.customer_id = c.customer_id
WHERE s.delivery_date IS NOT NULL
  AND s.shipped_date IS NOT NULL;

------------------------------------------------------------

-- Question 60
-- Build a customer 360 summary showing, for every customer, the total number
-- of orders, total amount spent, number of reviews written and average rating
-- given. Include customers with no activity.

WITH order_spend AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id)         AS total_orders,
        SUM(oi.quantity * oi.price_each)   AS total_spent
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
review_stats AS (
    SELECT
        customer_id,
        COUNT(review_id) AS total_reviews,
        AVG(rating)      AS avg_rating_given
    FROM reviews
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    IFNULL(os.total_orders, 0)     AS total_orders,
    IFNULL(os.total_spent, 0)      AS total_spent,
    IFNULL(rs.total_reviews, 0)    AS total_reviews,
    rs.avg_rating_given
FROM customers c
LEFT JOIN order_spend os
    ON c.customer_id = os.customer_id
LEFT JOIN review_stats rs
    ON c.customer_id = rs.customer_id;


/* ============================================================================
   SECTION 5 - CLASSIC INTERVIEW PROBLEMS  (Q61 - Q66)
   ============================================================================ */

-- Question 61
-- Find the second highest spending customer.
-- (LIMIT 1 OFFSET 1 over the ranked spend. Use DENSE_RANK if ties must share
--  the same position.)

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.price_each) AS total_spent
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 1 OFFSET 1;

------------------------------------------------------------

-- Question 62
-- Find the top-selling product (by quantity) in each category.

WITH category_product_sales AS (
    SELECT
        cat.category_name,
        p.product_name,
        SUM(oi.quantity) AS total_quantity
    FROM categories cat
    INNER JOIN products p
        ON cat.category_id = p.category_id
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY cat.category_name, p.product_name
),
ranked AS (
    SELECT
        category_name,
        product_name,
        total_quantity,
        RANK() OVER (PARTITION BY category_name ORDER BY total_quantity DESC) AS rnk
    FROM category_product_sales
)
SELECT
    category_name,
    product_name,
    total_quantity
FROM ranked
WHERE rnk = 1;

------------------------------------------------------------

-- Question 63
-- Return the latest order (all order columns) for each customer.
-- (order_id used as a tie-breaker when a customer has two orders on the same
--  date.)

WITH ranked_orders AS (
    SELECT
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date DESC, o.order_id DESC
        ) AS rn
    FROM orders o
)
SELECT
    order_id,
    customer_id,
    employee_id,
    order_date,
    order_status
FROM ranked_orders
WHERE rn = 1;

------------------------------------------------------------

-- Question 64
-- Market-basket analysis: find pairs of products that were bought together in
-- the same order, and how often each pair occurs.
-- (Self join order_items on order_id; product_id < product_id avoids
--  duplicate and self pairs.)

SELECT
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(*)        AS times_bought_together
FROM order_items oi1
INNER JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id
INNER JOIN products p1
    ON oi1.product_id = p1.product_id
INNER JOIN products p2
    ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
ORDER BY times_bought_together DESC;

------------------------------------------------------------

-- Question 65
-- Calculate each customer's percentage contribution to the total revenue.

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.price_each) AS revenue
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS pct_of_total_revenue
FROM customer_revenue
ORDER BY pct_of_total_revenue DESC;

------------------------------------------------------------

-- Question 66
-- Find customers whose average order value is above the overall average order
-- value.

WITH order_values AS (
    SELECT
        o.customer_id,
        o.order_id,
        SUM(oi.quantity * oi.price_each) AS order_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
),
customer_avg AS (
    SELECT
        customer_id,
        AVG(order_value) AS avg_order_value
    FROM order_values
    GROUP BY customer_id
)
SELECT
    c.customer_name,
    ca.avg_order_value
FROM customer_avg ca
INNER JOIN customers c
    ON ca.customer_id = c.customer_id
WHERE ca.avg_order_value > (
    SELECT AVG(order_value)
    FROM order_values
);
