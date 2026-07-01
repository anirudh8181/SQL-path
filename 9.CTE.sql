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


-- Keep one row per (lowercased) email, lowest customer_key wins
WITH dedup AS (
    SELECT customer_key, email,
           ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY customer_key) AS rn
    FROM dim_customer
)
SELECT * FROM dedup
WHERE rn = 1;

-- Flag duplicates instead of removing them
WITH dedup AS (
    SELECT customer_key, email,
           ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY customer_key) AS rn
    FROM dim_customer
)
SELECT customer_key, email,
       CASE WHEN rn = 1 THEN 'Keep' ELSE 'Duplicate' END AS status
FROM dedup;

-- Identify duplicate product names (any rn > 1 means a repeat)
WITH dups AS (
    SELECT product_key, product_name,
           ROW_NUMBER() OVER (PARTITION BY product_name ORDER BY product_key) AS rn
    FROM dim_product
)
SELECT * FROM dups
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


-- Per-store revenue vs the overall average store revenue
WITH store_rev AS (
    SELECT store_key, SUM(total_amount) AS revenue
    FROM fact_sales
    GROUP BY store_key
)
SELECT store_key,
       ROUND(revenue, 2) AS revenue,
       ROUND((SELECT AVG(revenue) FROM store_rev), 2) AS avg_store_revenue,
       CASE WHEN revenue > (SELECT AVG(revenue) FROM store_rev)
            THEN 'Above Avg' ELSE 'Below Avg' END AS performance
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
    SELECT 1 AS n                      -- anchor
    UNION ALL
    SELECT n + 1 FROM numbers          -- recursive step
    WHERE n < 20                       -- termination condition
)
SELECT n FROM numbers;

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
    SELECT DATE '2023-10-01' AS dt
    UNION ALL
    SELECT dt + INTERVAL 1 DAY FROM date_spine
    WHERE dt < '2023-10-31'
)
SELECT dt FROM date_spine;

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


 -- Practice scaffold (uncomment after creating the sample table):
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





--  CTE in DML (INSERT / UPDATE / DELETE)
-- A CTE can feed a write statement: define the transformed/target rows in the
-- CTE, then INSERT/UPDATE/DELETE based on it. (MySQL 8.0+)
-- Syntax: WITH c AS (...) INSERT INTO target SELECT * FROM c;  (or DELETE/UPDATE)


-- Example: build a high-value sales summary table from a CTE
CREATE TABLE high_value_sales_summary (
    store_key INT,
    total_high_value DECIMAL(12,2)
);

WITH hv AS (
    SELECT store_key, SUM(total_amount) AS total_high_value
    FROM fact_sales
    WHERE total_amount >= 1000
    GROUP BY store_key
)
INSERT INTO high_value_sales_summary (store_key, total_high_value)
SELECT store_key, total_high_value FROM hv;


-- Example: delete duplicate customers, keeping the lowest customer_key
WITH dups AS (
    SELECT customer_key,
           ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY customer_key) AS rn
    FROM dim_customer
)
DELETE FROM dim_customer
WHERE customer_key IN (SELECT customer_key FROM dups WHERE rn > 1);




