-- TRANSFORMATIONS

-- Numeric Transformations

SELECT * FROM dim_product;
SELECT 
    unit_price * 0.90 AS discounted_price,
    unit_price + 10 AS taxed_price,
    unit_price / 10 AS fractioned_price
FROM
    dim_product;
    
SELECT * FROM dim_product;    
SELECT 
    unit_price * 0.90 AS discounted_prices,
    unit_price + 10 AS taxed_price,
    unit_price / 10 AS fractioned_price,
    ROUND(unit_price,1) AS rounded_price, -- used to round numeric values to a specified number of decimal places.
    unit_price * unit_price AS multiply_price
FROM
    dim_product;
    
    
-- DATE Transformations

SELECT * FROM dim_date; 

-- 1)
SELECT 
    date,
    NOW() AS 'current_timestamp'
FROM
    dim_date;
    
-- 2)    
SELECT 
    date, now() AS 'current_timestamp',
    utc_date(),
    utc_time(),
    utc_timestamp()
FROM
    dim_date;
    
-- 3)

SELECT * FROM dim_date; 

SELECT 
   date,
   YEAR(date),
   MONTH(date),
   DAY(date),
   DAYNAME(date)
FROM dim_date;   

-- 4)

SELECT 
   date,
   YEAR(date),
   MONTH(date),
   DAY(date),
   DAYNAME(date),
   WEEKDAY(date), -- is used to find which day of the week a date falls on (as a number).
   DATE(utc_timestamp())  -- Extracts only the date part from a DATETIME value
FROM dim_date; 


-- 5) ADDDATE(date, INTERVAL value unit), SUBDATE(date, INTERVAL value unit)

SELECT * FROM dim_date; 
SELECT 
   date,
   ADDDATE(date,2),
   SUBDATE(date,2)
FROM dim_date; 
   
SELECT ADDDATE('2026-05-03', 4);   


-- 6) DATEDIFF(date1, date2)    -- returns date1 - date2 (in days)
SELECT * FROM dim_date;

SELECT 
   date,
   DATEDIFF(DATE(UTC_TIMESTAMP()), date) AS total_days
FROM dim_date;


-- 7) CAST() converts a string → DATETIME value. CAST(string_expression AS DATETIME)
SELECT 
   date,
   CAST(date AS datetime) AS Casted_time
FROM dim_date;


-- 8) DATE_FORMAT(date, format) -- It formats a date or datetime into a custom string

/*
usecase:

Reports (human-readable dates)
Dashboards
Exporting data
UI display formatting

*/

SELECT DATE_FORMAT('2026-05-03', '%d-%m-%Y') AS date;

SELECT DATE_FORMAT('2026-05-03', '%d %M %Y')  AS date;

SELECT DATE_FORMAT('2026-05-03 14:30:00', '%h:%i %p') AS time;

SELECT DATE_FORMAT('2026-05-03 14:30:00', '%W %M %e %Y') AS converted_date;


SELECT date, DATE_FORMAT(date, '%d-%m-%Y') AS formatted_date
FROM dim_date;



/*

| Format | Meaning         | Example |
| ------ | --------------- | ------- |
| `%d`   | Day (01–31)     | 03      |
| `%m`   | Month (01–12)   | 05      |
| `%Y`   | Year (4 digits) | 2026    |
| `%y`   | Year (2 digits) | 26      |
| `%M`   | Full month name | May     |
| `%b`   | Short month     | May     |
| `%W`   | Day name        | Sunday  |
| `%H`   | Hour (00–23)    | 14      |
| `%h`   | Hour (01–12)    | 02      |
| `%i`   | Minutes         | 30      |
| `%p`   | AM/PM           | PM      |
| ------ | ------------------------------ | ------- |
| `%W`   | Full weekday name              | Sunday  |
| `%M`   | Full month name                | May     |
| `%e`   | Day of month (no leading zero) | 3       |
| `%Y`   | 4-digit year                   | 2026    |


*/



-- TYPE CASTING
SELECT * FROM dim_customer;

SELECT customer_key,
CAST(customer_key AS CHAR(100)) AS Casted_key
FROM dim_customer; 
 
 /*
column remains its original type (e.g., INT) in the table
Only the output of this query is treated as CHAR

*/
   
   
SELECT * FROM dim_customer;


-- STRING FUNCTIONS

-- CONCAT() - combine (join) multiple strings into one.

-- query 1
SELECT * FROM dim_customer;

SELECT CONCAT(first_name,last_name) AS Full_name
FROM
dim_customer;

-- query2
SELECT CONCAT(first_name,' ',last_name) AS Full_name
FROM
dim_customer;
   
   
   
 -- LENGTH() length query is used to find the number of characters in a string
 
SELECT * FROM dim_customer;
 
SELECT 
    LENGTH(country) AS country_size
FROM
    dim_customer;


-- * select all columns ,along with chosen columns
SELECT *,
    CONCAT(first_name, ' ', last_name) AS Full_name,
    LENGTH(country) AS country_size
FROM
    dim_customer;

    
-- LOWER -convert a string to lowercase.

 
SELECT * FROM dim_customer;

 SELECT 
    CONCAT(first_name, ' ', last_name) AS Full_name,
    LENGTH(country) AS country_size,
    LOWER(city) AS city
FROM
    dim_customer;   
    
    
    
-- SUBSTRING 
 -- extract a part of a string -- SELECT SUBSTRING(string, start, length)

SELECT * FROM dim_customer;
        
 SELECT 
    CONCAT(first_name, ' ', last_name) AS Full_name,   
    LENGTH(country) AS Country_size,  
    LOWER(city) AS City,      
    substring(email,1,4) as State    -- This extracts the first 4 characters of the email address, starting from the very first letter, and aliases it as State.
FROM
    dim_customer;   
    
 
 -- REPLACE   -- This takes the string, finds the specific symbol/character, and replaces it with another symnbol/character at that place
 
 SELECT * FROM dim_customer;
 
 SELECT 
    CONCAT(first_name, ' ', last_name) AS Full_name,
    LENGTH(country) AS country_size,
    LOWER(city) AS city,
    substring(email,1,4) as State,
    REPLACE(email,'@','@@') as Modified_Email  -- This takes the email string, finds the @ symbol, and replaces it with two at-symbols
FROM
    dim_customer;  
    
    
    
SELECT * FROM   dim_customer;


-- LEFT() Function, Returns characters from the beginning of a string.

SELECT *,
   LEFT(product_name,3) as Short_Product_Name
FROM 
  dim_product;   
  
  
  
-- RIGHT() Function, Returns characters from the end of a string.
  
SELECT *,
   RIGHT(product_name,3) as Short_Product_Name
FROM 
  dim_product; 
  
  
  
  -- REVERSE 
   SELECT *,
    REVERSE(launch_date) AS Reversed_date,
    REVERSE(product_name) AS Reversed_prod_name
FROM
    dim_product;
    
SELECT REVERSE("HI IM DHONI") AS Reversed_string;   
    
    
-- REPEAT , The REPEAT() function is used to repeat a string multiple times.    syntax: REPEAT(string, number_of_times)

 SELECT REPEAT('Hi ', 3);  

SELECT *,
    REPEAT(product_name, 2) AS Repeat_Name
FROM
    dim_product;   
   
   
-- Repeat with space
    
SELECT product_name,
       CONCAT(product_name, ' ', product_name) AS Repeated_name
FROM dim_product;    
   

-- CONCAT_WS , CONCAT With Separator , Syntax: CONCAT_WS(separator, string1, string2, string3, ...)
-- It joins multiple strings using a separator between them.

 SELECT *,
    CONCAT_WS(' ',first_name, last_name,country) AS Meta_info
FROM
    dim_customer;  
  
      
    
    

    
