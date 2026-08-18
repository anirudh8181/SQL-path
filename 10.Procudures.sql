-- STORED PROCEDURE

/*
A Stored Procedure is a named block of SQL statements stored inside the database.

Instead of writing the same query again and again, you save it once and execute it whenever needed.

-------------------------------------------------------------------------

Stored Procedure Syntax:

DELIMITER //

CREATE PROCEDURE procedure_name()
BEGIN
    -- SQL statements
END //

DELIMITER ;



CREATE PROCEDURE procedure_name()
-- Creates a procedure.
-- procedure_name is the name of the procedure.



BEGIN
Marks the start of the procedure body.


END
Marks the end of the procedure body


DELIMITER //
Changes the statement terminator from ; to //.

DELIMITER ;
Changes it back to normal.


--------------------------------------------------------------------------
Without Procedure?

Every time:

SELECT * 
FROM employees
WHERE department = 'IT';

You must type the query again.


With Procedure:

CREATE PROCEDURE GetITEmployees()
BEGIN
  OUR OWN QUERY LOGIC
END

CALL GetITEmployees();


*/
-- - --------------------------------------------------------------------------------------
/*
DELIMETER:
A delimiter is a character or sequence of characters that tells MySQL where a SQL statement ends.


-- example:
SELECT * FROM employees;

MySQL sees ; and knows the statement is complete.



Why Do We Change the Delimiter?

When creating a stored procedure, we write multiple SQL statements inside it, and each statement ends with ;.




Example:

CREATE PROCEDURE GetEmployees()
BEGIN
    SELECT * FROM employees;
END;


Problem:
MySQL sees the first ; after:

SELECT * FROM employees;
and thinks the CREATE PROCEDURE statement has ended there.

This causes an error.

So the Solution is : Change the Delimiter Temporarily
DELIMITER //

Now MySQL will use // instead of ; to mark the end of a statement.



DELIMITER //

CREATE PROCEDURE GetEmployees()
BEGIN
    logic code
END //

DELIMITER ;


MySQL waits until it sees:
//

Then it understands the whole procedure definition is complete.


change back to normal:
DELIMITER ;

Now MySQL again treats ; as the statement terminator.

*/


-- example 1 (without paramters)

DELIMITER //

CREATE PROCEDURE Avg_info()
BEGIN
SELECT category,
    AVG(unit_price) AS Avg_unit_price
FROM
    dim_product
GROUP BY category;
END //


DELIMITER ;

CALL Avg_info();

DROP PROCEDURE  Avg_info;


-- sample 1	

DELIMITER //

CREATE PROCEDURE CheckProductPrice(
    IN input_product_key INT
)
BEGIN
    DECLARE price DECIMAL(10,2);

    SELECT unit_price
    INTO price
    FROM dim_product
    WHERE product_key = input_product_key;

    IF price >= 5000 THEN
        SELECT 'Expensive Product' AS price_category;
    ELSEIF price >= 2000 THEN
        SELECT 'Medium Price Product' AS price_category;
    ELSE
        SELECT 'Affordable Product' AS price_category;
    END IF;
END //

DELIMITER ;

/*

IN Parameter in Stored Procedures

An IN parameter is used to pass a value into a stored procedure.

The procedure receives the value and uses it inside its SQL statements.

Syntax:

DELIMITER //

CREATE PROCEDURE procedure_name(
    IN parameter_name datatype
)
BEGIN
    -- SQL statements
END //

DELIMITER ;

The input value will come from the caller.

An IN parameter is used to pass a value from the caller into a stored procedure. 
The procedure can use the value, but changes made to the parameter inside the procedure are not returned 
to the caller.

----------------------------------------------------

Example:

DELIMITER //

CREATE PROCEDURE Test(IN num INT)
BEGIN
    SET num = num + 10;
    SELECT num;
END //

DELIMITER ;

Call it:
CALL Test(5);

Inside the procedure:
num = 5
num = num + 10
num = 15

Output:
15

But after the procedure finishes:

SELECT @num;

There is no returned value because num was just a local copy.

Analogy!:
Think of IN as giving someone a photocopy of a document.

Original = 5
Copy = 5

They change the copy:

Copy = 15

But your original remains:

Original = 5

*/

-- example 2
DELIMITER //

CREATE PROCEDURE Insert_data(IN customer_id INT, IN name VARCHAR(100), IN city VARCHAR(100))
BEGIN
  INSERT INTO customers(customer_id, name ,city)
  VALUES
  (customer_id,name,city);
END //  
  

DELIMITER ;  


CALL Insert_data(6,'Albert','Pune');

-- Drop a procedure
DROP PROCEDURE  Insert_data;


/*

What is an OUT Parameter?

An OUT parameter is used when a stored procedure needs to send a value back to the caller.

Think of it like a function's return value.

Syntax:
DELIMITER //

CREATE PROCEDURE procedure_name(
    OUT parameter_name datatype
)
BEGIN
    -- assign value to parameter
END //

DELIMITER ;

*/

-- example 3

DELIMITER //

CREATE PROCEDURE Count_Employees(OUT Total_count INT)
BEGIN
	SELECT COUNT(*)
	INTO total_count
	FROM employees;
END //

DELIMITER ;


-- function call
CALL Count_Employees(@count);


-- check the value
SELECT @count;


/*

Procedure starts
      ↓
COUNT(*) = 3
      ↓
total = 3
      ↓
@count = 3

------------------------
employees table
      |
      | COUNT(*)
      ↓
     5
      |
      ↓
Total_count
   (OUT parameter)
      |
      ↓
    @count
   (session variable)
      |
      ↓
SELECT @count
      |
      ↓
      5

*/

DELIMITER //

CREATE PROCEDURE GetDouble(
    OUT result INT
)
BEGIN
    SET result = 10 * 2;
END //

DELIMITER ;


CALL GetDouble(@ans);

SELECT @ans;

DROP PROCEDURE GetDouble;


/*

An INOUT parameter acts as both:

IN → receives a value from the caller.
OUT → returns the modified value back to the caller.

An INOUT parameter is a parameter that can both receive a value from the caller and 
return a modified value back to the caller. It combines the functionality of IN and OUT parameters.


Syntax:

DELIMITER //

CREATE PROCEDURE procedure_name(
    INOUT parameter_name datatype
)
BEGIN
    -- modify parameter
END //

DELIMITER ;


*/

DELIMITER //

CREATE PROCEDURE IncreaseValue(
    INOUT num INT
)
BEGIN
    SET num = num + 100;
END //

DELIMITER ;


-- Initial value:
SET @value = 500;

-- function call
CALL IncreaseValue(@value);

SELECT @value;


/*

Caller
  |
  | @value = 500
  v
Procedure (INOUT num)
  |
  | num = num + 100
  v
num = 600
  |
  v
Caller
@value = 600

----------------------------------------------------------------------------

Compare IN, OUT, and INOUT:

IN:

CREATE PROCEDURE Demo(IN num INT)

Caller → Procedure
Receives value.
Changes are NOT returned.


OUT:

CREATE PROCEDURE Demo(OUT num INT)

Caller ← Procedure
No input value required.
Procedure sends value back.


INOUT:

CREATE PROCEDURE Demo(INOUT num INT)

Caller ↔ Procedure
Receives value.
Modifies value.
Returns updated value.




*/

-- switch to sample 'procedure' schema

CREATE DATABASE Sample_Procedure;

USE Sample_Procedure;



-- Get product information

DELIMITER //

CREATE PROCEDURE GetProduct(
    IN p_product_id INT
)
BEGIN

    SELECT
        product_id,
        product_name,
        category,
        price,
        stock
    FROM products
    WHERE product_id = p_product_id
      AND active = TRUE;

END //

DELIMITER ;

CALL GetProduct(1);


-- Update product price with validation

/*

IF marks >= 90 THEN
    SET grade = 'A';

ELSEIF marks >= 75 THEN
    SET grade = 'B';

ELSEIF marks >= 50 THEN
    SET grade = 'C';

ELSE
    SET grade = 'F';
END IF;


             Price <= 0?
             /        \
           YES         NO
           ↓            ↓
     Error message   Product exists?
                     /          \
                   NO            YES
                   ↓              ↓
             Error message      UPDATE

*/



DELIMITER //

CREATE PROCEDURE UpdateProductPrice(
    IN p_product_id INT,
    IN p_new_price DECIMAL(10,2),
    OUT p_message VARCHAR(100)
)
BEGIN

    IF p_new_price <= 0 THEN

        SET p_message = 'Price must be greater than zero';

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM products
        WHERE product_id = p_product_id
    ) THEN

        SET p_message = 'Product does not exist';

    ELSE

        UPDATE products
        SET price = p_new_price
        WHERE product_id = p_product_id;

        SET p_message = 'Product price updated successfully';

    END IF;

END //

DELIMITER ;


CALL UpdateProductPrice(
    1,
    70000,
    @message
);


-- Customer purchase summary
DELIMITER //

CREATE PROCEDURE GetCustomerPurchaseSummary(
    IN p_customer_id INT,
    OUT p_order_count INT,
    OUT p_total_spent DECIMAL(12,2)
)
BEGIN

    SELECT COUNT(*)
    INTO p_order_count
    FROM orders
    WHERE customer_id = p_customer_id;

    SELECT COALESCE(SUM(total_amount), 0)
    INTO p_total_spent
    FROM orders
    WHERE customer_id = p_customer_id
      AND status <> 'CANCELLED';

END //

DELIMITER ;


-- Cancel an order and restore stock

/*
Check order.
Check status.
Restore product stock.
Mark order cancelled.
Do everything inside one transaction.

*/
DELIMITER //

CREATE PROCEDURE CancelOrder(
    IN p_order_id INT
)
BEGIN

    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock the order
    SELECT status
    INTO v_status
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;

    IF v_status IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order does not exist';

    ELSEIF v_status IN ('CANCELLED', 'COMPLETED') THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Order cannot be cancelled';

    END IF;

    -- Restore stock
    UPDATE products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    SET p.stock = p.stock + oi.quantity
    WHERE oi.order_id = p_order_id;

    -- Cancel order
    UPDATE orders
    SET status = 'CANCELLED'
    WHERE order_id = p_order_id;

    COMMIT;

END //

DELIMITER ;
