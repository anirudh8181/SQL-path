-- VIEW

/*
A View is a virtual table based on the result of an SQL query.
It does not store data itself (except materialized behavior in some engines) — it stores the query definition.


Why Use Views?

Views help you:

Simplify complex queries
Reuse SQL logic
Hide sensitive columns
Improve readability
Provide abstraction/security


Syntax:

CREATE VIEW view_name AS
-- our own query logic
SELECT column1, column2
FROM table_name
WHERE condition;


Difference Between Table and View
| Table            | View              |
| ---------------- | ----------------- |
| Stores data      | Stores query      |
| Physical object  | Virtual object    |
| Faster retrieval | May be slower     |
| Independent      | Depends on tables |


Types of Views

1. Simple View

-- Based on one table
-- No aggregate functions
-- Usually updatable

Example:

CREATE VIEW student_view AS
SELECT id, name
FROM students;


2. Complex View

-- Uses joins
-- Aggregate functions
-- GROUP BY
-- Usually not updatable

Example:

CREATE VIEW dept_salary AS
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;



3. Updatable Views

A view can be updated if it:

-- Uses a single table
-- Has no GROUP BY
-- No aggregate functions
-- No DISTINCT
-- No UNION

Example:

UPDATE employee_view
SET emp_name = 'John'
WHERE emp_id = 1;

This updates the original table.

*/

-- Create a View

CREATE VIEW Dedup_View AS
SELECT 
    subquery.*  
FROM    
(
SELECT *,
      ROW_NUMBER() OVER(PARTITION BY emp_id ORDER BY emp_id) AS Deduplicate_Ranking 
FROM 
   employees
) subquery 
WHERE Deduplicate_Ranking=1;





-- Updating a View

CREATE OR REPLACE VIEW MOVING_AVG AS
SELECT 
    product_name,
    category,
    brand,
    unit_price,
    AVG(unit_price) OVER(  ORDER BY launch_date  ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING ) AS Moving_Avg
FROM dim_product;



-- Query it like a table:

SELECT * FROM dedup_view;




-- Drop View  syntax: DROP VIEW view_name;

DROP VIEW dedup_view;




-- Check Existing Views
SHOW FULL TABLES
WHERE Table_type = 'VIEW';


