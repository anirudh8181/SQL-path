-- SET Operators

/*

Set operators are SQL operators that combine the results of two or more SELECT queries into a single result set.

Instead of joining tables horizontally (adding columns where we use JOINS) , set operators combine rows vertically

Types of Set Operators

There are four major set operators:

UNION - Returns all unique rows.
UNION ALL
INTERSECT
EXCEPT (called MINUS in Oracle)


Rules Before Using Set Operators
Both queries must satisfy these conditions


*/

-- 1. Same number of columns (from both the tables)

SELECT first_name, last_name
FROM dim_customer

UNION

SELECT product_name, category
FROM dim_product;

-- 1st query controls the names of the output table coulmns


-- 2. Compatible Data Types (both the tables columns must be of same data type)
SELECT first_name, last_name
FROM dim_customer

UNION

SELECT product_name, category
FROM dim_product;


-- Column Order Must Match
SELECT first_name, customer_id
FROM dim_customer

UNION

SELECT product_key,product_name
FROM dim_product;

/*

In MySQL, if first_name is VARCHAR and product_key is INT, MySQL can implicitly convert the integer to text.
The result is logically meaningless, but SQL allows it because the data types are compatible.


*/

SELECT customer_key, first_name
FROM dim_customer

UNION

SELECT product_key, product_name
FROM dim_product;

-- UNION - Combines the results of two queries and removes duplicate rows.
/*

Query A
+
Query B
=
Unique rows only

*/

SELECT country
FROM dim_customer


UNION

SELECT country
FROM dim_store
ORDER BY country;


-- UNION ALL - Combines the results of two queries without removing duplicates.

SELECT country
FROM dim_customer


UNION ALL

SELECT country
FROM dim_store
ORDER BY country;

--  ----------------------
SELECT country
FROM dim_customer
ORDER BY country;

SELECT country
FROM dim_store
ORDER BY country;



-- INTERSECT - Returns only the rows that exist in both queries.

SELECT country
FROM dim_customer

INTERSECT

SELECT country
FROM dim_store;


-- EXCEPT- Returns rows from the first query that do not exist in the second query.


SELECT country
FROM dim_customer

EXCEPT

SELECT country
FROM dim_store;


-- Q1
-- List all unique countries where the company has either customers or stores.

SELECT country
FROM dim_customer

UNION

SELECT country
FROM dim_store;

-- Q2
-- List every country from customers and stores including duplicates.

SELECT country
FROM dim_customer

UNION ALL

SELECT country
FROM dim_store;

-- Q3
-- Find countries that have both customers and stores.

SELECT country
FROM dim_customer

INTERSECT

SELECT country
FROM dim_store;

-- Q4
-- Find countries that have customers but no stores.

SELECT country
FROM dim_customer

EXCEPT

SELECT country
FROM dim_store;

-- Q5
-- Find products that have been sold.

SELECT product_key
FROM dim_product

INTERSECT

SELECT product_key
FROM fact_sales;

-- Q6
-- Find products that have never been sold.

SELECT product_key
FROM dim_product

EXCEPT

SELECT product_key
FROM fact_sales;


-- Q7
-- Create a master list of all names from customers and products.

SELECT first_name AS name
FROM dim_customer

UNION

SELECT product_name
FROM dim_product;




# 1. Find customers who made purchases in both 2022 and 2023.


SELECT DISTINCT
       dc.customer_key,
       dc.customer_id,
       dc.first_name,
       dc.last_name
FROM fact_sales fs
JOIN dim_customer dc
ON fs.customer_key = dc.customer_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2022

INTERSECT

SELECT DISTINCT
       dc.customer_key,
       dc.customer_id,
       dc.first_name,
       dc.last_name
FROM fact_sales fs
JOIN dim_customer dc
ON fs.customer_key = dc.customer_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2023;



# 2. Find customers who purchased in 2022 but not in 2023.


SELECT DISTINCT
       dc.customer_key,
       dc.customer_id,
       dc.first_name,
       dc.last_name
FROM fact_sales fs
JOIN dim_customer dc
ON fs.customer_key = dc.customer_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2022

EXCEPT

SELECT DISTINCT
       dc.customer_key,
       dc.customer_id,
       dc.first_name,
       dc.last_name
FROM fact_sales fs
JOIN dim_customer dc
ON fs.customer_key = dc.customer_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2023;




# 3. Find products sold in both years.


SELECT DISTINCT
       dp.product_key,
       dp.product_name,
       dp.category,
       dp.brand
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2022

INTERSECT

SELECT DISTINCT
       dp.product_key,
       dp.product_name,
       dp.category,
       dp.brand
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2023;



# 4. Find products sold only in 2022.

SELECT DISTINCT
       dp.product_key,
       dp.product_name,
       dp.category
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2022

EXCEPT

SELECT DISTINCT
       dp.product_key,
       dp.product_name,
       dp.category
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2023;


---

# 5. Find stores that had sales in both years.


SELECT DISTINCT
       ds.store_key,
       ds.store_name,
       ds.city,
       ds.country
FROM fact_sales fs
JOIN dim_store ds
ON fs.store_key = ds.store_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2022

INTERSECT

SELECT DISTINCT
       ds.store_key,
       ds.store_name,
       ds.city,
       ds.country
FROM fact_sales fs
JOIN dim_store ds
ON fs.store_key = ds.store_key
JOIN dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.year = 2023;



# 6. Find countries where you have both customers and stores.


SELECT country
FROM dim_customer

INTERSECT

SELECT country
FROM dim_store;


# 7. Find countries where customers exist but stores don't.


SELECT country
FROM dim_customer

EXCEPT

SELECT country
FROM dim_store;




# 8. Create a unique master list of cities.


SELECT city
FROM dim_customer

UNION

SELECT city
FROM dim_store;




# 9. Create a list of all cities including duplicates.


SELECT city
FROM dim_customer

UNION ALL

SELECT city
FROM dim_store;




# 10. Create one master list of names.


SELECT first_name AS Name
FROM dim_customer

UNION

SELECT product_name
FROM dim_product;




# 11. Find brands that have sold products.


SELECT DISTINCT brand
FROM dim_product

INTERSECT

SELECT DISTINCT dp.brand
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key;




# 12. Find brands that have never been sold.


SELECT DISTINCT brand
FROM dim_product

EXCEPT

SELECT DISTINCT dp.brand
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key;




# 13. Find categories that had sales.


SELECT DISTINCT category
FROM dim_product

INTERSECT

SELECT DISTINCT dp.category
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key;




# 14. Find categories with no sales.


SELECT DISTINCT category
FROM dim_product

EXCEPT

SELECT DISTINCT dp.category
FROM fact_sales fs
JOIN dim_product dp
ON fs.product_key = dp.product_key;


# 15. Create a master ID list with the source.


SELECT customer_id AS id,
       'Customer' AS Source
FROM dim_customer

UNION ALL

SELECT product_id,
       'Product'
FROM dim_product

UNION ALL

SELECT store_id,
       'Store'
FROM dim_store;



# ⭐ Challenge Questions (Interview Favorites)



### Q16. Find customers who purchased from stores in both India and the USA.

---

### Q17. Find products sold in every quarter.

---

### Q18. Find stores that sold products from every category.

---

### Q19. Find customers who bought products from multiple brands.

---

### Q20. Find products that were sold in every country.

---


