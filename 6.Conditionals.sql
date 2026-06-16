-- CONDITIONALS

SELECT * FROM dim_product;


/*

Full Structure of CASE Syntax:

CASE
    WHEN condition THEN value
    WHEN condition THEN value
    ELSE value
END 
or    
END AS Alias name of the column  <-- Creates a column alias (temporary column name).


It works like:
IF condition is true
    return some value
ELSE
    return another value
    
*/


-- 1
SELECT 
     *,
     CASE 
     WHEN unit_price <= 100 THEN 'Affordable'
     WHEN unit_price <= 200 THEN 'Normal_price'
     ELSE 'Expensive'
     END AS price_category
 FROM 
     dim_product; 
     
     
-- 2
SELECT 
     *,
     CASE
     WHEN  unit_price <=100 AND category='clothing' THEN 'Cheap'
     WHEN unit_price <=200  AND category ='clothing' THEN 'Normal'
     WHEN unit_price >200 AND category='clothing'  THEN 'Expensive'
     ELSE CONCAT('Not this category:',category)
     END AS  Descriptive_analysis
FROM 
    dim_product;
    
    
-- Categorize Products by Price Range using CASE
SELECT 
    product_name,
    category,
    unit_price,
    CASE
        WHEN unit_price < 200 THEN 'Low Price'
        WHEN unit_price BETWEEN 200 AND 700 THEN 'Medium Price'
        ELSE 'High Price'
    END AS price_category
FROM dim_product;


-- Show Brand Priority using CASE
SELECT 
    product_name,
    brand,
    CASE
        WHEN brand = 'BrandA' THEN 'Premium Brand'
        WHEN brand = 'BrandB' THEN 'Popular Brand'
        ELSE 'Regular Brand'
    END AS brand_type
FROM dim_product;


-- Check Whether Product is Old or New
SELECT 
    product_name,
    launch_date,
    CASE
        WHEN YEAR(launch_date) >= 2024 THEN 'New Product'
        ELSE 'Old Product'
    END AS product_status
FROM dim_product;    
    
    
-- Sort Products Based on Conditional Priority

SELECT 
    product_name,
    category,
    unit_price
FROM dim_product
ORDER BY 
    CASE
        WHEN category = 'Electronics' THEN 1
        WHEN category = 'Sports' THEN 2
        WHEN category = 'clothing' THEN 3
        ELSE 4
    END;
  
  
 -- Display Discount Eligibility
 SELECT 
    product_name,
    unit_price,
    CASE
        WHEN unit_price > 800 THEN '20% Discount'
        WHEN unit_price > 500 THEN '10% Discount'
        ELSE 'No Discount'
    END AS Discount_Offer
FROM dim_product;


-- Check Product Cost Status using IF,   synatx: IF(condition, value_if_true, value_if_false)
/*
if condition is true
    return value_if_true
else
    return value_if_false
*/    
SELECT 
    product_name,
    unit_price,
    IF(unit_price > 500, 'Costly', 'Affordable') AS Price_Status
FROM dim_product;
 
 
 
-- 1 
SELECT 
    product_name,
    category,
    unit_price
FROM dim_product
ORDER BY 
    CASE
        WHEN category = 'Electronics' THEN 1
        WHEN category = 'Sports' THEN 2
        ELSE 3
    END;



-- 2    
SELECT 
    product_name,
    category,
    unit_price,
    CASE
        WHEN category = 'Electronics' THEN 1
        WHEN category = 'Sports' THEN 2
        ELSE 3
    END AS sort_order
FROM dim_product
ORDER BY sort_order; 

    
 /*
 Step-by-Step Internal Working:
 Step 1: SQL Reads Rows from dim_product
 
 
 Step 2: CASE Expression Executes for Every Row

For each row, SQL evaluates:

CASE
    WHEN category = 'Electronics' THEN 1
    WHEN category = 'Sports' THEN 2
    ELSE 3
END

It creates a temporary hidden value internally.

example:

Row-by-Row Evaluation:

Row 1:
category = Electronics

Condition matched:
WHEN category = 'Electronics' THEN 1

Temporary value: 1

Row 2:
category = Sports

Condition matched:
WHEN category = 'Sports' THEN 2

Temporary value:2

Row 3:
category = Education

No condition matched.

So:
ELSE 3
Temporary value: 3


Internally SQL Creates Something Like 
--------------------------------------------
product_name	category	temp_sort_value
--------------------------------------------
Laptop	        Electronics	    1
Football	    Sports	        2
Book	        Education	    3
Mobile	        Electronics	    1
Bat	             Sports	        2
---------------------------------------------


SQL sorts rows based on:

1 → first
2 → second
3 → last


 */
 
 
 


 