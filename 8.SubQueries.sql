-- SUBQUERIES

/*

A subquery is:

A query written inside another SQL query.

It is also called:
Inner Query
Nested Query

-------------------------------
General Syntax:

SELECT column1, column2
FROM table1
WHERE column OPERATOR   < -- outer query
(
    SELECT column
    FROM table2
    WHERE condition <--inner query
);
----------------------------




1. Subquery in WHERE (Most Common)

SELECT column_names
FROM table_name
WHERE column =
(
    SELECT column
    FROM another_table
);

Example:

SELECT *
FROM employees
WHERE dept_id =
(
    SELECT dept_id
    FROM departments
    WHERE dept_name = 'HR'
);


--------------------------------------------
Execution

Inner Query
↓

Returns dept_id = 20

↓

Outer Query

SELECT *
FROM employees
WHERE dept_id = 20;


--------------------------------------
2. Subquery in FROM

The subquery acts like a temporary table.

SELECT *
FROM
(
    SELECT product_key,
           AVG(total_amount) AS avg_sales
    FROM fact_sales
    GROUP BY product_key
) AS product_avg;


Execution:

Run Inner Query

↓

Temporary Table Created

↓

Outer Query Reads It


-------------------------------------
3. Subquery in SELECT

Used to return an additional calculated value.

SELECT
    sales_id,
    total_amount,
    (
        SELECT AVG(total_amount)
        FROM fact_sales
    ) AS company_average_sales
FROM fact_sales;


-------------------------------------

4. Subquery with IN:

SELECT *
FROM dim_customer
WHERE country IN
(
    SELECT country
    FROM dim_store
    WHERE region = 'North'
);

Suppose the subquery returns



-------------------------------------

5. Subquery with EXISTS:

EXISTS checks whether the subquery returns at least one row.

If at least one row exists → TRUE
If no rows exist → FALSE

It does not care about the values returned by the subquery.

SELECT *
FROM dim_product p
WHERE EXISTS
(
    SELECT *
    FROM fact_sales f
    WHERE f.product_key = p.product_key
);

The subquery checks whether at least one matching row exists.

----------------------------------------------

6. Correlated Subquery:

SELECT *
FROM employees e1
WHERE salary >
(
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.dept_id = e1.dept_id
);




Types of Subqueries

There are mainly 5 important types:

Single-row subquery
Multiple-row subquery
Multiple-column subquery
Correlated subquery
Nested subquery


*/



/*


Problem:

Find all products whose price is greater than the average product price.

sql:

SELECT
    product_name,
    unit_price
FROM dim_product
WHERE unit_price >
(
    SELECT AVG(unit_price)
    FROM dim_product
);




---

 Step 0: SQL Parser

When MySQL receives the query, it doesn't execute it immediately.

It first understands the query.

It notices:

* Outer query

sql
SELECT product_name, unit_price
FROM dim_product
WHERE unit_price > ( ... )


* Inner query

sql
SELECT AVG(unit_price)
FROM dim_product


It also notices:

> The inner query does not depend on the outer query.

So MySQL marks it as an independent subquery.

---

 Step 1: Execute the inner query first

It runs:

SELECT AVG(unit_price)
FROM dim_product;


Suppose your table is

| product_name | unit_price |
| ------------ | ---------: |
| Mouse        |        500 |
| Keyboard     |        800 |
| Monitor      |       1200 |
| Laptop       |       3000 |
| Webcam       |       1000 |

MySQL reads every row.


500
800
1200
3000
1000


Computes:
AVG = 1300


The subquery returns

| AVG(unit_price) |
| --------------: |
|            1300 |

Notice:

Only one row.

So this is called a single-row subquery.

---

 Step 2: Store the result

MySQL stores:

1300 internally.

it's like
temporary_value = 1300

It doesn't execute the subquery again, because it already knows the answer.

---

 Step 3: Rewrite mentally

Now MySQL effectively sees

sql
SELECT
    product_name,
    unit_price
FROM dim_product
WHERE unit_price > 1300;


The subquery has disappeared.

Only its result remains.

---

 Step 4: Scan the outer table

Now MySQL starts reading `dim_product`.

Row 1:

Mouse:
500


Checks:
500 > 1300 ?


No.
Discard.

---

 Row 2:

Keyboard:
800


Checks:
800 > 1300 ?

No.
Discard.

---

 Row 3:

Monitor:
1200


Checks:
1200 > 1300 ?


No.
Discard.

---

 Row 4:

Laptop:
3000


Checks
3000 > 1300 ?


Yes.

Keep it.

---

Row 5:

Webcam:
1000


Checks:
1000 > 1300 ?


No.

Discard.



step 5: Return the result

Finally

| product_name | unit_price |
| ------------ | ---------: |
| Laptop       |       3000 |

---

Internal execution flow:

User executes query
        │
        ▼
SQL Parser
        │
        ▼
Find subquery
        │
        ▼
Execute subquery
        │
        ▼
AVG(unit_price)=1300
        │
        ▼
Store 1300
        │
        ▼
Scan dim_product
        │
        ▼
Compare every row with 1300
        │
        ▼
Return matching rows


-------------------------------------------------------------------------

Why isn't the subquery executed multiple times?

Because it is independent.

It has no reference to the outer query.


SELECT AVG(unit_price)
FROM dim_product;


This query always returns the same answer, no matter which product is currently being examined.

So MySQL executes it once, stores the result, and reuses it.

--------------------------------------------------------------------------------------

*/


-- Display Avg price
SELECT AVG(unit_price) 
FROM dim_product; -- returns single value


-- display products having price more than Avg 
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
    SELECT AVG(unit_price) as AVG
    FROM dim_product
);

-- 2. Find customers who joined on the earliest join date
SELECT first_name, last_name, join_date
FROM dim_customer
WHERE join_date = (
    SELECT MIN(join_date) AS earlier_joinee
    FROM dim_customer
    WHERE state = 'Alaska'
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
SELECT product_name, launch_date, category
FROM dim_product
WHERE launch_date > (
    SELECT MAX(launch_date)
    FROM dim_product
    WHERE category = 'Electronics'
);



-- 2. Multiple-Row Subquery  (returns multiple values)

-- 1. Find customers who made purchases in stores located in singapore
SELECT first_name, last_name
FROM dim_customer
WHERE customer_key IN ( 
    SELECT fs.customer_key
    FROM fact_sales fs
    JOIN dim_store ds
    ON fs.store_key = ds.store_key
    WHERE ds.country = 'singapore'
);

-- 2. Find products belonging to categories having more than 80 products
SELECT product_name, category
FROM dim_product
WHERE category IN (   -- Return rows where the category matches any one of these values
    SELECT category
    FROM dim_product
    GROUP BY category
    HAVING COUNT(*) > 80 -- COUNT(*) is an aggregate function, and aggregate conditions belong in the HAVING clause.
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

-- 1. Find customers and cities matching customers from singapore

/*

Syntax:

SELECT column_list
FROM table1
WHERE (column1, column2, ...)
      operator
(
    SELECT column1, column2, ...
    FROM table2
);

1.The number of columns returned by the subquery must match the number of columns in the outer query.
2.The data types should be compatible.

Outer query compares:

(10,50000) no
(20,60000) no
(10,70000) yes
(30,45000) no
(20,65000) yes

Use one when the condition depends on a combination of columns, such as:

(department, salary)
(city, state)
(customer_id, order_date)
(product_id, warehouse_id)

*/

-- 1
SELECT first_name, city
FROM dim_customer
WHERE (country, city) IN (
    SELECT country, city
    FROM dim_customer
    WHERE country = 'singapore'
);

-- 2. Find products having same category and brand as premium products
SELECT product_name, category, brand
FROM dim_product
WHERE (category, brand) IN (
    SELECT category, brand
    FROM dim_product
    WHERE unit_price >  820
);

-- 2.1 Find the sales where the sold price is the highest price ever recorded for that product.

SELECT
    sales_id,
    product_key,
    unit_price
FROM fact_sales
WHERE (product_key, unit_price) IN
(
    SELECT
        product_key,
        MAX(unit_price)
    FROM fact_sales
    GROUP BY product_key
);

SELECT product_key, unit_price
FROM fact_sales
ORDER BY product_key;


-- 3. Find stores located in same country and region as top-performing stores having amount greater thn 50000
SELECT store_name, country, region
FROM dim_store
WHERE (country, region) IN (
    SELECT country, region
    FROM dim_store
    WHERE store_key IN (
        SELECT store_key
        FROM fact_sales
        GROUP BY store_key
        HAVING SUM(total_amount) > 55000
    )
);



-- 4. Find sales records having same customer and product combinations as discounted sales
SELECT sales_id, customer_key, product_key
FROM fact_sales
WHERE (customer_key, product_key) IN (
    SELECT customer_key, product_key
    FROM fact_sales
    WHERE discount > 43.9
);




-- 5.Find sales where the quantity equals the maximum quantity sold for that product.

SELECT
    sales_id,
    product_key,
    quantity_sold
FROM fact_sales
WHERE (product_key, quantity_sold) IN
(
    SELECT
        product_key,
        MAX(quantity_sold)  AS quantity_sold
    FROM fact_sales
    GROUP BY product_key
    ORDER BY quantity_sold DESC
)
ORDER BY quantity_sold DESC;







-- 6 Sales that are not the highest sale for each product

SELECT
    sales_id,
    product_key,
    unit_price
FROM fact_sales
WHERE (product_key, unit_price) NOT IN
(
    SELECT
        product_key,
        MAX(unit_price)
    FROM fact_sales
    GROUP BY product_key
);


-- 7.Purchases that are not the customer's biggest purchase
SELECT
    sales_id,
    customer_key,
    total_amount
FROM fact_sales
WHERE (customer_key, total_amount) NOT IN
(
    SELECT
        customer_key,
        MAX(total_amount)
    FROM fact_sales
    GROUP BY customer_key
);



-- 8.Filter out NULLs in the subquery
SELECT
    sales_id,
    product_key,
    unit_price
FROM fact_sales
WHERE (product_key, unit_price) NOT IN
(
    SELECT
        product_key,
        unit_price
    FROM dim_product
    WHERE unit_price IS NOT NULL
);


/*

Framing subquery:

Step 1: Ask yourself one question

What information do I need before I can write the outer query?

That information usually comes from the subquery.

For example:

Find customers who spent the maximum amount.

Ask yourself:

"What do I need first?"

Answer:
The maximum amount for every customer.

That's your subquery.


SELECT customer_key, MAX(total_amount)
FROM fact_sales
GROUP BY customer_key;

Now use it.

SELECT *
FROM fact_sales
WHERE (customer_key, total_amount) IN
(
    SELECT customer_key, MAX(total_amount)
    FROM fact_sales
    GROUP BY customer_key
);




Step 2: Build the subquery first

Never write the outer query first.

Example:

Question:
Find products that have never been sold.

First ask:
Which products have been sold?


SELECT DISTINCT product_key
FROM fact_sales;


Then think:
I want products not in that list.


SELECT *
FROM dim_product
WHERE product_key NOT IN
(
    SELECT DISTINCT product_key
    FROM fact_sales
);


Always build from the inside out.


Step 3: Recognize the patterns

Almost every interview subquery falls into one of these.

Pattern 1:

Find rows matching a value.

Question:
Highest sale

Subquery:
SELECT MAX(total_amount)
FROM fact_sales;


Outer query:
SELECT *
FROM fact_sales
WHERE total_amount =
(
    SELECT MAX(total_amount)
    FROM fact_sales
);


Pattern 2:

Find rows matching grouped values.

Question:
 Highest sale per customer

Subquery:

SELECT customer_key,
       MAX(total_amount)
FROM fact_sales
GROUP BY customer_key;


Outer query:

WHERE (customer_key,total_amount) IN (...)


Pattern 3:

Find rows that exist elsewhere.

Question:
Customers who purchased.

Subquery:
SELECT customer_key
FROM fact_sales;

Outer:
SELECT *
FROM dim_customer
WHERE customer_key IN (...)

Pattern 4:

Find rows that do not exist.

Question:
Products never sold

Subquery
SELECT product_key
FROM fact_sales;

Outer:
WHERE product_key NOT IN (...)

or

WHERE NOT EXISTS (...)




Pattern 5

Compare every row.

Question:
Employees earning above department average.

Subquery:
SELECT AVG(...)

Needs each department.
That's a correlated subquery.



Step 4: Translate English into SQL

Example:
Find customers whose largest purchase exceeds ₹10,000.

Break it down.

Largest purchase

↓

MAX(total_amount)


For each customer
↓
GROUP BY customer_key


Greater than 10000

↓
HAVING MAX(total_amount)>10000


Subquery:

SELECT customer_key
FROM fact_sales
GROUP BY customer_key
HAVING MAX(total_amount)>5000


Outer query:

SELECT *
FROM dim_customer
WHERE customer_key IN (...)


Mental Framework

Whenever you see a question, ask these 5 questions:

1. What table should the final answer come from?

Example:

"Find customers..."

Answer:
dim_customer




2. What information is missing?

Example:
Customers who spent the most.

Missing:
Maximum spending


3. Can that information be obtained separately?

If yes,

That's the subquery.


4. How do I connect it?

we'll Choose one:

=
IN
NOT IN
EXISTS
NOT EXISTS
ANY
ALL


5. Finish the outer query.



1. Highest sale overall (`=`)
2. Customers who made a purchase (`IN`)
3. Products never sold (`NOT IN` / `NOT EXISTS`)
4. Customers whose purchase is above average (`>`)
5. Products sold at original price (multi-column `IN`)
6. Largest sale per customer (multi-column `IN`)
7. Customers who bought from every store (`NOT EXISTS`)
8. Products sold in all regions (`NOT EXISTS`)
9. Customers spending above their own average (correlated)
10. Stores whose revenue exceeds the average revenue (correlated)




*/


/*

Requirement:
Find employees earning more than their department's average.

Compare with a correlated subquery:


SELECT product_name,
       category,
       unit_price
FROM dim_product p
WHERE unit_price >
(
    SELECT AVG(unit_price)
    FROM dim_product
    WHERE category = p.category
);


The inner query depends on the current outer row (`p.category`), so MySQL cannot execute it just once. 
It must re-evaluate it for each outer row (or transform it into an equivalent execution plan if the optimizer chooses).

This difference—execute once versus execute per outer row—is the most important concept for understanding 
how subqueries work internally.

The biggest difference between a normal (independent) subquery and a correlated subquery is:

* Independent subquery: Runs once.
* Correlated subquery: Runs for every row of the outer query (conceptually).


sql:
SELECT
    product_name,
    category,
    unit_price
FROM dim_product p
WHERE unit_price >
(
    SELECT AVG(unit_price)
    FROM dim_product
    WHERE category = p.category
);


---

 Problem Statement

Find products whose price is greater than the average price of products in their own category.

Suppose `dim_product` contains:

| product_name | category    | unit_price |
| ------------ | ----------- | ---------: |
| Mouse        | Accessories |        500 |
| Keyboard     | Accessories |        800 |
| Webcam       | Accessories |       1000 |
| Laptop A     | Laptop      |       2500 |
| Laptop B     | Laptop      |       3000 |
| Laptop C     | Laptop      |       3500 |

---

 Step 0: Parser

MySQL separates the query into

Outer Query :

SELECT
    product_name,
    category,
    unit_price
FROM dim_product p


Inner Query:

SELECT AVG(unit_price)
FROM dim_product
WHERE category = p.category


Now MySQL notices something important.

The inner query contains:

p.category


But `p` belongs to the outer query.

So the inner query cannot run independently.

It needs the current outer row.

This is why it is called a correlated subquery.

---

 Step 1: Read the first outer row

Current row

| product | category    | price |
| ------- | ----------- | ----: |
| Mouse   | Accessories |   500 |

Now the value


p.category = 'Accessories'


is known.

---

 Step 2: Execute the inner query

The inner query becomes

sql:

SELECT AVG(unit_price)
FROM dim_product
WHERE category = 'Accessories';


Notice that:
p.category


has been replaced with 'Accessories'


MySQL calculates


Accessories:
500
800
1000


Average:
(500 + 800 + 1000)/3

= 766.67


---

 Step 3: Compare

Current row

Mouse:
500


Compare:
500 > 766.67 ?


No.

Discard Mouse.

---

 Step 4: Move to the next row

Current row

| product  | category    | price |
| -------- | ----------- | ----: |
| Keyboard | Accessories |   800 |

Again

text
p.category = 'Accessories'


The inner query runs again.

sql
SELECT AVG(unit_price)
FROM dim_product
WHERE category='Accessories';


Result:
766.67


Compare:
800 > 766.67

Yes.

Return Keyboard.

---

 Step 5: Next row

Current row

| product | category    | price |
| ------- | ----------- | ----: |
| Webcam  | Accessories |  1000 |

Again

sql
SELECT AVG(unit_price)
FROM dim_product
WHERE category='Accessories';


Average:
766.67


Compare:
1000 > 766.67


Yes.

Return Webcam.

---

 Step 6: Fourth row

Current row

| product  | category | price |
| -------- | -------- | ----: |
| Laptop A | Laptop   |  2500 |

Now

text
p.category = 'Laptop'


The inner query changes.

sql
SELECT AVG(unit_price)
FROM dim_product
WHERE category='Laptop';


Laptop prices:

2500
3000
3500


Average:
3000


Compare:
2500 > 3000

No.

Discard.

---

 Step 7: Fifth row

Current row:
Laptop B

3000


Inner query runs again

sql:
SELECT AVG(unit_price)
FROM dim_product
WHERE category='Laptop';


Average:
3000


Compare:
3000 > 3000
False.

Discard.

---

 Step 8: Sixth row

Current row:


Laptop C
3500


Inner query:

SELECT AVG(unit_price)
FROM dim_product
WHERE category='Laptop';


Average:
3000


Compare:
3500 > 3000


True.

Return Laptop C.

---

 Final Result:

| product  | category    | price |
| -------- | ----------- | ----: |
| Keyboard | Accessories |   800 |
| Webcam   | Accessories |  1000 |
| Laptop C | Laptop      |  3500 |

---

Visual Execution Flow


Outer Row 1 (Mouse)
        │
        ▼
Run inner query for Accessories
        │
        ▼
Average = 766.67
        │
        ▼
500 > 766.67 ? 


Outer Row 2 (Keyboard)
        │
        ▼
Run inner query for Accessories
        │
        ▼
Average = 766.67
        │
        ▼
800 > 766.67 ? 


Outer Row 3 (Webcam)
        │
        ▼
Run inner query for Accessories
        │
        ▼
Average = 766.67
        │
        ▼
1000 > 766.67 ? 


Outer Row 4 (Laptop A)
        │
        ▼
Run inner query for Laptop
        │
        ▼
Average = 3000
        │
        ▼
2500 > 3000 ? 


Outer Row 5 (Laptop B)
        │
        ▼
Run inner query for Laptop
        │
        ▼
Average = 3000
        │
        ▼
3000 > 3000 ? ❌


Outer Row 6 (Laptop C)
        │
        ▼
Run inner query for Laptop
        │
        ▼
Average = 3000
        │
        ▼
3500 > 3000 ? 




Why is it called a "correlated" subquery?

Because the inner query is correlated (linked) to the outer query.

The line:

sql:
WHERE category = p.category


means:

"Use the `category` value from the current row of the outer query."

Without the outer row, the inner query is incomplete—it doesn't know what `p.category` is.

---

A note about real databases

Conceptually, we should think of a correlated subquery as running once for every outer row, 
which is the correct mental model for learning SQL.

However, modern database optimizers (such as MySQL, PostgreSQL, SQL Server, and Oracle) may recognize certain correlated subqueries 
and internally rewrite them into a more efficient `JOIN` or another execution strategy. 
This optimization doesn't change the result—it only improves performance. For interviews and understanding query logic, the "runs once per outer row" model is the right way to reason about correlated subqueries.




*/


-- Correlated Subquery (inner query depends on outer query)

-- 1. Find products priced above their category average
SELECT product_name, category, unit_price
FROM dim_product p
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM dim_product
    WHERE category = p.category
);

-- 1.1 Find the largest purchase made by each customer.

SELECT *
FROM fact_sales f1
WHERE total_amount =
(
    SELECT MAX(total_amount)
    FROM fact_sales f2
    WHERE f2.customer_key = f1.customer_key
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




/*

Extra topics:

1. EXISTS
2. NOT EXISTS
3. ANY (or SOME)
4. ALL
5. NOT IN (NULL issue)
6. Subquery in SELECT clause
7. Correlated UPDATE
8. Correlated DELETE
9. Subquery vs JOIN (Performance Example)

*/

-- 
-- 1. EXISTS
-- Returns TRUE if the subquery returns at least one row
-- 

-- Find customers who have made at least one purchase

SELECT first_name, last_name
FROM dim_customer c
WHERE EXISTS (
    SELECT 1
    FROM fact_sales fs
    WHERE fs.customer_key = c.customer_key
);



-- Find stores that have recorded at least one sale

SELECT store_name
FROM dim_store ds
WHERE EXISTS (
    SELECT 1
    FROM fact_sales fs
    WHERE fs.store_key = ds.store_key
);



-- 
-- 2. NOT EXISTS
-- Returns TRUE if the subquery returns NO rows
-- 

-- Customers who never purchased anything

SELECT first_name, last_name
FROM dim_customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_sales fs
    WHERE fs.customer_key = c.customer_key
);



-- Stores that never recorded any sales

SELECT store_name
FROM dim_store ds
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_sales fs
    WHERE fs.store_key = ds.store_key
);



-- 
-- 3. ANY (SOME)
-- Comparison against at least one value
-- 

-- Products more expensive than at least one Electronics product

SELECT product_name, unit_price
FROM dim_product
WHERE unit_price > ANY (
    SELECT unit_price
    FROM dim_product
    WHERE category = 'Electronics'
);



-- Products cheaper than at least one Furniture product

SELECT product_name, unit_price
FROM dim_product
WHERE unit_price < ANY (
    SELECT unit_price
    FROM dim_product
    WHERE category = 'Furniture'
);



-- 
-- 4. ALL
-- Comparison against every value
-- 

-- Products more expensive than every Electronics product

SELECT product_name, unit_price
FROM dim_product
WHERE unit_price > ALL (
    SELECT unit_price
    FROM dim_product
    WHERE category = 'Electronics'
);



-- Products cheaper than every Furniture product

SELECT product_name, unit_price
FROM dim_product
WHERE unit_price < ALL (
    SELECT unit_price
    FROM dim_product
    WHERE category = 'Furniture'
);



-- 
-- 5. NOT IN
-- 

-- Customers who never purchased anything

SELECT first_name, last_name
FROM dim_customer
WHERE customer_key NOT IN (
    SELECT customer_key
    FROM fact_sales
);



/*
IMPORTANT INTERVIEW NOTE

If the subquery returns NULL

Example:

customer_key
------------
1
2
NULL

Then

WHERE customer_key NOT IN (...)

returns NO ROWS because NULL makes the comparison UNKNOWN.

Therefore NOT EXISTS is usually preferred.
*/



-- 
-- 6. Subquery in SELECT Clause
-- 

-- Display every product with overall average price

SELECT
    product_name,
    unit_price,
    (
        SELECT AVG(unit_price)
        FROM dim_product
    ) AS average_price
FROM dim_product;



-- Display each customer with total number of orders

SELECT
    c.customer_key,
    c.first_name,
    (
        SELECT COUNT(*)
        FROM fact_sales fs
        WHERE fs.customer_key = c.customer_key
    ) AS total_orders
FROM dim_customer c;



-- Display each store with total sales

SELECT
    ds.store_name,
    (
        SELECT SUM(total_amount)
        FROM fact_sales fs
        WHERE fs.store_key = ds.store_key
    ) AS total_sales
FROM dim_store ds;




-- 7. Correlated UPDATE


/*

Example

Suppose dim_customer contains

total_sales

Update it using fact_sales.

*/

UPDATE dim_customer c
SET total_sales = (
    SELECT SUM(total_amount)
    FROM fact_sales fs
    WHERE fs.customer_key = c.customer_key
);



-- 
-- 8. Correlated DELETE
-- 

-- Delete customers who never made a purchase

DELETE FROM dim_customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_sales fs
    WHERE fs.customer_key = c.customer_key
);



-- Delete stores with no sales

DELETE FROM dim_store ds
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_sales fs
    WHERE fs.store_key = ds.store_key
);



-- 
-- 9. Subquery vs JOIN (Performance Example)
-- 

-- Subquery Version
-- Products belonging to categories with more than 5 products

SELECT *
FROM dim_product
WHERE category IN (
    SELECT category
    FROM dim_product
    GROUP BY category
    HAVING COUNT(*) > 5
);



-- Equivalent JOIN Version
-- Often preferred for readability and optimization

SELECT p.*
FROM dim_product p
JOIN (
    SELECT category
    FROM dim_product
    GROUP BY category
    HAVING COUNT(*) > 5
) c
ON p.category = c.category;




-- BONUS: EXISTS vs IN


-- Using IN

SELECT first_name, last_name
FROM dim_customer
WHERE customer_key IN (
    SELECT customer_key
    FROM fact_sales
);



-- Equivalent EXISTS

SELECT first_name, last_name
FROM dim_customer c
WHERE EXISTS (
    SELECT 1
    FROM fact_sales fs
    WHERE fs.customer_key = c.customer_key
);




-- BONUS: Scalar Subquery
-- (Returns exactly one value)


SELECT
    product_name,
    unit_price,
    (
        SELECT MAX(unit_price)
        FROM dim_product
    ) AS highest_price
FROM dim_product;




-- BONUS: Derived Table (Subquery in FROM)


SELECT *
FROM (
    SELECT
        category,
        AVG(unit_price) AS avg_price
    FROM dim_product
    GROUP BY category
) AS category_avg
WHERE avg_price > 500;