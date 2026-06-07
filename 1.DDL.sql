#DDL COMMANDS

/*

DDL (Data Definition Language) commands are used to define and manage the structure of a database

1. CREATE
Used to create database objects like tables, databases, views, etc.

2. ALTER
Used to modify an existing database object (add, delete, modify columns).

3. DROP
Used to delete database objects permanently.

4. TRUNCATE
Used to remove all records from a table (faster than DELETE, cannot be rolled back in most cases).

5. RENAME
Used to rename database objects.

--DDL changes structure, not data
--Auto-commit (cannot rollback in most DBs)
--Affects schema (tables, database)

*/

-- Create Database
CREATE DATABASE sales;


-- Use the Database
USE sales;



/*
Data types in SQL (especially MySQL / relational databases) 

---

1. Numeric Data Types

 INT – Stores whole numbers (e.g., 10, -5). Most commonly used integer type.

 TINYINT – Very small integers (-128 to 127). Useful for flags like 0/1.

 SMALLINT – Small range integers, larger than TINYINT but smaller than INT.

 MEDIUMINT – Medium-sized integers, rarely used but saves space.

 BIGINT – Very large integers (used for IDs like user_id in big systems).

 DECIMAL(p, s) – Stores exact fixed-point numbers (e.g., money values like 10.25).

 FLOAT – Stores approximate decimal numbers, less precise.

 DOUBLE – Higher precision than FLOAT but still approximate.
 
 
 
---

2. String (Character) Data Types

 CHAR(n) – Fixed-length string (always uses full length). Faster for fixed-size data.

 VARCHAR(n) – Variable-length string (uses only required space). Most commonly used.

 TEXT – Stores large text data (like descriptions).

 TINYTEXT / MEDIUMTEXT / LONGTEXT – Variants of TEXT with increasing storage capacity.

---

3. Date and Time Data Types

 DATE – Stores date in format YYYY-MM-DD.
 TIME – Stores time in HH:MM:SS format.
 DATETIME – Stores both date and time.
 TIMESTAMP – Similar to DATETIME but auto-updates and timezone-aware.
 YEAR – Stores only year values.

---

4. Boolean Data Type

 BOOLEAN / BOOL – Stores true or false (internally stored as TINYINT: 1 or 0).

---

5. Binary Data Types

 BINARY(n) – Fixed-length binary data.

 VARBINARY(n) – Variable-length binary data.

 BLOB – Stores large binary data (e.g., images, files).

 TINYBLOB / MEDIUMBLOB / LONGBLOB – Variants with different sizes.

---
 6. Enum and Set Types

 ENUM – Stores one value from a predefined list (e.g., 'active', 'inactive').
 SET – Stores multiple values from a predefined list.

---

7. JSON Data Type

 JSON – Stores structured JSON data, useful for semi-structured data.

---

8. Spatial Data Types (Advanced)

 GEOMETRY – Stores geometric data (points, shapes).
 POINT, LINESTRING, POLYGON – Specific spatial types used in GIS applications.

---

Simple Summary:

 Use INT / BIGINT for numbers
 Use VARCHAR for most text
 Use DECIMAL for money
 Use DATETIME / TIMESTAMP for date-time
 Use TEXT / BLOB for large data
 Use JSON for flexible structured data

---

SCHEMA:

A schema tells:

what tables exist
what columns each table has
what data types those columns use
how tables are related (keys, constraints)

So, it is basically the design of the database, not the actual data.

Example:
Suppose you have a database for an e-commerce app.

Schema defines:

Table: users → columns: id (INT), name (VARCHAR), email (VARCHAR)
Table: orders → columns: order_id, user_id, amount
Relationship: user_id in orders links to users table

This structure is the schema.

Key Points
Schema = structure/design
Data = actual values stored inside tables
One database can have multiple schemas
Helps organize large systems (like grouping tables logically)





*/


-- create Table

/*
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    column3 datatype constraints
);

*/

CREATE TABLE stores
(
  store_id INT,
  store_name VARCHAR(100),
  store_location VARCHAR(100)

);


DROP TABLE stores;


-- INSERT DATA INTO STORES

INSERT INTO stores (store_id, store_name,store_location)
VALUES
(1, 'Tech Hub', 'Chennai'),
(2, 'Fresh Mart', 'Bangalore'),
(3, 'Daily Needs', 'Hyderabad'),
(4, 'Super Bazaar', 'Mumbai'),
(5, 'Urban Store', 'Delhi'),
(6, 'Smart Retail', 'Pune'),
(7, 'City Mart', 'Kolkata'),
(8, 'Green Grocers', 'Coimbatore'),
(9, 'Value Store', 'Ahmedabad'),
(10, 'Mega Mart', 'Jaipur');





INSERT INTO stores (store_id)
VALUES (11);


-- SELECT ALL COLUMNS FROM THE TABLE
SELECT *FROM stores; 


-- DIFFERENCE BETWEEN DROP VS TRUNCATE

/*

DROP (Deletes the entire table)

What it does: Completely removes the table from the database

Deletes:
Data 
Structure (schema) 
After execution: Table no longer exists
Rollback: Cannot be rolled back (in most DBs)

*/

-- DROP TABLE
DROP TABLE stores;

/*
TRUNCATE (Deletes all rows, keeps table)

What it does: Removes all rows from the table
Structure  (table remains)

Deletes:
Data 
After execution: Table is empty but still exists
Rollback:  Usually not possible
Faster than DELETE because it doesn't log row-by-row deletion


*/

-- TRUNCATE TABLE
TRUNCATE TABLE Stores;




-- LET'S CREATE TABLE WITH CONSTRAINTS

CREATE TABLE New_Stores
(
    store_id INT UNIQUE,
    store_name VARCHAR(100) NOT NULL,
    store_location VARCHAR(100) NOT NULL

);

DROP TABLE New_Stores;

INSERT INTO New_stores (store_id, store_name,store_location)
VALUES
(1, 'Tech Hub', 'Chennai'),
(2, 'Fresh Mart', 'Bangalore'),
(3, 'Daily Needs', 'Hyderabad'),
(4, 'Super Bazaar', 'Mumbai'),
(5, 'Urban Store', 'Delhi'),
(6, 'Smart Retail', 'Pune'),
(7, 'City Mart', 'Kolkata'),
(8, 'Green Grocers', 'Coimbatore'),
(9, 'Value Store', 'Ahmedabad'),
(10, 'Mega Mart', 'Jaipur');



INSERT INTO New_stores (store_id, store_name,store_location)
VALUES
(10, 'Mega Mart', 'Jaipur');

INSERT INTO New_stores (store_id)
VALUES (11);

INSERT INTO New_Stores(store_id, store_name, store_location)
VALUES
(11,'Reliance Mart','Chittoor');

SELECT *FROM New_Stores;


-- CONSTRAINTS

-- 1. NOT NULL

 /*

Ensures that a column cannot have NULL (empty) values.
 Both id and name must have values.

 */

CREATE TABLE users (
    id INT NOT NULL,
    name VARCHAR(50) NOT NULL
);





-- 2. UNIQUE

/*

Ensures that all values in a column are different (no duplicates).
No two users can have the same email.

*/

CREATE TABLE users (
    email VARCHAR(100) UNIQUE
);



-- 3. PRIMARY KEY

/*

A combination of NOT NULL + UNIQUE. It uniquely identifies each row in a table.
Each id must be unique and not null.
    A table can have only one primary key
    It can be single-column or composite.

*/

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

-- Composite PRIMARY KEY (multi-column)

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id)
);



-- 4. FOREIGN KEY

/*

Maintains a relationship between two tables. It ensures that a value in one table exists in another table.
user_id must match an existing id in the users table.

*/


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);



-- 5. CHECK

/*

Ensures that values in a column satisfy a specific condition.
Only values ≥ 18 are allowed.
(Note: Fully enforced in MySQL 8.0+)

*/


CREATE TABLE employees (
    age INT CHECK (age >= 18)
);



-- 6. DEFAULT

/*

Sets a default value for a column if no value is provided.
If no status is given, it becomes 'active'.

*/

CREATE TABLE users (
    status VARCHAR(20) DEFAULT 'active'
);
 


-- 7. AUTO_INCREMENT

/*

Automatically generates a unique number for new rows (usually for primary keys).
Each new row gets an incremented id.

*/


CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY
);

INSERT INTO users (id)
VALUES
(1236);

DROP TABLE users;

INSERT INTO users
VALUES
(),
();






/*

Why Constraints are Important
Prevent invalid data entry
Maintain data consistency
Enforce business rules
Improve database reliability

*/


-- ALTER TABLE

CREATE TABLE employee
(
    employee_id INT, 
    employee_name VARCHAR(100)
);

DROP TABLE employee;

-- add column
ALTER TABLE employee
ADD COLUMN age INT;

-- rename column
ALTER TABLE employee
RENAME COLUMN Salary TO Monthly_Salary;


-- Modify Column Data Type
ALTER TABLE employee
MODIFY employee_name VARCHAR(200);

-- Drop a Column
ALTER TABLE employee
DROP COLUMN age;

-- Add Constraint (PRIMARY KEY)
ALTER TABLE employee
ADD CONSTRAINT pk_employee PRIMARY KEY (employee_id);


--  Add NOT NULL Constraint
ALTER TABLE employee
MODIFY employee_name VARCHAR(100) NOT NULL;


-- Add DEFAULT Value
ALTER TABLE employee
MODIFY Monthly_Salary BIGINT DEFAULT 25000;

INSERT INTO employee(employee_id,employee_name)
VALUES
(112,'YAMINI');



-- Add UNIQUE Constraint
ALTER TABLE employee
ADD CONSTRAINT unique_name UNIQUE (employee_name);


-- Drop Constraint
ALTER TABLE employee
DROP CONSTRAINT unique_name;

-- Add table
ALTER TABLE employee
ADD department_id INT;


ALTER TABLE employee
ADD CONSTRAINT fk_dept
FOREIGN KEY (department_id)
REFERENCES department(department_id);

-- Constraint name = identifier for a rule in your database

-- creating refernce table

CREATE TABLE department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);




DROP TABLE employee;





--------- Keys in SQL--------------------------------------------



-- 1. Primary Key

/*

Uniquely identifies each row in a table
Cannot contain NULL values
A table can have only one primary key (can be single or composite)

*/


CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);




-- 2. Foreign Key

/*

A foreign key is a column in one table that refers to the primary key in 
another table.

departments.dept_id → Parent (Primary Key)
employees.dept_id → Child (Foreign Key)

*/

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)

);


/*

Key Points:

A table can have multiple foreign keys
Foreign key can allow NULL (unless restricted)
Helps link related tables

Why Foreign Key is Used?

Maintains referential integrity
Ensures that values in the child table exist in the parent table
Prevents invalid data

*/

-- Example:

INSERT INTO departments VALUES (1, 'HR'), (2, 'IT');

INSERT INTO employees VALUES
(101, 'Anirudh', 1),
(102, 'Rahul', 2);

INSERT INTO employees VALUES (103, 'Kiran', 5);





-- 3. Candidate Key

/*

All possible columns that can qualify as a primary key
Must be unique and not NULL
One is chosen as the primary key

Example:
In a table, both email and id can be candidate keys

*/




-- 4. Alternate Key

/*

Candidate keys that are not selected as the primary key

Example:
If id is primary key, email becomes an alternate key

*/




-- 5. Composite Key

-- A primary key made up of multiple columns


/*
Almost exactly right! But there is one very important distinction to make:

They are not two separate primary keys. Instead, they work together as ONE single primary key 
that is made up of two columns. In database terms, this is called a Composite Primary Key.

A database table can only ever have one primary key. When you write PRIMARY KEY (student_id, course_id), 
you are telling the database: "I want my one primary key to be the combination of these two columns."

*/

CREATE TABLE enrollment (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO enrollment (student_id, course_id) VALUES
(101, 1),  -- Student 101 enrolled in Course 1
(101, 2),  -- Student 101 enrolled in Course 2 (Valid: same student, different course)
(101, 3),  -- Student 101 enrolled in Course 3
(102, 1),  -- Student 102 enrolled in Course 1 (Valid: different student, same course)
(102, 4),  -- Student 102 enrolled in Course 4
(103, 2),  -- Student 103 enrolled in Course 2
(104, 5);  -- Student 104 enrolled in Course 5


-- 6. Unique Key

/*

Ensures all values in a column are unique
Can contain one NULL value (in most databases like MySQL)
Multiple unique keys allowed in a table


*/

CREATE TABLE users (
    id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE
);



DROP TABLE stores;



-- 7. Super Key

/*

Any set of columns that uniquely identifies a row
Includes candidate keys and combinations of columns

*/

--  Example
CREATE TABLE STUDENT (
    RollNo INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15) UNIQUE
);


INSERT INTO STUDENT (RollNo, Name, Email, Phone) VALUES
(101, 'Anil', 'anil@gmail.com', '9876543210'),
(102, 'Ravi', 'ravi@gmail.com', '9123456780'),
(103, 'Sneha', 'sneha@gmail.com', '9988776655');

SELECT * FROM STUDENT;

/*

For this table, these are super keys:

{RollNo} 
{Email} 
{Phone} 
{RollNo, Name} 
{RollNo, Email} 
{Email, Phone} 
{RollNo, Name, Email, Phone} 


*/


-- 8. Natural Key

/*

A key derived from real-world data

Has meaning in the real world
Is already available in the data
Uniquely identifies a record without needing artificial value



*/
 


-- 9. Surrogate Key

/*

A surrogate key is a column (or field) created artificially by the database to 
uniquely identify each row in a table. 
It has no real-world meaning and is usually generated automatically.

Is system-generated
Has no business meaning
Is used only for unique identification
Is typically an integer (often auto-incremented)


Characteristics:

-- Unique for each row
-- Stable (does not change)
-- Simple (usually numeric)
-- No dependency on business logic


Why Use Surrogate Keys?

-- Real-world data (like email or phone) can change
-- Avoids issues with duplicate or messy data
-- Improves performance (numeric keys are faster than strings)
-- Simplifies relationships between tables

Key idea
You declare the rule (AUTO_INCREMENT)
The database engine executes it (generates values internally)

When to Use?

Use a surrogate key when:

-- Natural key is large (like long strings)
-- Natural key may change
-- No reliable natural key exists
-- Real-world Practice

In most real databases:

Surrogate key → used as primary key
Natural key → used with UNIQUE constraint


*/


CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100)
);


INSERT INTO users (name, email) VALUES ('Anirudh', 'ani@gmail.com');
INSERT INTO users (name, email) VALUES ('Rahul', 'rahul@gmail.com');
INSERT INTO users (user_id,name, email) VALUES (102,'Anirudh', 'ani@gmail.com');
INSERT INTO users (name, email) VALUES ('Rahul', 'rahul@gmail.com');



CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,  -- Surrogate key
    email VARCHAR(100) UNIQUE, -- Natural Key
    name VARCHAR(50)
);

DROP TABLE users;









