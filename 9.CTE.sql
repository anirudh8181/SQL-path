-- CTE [ Common Table Expressions 

/*

A CTE (Common Table Expression) is a temporary result set that you can define within a query and 
then reference like a table. It makes complex queries easier to read, organize, and reuse.

Syntax:

WITH cte_name AS (
    SELECT column1, column2
    FROM table_name
    WHERE condition
)
SELECT *
FROM cte_name;




1. Improves Readability
Instead of deeply nested subqueries, you break logic into steps.

2. Reusability in Same Query
You can reference the CTE multiple times.

3. Recursive Queries
CTEs support recursion (very powerful for hierarchical data like trees).


*/

SELECT *
FROM dim_product
WHERE unit_price > (SELECT AVG(unit_price) FROM dim_product)
ORDER BY unit_price ASC;

WITH cte_table AS
(
SELECT *
FROM dim_product
WHERE unit_price > (SELECT AVG(unit_price) FROM dim_product)
ORDER BY unit_price ASC
)
SELECT * FROM cte_table
WHERE product_name='Trade Onto';

-----------------------------------------

-- chained CTE , A chained CTE means one CTE uses the result of a previous CTE.

WITH cte_table AS
(
SELECT *
FROM dim_product
WHERE unit_price > (SELECT AVG(unit_price) FROM dim_product)
ORDER BY unit_price ASC
),

cte_table2 AS 
(
SELECT * FROM cte_table
WHERE product_name IN ('Figure Method','Huge Change', 'Film Finally')
)

SELECT * FROM cte_table2
WHERE product_name='Figure Method';





--  CTE + Window Functions
-- The most common real-world CTE pattern: compute a ranking/row number inside
-- the CTE, then FILTER on it in the outer query (you cannot filter a window
-- function directly in WHERE).
-- Syntax: WITH c AS (SELECT ..., ROW_NUMBER() OVER(...) rn FROM t) SELECT * FROM c WHERE rn = 1


-- Rank products by price within each category, then keep only rank 1
WITH ranked AS (
    SELECT product_name, category, unit_price,
           RANK() OVER (PARTITION BY category ORDER BY unit_price DESC) AS price_rank
    FROM dim_product
)
SELECT * FROM ranked
WHERE price_rank = 1;


-- Top 3 most expensive products per category
WITH ranked AS (
    SELECT product_name, category, unit_price,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY unit_price DESC) AS rnk
    FROM dim_product
)
SELECT * FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;

-- Number each customer's products and show only their first sale (by sales_id)
WITH numbered AS (
    SELECT sales_id, customer_key, total_amount,
           ROW_NUMBER() OVER (PARTITION BY customer_key ORDER BY sales_id) AS seq
    FROM fact_sales
)
SELECT * FROM numbered
WHERE seq = 1;




--  CTE for Deduplication
-- Standard way to remove duplicates: ROW_NUMBER() over the "duplicate key" in
-- a CTE, then keep rn = 1 (survivor) and treat the rest as duplicates.
-- Syntax: WITH d AS (SELECT ..., ROW_NUMBER() OVER(PARTITION BY key ORDER BY tiebreak) rn ...) SELECT * FROM d WHERE rn = 1

CREATE TABLE dim_customer_duplicates
(
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    email VARCHAR(100),
    phone VARCHAR(20),
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    join_date DATE
);

INSERT INTO dim_customer_duplicates
VALUES
(1,'CUST001','Rahul','Sharma','Male',
'rahul@gmail.com',
'9876543210',
'India',
'Tamil Nadu',
'Chennai',
'2024-01-01'),

(2,'CUST002','Amit','Verma','Male',
'amit@gmail.com',
'9876543211',
'India',
'Karnataka',
'Bangalore',
'2024-01-05'),

(3,'CUST003','Rahul','Kumar','Male',
'rahul@gmail.com',
'9876543212',
'India',
'Tamil Nadu',
'Chennai',
'2024-02-10'),

(4,'CUST004','Priya','Rao','Female',
'PRIYA@GMAIL.COM',
'9876543213',
'India',
'Kerala',
'Kochi',
'2024-03-11'),

(5,'CUST005','Priya','Iyer','Female',
'priya@gmail.com',
'9876543214',
'India',
'Kerala',
'Kochi',
'2024-03-20'),

(6,'CUST006','Anil','Menon','Male',
'  anil@gmail.com  ',
'9876543215',
'India',
'Telangana',
'Hyderabad',
'2024-04-15'),

(7,'CUST007','Anil','Nair','Male',
'anil@gmail.com',
'9876543216',
'India',
'Telangana',
'Hyderabad',
'2024-05-01'),

(8,'CUST008','Sneha','Das','Female',
'sneha@gmail.com',
'9876543217',
'India',
'West Bengal',
'Kolkata',
'2024-05-10');

CREATE TABLE dim_product_duplicates
(
    product_key INT PRIMARY KEY,
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    launch_date DATE
);

INSERT INTO dim_product_duplicates
VALUES
(1,'P001','Wireless Mouse','Electronics','Logitech',1200,'2023-01-01'),

(2,'P002','Wireless Mouse','Electronics','HP',1250,'2023-01-15'),

(3,'P003','Gaming Keyboard','Electronics','Redragon',3500,'2023-02-01'),

(4,'P004','Gaming Keyboard','Electronics','Corsair',4200,'2023-02-10'),

(5,'P005','USB Hub','Accessories','Anker',900,'2023-03-01'),

(6,'P006','USB Hub','Accessories','TP-Link',850,'2023-03-10'),

(7,'P007','Monitor','Electronics','Dell',14000,'2023-04-01'),

(8,'P008','MONITOR','Electronics','LG',14500,'2023-04-15'),

(9,'P009','  Monitor  ','Electronics','Samsung',15000,'2023-05-01');


-- Keep one row per (lowercased) email, lowest customer_key wins
WITH dedup AS (
    SELECT customer_key, email,
           ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY customer_key) AS rn
    FROM dim_customer
)
SELECT * FROM dedup
WHERE rn = 1;

-- Flag duplicates instead of removing them
WITH dedup AS
(
    SELECT
        customer_key,
        email,
        ROW_NUMBER() OVER
        (
            PARTITION BY LOWER(TRIM(email))
            ORDER BY customer_key
        ) AS rn
    FROM dim_customer_duplicates
)
SELECT
    customer_key,
    email,
    CASE
        WHEN rn = 1 THEN 'Keep'
        ELSE 'Duplicate'
    END AS status
FROM dedup;



-- Identify duplicate product names (any rn > 1 means a repeat)
WITH dups AS
(
    SELECT
        product_key,
        product_name,
        ROW_NUMBER() OVER
        (
            PARTITION BY LOWER(TRIM(product_name))
            ORDER BY product_key
        ) AS rn
    FROM dim_product_duplicates
)
SELECT *
FROM dups
WHERE rn > 1;




--  CTE for Multi-Step Aggregation
-- Aggregate in one CTE, then do a SECOND calculation (ratio, % of total,
-- comparison) in the outer query. Keeps multi-stage logic readable.
-- Syntax: WITH agg AS (SELECT k, SUM(x) s FROM t GROUP BY k) SELECT k, s / SUM(s) OVER() FROM agg


-- Each product's revenue as a % of its category total
WITH product_rev AS (
    SELECT dp.category, dp.product_name, SUM(fs.total_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_product dp ON fs.product_key = dp.product_key
    GROUP BY dp.category, dp.product_name
)
SELECT category, product_name,
       ROUND(revenue, 2) AS revenue,
       ROUND(revenue / SUM(revenue) OVER (PARTITION BY category) * 100, 2) AS pct_of_category
FROM product_rev
ORDER BY category, pct_of_category DESC;


-- Per-store total revenue vs the overall average stores revenue
WITH store_rev AS (
    SELECT store_key, SUM(total_amount) AS revenue
    FROM fact_sales
    GROUP BY store_key
)
SELECT store_key,
       ROUND(revenue, 2) AS revenue,
       ROUND((SELECT AVG(revenue) FROM store_rev), 2) AS avg_store_revenue,
       CASE 
         WHEN revenue > (SELECT AVG(revenue) FROM store_rev) THEN 'Above Avg' 
         ELSE 'Below Avg' 
       END AS performance
FROM store_rev;


-- Monthly revenue, then each month's share of the yearly total
WITH monthly AS (
    SELECT d.year, d.month, SUM(fs.total_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_date d ON fs.date_key = d.date_key
    GROUP BY d.year, d.month
)
SELECT year, month,
       ROUND(revenue, 2) AS revenue,
       ROUND(revenue / SUM(revenue) OVER (PARTITION BY year) * 100, 2) AS pct_of_year
FROM monthly
ORDER BY year, month;




--  Reusing a CTE multiple times
-- A CTE defined once can be referenced many times in the outer query (e.g.,
-- joined to itself, or compared against its own aggregate). Avoids repeating
-- the same subquery.
-- Syntax: WITH c AS (...) SELECT ... FROM c a JOIN c b ON ...


-- Compare each category's avg price against the global avg (CTE used twice)
WITH cat_avg AS (
    SELECT category, AVG(unit_price) AS avg_price
    FROM dim_product
    GROUP BY category
)

SELECT category,
       ROUND(avg_price, 2) AS category_avg,
       ROUND((SELECT AVG(avg_price) FROM cat_avg), 2) AS overall_avg
FROM cat_avg;


-- Self-join a CTE to pair each product with others in the same category
WITH prods AS (
    SELECT product_key, product_name, category, unit_price
    FROM dim_product
)
SELECT a.category, a.product_name AS product_a, b.product_name AS product_b
FROM prods a
JOIN prods b
  ON a.category = b.category
 AND a.product_key < b.product_key
LIMIT 20;




--  Recursive CTE — Number Series
-- A recursive CTE has an ANCHOR member (starting row) + a RECURSIVE member
-- (references itself) joined by UNION ALL, and stops via a WHERE condition.
-- Syntax: WITH RECURSIVE c AS (SELECT seed ... UNION ALL SELECT next FROM c WHERE stop) SELECT * FROM c


-- Generate numbers 1 to 20
WITH RECURSIVE numbers AS (
    SELECT 1 AS n                      -- anchor query
    UNION ALL
    SELECT n + 1 FROM numbers          -- recursive step query
    WHERE n < 20                       -- termination condition
)
SELECT n FROM numbers;

/*

Table name: numbers
Column name: n
Row value: 1

Execute the Recursive Query:
SELECT n + 1
FROM numbers
WHERE n < 20;


*/

-- Generate the first 10 multiples of 5
WITH RECURSIVE multiples AS (
    SELECT 5 AS val
    UNION ALL
    SELECT val + 5 FROM multiples
    WHERE val < 50
)
SELECT val FROM multiples;




--  Recursive CTE — Date Spine
-- Recursion is the classic way to build a continuous calendar/date series
-- (useful to fill gaps where no sales happened on some days).
-- Syntax: anchor = start date; recursive = DATE_ADD(prev, INTERVAL 1 DAY) until end


-- Generate every date in October 2023
WITH RECURSIVE date_spine AS (
    SELECT DATE '2023-10-01' AS Month_date
    UNION ALL
    SELECT Month_date + INTERVAL 1 DAY FROM date_spine
    WHERE Month_date < '2023-10-31'
)
SELECT Month_date FROM date_spine;

/*
This combines

Anchor query
Recursive query

into one result.0

*/

-- Date spine joined to sales so days with no sales still appear (as 0)
WITH RECURSIVE date_spine AS (
    SELECT DATE '2023-10-01' AS dt
    UNION ALL
    SELECT dt + INTERVAL 1 DAY FROM date_spine
    WHERE dt < '2023-10-31'
)
SELECT s.dt,
       COALESCE(SUM(fs.total_amount), 0) AS daily_revenue
FROM date_spine s
LEFT JOIN dim_date d  ON d.date = s.dt
LEFT JOIN fact_sales fs ON fs.date_key = d.date_key
GROUP BY s.dt
ORDER BY s.dt;




--  Recursive CTE — Hierarchy Traversal
-- Recursion walks parent -> child relationships (org charts, category trees).
-- NOTE: Real_Sales has no parent-child column, so here is the GENERIC pattern
-- on a sample employee-manager table you would create to practice.
-- Syntax: anchor = root rows (parent IS NULL); recursive = join children to parents


 -- Practice scaffold 
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT
);
INSERT INTO employees VALUES
(1,'CEO',NULL),(2,'VP Sales',1),(3,'VP Tech',1),
(4,'Sales Lead',2),(5,'Engineer',3),(6,'Analyst',4);

WITH RECURSIVE org_chart AS (
    SELECT emp_id, emp_name, manager_id, 1 AS level   -- anchor: top of tree
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.manager_id, oc.level + 1  -- recursive: children
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.emp_id
)
SELECT emp_id, emp_name, level FROM org_chart ORDER BY level, emp_id;

/*


Starting `employees` table

| emp_id | emp_name   | manager_id |
| -----: | ---------- | ---------: |
|      1 | CEO        |       NULL |
|      2 | VP Sales   |          1 |
|      3 | VP Tech    |          1 |
|      4 | Sales Lead |          2 |
|      5 | Engineer   |          3 |
|      6 | Analyst    |          4 |

And the recursive CTE is:

WITH RECURSIVE org_chart AS (

    -- Anchor
    SELECT emp_id, emp_name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive part
    SELECT e.emp_id, e.emp_name, e.manager_id, oc.level + 1
    FROM employees e
    JOIN org_chart oc
        ON e.manager_id = oc.emp_id
)
SELECT *
FROM org_chart;


ITERATION 0 — Anchor

The anchor runs only once:


SELECT emp_id, emp_name, manager_id, 1 AS level
FROM employees
WHERE manager_id IS NULL


SQL searches `employees`:


Who has manager_id = NULL?


Answer:
CEO


So:
org_chart
┌────────┬────────┬────────────┬───────┐
│ emp_id │ name   │ manager_id │ level │
├────────┼────────┼────────────┼───────┤
│ 1      │ CEO    │ NULL       │ 1     │
└────────┴────────┴────────────┴───────┘


This is our starting point.



ITERATION 1 — Find CEO's children

Now the recursive part runs.


SELECT e.emp_id, e.emp_name, e.manager_id, oc.level + 1
FROM employees e
JOIN org_chart oc
    ON e.manager_id = oc.emp_id


Currently `org_chart` contains:

CEO
emp_id = 1
level = 1


The JOIN says:

e.manager_id = oc.emp_id


So:


e.manager_id = 1


SQL looks in `employees`:

| emp_id | emp_name | manager_id |
| -----: | -------- | ---------: |
|      2 | VP Sales |      **1** |
|      3 | VP Tech  |      **1** |

Therefore, iteration 1 produces:


2 | VP Sales | 1 | 2
3 | VP Tech  | 1 | 2


Why level 2?


oc.level + 1
1 + 1 = 2


Now the CTE has:

org_chart

1 | CEO      | NULL | 1
2 | VP Sales | 1    | 2
3 | VP Tech  | 1    | 2




ITERATION 2 — Find their children

This is the important one

Now the recursive process takes the newly discovered rows:


2 | VP Sales | 1 | 2
3 | VP Tech  | 1 | 2


and uses them as `oc`.

First `oc` row

oc.emp_id = 2
oc.level = 2


JOIN:
e.manager_id = oc.emp_id


becomes:
e.manager_id = 2


Look in `employees`:
4 | Sales Lead | 2


So:

4 | Sales Lead | 2 | 3


---

Second `oc` :

oc.emp_id = 3
oc.level = 2

JOIN becomes:


e.manager_id = 3


Look in `employees`:


5 | Engineer | 3


So:


5 | Engineer | 3 | 3


Therefore **iteration 2 produces**:


4 | Sales Lead | 2 | 3
5 | Engineer   | 3 | 3


Now we have:


org_chart

1 | CEO         | NULL | 1
2 | VP Sales    | 1    | 2
3 | VP Tech     | 1    | 2
4 | Sales Lead  | 2    | 3
5 | Engineer    | 3    | 3


---

 ITERATION 3 — Find their children

Now the newly found rows are:


4 | Sales Lead | 2 | 3
5 | Engineer   | 3 | 3


Again:

sql
e.manager_id = oc.emp_id


 For Sales Lead


oc.emp_id = 4


Therefore:


e.manager_id = 4


Find in employees:


6 | Analyst | 4


So:


6 | Analyst | 4 | 4


 For Engineer


oc.emp_id = 5


Therefore:


e.manager_id = 5


Nobody has `manager_id = 5`.

So iteration 3 produces only:


6 | Analyst | 4 | 4


Now:


org_chart

1 | CEO         | NULL | 1
2 | VP Sales    | 1    | 2
3 | VP Tech     | 1    | 2
4 | Sales Lead  | 2    | 3
5 | Engineer    | 3    | 3
6 | Analyst     | 4    | 4


---

 ITERATION 4 — Find Analyst's children

Now the new row is:

6 | Analyst | 4 | 4


The JOIN becomes:
e.manager_id = 6


Look at employees:
Who has manager_id = 6?


Nobody.

Therefore:


Iteration 4 → 0 rows

And now recursion stops**.

---

 Where exactly does `UNION ALL` fit?

This is very important.

`UNION ALL` combines the output of each stage.

Think of it as:


ANCHOR
  ↓
CEO
  +
ITERATION 1
  ↓
VP Sales, VP Tech
  +
ITERATION 2
  ↓
Sales Lead, Engineer
  +
ITERATION 3
  ↓
Analyst
  +
ITERATION 4
  ↓
Nothing


So the final CTE is:


CEO
VP Sales
VP Tech
Sales Lead
Engineer
Analyst


Or with levels:


Level 1 → CEO

Level 2 → VP Sales
           VP Tech

Level 3 → Sales Lead
           Engineer

Level 4 → Analyst


---

 The entire thing in one picture


                    ANCHOR
                       │
                       ▼
                  ┌─────────┐
                  │   CEO   │
                  │ Level 1 │
                  └────┬────┘
                       │
                ITERATION 1
                       │
              ┌────────┴────────┐
              ▼                 ▼
        ┌──────────┐      ┌─────────┐
        │ VP Sales │      │ VP Tech │
        │ Level 2  │      │ Level 2 │
        └────┬─────┘      └────┬────┘
             │                 │
             └────────┬────────┘
                      │
                ITERATION 2
                      │
             ┌────────┴────────┐
             ▼                 ▼
       ┌────────────┐    ┌──────────┐
       │Sales Lead  │    │ Engineer │
       │  Level 3   │    │ Level 3  │
       └─────┬──────┘    └──────────┘
             │
             │
        ITERATION 3
             │
             ▼
       ┌──────────┐
       │ Analyst  │
       │ Level 4  │
       └────┬─────┘
            │
       ITERATION 4
            │
            ▼
       No children
            │
            ▼
           STOP


 The key rule to remember

Anchor runs once.

Recursive part repeatedly takes the newly found rows and joins them back to `employees` to find their children.


Current org_chart rows
        ↓
JOIN employees
        ↓
Find children
        ↓
UNION ALL
        ↓
Add children to result
        ↓
Use those children in next iteration
        ↓
Repeat


That's the entire mechanism of your recursive CTE.


*/

-- Find all managers of an employee

WITH RECURSIVE managers AS
(
    -- Anchor
    SELECT
        emp_id,
        emp_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE emp_id = 6

    UNION ALL

    -- Recursive step
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        m.level + 1
    FROM employees e
    JOIN managers m
        ON e.emp_id = m.manager_id
)

SELECT *
FROM managers;

-- Find all managers of an employee

WITH RECURSIVE org_chart AS
(
    SELECT
        emp_id,
        emp_name,
        manager_id,
        1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        oc.level + 1
    FROM employees e
    JOIN org_chart oc
        ON e.manager_id = oc.emp_id
)
SELECT
    emp_name,
    level,
    CASE
        WHEN level = 1 THEN 'Top Management'
        WHEN level = 2 THEN 'Management'
        WHEN level = 3 THEN 'Team Lead'
        ELSE 'Employee'
    END AS employee_level
FROM org_chart
ORDER BY level;







--  CTE in DML (INSERT / UPDATE / DELETE)
-- A CTE can feed a write statement: define the transformed/target rows in the
-- CTE, then INSERT/UPDATE/DELETE based on it. (MySQL 8.0+)
-- Syntax: WITH c AS (...) INSERT INTO target SELECT * FROM c;  (or DELETE/UPDATE)

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2)
);

INSERT INTO sales VALUES
(1, 'Laptop', 2, 60000),
(2, 'Mouse', 5, 800),
(3, 'Keyboard', 3, 1500),
(4, 'Monitor', 2, 12000),
(5, 'Laptop', 1, 60000);

-- creat destination table
CREATE TABLE high_value_sales (
    sale_id INT,
    product VARCHAR(50),
    total_amount DECIMAL(10,2)
);

WITH calculated_sales AS (
    SELECT
        sale_id,
        product,
        quantity * price AS total_amount
    FROM sales
)
INSERT INTO high_value_sales  -- wromg way
    (sale_id, product, total_amount)
SELECT
    sale_id,
    product,
    total_amount
FROM calculated_sales
WHERE total_amount > 50000;


INSERT INTO high_value_sales
    (sale_id, product, total_amount)
WITH calculated_sales AS (
    SELECT
        sale_id,
        product,
        quantity * price AS total_amount
    FROM sales
)
SELECT
    sale_id,
    product,
    total_amount
FROM calculated_sales
WHERE total_amount > 50000;



CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
);

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 75000, 10),
(2, 'Mouse', 'Electronics', 1200, 50),
(3, 'Keyboard', 'Electronics', 2500, 30),
(4, 'Chair', 'Furniture', 8000, 15),
(5, 'Desk', 'Furniture', 15000, 8),
(6, 'Monitor', 'Electronics', 20000, 5),
(7, 'Notebook', 'Stationery', 200, 100),
(8, 'Pen', 'Stationery', 50, 200);

-- increase the price of all Electronics products by 10%.
WITH electronic_products AS (
    SELECT product_id
    FROM products
    WHERE category = 'Electronics'
)
UPDATE products
SET price = price * 1.10
WHERE product_id IN (
    SELECT product_id
    FROM electronic_products
);

-- increase the price of products whose price is below the average price of their category.
WITH category_avg AS (
    SELECT
        category,
        AVG(price) AS avg_price
    FROM products
    GROUP BY category
)
UPDATE products p
JOIN category_avg c
    ON p.category = c.category
SET p.price = p.price * 1.10
WHERE p.price < c.avg_price;


-- delete products where stock is less than 10.
WITH low_stock AS (
    SELECT product_id
    FROM products
    WHERE stock < 10
)
DELETE FROM products
WHERE product_id IN (
    SELECT product_id
    FROM low_stock
);

-- Delete an entire category
WITH stationery_products AS (
    SELECT product_id
    FROM products
    WHERE category = 'Stationery'
)
DELETE FROM products
WHERE product_id IN (
    SELECT product_id
    FROM stationery_products
);





-- Example: delete duplicate customers, keeping the lowest customer_key
WITH dups AS (
    SELECT customer_key,
           ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY customer_key) AS rn
    FROM dim_customer
)
DELETE FROM dim_customer
WHERE customer_key IN (SELECT customer_key FROM dups WHERE rn > 1);


-- CTE vs SUBQUERY

/*

| Subquery                            | CTE                                   |
| ----------------------------------- | ------------------------------------- |
| Written inside another query        | Defined at the top with `WITH`        |
| Can become hard to read when nested | Easier to read and organize           |
| Good for simple queries             | Better for multi-step transformations |
| May repeat the same logic           | Define once, reuse multiple times     |
| Often used for one-off calculations | Common in ETL and analytics pipelines |

*/


-- 1. Total Revenue Per Store, Find all stores whose revenue is greater than ₹500,000.

-- Using a Subquery
SELECT *
FROM
(
    SELECT
        store_key,
        SUM(total_amount) AS revenue
    FROM fact_sales
    GROUP BY store_key
) s
WHERE revenue > 500000;

-- Same Query Using a CTE

WITH store_revenue AS
(
    SELECT
        store_key,
        SUM(total_amount) AS revenue
    FROM fact_sales
    GROUP BY store_key
)

SELECT *
FROM store_revenue
WHERE revenue > 500000;

-- 2. Average Revenue Across Stores, Find stores whose revenue is above the average store revenue.
-- subquery
SELECT *
FROM
(
    SELECT
        store_key,
        SUM(total_amount) AS revenue
    FROM fact_sales
    GROUP BY store_key
) s
WHERE revenue >
(
    SELECT AVG(revenue)
    FROM
    (
        SELECT
            SUM(total_amount) AS revenue
        FROM fact_sales
        GROUP BY store_key
    ) x
);


-- cte
WITH store_revenue AS(
SELECT  store_key,
       SUM(total_amount) AS revenue
 FROM fact_sales
 GROUP BY store_key
)
SELECT * 
FROM store_revenue
WHERE revenue > (SELECT AVG(revenue) FROM store_revenue);


-- Top 5 Products, Find the top 5 products by revenue.

SELECT *
FROM
(
   SELECT
        dp.product_name,
        SUM(fs.total_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_product dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.product_name
) x
ORDER BY revenue DESC
LIMIT  5;

-- CTE
WITH product_revenue AS
(
    SELECT
        dp.product_name,
        SUM(fs.total_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_product dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.product_name
)

SELECT *
FROM product_revenue
ORDER BY revenue DESC
LIMIT 5;

-- 4. Find regions whose revenue is above the average regional revenue.

SELECT *
FROM
(
    SELECT
        ds.region,
        SUM(fs.total_amount) revenue
    FROM fact_sales fs
    JOIN dim_store ds
        ON fs.store_key = ds.store_key
    GROUP BY ds.region
) r
WHERE revenue >
(
    SELECT AVG(revenue)
    FROM
    (
        SELECT
            ds.region,
            SUM(fs.total_amount) revenue
        FROM fact_sales fs
        JOIN dim_store ds
            ON fs.store_key = ds.store_key
        GROUP BY ds.region
    ) x
);


-- CTE

WITH high_revenue AS(

SELECT ds.region, SUM(fs.total_amount) AS revenue
FROM fact_sales fs
JOIN dim_store ds
ON fs.store_key =  ds.store_key
GROUP BY ds.region

)

SELECT * FROM high_revenue
WHERE revenue > (SELECT AVG(revenue) FROM high_revenue);

/*
Situation 1: Repeated Logic

-Subquery repeats the same aggregation.

SUM(total_amount)
GROUP BY store_key

appears multiple times.

Move it into a CTE.


Multiple Transformations:

Instead of deeply nested subqueries:

Subquery
    ↓
Subquery
    ↓
Subquery

write:

sales
    ↓
store_revenue
    ↓
region_revenue
    ↓
final_result

Each step has a meaningful name.

Readability: Complex logic is broken into named steps.
Maintainability: Repeated logic is written once.
Reusability: The same intermediate result can be referenced multiple times in the query.
Debugging: You can inspect each transformation step independently during development.
ETL suitability: Multi-step data transformations are much easier to express with chained CTEs.

One important clarification: a CTE is not automatically faster than a subquery.
Modern database optimizers often produce the same execution plan for equivalent queries. 
The primary reason to choose a CTE is usually clarity and maintainability, not performance.


*/











