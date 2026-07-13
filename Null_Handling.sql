# NULL means missing, unknown, or no value. It is not the same as 0, an empty string (''), or FALSE.

USE real_sales;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    bonus DECIMAL(10,2),
    email VARCHAR(100),
    mobile VARCHAR(15),
    home_phone VARCHAR(15),
    manager_id INT
);


INSERT INTO employees
(emp_id, emp_name, department, salary, bonus, email, mobile, home_phone, manager_id)
VALUES
(101, 'Anirudh', 'IT', 60000, 5000, 'anirudh@gmail.com', '9876543210', NULL, 201),
(102, 'Rahul', 'HR', NULL, NULL, NULL, '9876501234', '0442345678', 202),
(103, 'Priya', 'Finance', 75000, NULL, 'priya@gmail.com', NULL, '0448765432', NULL),
(104, 'Sneha', 'IT', 68000, 3000, NULL, NULL, NULL, 201),
(105, 'Karan', 'Sales', NULL, 2000, 'karan@gmail.com', '9988776655', NULL, NULL),
(106, 'Meena', 'Marketing', 52000, NULL, NULL, NULL, '0449988776', 203),
(107, 'John', 'IT', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 'David', 'Finance', 85000, 8000, 'david@gmail.com', '9123456789', '0445678901', 202),
(109, 'Dawis', 'Flamce', 5000, 9000, 'dawis@gmail.com', '91355456789', '91355456789', 203);





-- 1. IS NULL , Checks whether a column contains a NULL value.

SELECT *
FROM employees
WHERE salary IS NULL;

-- 2. IS NOT NULL , Returns rows where the value exists.
SELECT emp_name, email
FROM employees
WHERE email IS NOT NULL;

/*

Syntax:
1. ISNULL(expression, replacement_value) - SQL server

returns the replacement value if the expression is NULL.

MY SQL equivalent - IFNULL()

Syntax:
3. IFNULL(expression, replacement_value)


*/

SELECT
    *,
    IFNULL(salary,0) AS null_salary_check
FROM employees;




/*

4. COALESCE()

COALESCE() returns the first non-NULL value from a list of expressions.

Synatax:
COALESCE(value1, value2, value3, ..., default)

When you have multiple columns that may contain the required value.

Example:

Mobile
Home phone
Office phone
Emergency phone

Return whichever exists first.

*/

SELECT mobile,home_phone,
COALESCE(mobile, home_phone) AS First_not_null
FROM employees;


SELECT email,bonus, mobile, home_phone,
COALESCE(email,bonus, mobile, home_phone, 'Not available') AS replacement
FROM employees;


-- 5.NULLIF() - NULLIF() compares two expressions.
/*

If they are equal,
it returns NULL.

Otherwise,
it returns the first expression.

Syntax:
NULLIF(expression1, expression2)

*/

SELECT mobile,home_phone,
NULLIF(mobile, home_phone) AS Check_null
FROM employees;

/*

| Feature             |    IFNULL()                 |    COALESCE()                                          |
| ------------------- | -------------------------- | ---------------------------------------------------- |
| Number of arguments | Exactly 2                  |       2 or more                                      |
| Purpose             | Replace a NULL value       | Return the first non-NULL value                      |
| SQL Standard        | No (MySQL-specific)        |  Yes (ANSI SQL standard)                             |
| Portability         | Mainly MySQL (also SQLite) | Works in MySQL, PostgreSQL, SQL Server, Oracle, etc. |
| Typical use         | Simple NULL replacement    | Multiple fallback values                             |



*/

-- Check Null values before data aggregation

-- 1. 	
SELECT emp_id, emp_name, salary,
AVG(salary) OVER() AS Avg_Score
FROM employees;


-- 2. First the handle values
SELECT emp_id, emp_name, salary,
COALESCE(salary,0) 
FROM employees;

-- 3.
SELECT emp_id, emp_name, salary,
AVG(salary) OVER() AS Avg_Score,
AVG(COALESCE(salary,0))  OVER() Avg_score2
FROM employees;


/*

" Can IFNULL() replace COALESCE()?"


Yes, but only when there are two arguments. For example, IFNULL(salary, 0) and COALESCE(salary, 0) are equivalent in MySQL. 
However, COALESCE() is more flexible because it can accept multiple arguments and return the first non-NULL value. 
It's also part of the SQL standard, making it more portable across different database systems.

*/






