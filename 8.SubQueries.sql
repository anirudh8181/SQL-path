-- SUBQUERIES

/*

A subquery is:

A query written inside another SQL query.

It is also called:
Inner Query
Nested Query

Types of Subqueries

There are mainly 5 important types:

Single-row subquery
Multiple-row subquery
Multiple-column subquery
Correlated subquery
Nested subquery

*/

-- Display Avg price
SELECT AVG(unit_price) 
FROM dim_product; -- returns single value


-- display products having price more than Avg price
SELECT *
FROM dim_product
WHERE unit_price > 495.790060 -- can be replced with a subquery
ORDER BY unit_price ASC;


-- subquery to find unit price of products greater than AVG price
SELECT *
FROM dim_product
WHERE unit_price > (SELECT AVG(unit_price) FROM dim_product)
ORDER BY unit_price ASC;


-- writing subquery for FROM clause

SELECT *
FROM 
(
SELECT *
FROM dim_product
WHERE unit_price > (SELECT AVG(unit_price) FROM dim_product)
ORDER BY unit_price ASC
) AS sub_query_table  -- IN MEMORY TABLE
WHERE product_name= 'Figure Method';




-- 1. Single-Row Subquery (returns only one value)

-- 1. Find products priced higher than the average product price
SELECT product_name, unit_price
FROM dim_product
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM dim_product
);

-- 2. Find customers who joined on the earliest join date
SELECT first_name, last_name, join_date
FROM dim_customer
WHERE join_date = (
    SELECT MIN(join_date)
    FROM dim_customer
);

-- 3. Find the store with the highest total sales amount
SELECT store_name
FROM dim_store
WHERE store_key = (
    SELECT store_key
    FROM fact_sales
    GROUP BY store_key
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
);

-- 4. Find products launched after the latest product in Electronics category
SELECT product_name, launch_date
FROM dim_product
WHERE launch_date > (
    SELECT MAX(launch_date)
    FROM dim_product
    WHERE category = 'Electronics'
);



-- 2. Multiple-Row Subquery  (returns multiple values)

-- 1. Find customers who made purchases in stores located in India
SELECT first_name, last_name
FROM dim_customer
WHERE customer_key IN (
    SELECT customer_key
    FROM fact_sales fs
    JOIN dim_store ds
    ON fs.store_key = ds.store_key
    WHERE ds.country = 'India'
);

-- 2. Find products belonging to categories having more than 5 products
SELECT product_name, category
FROM dim_product
WHERE category IN (
    SELECT category
    FROM dim_product
    GROUP BY category
    HAVING COUNT(*) > 5
);

-- 3. Find stores that sold products with discounts greater than 20
SELECT store_name
FROM dim_store
WHERE store_key IN (
    SELECT DISTINCT store_key
    FROM fact_sales
    WHERE discount > 20
);

-- 4. Find products sold during weekends
SELECT product_name
FROM dim_product
WHERE product_key IN (
    SELECT DISTINCT fs.product_key
    FROM fact_sales fs
    JOIN dim_date dd
    ON fs.date_key = dd.date_key
    WHERE dd.is_weekend = 1
);


-- 3. Multiple-Column Subquery (subquery returns multiple columns)

-- 1. Find customers and cities matching customers from USA
SELECT first_name, city
FROM dim_customer
WHERE (country, city) IN (
    SELECT country, city
    FROM dim_customer
    WHERE country = 'USA'
);

-- 2. Find products having same category and brand as premium products
SELECT product_name, category, brand
FROM dim_product
WHERE (category, brand) IN (
    SELECT category, brand
    FROM dim_product
    WHERE unit_price > 1000
);

-- 3. Find stores located in same country and region as top-performing stores
SELECT store_name, country, region
FROM dim_store
WHERE (country, region) IN (
    SELECT country, region
    FROM dim_store
    WHERE store_key IN (
        SELECT store_key
        FROM fact_sales
        GROUP BY store_key
        HAVING SUM(total_amount) > 50000
    )
);

-- 4. Find sales records having same customer and product combinations as discounted sales
SELECT sales_id, customer_key, product_key
FROM fact_sales
WHERE (customer_key, product_key) IN (
    SELECT customer_key, product_key
    FROM fact_sales
    WHERE discount > 15
);


-- Correlated Subquery (inner query depends on outer query)

-- 1. Find products priced above their category average
SELECT product_name, category, unit_price
FROM dim_product p
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM dim_product
    WHERE category = p.category
);

-- 2. Find customers whose total purchases exceed average customer spending
SELECT customer_key
FROM fact_sales fs
GROUP BY customer_key
HAVING SUM(total_amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(total_amount) AS customer_total
        FROM fact_sales
        GROUP BY customer_key
    ) t
);

-- 3. Find stores whose sales are above average sales of stores in same region
SELECT store_name, region
FROM dim_store ds
WHERE (
    SELECT SUM(total_amount)
    FROM fact_sales fs
    WHERE fs.store_key = ds.store_key
) > (
    SELECT AVG(store_sales)
    FROM (
        SELECT ds2.region,
               SUM(fs2.total_amount) AS store_sales
        FROM fact_sales fs2
        JOIN dim_store ds2
        ON fs2.store_key = ds2.store_key
        WHERE ds2.region = ds.region
        GROUP BY fs2.store_key
    ) x
);

-- 4. Find highest-priced product in each 

SELECT product_name, category, unit_price
FROM dim_product p
WHERE unit_price = (
    SELECT MAX(unit_price)
    FROM dim_product
    WHERE category = p.category
);


-- Nested Subquery (subquery inside another subquery)
-- 1. Find customers who purchased the most expensive product
SELECT first_name, last_name
FROM dim_customer
WHERE customer_key IN (
    SELECT customer_key
    FROM fact_sales
    WHERE product_key = (
        SELECT product_key
        FROM dim_product
        WHERE unit_price = (
            SELECT MAX(unit_price)
            FROM dim_product
        )
    )
);

-- 2. Find stores that sold products from the category with highest average price
SELECT store_name
FROM dim_store
WHERE store_key IN (
    SELECT DISTINCT store_key
    FROM fact_sales
    WHERE product_key IN (
        SELECT product_key
        FROM dim_product
        WHERE category = (
            SELECT category
            FROM dim_product
            GROUP BY category
            ORDER BY AVG(unit_price) DESC
            LIMIT 1
        )
    )
);

-- 3. Find customers who purchased products launched in the latest year
SELECT first_name, last_name
FROM dim_customer
WHERE customer_key IN (
    SELECT customer_key
    FROM fact_sales
    WHERE product_key IN (
        SELECT product_key
        FROM dim_product
        WHERE YEAR(launch_date) = (
            SELECT MAX(YEAR(launch_date))
            FROM dim_product
        )
    )
);

-- 4. Find products sold in stores located in the region with highest sales
SELECT product_name
FROM dim_product
WHERE product_key IN (
    SELECT DISTINCT product_key
    FROM fact_sales
    WHERE store_key IN (
        SELECT store_key
        FROM dim_store
        WHERE region = (
            SELECT ds.region
            FROM fact_sales fs
            JOIN dim_store ds
            ON fs.store_key = ds.store_key
            GROUP BY ds.region
            ORDER BY SUM(fs.total_amount) DESC
            LIMIT 1
        )
    )
);