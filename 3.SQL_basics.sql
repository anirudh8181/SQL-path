USE real_sales;

DROP TABLE enrollment;

-- FIRST SELECT

-- * Select all columns
SELECT * FROM dim_customer;



-- Select particular coulmns
SELECT customer_key,customer_id,email FROM dim_customer;




-- with identation
SELECT 
    customer_key,
    customer_id,
    email
FROM 
    dim_customer;    
    
   
   
   
 -- Limit
 SELECT customer_key, customer_id,email
 FROM dim_customer
 LIMIT 10;
 
 
 


-- WHERE [CONDITION]

-- select only female customers

SELECT * FROM dim_customer
WHERE gender = 'F';


-- Filter by Join Date    
SELECT * FROM dim_customer
WHERE join_date = '2020-12-02';


-- Customers Joined After a Date    
SELECT * FROM dim_customer
WHERE join_date > '2020-01-01';

SELECT * FROM dim_customer
WHERE join_date < '2020-01-01';


-- Customers Joined Between Dates
SELECT * FROM dim_customer
WHERE join_date BETWEEN ('2020-01-01') AND ('2020-12-31');



-- Using IN
SELECT * FROM dim_customer
WHERE state IN ('Alaska', 'Texas', 'California');



-- Check NULL Values
SELECT * FROM dim_customer
WHERE phone IS NULL;






--  (AND CONDITON)----------------------------------------------------------------------

-- select only female customers , from particular country

SELECT *FROM dim_customer
WHERE gender='F' AND country='South Africa';

SELECT *FROM dim_customer
WHERE (gender='F') AND (country='South Africa');


SELECT *FROM dim_customer
WHERE (gender='F') AND (country='South Africa') AND (join_date > '2023-04-07');



-- Multiple Conditions using AND

-- 1
SELECT * FROM dim_customer
WHERE gender = 'F'
AND country = 'Turkmenistan';

-- 2
SELECT * FROM dim_customer
WHERE gender = 'F'
AND join_date > '2020-01-01'
AND country = 'Turkmenistan';




-- (OR CONDITION)---------------------------------------------------------------------

SELECT *FROM dim_customer
WHERE (gender='M' OR country='France');


-- Multiple Conditions using OR
SELECT * FROM dim_customer
WHERE country = 'India'




/*

Rule to remember
1. AND > OR (priority)
2. Always use parentheses when mixing them

*/

-- query1

SELECT  * FROM dim_customer
WHERE (gender='F') AND (country='France') OR (join_date > '2022-01-01')
LIMIT 15;



/*

How SQL interprets it:

( (gender = 'F' AND country = 'France') )
OR
( join_date > '2022-01-01' )

Key point:

-- AND has higher precedence than OR
-- So this runs as:
-- First: gender='F' AND country='France'
-- Then: OR with join_date > '2022-01-01'

Result:

All female customers from France
+
ANY customer (male or female) who joined after '2022-01-01'

That’s why we see male (M) records also appearing in output.

*/



-- query2

SELECT *FROM dim_customer
WHERE (gender='F') AND ((country='France') OR (join_date > '2022-01-01'))
LIMIT 15;


/*

How SQL interprets it:

gender = 'F'
AND
( country = 'France' OR join_date > '2022-01-01' )

Key point:
-- Parentheses change evaluation order
-- Now gender='F' is mandatory


Result:

Only female customers

who also satisfy:
either from France
OR joined after 2022-01-01

That’s why all records are F only


*/


-- LIKE----------------------------------------------

-- 1. Choose a particular data starting with a particular starting letter

SELECT * FROM dim_customer
WHERE 
first_name LIKE 'A%';

-- % anything  after

-- SELECT * FROM dim_customer
-- WHERE 
-- join_date BETWEEN '2021-09-08' AND '2023-06-08';


-- 2.Choose a particular data starting with a particular starting letter, and ending with particular letter data

SELECT * FROM dim_customer
WHERE 
first_name LIKE 'T%y';


-- 3. Choose a particular data starting,ending  with a particular letter, and also the middle pattern


SELECT * FROM dim_customer
WHERE 
first_name LIKE 'T__f%y';




-- Sorting

SELECT * FROM dim_product
ORDER BY unit_price ASC; -- default descending order

SELECT * FROM dim_product
ORDER BY unit_price DESC;


-- TOP 3 expensive products

-- 1.
SELECT * FROM dim_product
ORDER BY unit_price DESC
LIMIT 10;   



-- ALIAS

SELECT 
    product_key, product_id, product_name, category
FROM
    dim_product;


SELECT 
    product_key, 
    product_id,
    product_name AS 'Product_Name',  -- can write column without '' also
    category
FROM
    dim_product;
    
    
    
    
-- GROUPING

  SELECT  *  FROM dim_product;
  
 -----------------------  wrong way of grouping
 
SELECT * FROM dim_product
GROUP BY category;

SELECT category,unit_price FROM dim_product
GROUP BY category;

-----------------------



-- Aggregate - Average

SELECT 
    category, AVG(unit_price) AS AVERAGE_PRICE
FROM
    dim_product
GROUP BY category;

SELECT * FROM real_sales.dim_product;



-- Aggregate - Sum

SELECT 
    category, SUM(unit_price) AS SUM_PRICE, AVG(unit_price) AS AVERAGE_PRICE
FROM
    dim_product
GROUP BY category;

SELECT * FROM real_sales.dim_product;

-- Aggregate - Count 

SELECT 
    category,
    COUNT(*) AS total_products,  -- COUNT(*) counts rows, not column values or COUNT(*) counts number of rows in each category group
    SUM(unit_price) AS total_price,
    AVG(unit_price) AS avg_price
FROM dim_product
GROUP BY category;

SELECT * FROM real_sales.dim_product;

SELECT COUNT(category) AS count_category FROM dim_product
WHERE category='clothing';




/*
Electronics → 2 rows
Clothing    → 2 rows
Furniture   → 1 row
*/


-- problems

-- multi-level grouping

SELECT 
    category,
    brand,
    COUNT(*) AS total_products,
    AVG(unit_price) AS avg_price
FROM dim_product
GROUP BY category, brand
ORDER BY category, avg_price DESC;


-- latest products

-- MAX(column_name) returns the highest (maximum) value from a column.


SELECT MAX(unit_price) AS highest_price
FROM dim_product;

SELECT 
    category,
    MAX(launch_date) AS latest_launch
FROM dim_product
GROUP BY category;


-- year wise product launches

SELECT 
    YEAR(launch_date) AS launch_year,
    COUNT(*) AS total_products
FROM dim_product
GROUP BY launch_year
ORDER BY launch_year;







-------- Having Clause --------------------------------------------------------

SELECT 
    category,
    SUM(unit_price) AS sum_price,  -- <---- calculate column
    AVG(unit_price) AS avg_price
FROM
    dim_product
GROUP BY category;  -- <-- Filter on aggregated data



SELECT 
    category,
    SUM(unit_price) AS sum_price,  -- <---- calculate column
    AVG(unit_price) AS avg_price
FROM
    dim_product
GROUP BY category
HAVING avg_price > 500;


SELECT 
    brand,
    SUM(unit_price) AS total_value,
    AVG(unit_price) AS avg_price,
    COUNT(*) AS total_products
FROM dim_product
GROUP BY brand
HAVING total_products > 5
ORDER BY total_value DESC;




--------- Execution Flow  ------------------

  
SELECT 
    brand,
    SUM(unit_price) AS total_value,
    AVG(unit_price) AS avg_price,
    COUNT(*) AS total_products
FROM dim_product
GROUP BY brand
HAVING total_products > 5
ORDER BY total_value DESC;

/*
MySQL executes it in this order:

1. FROM (including JOIN + ON)
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY
7. LIMIT


1. FROM
MySQL first decides which table(s) to read
Joins are also processed here


2.WHERE
Filters rows before grouping
Cannot use aggregate functions here


3. GROUP BY
Groups rows based on column(s)
Prepares data for aggregate functions


4. HAVING
Filters groups (not rows)
Used after aggregation

5. SELECT
Finally selects columns
Aggregate functions are calculated here


6. ORDER BY
Sorts the final result

7. LIMIT
Restricts number of rows returned


Table Data
   ↓
FROM (pick table)
   ↓
WHERE (filter rows)
   ↓
GROUP BY (make groups)
   ↓
HAVING (filter groups)
   ↓
SELECT (choose columns)
   ↓
ORDER BY (sort)
   ↓
LIMIT (final output)

*/
  
    
    

  











 
 
 
 
 
 
 
 
 
    