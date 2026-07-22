-- WINDOW FUNCTION

/*

Window Functions let you perform calculations across a set of rows related to the  'current row'  without collapsing 
the result into a single row like GROUP BY.

- It performs a calculation over a window '(subset) of rows' while still keeping individual rows.


Syntax:

function_name() OVER(
    PARTITION BY column
    ORDER BY column
    ROWS/RANGE frame
)

This has 4 major parts:

Function
OVER()
PARTITION BY
ORDER BY
ROWS / RANGE (window frame)

Components of Window Functions:

Window Function mainly has these components:

1. FUNCTION

This is the operation SQL performs.

Examples:

| Function Type | Examples                     |
| ------------- | ---------------------------- |
| Aggregate     | SUM, AVG, COUNT, MIN, MAX    |
| Ranking       | ROW_NUMBER, RANK, DENSE_RANK |
| Analytical    | LAG, LEAD, FIRST_VALUE ,NTH tile      |


Example:
SUM(salary)

Means:
Calculate total salary.

But SQL still doesn't know:
over which rows?
grouped how?
ordered how?

That is handled by OVER().


2. OVER()

This is the MOST IMPORTANT component.

It defines:
Which rows belong to the window.

Without OVER(), SQL treats functions normally.

*/

-- Normal Aggregate

SELECT SUM(unit_price)
FROM dim_product;

-- returns one row.


-- Windows Function

SELECT
    *,
    SUM(unit_price) OVER()
FROM dim_product;

-- Now:

-- rows are preserved
-- calculation happens over a window

/*

What OVER() Can  ?

OVER(
    PARTITION BY ...
    ORDER BY ...
    ROWS/RANGE ...
)

it's like:

OVER(
   divide rows,
   sort rows,
   choose rows
)


3. PARTITION BY

This divides rows into groups.

VERY SIMILAR to GROUP BY.

BUT:
rows are NOT collapsed

Example Table:
| emp | dept | salary |
| --- | ---- | ------ |
| A   | IT   | 100    |
| B   | IT   | 200    |
| C   | HR   | 300    |

*/

SELECT * FROM dim_product;

SELECT
    product_name,
    brand,
    category,
    unit_price,
    SUM(unit_price) OVER( PARTITION BY category ) AS Total
FROM dim_product;

/*

4. ORDER BY Inside OVER()

This defines order INSIDE each partition.

Very important for:

ranking
running totals/ moving totals
lag/lead
moving averages/ running averages

*/

SELECT * FROM dim_product;

SELECT
    product_name,
    brand,
    category,
    unit_price,
	launch_date,
    SUM(unit_price) OVER( ORDER BY  launch_date) AS Running_Total
FROM dim_product;

SELECT
    product_name,
    brand,
    category,
    unit_price,
	launch_date,
    AVG(unit_price) OVER( ORDER BY  launch_date) AS Moving_AVG
FROM dim_product;

/*

5. ROWS / RANGE (Window Frame)

This defines:

EXACTLY which rows participate in calculation.

This is called:

frame clause
sliding window

Example:
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
ROWS BETWEEN UNBOUNDED PRECEDING AND  UNBOUNDED FOLLOWING
ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING


Means:
Take:
2 previous rows
+ current row

| Keyword             | Meaning              |
| ------------------- | -------------------- |
| CURRENT ROW         | Current row          |
| UNBOUNDED PRECEDING | Start from first row |
| UNBOUNDED FOLLOWING | Till last row        |
| 2 PRECEDING         | 2 rows before        |
| 3 FOLLOWING         | 3 rows after         |


*/





-----------------------------------------------
SELECT *FROM dim_product;



SELECT 
    AVG(unit_price)
FROM
    dim_product;     
----------------------------------------------------



-- Normal Aggregate

-- Problem: Original rows are lost

SELECT category, AVG(unit_price) AS Avg_unit_price
FROM dim_product
GROUP BY category;



-- Window Function Version

SELECT category,
      AVG(unit_price) OVER(ORDER BY unit_price) as Avg_unit_price
FROM dim_product;








-- 1. Running SUM/Total

SELECT *,
     SUM(unit_price) OVER(ORDER BY unit_price) AS Running_sum
FROM 
     dim_product; 
 
 /*
 
Internal Processing:

Row 1: 100
SUM = 100

Row 2: 200
SUM = 100 + 200=300

Row 3: 300
SUM = 100 + 200 + 300

SUM = 600
 
 */
     
     

-- 2. Running_Total

SELECT *,
     SUM(unit_price) OVER(ORDER BY launch_date) AS Running_Total
FROM 
     dim_product;  

     
-- 3. Moving Average

SELECT *,
     AVG(unit_price) OVER(ORDER BY launch_date) AS Moving_Average
FROM 
     dim_product;   
     
     
 -- FRAMES ---------
 
/*

| Keyword             | Meaning              |
| ------------------- | -------------------- |
| CURRENT ROW         | Current row          |
| UNBOUNDED PRECEDING | Start from first row |
| UNBOUNDED FOLLOWING | Till last row        |
| 2 PRECEDING         | 2 rows before        |
| 3 FOLLOWING         | 3 rows after         |

*/ 
 
 SELECT *,
     SUM(unit_price) OVER(ORDER BY launch_date) AS Running_Total
FROM 
     dim_product;  
 
 
 SELECT *,
      SUM(unit_price) OVER(ORDER BY product_key ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Runnning_Total
FROM 
   dim_product;
   
   
 SELECT *,
      SUM(unit_price) OVER(ORDER BY product_key ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Total_Sum
FROM 
   dim_product;
 
 
 
  
SELECT * FROM dim_product;  




-- type 1
SELECT 
    product_name,
    category,
    brand,
    unit_price,
    AVG(unit_price) OVER(  ORDER BY launch_date  ROWS BETWEEN UNBOUNDED PRECEDING AND 3 FOLLOWING ) AS Moving_Avg
FROM dim_product;


-- type 2
SELECT 
    product_name,
    category,
    brand,
    unit_price,
    AVG(unit_price) OVER(  ORDER BY launch_date  ROWS BETWEEN 2 PRECEDING AND UNBOUNDED FOLLOWING ) AS Moving_Avg
FROM dim_product;


-- type 3
SELECT 
    product_name,
    category,
    brand,
    unit_price,
    AVG(unit_price) OVER(  ORDER BY launch_date  ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING ) AS Moving_Avg
FROM dim_product;

   
 
 

 
-- Ranking -----------------------------------------------------   


CREATE TABLE employees (
    emp_id INT,
    employee_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees (emp_id, employee_name, department, salary)
VALUES
(1, 'Anil',   'IT',      90000),
(2, 'Ravi',   'IT',      90000),
(3, 'Kiran',  'IT',      75000),
(4, 'Meena',  'HR',      80000),
(5, 'Sneha',  'HR',      80000),
(6, 'Arjun',  'HR',      60000),
(7, 'David',  'Sales',   70000),
(8, 'Priya',  'Sales',   65000),
(9, 'John',   'Sales',   65000),
(10,'Asha',   'Sales',   50000);



DROP TABLE IF EXISTS employees_1;


/*
Ranking Window Functions in SQL:

Functions:

ROW_NUMBER()
RANK()
DENSE_RANK()

All are used with:
OVER(ORDER BY column_name)


*/

-- ROW_NUMBER()

/*

1. ROW_NUMBER()

Assigns:

Unique sequential number to every row.
Even duplicate values get different numbers.

Syntax:
ROW_NUMBER() OVER(ORDER BY column_name DESC)


*/

SELECT * FROM employees;

SELECT *,
ROW_NUMBER() OVER(ORDER BY salary DESC) AS 'Ranking_Row_Number'
FROM employees;


-- RANK()

/*
2. RANK()

Assigns:
Same rank to duplicate values.

BUT:
skips next rank numbers.

Syntax:
RANK() OVER(ORDER BY column_name DESC)


IF Two people occupied rank 1.
So next rank becomes:
1,1,3,4

This is called:
ranking with gaps

*/

SELECT * FROM employees;

SELECT *,
RANK() OVER(ORDER BY salary DESC) AS 'Row_Rank'
FROM employees;


-- DENSE_RANK()
/*

Assigns:
Same rank for duplicates

BUT:
does NOT skip ranks

*/
SELECT * FROM employees;

SELECT *,
DENSE_RANK() OVER(ORDER BY salary DESC) AS 'Dense_Rank'
FROM employees;


-- 1 
SELECT *,
ROW_NUMBER() OVER(ORDER BY salary DESC) AS 'Row_Number',
RANK() OVER(ORDER BY salary DESC) AS 'Row_Rank',
DENSE_RANK() OVER(ORDER BY salary DESC) AS 'Dense_Rank'
FROM employees;


-- Applying Partition

/*

For each department:

Employees are grouped using PARTITION BY department
Salaries are sorted descending
Rankings are assigned

*/

-- 2

SELECT *,
ROW_NUMBER() OVER(PARTITION BY department ORDER BY salary DESC) AS 'Row_Number',
RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS 'Row_Rank',
DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS 'Dense_Rank'
FROM employees;


-- REAL TIME scenarios

-- SCENARIO 1. FIND Nth Value [Most afordable/ most expensive from top to bottom]

-- SUBQUERY

SELECT 
       *,
       DENSE_RANK() OVER(ORDER BY unit_Price) AS ranking
FROM 
  dim_product;       


SELECT subquery.*
FROM
(
SELECT 
       *,
       DENSE_RANK() OVER(ORDER  BY unit_Price) AS ranking
FROM 
  dim_product
) subquery
WHERE 
  ranking =5;
  
  
SELECT subquery.*  -- subquery.* means: "Open the  'subquery' and give me every folder inside it."
FROM
(
SELECT 
       *,
       DENSE_RANK() OVER(PARTITION BY category  ORDER BY unit_Price DESC) AS ranking
FROM 
  dim_product
) subquery -- <-- This names the inner results "subquery"
WHERE 
  ranking =5;


-- SCENARIO 2. [Removing duplicates/ Deduplicating] 

SELECT * FROM employees;

INSERT INTO employees(emp_id,employee_name,department,salary)
VALUES
(10, "Asha","sales","50000");


-- SUBQUERY
SELECT *,
      ROW_NUMBER() OVER(PARTITION BY emp_id ORDER BY emp_id) AS Rownumber
FROM 
   employees;   
   
   
-- Deduplicate_Ranking is just an alias (column name) given to the result of ROW_NUMBER()
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

/*

Step 1: PARTITION BY emp_id

The rows are grouped by emp_id.
Since each emp_id appears only once:

emp_id	 Rows in Partition
--------------------------
1	     1 row
2	     1 row
3	     1 row


Step 2: ROW_NUMBER()

For each partition, numbering starts from 1.

Since every partition contains only one row:

emp_id	ROW_NUMBER()
----------------------
1	       1
2	       1
3	       1


Step 3: WHERE Deduplicate_Ranking = 1

Keeps only rows with rank 1.
Because every row has rank 1, all rows are returned.

*/



-- SCENARIO 3 [Lag and Lead] 
-- LAG() and LEAD() are SQL window functions used to access values from previous and next rows without using self-joins.
/*

LAG Syntax:

LAG(column_name, offset, default_value)
OVER (
    [PARTITION BY column_name]
    ORDER BY column_name
)



LEAD Syntax:

LEAD(column_name, offset, default_value)
OVER (
    [PARTITION BY column_name]
    ORDER BY column_name
)

*/

CREATE TABLE monthly_sales (
    month_id INT,
    month_name VARCHAR(10),
    sales_amount INT
);

INSERT INTO monthly_sales (month_id, month_name, sales_amount) VALUES
(1, 'Jan', 10000),
(2, 'Feb', 12000),
(3, 'Mar', 15000),
(4, 'Apr', 13000),
(5, 'May', 17000),
(6, 'Jun', 20000);


SELECT * FROM monthly_sales;



SELECT *,
LAG(sales_amount,1)  OVER(ORDER BY month_id) AS previous_sales,
LEAD(sales_amount,1) OVER(ORDER BY month_id) AS Next_sales
FROM monthly_sales;

SELECT *,
LAG(sales_amount,1)  OVER(ORDER BY month_id) AS previous_sales
FROM monthly_sales;

SELECT *,
LEAD(sales_amount,1) OVER(ORDER BY month_id) AS Next_sales
FROM monthly_sales;


SELECT *,
LAG(sales_amount,1,'Data Not Available')  OVER(ORDER BY month_id) AS previous_sales,
LEAD(sales_amount,1,'Data Not Available') OVER(ORDER BY month_id) AS Next_sales
FROM monthly_sales;

SELECT *,
LAG(sales_amount,2,'Data Not Available')  OVER(ORDER BY month_id) AS previous_sales,
LEAD(sales_amount,2,'Data Not Available') OVER(ORDER BY month_id) AS Next_sales
FROM monthly_sales;

SELECT *,
LAG(sales_amount,2,'Data Not Available')  OVER(ORDER BY month_id) AS previous_sales
FROM monthly_sales;

SELECT *,
LEAD(sales_amount,2,'Data Not Available') OVER(ORDER BY month_id) AS Next_sales
FROM monthly_sales;



-- Windows (range) Clause -----------------------------------------------------------------------------------------


CREATE TABLE monthly_sales (
    month_id INT,
    month_name VARCHAR(10),
    sales INT
);

INSERT INTO monthly_sales
VALUES
(1, 'Jan', 100),
(2, 'Feb', 200),
(3, 'Mar', 300),
(4, 'Apr', 400),
(5, 'May', 500);

SELECT * FROM monthly_sales;

DROP TABLE monthly_sales;



-- 1. Running Total
SELECT * FROM monthly_sales;

SELECT
     *,
    SUM(sales) OVER (ORDER BY month_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM monthly_sales;



-- 2. Remaining Total
SELECT * FROM monthly_sales;

SELECT
     *,
    SUM(sales) OVER (ORDER BY month_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS remaining_total
FROM monthly_sales;



-- 3. Grand Total
SELECT * FROM monthly_sales;

SELECT
     *,
    SUM(sales) OVER (ORDER BY month_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS grand_total
FROM monthly_sales;



-- 4. Rolling Sum of Last 2 Rows
SELECT * FROM monthly_sales;

SELECT
    *,
    SUM(sales) OVER (ORDER BY month_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_sum
FROM monthly_sales;



-- 5. Forward Looking Sum
SELECT * FROM monthly_sales;

SELECT
    *,
    SUM(sales) OVER (ORDER BY month_id ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS future_sum
FROM monthly_sales;



-- 6. Moving Average
SELECT * FROM monthly_sales;

SELECT
    *,
    AVG(sales) OVER (ORDER BY month_id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS moving_avg
FROM monthly_sales;



-- 7. Previous Row + Current Row
SELECT * FROM monthly_sales;

SELECT
    *,
    SUM(sales) OVER (ORDER BY month_id ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS prev_current_sum
FROM monthly_sales;



-- 8. Current Row + Next Row
SELECT * FROM monthly_sales;

SELECT
   *,
    SUM(sales) OVER (ORDER BY month_id ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS current_next_sum
FROM monthly_sales;


