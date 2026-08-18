# NULL means missing, unknown, or no value. It is not the same as 0, an empty string (''), or FALSE.

create database NULL_DATA;
USE NULL_DATA;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    bonus DECIMAL(10,2),
    email VARCHAR(100),
    mobile VARCHAR(15),
    home_phone VARCHAR(15),
    manager_id INT
);


INSERT INTO employees
(emp_id, emp_name, department, salary, bonus, email, mobile, home_phone, manager_id)
VALUES
(101, 'Anirudh', 'IT', 60000, 5000, 'anirudh@gmail.com', '9876543210', NULL, 201),
(102, 'Rahul', 'HR', NULL, NULL, NULL, '9876501234', '0442345678', 202),
(103, 'Priya', 'Finance', 75000, NULL, 'priya@gmail.com', NULL, '0448765432', NULL),
(104, 'Sneha', 'IT', 68000, 3000, NULL, NULL, NULL, 201),
(105, 'Karan', 'Sales', NULL, 2000, 'karan@gmail.com', '9988776655', NULL, NULL),
(106, 'Meena', 'Marketing', 52000, NULL, NULL, NULL, '0449988776', 203),
(107, 'John', 'IT', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 'David', 'Finance', 85000, 8000, 'david@gmail.com', '9123456789', '0445678901', 202),
(109, 'Dawis', 'Flamce', 5000, 9000, 'dawis@gmail.com', '91355456789', '91355456789', 203);





-- 1. IS NULL , Checks whether a column contains a NULL value.

SELECT *
FROM employees
WHERE salary IS NULL;

-- 2. IS NOT NULL , Returns rows where the value exists.
SELECT emp_name, email
FROM employees
WHERE email IS NOT NULL;

/*

Syntax:
1. ISNULL(expression, replacement_value) - SQL server

returns the replacement value if the expression is NULL.

MY SQL equivalent - IFNULL()

Syntax:
3. IFNULL(expression, replacement_value)


*/

SELECT
    *,
    IFNULL(salary,0) AS null_salary_check
FROM employees;




/*

4. COALESCE()

COALESCE() returns the first non-NULL value from a list of expressions.

Synatax:
COALESCE(value1, value2, value3, ..., default)

When you have multiple columns that may contain the required value.

Example:

Mobile
Home phone
Office phone
Emergency phone

Return whichever exists first.

*/

SELECT mobile,home_phone,
COALESCE(mobile, home_phone) AS First_not_null
FROM employees;


SELECT email,bonus, mobile, home_phone,
COALESCE(email,bonus, mobile, home_phone, 'Not available') AS replacement
FROM employees;


-- 5.NULLIF() - NULLIF() compares two expressions.
/*

If they are equal,
it returns NULL.

Otherwise,
it returns the first expression.

Syntax:
NULLIF(expression1, expression2)

*/
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    total_sales DECIMAL(10,2),
    orders_count INT
);

INSERT INTO sales (sale_id, total_sales, orders_count)
VALUES
(1, 1000.00, 10),
(2, 500.00, 5),
(3, 800.00, 0),
(4, 1200.00, 12),
(5, 300.00, 3);



--
SELECT mobile,home_phone,
NULLIF(mobile, home_phone) AS Check_null
FROM employees;




-- Avoid Division by Zero (Most Common Use)

SELECT
    sale_id,
    total_sales,
    orders_count,
    total_sales / orders_count AS avg_sale_per_order
FROM sales;


SELECT
    sale_id,
    total_sales,
    orders_count,
    total_sales / NULLIF(orders_count, 0) AS avg_sale_per_order
FROM sales;


/*

| Feature             |    IFNULL()                 |    COALESCE()                                          |
| ------------------- | -------------------------- | ---------------------------------------------------- |
| Number of arguments | Exactly 2                  |       2 or more                                      |
| Purpose             | Replace a NULL value       | Return the first non-NULL value                      |
| SQL Standard        | No (MySQL-specific)        |  Yes (ANSI SQL standard)                             |
| Portability         | Mainly MySQL (also SQLite) | Works in MySQL, PostgreSQL, SQL Server, Oracle, etc. |
| Typical use         | Simple NULL replacement    | Multiple fallback values                             |



*/

-- Check Null values before data aggregation

-- 1. 	
SELECT emp_id, emp_name, salary,
AVG(salary) OVER() AS Avg_Score
FROM employees;


-- 2. First the handle values
SELECT emp_id, emp_name, salary,
COALESCE(salary,0) 
FROM employees;

-- 3.
SELECT emp_id, emp_name, salary,
AVG(salary) OVER() AS Avg_Score,
AVG(COALESCE(salary,0))  OVER() AS Avg_score2
FROM employees;


/*

" Can IFNULL() replace COALESCE()?"


Yes, but only when there are two arguments. For example, IFNULL(salary, 0) and COALESCE(salary, 0) are equivalent in MySQL. 
However, COALESCE() is more flexible because it can accept multiple arguments and return the first non-NULL value. 
It's also part of the SQL standard, making it more portable across different database systems.

*/

/*

10 + 5 =5

a + b = ab

a' + b' = a'b'

but,

null + 5 = 5
 
null + b = null


*/

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    score INT
);

INSERT INTO customers (customer_id, first_name, last_name, score) VALUES
(101, 'John',      'Smith',     85),
(102, 'Emma',      'Johnson',   92),
(103, 'Michael',   NULL,        76),
(104, NULL,        'Davis',     NULL),
(105, 'William',   'Wilson',    67),
(106, 'Olivia',    NULL,        95),
(107, NULL,        'Anderson',  NULL),
(108, 'Isabella',  'Thomas',    73),
(109, NULL,        NULL,        90),
(110, 'Mia',       'White',     NULL);

CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(50),
    country VARCHAR(50)
);

INSERT INTO cities VALUES
(1, 'New York', 'USA'),
(2, 'London', 'UK'),
(3, 'Tokyo', 'Japan'),
(4, 'Paris', 'France'),
(5, 'Mumbai', 'India'),
(6, 'Sydney', 'Australia'),
(7, 'Dubai', 'UAE'),
(8, 'Berlin', 'Germany'),
(9, 'Toronto', 'Canada');

-- 1
SELECT customer_id, 
       first_name, 
       last_name,
       CONCAT(first_name,' ',last_name) AS Full_name  -- return null
FROM customers; 

-- handling null values
SELECT
    customer_id,
    first_name,
    last_name,
    CONCAT(
        COALESCE(first_name, ''),  -- COALESCE TO HANDLE NULL VALUES , COALESCE(first_name, '') returns an empty string ('')
        ' ',
        COALESCE(last_name, '')
    ) AS full_name
FROM customers;  

SELECT LENGTH('');

SELECT LENGTH(' ');  


-- 2
SELECT customer_id, 
       first_name, 
       last_name,
       score,
       score + 10 AS Score_add
FROM customers;  

-- hamdling null values
SELECT customer_id, 
       first_name, 
       last_name,
       score,
       COALESCE(score , 0)+ 10 AS Score_add
FROM customers;     



-- handling nulls before Joins  
/*
Table 1:

| year | type   | orders |
| ---- | ------ | ------ |
| 2024 | Retail | 100    |
| 2024 | NULL   | 250    |
| 2025 | Online | 300    |

Table 2:

| year | type   | sales |
| ---- | ------ | ----- |
| 2024 | Retail | 1000  |
| 2024 | NULL   | 2500  |
| 2025 | Online | 3500  |

SQL compares:

First row:
2024 = 2024 ✅
Retail = Retail ✅

Matches.

Second row:
2024 = 2024 ✅
NULL = NULL ❌

This does not match because in SQL,
NULL = NULL
is UNKNOWN, not TRUE.
So the second row is not joined.

Using ISNULL()

Now SQL evaluates	
ISNULL(a.type, '')

If type is NULL

↓

Replace with

''

Likewise

ISNULL(b.type, '')

also becomes

''

Now SQL compares

'' = ''

which is TRUE

So the rows join successfully.

Evaluation

Instead of:

NULL = NULL ❌

SQL actually evaluates

ISNULL(NULL,'') = ISNULL(NULL,'')

↓

'' = ''

↓

TRUE 



*/ 

CREATE TABLE Table1 (
    year INT,
    type VARCHAR(20),
    orders INT
);

INSERT INTO Table1 VALUES
(2023, 'Retail', 120),
(2023, 'Online', 200),
(2023, NULL, 150),
(2024, 'Retail', 180),
(2024, NULL, 250),
(2025, 'Wholesale', 300),
(2025, NULL, 400);

CREATE TABLE Table2 (
    year INT,
    type VARCHAR(20),
    sales INT
);

INSERT INTO Table2 VALUES
(2023, 'Retail', 1200),
(2023, 'Online', 1800),
(2023, NULL, 900),
(2024, 'Retail', 2200),
(2024, NULL, 1500),
(2025, 'Wholesale', 3500),
(2025, NULL, 2500);


-- joining without handling nulls
SELECT
    a.year,
    a.type,
    a.orders,
    b.sales
FROM Table1 a
JOIN Table2 b
ON a.year = b.year
AND a.type = b.type;

-- Using COALESCE()
SELECT
    a.year,
    a.type,
    a.orders,
    b.sales
FROM Table1 a
JOIN Table2 b
ON a.year = b.year
AND COALESCE(a.type, '') = COALESCE(b.type, ''); 


-- Using IFNULL() (MySQL)
SELECT
    a.year,
    a.type,
    a.orders,
    b.sales
FROM Table1 a
JOIN Table2 b
ON a.year = b.year
AND IFNULL(a.type, '') = IFNULL(b.type, '');   


-- LEFT JOIN with NULL handling
SELECT
    a.year,
    a.type,
    a.orders,
    COALESCE(b.sales, 0) AS sales -- Instead of displaying NULL, COALESCE(b.sales, 0) returns 0
FROM Table1 a
LEFT JOIN Table2 b
ON a.year = b.year
AND COALESCE(a.type, '') = COALESCE(b.type, '');   
       




-- --Handling null data, while sorting

-- In MySQL, NULL is treated as the smallest value, so it appears first when sorting ascending.

-- Ascending order

SELECT emp_id, emp_name, department, salary
FROM employees
ORDER BY salary ASC;

-- Descending order
SELECT emp_id, emp_name, department, salary
FROM employees
ORDER BY salary DESC;

-- Controlling the Position of NULLs

-- Put NULLs Last in Ascending Order
SELECT *
FROM employees
ORDER BY salary IS NULL, salary ASC;


-- Put NULLs First in Descending Order
SELECT *
FROM employees
ORDER BY salary IS NOT NULL, salary DESC;


/*

1.First Sorting Condition (salary IS NOT NULL): 
The database evaluates this boolean expression for every row before doing anything else. 

If a row has a salary, salary IS NOT NULL evaluates to TRUE (which SQL treats numerically as 1).

If a row lacks a salary, salary IS NOT NULL evaluates to FALSE (which SQL treats numerically as 0). 

Because ORDER BY defaults to ascending order (ASC), it sorts 0 before 1. 

The Problem: This means FALSE (0) comes first, putting NULL salaries at the top.

The Fix: To get valid salaries at the top, you must reverse this logic by explicitly stating salary IS
NOT NULL DESC (since 1 comes before 0 in descending order). 

Note: In the query provided (ORDER BY salary IS NOT NULL), the absence of DESC means it is sorting in ascending order.
If the goal was to push NULL values to the bottom, the syntax should technically be ORDER BY salary IS NOT NULL DESC, salary DESC;. 

2. Second Sorting Condition (salary DESC)
salary DESC: This acts as a tie-breaker.
For all rows where the first condition evaluated to TRUE (all valid salaries), it sorts them from the highest amount to the lowest amount. 


*/  

-- Method 2 (Using )
-- NULL last
SELECT *
FROM employees
ORDER BY
    CASE
        WHEN salary IS NULL THEN 1
        ELSE 0
    END,
    salary ASC;
  
  
  
-- NULLS FIRST               
SELECT *
FROM employees
ORDER BY
    CASE
        WHEN salary IS NULL THEN 0
        ELSE 1
    END ,
    salary ASC;
    
-- one more way    
SELECT *,
       CASE
           WHEN salary IS NULL THEN 0
           ELSE 1
       END AS flag
FROM employees
ORDER BY flag; 


SELECT *,
       CASE
           WHEN salary IS NULL THEN 0
           ELSE 1
       END AS flag
FROM employees
ORDER BY flag,salary;


-- IS NULL and IS NOT NULL are SQL operators used to check whether a column contains a NULL values
/*
-- This does not work.
!= NULL;

Why?
A NULL represents an unknown value.

If you ask:
NULL = NULL

SQL cannot determine whether two unknown values are equal.

The result is: UNKNOWN

not TRUE.

Therefore SQL provides special operators:
IS NULL
IS NOT NULL


*/
SELECT * 
FROM customers
WHERE first_name = NULL;

-- IS NULL, Used to find rows where a column has no value
SELECT * 
FROM customers
WHERE first_name IS NULL;


-- IS NOT NULL, Used to find rows where a column contains a value.

SELECT * 
FROM customers
WHERE first_name IS NOT NULL;


/*
A LEFT ANTI JOIN returns rows from the left table that do not have a matching row in the right table.

A RIGHT ANTI JOIN returns rows from the right table that do not have a matching row in the left table.

Since MySQL doesn't have ANTI JOIN syntax, you'll usually use NOT EXISTS, NOT IN, or LEFT JOIN ... IS NULL.

*/

CREATE TABLE customs (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);


INSERT INTO customs VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Emma'),
(6, 'Frank');

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2)
);

INSERT INTO orders VALUES
(101, 1, 1200),
(102, 2, 800),
(103, 2, 1500),
(104, 4, 900),
(105, 7, 500);

-- in sql we dont have right/left anti join

SELECT c.*
FROM customs c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;


SELECT c.*
FROM customs c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- NOT EXISTS / want to know if at least one row exists

SELECT *
FROM customs c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


