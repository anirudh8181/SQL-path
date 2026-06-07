-- DML COMMANDS

/*

DML commands operate on data, not schema
They can be rolled back (except TRUNCATE in many cases)
Often used with transactions (COMMIT, ROLLBACK)

*/
 
 -- use sales
 
DROP TABLE IF EXISTS employees;


CREATE TABLE employees
( 
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100),
salary BIGINT
);

-- 1. INSERT — Add data into a table

INSERT INTO employees (emp_id, emp_name,salary)
VALUES
(101,"Ani",100000),
(102,"steve", 30000),
(103, 'Rahul', 40000),
(104, 'Sneha', 45000);


-- 2. SELECT — Retrieve data from a table

SELECT emp_name, salary
FROM employees
WHERE salary > 40000;


-- 3.UPDATE  - Modify existing data
UPDATE employees
SET salary = 90000;

-- Without WHERE, all rows will be updated

UPDATE employees
SET salary = 90000
WHERE emp_id=103;

SELECT * FROM  employees;




-- 4. DELETE — Remove data from a table
DELETE FROM employees
WHERE emp_id = 102;

-- Without WHERE, all rows are deleted


DELETE FROM employees;  -- deletes all rows
