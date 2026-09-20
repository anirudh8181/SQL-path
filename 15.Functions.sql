-- Functions

CREATE DATABASE functions;

USE functions;

CREATE TABLE customers (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    city VARCHAR(50),
    total_spent DECIMAL(10,2),
    created_at DATE
);


INSERT INTO customers
(customer_id, first_name, last_name, city, total_spent, created_at)
VALUES
(1, 'Anirudh', 'Gopi', 'Hyderabad', 120000.00, '2026-01-15'),
(2, 'Rahul', 'Sharma', 'Bangalore', 75000.00, '2026-02-10'),
(3, 'Priya', 'Reddy', 'Chennai', 45000.00, '2026-03-05'),
(4, 'Arjun', 'Kumar', 'Mumbai', 15000.00, '2026-04-20'),
(5, 'Sneha', 'Rao', 'Delhi', 95000.00, '2026-05-12');



/*


A function is a reusable piece of SQL logic that:

Accepts input values
Performs some operation
Returns exactly one value


Input → Function → Output

MySQL Functions
│
├── Built-in Functions
│   ├── String Functions
│   ├── Numeric Functions
│   ├── Date & Time Functions
│   ├── Aggregate Functions
│   └── Other Functions
│
└── User-Defined Functions
    └── Stored Functions

*/

SELECT UPPER('ani'); -- upper is a mysql function


/*
The basic syntax is:

CREATE FUNCTION function_name(parameter1 datatype)
RETURNS datatype
[characteristics] (declaration to MySQL about the function's behavior)
BEGIN

    -- logic

    RETURN value;

END;

*/

SELECT UPPER('hello'); -- DETERMINISTIC

SELECT RAND();  -- NON DETERMINSTIC


DELIMITER //

CREATE FUNCTION add_numbers(
    a INT,
    b INT
)
RETURNS INT
DETERMINISTIC -- For the same input values, the function will always return the same output.
BEGIN
    RETURN a + b;
END //

DELIMITER ;

SELECT add_numbers(10, 20) AS Sum; -- FUNCTION CALL


DELIMITER //

CREATE FUNCTION get_grade(
    marks INT
)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN

    RETURN CASE
        WHEN marks >= 90 THEN 'A'
        WHEN marks >= 75 THEN 'B'
        WHEN marks >= 60 THEN 'C'
        ELSE 'F'
    END;

END //

DELIMITER ;

SELECT get_grade('91') AS grade;

/*

Stored Function Characteristics
│
├── DETERMINISTIC
├── NOT DETERMINISTIC
│
├── CONTAINS SQL
├── NO SQL
├── READS SQL DATA
├── MODIFIES SQL DATA
│
└── SQL SECURITY
    ├── DEFINER
    └── INVOKER

*/

DELIMITER //

CREATE FUNCTION full_name(
    first_name VARCHAR(50),
    last_name VARCHAR(50)
)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN

    RETURN CONCAT(first_name, ' ', last_name);

END //

DELIMITER ;


SELECT
    customer_id,
    full_name(first_name, last_name) AS customer_name, -- function_call
    city
FROM customers;



-- Function using CASE

DELIMITER //

CREATE FUNCTION customer_category_case(
    amount DECIMAL(10,2)
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN

    RETURN CASE
        WHEN amount >= 100000 THEN 'VIP'
        WHEN amount >= 50000 THEN 'PREMIUM'
        ELSE 'REGULAR'
    END;

END //

DELIMITER ;


SELECT
    first_name,
    total_spent,
    customer_category_case(total_spent) AS category
FROM customers;


-- Function with multiple parameters

DELIMITER //

CREATE FUNCTION final_price(
    price DECIMAL(10,2),
    discount_percent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

    RETURN price - (price * discount_percent / 100);

END //

DELIMITER ;

SELECT final_price(1000, 10);   -- function call



-- involving dates

DELIMITER //

CREATE FUNCTION days_since_customer(
    created_date DATE
)
RETURNS INT
NOT DETERMINISTIC
BEGIN

    RETURN DATEDIFF(CURDATE(), created_date);

END //

DELIMITER ;



-- delete a function
DROP FUNCTION add_numbers;

-- check existing functions
SHOW FUNCTION STATUS;

-- get the definition:
SHOW CREATE FUNCTION add_numbers;


-- characterstics
-- READS SQL DATA

/*

CREATE FUNCTION get_customer_city(
    p_customer_id INT
)
RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
    -- read customer table
    ...
END;



*/


DELIMITER //

CREATE FUNCTION get_customer_spending(
    p_customer_id INT
)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN

    DECLARE v_total_spent DECIMAL(10,2);

    SELECT total_spent
    INTO v_total_spent
    FROM customers
    WHERE customer_id = p_customer_id;

    RETURN v_total_spent;

END //

DELIMITER ;



SELECT get_customer_spending(1);




-- MODIFIES SQL DATA, with UPDATE

DELIMITER //

CREATE PROCEDURE add_spending(
    IN p_customer_id INT,
    IN p_amount DECIMAL(10,2)
)
MODIFIES SQL DATA
BEGIN

    UPDATE customers
    SET total_spent = total_spent + p_amount
    WHERE customer_id = p_customer_id;

END //

DELIMITER ;



CALL add_spending(2, 5000);


-- MODIFIES SQL DATA , with INSERT

DELIMITER //

CREATE PROCEDURE add_customer(
    IN p_customer_id INT,
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_city VARCHAR(50),
    IN p_total_spent DECIMAL(10,2),
    IN p_created_at DATE
)
MODIFIES SQL DATA
BEGIN

    INSERT INTO customers
    (
        customer_id,
        first_name,
        last_name,
        city,
        total_spent,
        created_at
    )
    VALUES
    (
        p_customer_id,
        p_first_name,
        p_last_name,
        p_city,
        p_total_spent,
        p_created_at
    );

END //

DELIMITER ;


CALL add_customer(
    6,
    'Karthik',
    'Reddy',
    'Chennai',
    30000,
    '2026-06-01'
); 







