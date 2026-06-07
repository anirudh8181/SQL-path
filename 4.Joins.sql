-- Insertion Script

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO customers VALUES
(1, 'Anirudh', 'Chittoor'),
(2, 'Rahul', 'Bangalore'),
(3, 'Sneha', 'Hyderabad'),
(4, 'Kiran', 'Chennai'),
(5, 'Pooja', 'Mumbai');



CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE
);


INSERT INTO orders VALUES
(101, 1, '2024-01-10'),
(102, 2, '2024-01-11'),
(103, 1, '2024-01-12'),
(104, 3, '2024-01-13'),
(105, 6, '2024-01-14'); -- invalid customer (for edge case)



CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price INT
);



INSERT INTO products VALUES
(201, 'Laptop', 60000),
(202, 'Phone', 30000),
(203, 'Tablet', 20000),
(204, 'Headphones', 2000);



CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT
);

INSERT INTO order_items VALUES
(101, 201, 1),
(101, 204, 2),
(102, 202, 1),
(103, 203, 3),
(104, 201, 1),
(106, 202, 1); -- invalid order

SELECT * FROM orders; 
SELECT * FROM customers; 
SELECT * FROM order_items; 
SELECT * FROM products;



-- Joins

-- 1.inner join

SELECT * FROM orders; 
SELECT * FROM customers; 

SELECT 
    *
FROM
    orders o                                        
INNER JOIN 
    customers c ON o.customer_id = c.customer_id;   
    
    
-- visualize selected columns    


SELECT * FROM orders; 
SELECT * FROM customers;

SELECT 
    *
FROM
    orders o -- LEFT TABLE
INNER JOIN
    customers c ON o.customer_id = c.customer_id; -- RIGHT TABLE
    
    
/*
Matching Process:

Order 101
orders.customer_id = 1

Search in customers:

customer_id = 1 → Anirudh

Match found

Combined row:

order_id	customer_id	order_date	name	city
101	             1	    2024-01-10	Anirudh	 Chittoor

Order 102

customer_id = 2
Rahul found

Order 103

customer_id = 1
Anirudh found again

Order 104

customer_id = 3
Sneha found

*/  
    
    
-- 2. Left Join/Left Outer Join

SELECT * FROM orders; 
SELECT * FROM customers; 

SELECT 
    *
FROM
    orders o
        LEFT JOIN
    customers c ON o.customer_id = c.customer_id;
    

/*
Row-by-Row Matching
Order 101:

customer_id = 1

Customer found:
Anirudh

Combined row:

order_id	customer_id	order_date	name	city
101	          1	      2024-01-10	Anirudh	 Chittoor

Order 102:

customer_id = 2
Rahul found

Order 103:

customer_id = 1

Anirudh found again

Order 104:

customer_id = 3
Sneha found

Order 105:

customer_id = 6
Search in customers:
No match found:

But LEFT JOIN says:
Keep all rows from orders
So SQL keeps the row and fills customer columns with NULL.

ALL orders
+
matching customers

*/

    
    
-- 3. Right Join/Right outer Join

SELECT * FROM orders; 
SELECT * FROM customers; 

SELECT 
    *
FROM
    orders o
RIGHT JOIN
    customers c ON o.customer_id = c.customer_id;   
    
/*
Row-by-Row Matching

Customer 1 → Anirudh

Matching orders:

101
103

So two rows are created.

Customer 2 → Rahul
Matching order:
102

Customer 3 → Sneha
Matching order:
104

Customer 4 → Kiran

Search in orders:

No matching order
But RIGHT JOIN says:
Keep all rows from customers

So SQL keeps Kiran and fills order columns with NULL.

Customer 5 → Pooja

No order found:
Still included with NULL.

*/





    
    
 -- 4. FULL JOIN/FULL OUTER JOIN (NOT supported in MySQL)
 
 SELECT 
    *
FROM
    orders o
FULL JOIN
    customers c ON o.customer_id = c.customer_id; 
    
    
SELECT *
FROM orders
FULL OUTER JOIN customers
ON orders.customer_id = customers.customer_id;     
 
 
 
    
-- UNION (Replacement for full join)

SELECT * FROM orders; 
SELECT * FROM customers; 


-- Left Join

SELECT 
    *
FROM
    orders o
        LEFT JOIN
    customers c ON o.customer_id = c.customer_id


 
 
UNION    


-- Right Join
SELECT 
    *
FROM
    orders o
        RIGHT JOIN
    customers c ON o.customer_id = c.customer_id; 


-- step by step

SELECT 
    *
FROM
    orders o
        LEFT JOIN
    customers c ON o.customer_id = c.customer_id;
 
 
 
SELECT 
    *
FROM
    orders o
        RIGHT JOIN
    customers c ON o.customer_id = c.customer_id;     
    
SELECT * FROM orders; 
SELECT * FROM customers;  

-- Keep:

-- ALL rows from orders
-- Matching rows from customers

-- Keep:

-- ALL rows from customers
-- Matching rows from orders

-- UNION combines both results and removes duplicates.

/*
1. Execute first query
2. Execute second query
3. Stack both results
4. Remove duplicate rows
5. Return final result
*/
 
 
   
 
-- UNION ALL  

-- Left Join

SELECT 
    *
FROM
    orders o
        LEFT JOIN
    customers c ON o.customer_id = c.customer_id


 
 
UNION ALL   


-- Right Join
SELECT 
    *
FROM
    orders o
        RIGHT JOIN
    customers c ON o.customer_id = c.customer_id;  


/*
1. Execute first query
2. Execute second query
3. Stack both results
4. Return final result
*/    

-- union
SELECT 
    *
FROM
    orders o
        LEFT JOIN
    customers c ON o.customer_id = c.customer_id


 
 
UNION    


-- Right Join
SELECT 
    *
FROM
    orders o
        RIGHT JOIN
    customers c ON o.customer_id = c.customer_id;
    
    
-- union all
SELECT 
    *
FROM
    orders o
        LEFT JOIN
    customers c ON o.customer_id = c.customer_id


 
 
UNION ALL   


-- Right Join
SELECT 
    *
FROM
    orders o
        RIGHT JOIN
    customers c ON o.customer_id = c.customer_id;      



