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



