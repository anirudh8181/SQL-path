-- 	Triggers

/*

A trigger is a piece of SQL code that MySQL automatically executes when a specific event happens on a table.

You don't manually call the trigger.

Basic flow
INSERT / UPDATE / DELETE
        ↓
    Trigger fires
        ↓
   Trigger SQL runs

For example:

Someone inserts a sale
        ↓
fact_sales gets a new row
        ↓
Trigger automatically executes
        ↓
Some additional action happens


1. Types of Trigger Events

MySQL supports three main events:

INSERT
UPDATE
DELETE

And you can execute the trigger either:
BEFORE
AFTER

So you commonly get:

Trigger	         Meaning
BEFORE INSERT	Run before a row is inserted
AFTER INSERT	Run after a row is inserted
BEFORE UPDATE	Run before a row is updated
AFTER UPDATE	Run after a row is updated
BEFORE DELETE	Run before a row is deleted
AFTER DELETE	Run after a row is deleted




Trigger Syntax:

The general structure is:

CREATE TRIGGER trigger_name
BEFORE | AFTER INSERT | UPDATE | DELETE
ON table_name
FOR EACH ROW
BEGIN
    -- SQL statements
END;

------------------------------
we don't call it manually.

It automatically runs when its event occurs.

Stored Procedure:

Application
    ↓
CALL procedure
    ↓
Procedure executes


Trigger:

Application
    ↓
INSERT/UPDATE/DELETE
    ↓
Trigger automatically executes

*/


CREATE DATABASE SalesDB;
USE SalesDB;

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    total_amount DECIMAL(10,2)
);


INSERT INTO sales VALUES
(1, 'Laptop', 2, 50000, 5000, 95000),
(2, 'Mouse', 3, 1000, 100, 2900),
(3, 'Keyboard', 2, 2000, 200, 3800);


-- when someone inserts a new sale
INSERT INTO sales
VALUES (4, 'Monitor', 2, 15000, 1000, 0);


/*

total+amount = quantity × unit_price - discount
= 2 × 15000 - 1000
= 29000

*/

-- Create a BEFORE INSERT trigger

DELIMITER //

CREATE TRIGGER calculate_total -- creating a trigger
BEFORE INSERT ON sales         
FOR EACH ROW
BEGIN
    SET NEW.total_amount =
        (NEW.quantity * NEW.unit_price) - NEW.discount;
END //

DELIMITER ;


SHOW triggers;


/*
understand this line by line.

CREATE TRIGGER calculate_total

We are creating a trigger called:

calculate_total

Think of it as giving a name to our automatic SQL logic.

BEFORE INSERT
BEFORE INSERT ON sales

This means:

"Before a new row is inserted into the sales table, execute this trigger."

So when we do:

INSERT INTO sales VALUES (...);

MySQL automatically executes the trigger before inserting the row.


FOR EACH ROW

This means the trigger works for every row being inserted.

For example:

INSERT INTO sales VALUES
(4, 'Monitor', 2, 15000, 1000, 0),
(5, 'Phone', 1, 30000, 2000, 0);

The trigger runs once for the Monitor and once for the Phone.

4. What is NEW?

This is one of the most important concepts.

When inserting a row, NEW represents the new row that is about to be inserted.

Suppose we execute:

INSERT INTO sales
VALUES (4, 'Monitor', 2, 15000, 1000, 0);

MySQL sees the new row approximately like:

NEW.sale_id       → 4
NEW.product_name  → Monitor
NEW.quantity      → 2
NEW.unit_price    → 15000
NEW.discount      → 1000
NEW.total_amount  → 0

Therefore:

SET NEW.total_amount =
    (NEW.quantity * NEW.unit_price) - NEW.discount;

becomes:

NEW.total_amount = (2 × 15000) - 1000

NEW.total_amount = 29000

So MySQL actually inserts:

sale_id	product_name	quantity	unit_price	discount	total_amount
4	    Monitor	           2	      15000	      1000	    29000

Even though we originally supplied 0.


*/

-- we want to modify the row before it is stored.

-- trigger test
INSERT INTO sales
VALUES (4, 'Monitor', 2, 15000, 1000, 0);


SELECT * FROM sales;


-- example for update

-- dont't run
UPDATE sales
SET unit_price = 18000
WHERE sale_id = 4;


-- when unit price of product changes 
DELIMITER //

CREATE TRIGGER update_total
BEFORE UPDATE ON sales
FOR EACH ROW
BEGIN
    SET NEW.total_amount =
        (NEW.quantity * NEW.unit_price) - NEW.discount;
END //

DELIMITER ;


UPDATE sales
SET unit_price = 18000
WHERE sale_id = 4;

SELECT 
    *
FROM
    sales;


/*

OLD vs NEW

This is extremely important for interviews/exams.

For an INSERT:

NEW → new row
OLD → doesn't exist

For an UPDATE:

OLD → values before update
NEW → values after update

For a DELETE:

OLD → row being deleted
NEW → doesn't exist

For example, if:

OLD.unit_price = 15000
NEW.unit_price = 18000

the trigger can compare the old and new values.



*/

-- Example of an UPDATE trigger using OLD and NEW

-- prevent a price from being reduced below the old price

DELIMITER //

CREATE TRIGGER check_price
BEFORE UPDATE ON sales
FOR EACH ROW
BEGIN
    IF NEW.unit_price < OLD.unit_price THEN
        SET NEW.unit_price = OLD.unit_price;
    END IF;
END //

DELIMITER ;

-- trigger
UPDATE sales
SET unit_price = 15000
WHERE sale_id = 4;


-- AFTER Triggers

CREATE TABLE sales_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT,
    action VARCHAR(20),
    action_time DATETIME
);

-- create trigger
DELIMITER //

CREATE TRIGGER after_sale_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    INSERT INTO sales_audit(sale_id, action, action_time)
    VALUES (NEW.sale_id, 'INSERT', NOW());
END //

DELIMITER ;

-- check triggers
SHOW triggers;

INSERT INTO sales VALUES (5, 'Tablet', 2, 20000, 1000, 0);

TRUNCATE TABLE sales_audit;



-- AFTER UPDATE — Record price changes

CREATE TABLE price_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_at DATETIME
);

-- create trigger
DELIMITER //

CREATE TRIGGER after_price_update
AFTER UPDATE ON sales
FOR EACH ROW
BEGIN
    IF OLD.unit_price <> NEW.unit_price THEN   -- <> not equal to
        INSERT INTO price_audit(sale_id, old_price, new_price, changed_at)
        VALUES (NEW.sale_id, OLD.unit_price, NEW.unit_price, NOW());
    END IF;
END //

DELIMITER ;


UPDATE sales
SET unit_price = 20000
WHERE sale_id = 4;


-- AFTER DELETE — Keep a record of deleted rows

CREATE TABLE deleted_sales (
    sale_id INT,
    product_name VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10,2),
    deleted_at DATETIME
);

-- create trigger
DELIMITER //

CREATE TRIGGER after_sale_delete
AFTER DELETE ON sales
FOR EACH ROW
BEGIN
    INSERT INTO deleted_sales
        (sale_id, product_name, quantity, unit_price, deleted_at)
    VALUES
        (OLD.sale_id, OLD.product_name, OLD.quantity, OLD.unit_price, NOW());
END //

DELIMITER ;

DELETE FROM sales
WHERE sale_id = 4;

/*

BEFORE INSERT  → validate/modify NEW
AFTER INSERT   → audit/log NEW

BEFORE UPDATE  → validate/modify OLD + NEW
AFTER UPDATE   → audit/log OLD + NEW

BEFORE DELETE  → validate OLD
AFTER DELETE   → archive/log OLD


*/

