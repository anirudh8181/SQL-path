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




-- Simple CASE
-- Compares ONE column against exact values (equality only). Shorter than
-- searched CASE when every branch tests the same column.
-- Syntax: CASE col WHEN v1 THEN r1 WHEN v2 THEN r2 ELSE r3 END


-- Map gender code to a readable label
SELECT customer_key, gender,
       CASE gender
            WHEN 'M' THEN 'Male'
            WHEN 'F' THEN 'Female'
            ELSE 'Unknown'
       END AS gender_label
FROM dim_customer;

-- Turn each brand code into a tier name
SELECT product_name, brand,
       CASE brand
            WHEN 'BrandA' THEN 'Premium'
            WHEN 'BrandB' THEN 'Popular'
            ELSE 'Regular'
       END AS brand_tier
FROM dim_product;

-- Label the weekend flag stored as 1/0
SELECT date_key, date,
       CASE is_weekend
            WHEN 1 THEN 'Weekend'
            WHEN 0 THEN 'Weekday'
       END AS day_type
FROM dim_date;

-- Give each quarter number a descriptive label
SELECT DISTINCT year, quarter,
       CASE quarter
            WHEN 1 THEN 'Q1 - Jan-Mar'
            WHEN 2 THEN 'Q2 - Apr-Jun'
            WHEN 3 THEN 'Q3 - Jul-Sep'
            ELSE 'Q4 - Oct-Dec'
       END AS quarter_label
FROM dim_date;

-- Map store region to a zone code
SELECT store_name, region,
       CASE region
            WHEN 'North' THEN 'Z1'
            WHEN 'South' THEN 'Z2'
            WHEN 'East'  THEN 'Z3'
            WHEN 'West'  THEN 'Z4'
            ELSE 'Z0'
       END AS zone_code
FROM dim_store;




-- COALESCE()
-- Returns the FIRST non-NULL value from a list of arguments (2 or more).
-- ANSI-standard. Great for fallback chains.
-- Syntax: COALESCE(val1, val2, val3, ...)


-- Show phone, or fall back to 'No Phone' when NULL
SELECT customer_key,
       COALESCE(phone, 'No Phone') AS contact_phone
FROM dim_customer;

-- Fallback chain: prefer city, else state, else country, else 'Unknown'
SELECT customer_key,
       COALESCE(city, state, country, 'Unknown') AS best_location
FROM dim_customer;

-- Treat a missing discount as 0 before arithmetic
SELECT sales_id, total_amount,
       total_amount - COALESCE(discount, 0) AS net_after_discount
FROM fact_sales;

-- Build an email, defaulting to a generated placeholder when NULL
SELECT customer_key,
       COALESCE(email, CONCAT(LOWER(customer_id), '@noemail.com')) AS email_final
FROM dim_customer;

-- Multi-column fallback for a display handle
SELECT customer_key,
       COALESCE(first_name, last_name, customer_id) AS display_handle
FROM dim_customer;




-- IFNULL()   (MySQL-specific)
-- Two-argument shortcut: returns the fallback ONLY when the first value is
-- NULL. Like COALESCE but limited to exactly 2 arguments.
-- Syntax: IFNULL(value, fallback)


-- Replace NULL phone with a label
SELECT customer_key,
       IFNULL(phone, 'Not Available') AS phone_display
FROM dim_customer;

-- Default a missing discount to 0
SELECT sales_id,
       IFNULL(discount, 0) AS discount_clean
FROM fact_sales;

-- Default a missing city to 'N/A'
SELECT customer_key, city,
       IFNULL(city, 'N/A') AS city_display
FROM dim_customer;

-- Default a missing brand to 'Unbranded'
SELECT product_name,
       IFNULL(brand, 'Unbranded') AS brand_display
FROM dim_product;

-- IFNULL inside a concatenated address (stops NULL from blanking the string)
SELECT store_key,
       CONCAT(IFNULL(city, '?'), ', ', IFNULL(country, '?')) AS location
FROM dim_store;




-- NULLIF()
-- Returns NULL when the two arguments are equal, otherwise returns the first.
-- Two classic uses: (1) guard divide-by-zero, (2) turn a placeholder into NULL.
-- Syntax: NULLIF(a, b)   -> NULL if a = b, else a


-- Safe division: avoid divide-by-zero when discount is 0
SELECT sales_id, total_amount, discount,
       total_amount / NULLIF(discount, 0) AS amount_per_discount
FROM fact_sales;

-- Treat placeholder phone '0000000000' as missing (becomes NULL)
SELECT customer_key, phone,
       NULLIF(phone, '0000000000') AS phone_real
FROM dim_customer;

-- Combine NULLIF + IFNULL: placeholder -> NULL -> display value
SELECT customer_key,
       IFNULL(NULLIF(phone, '0000000000'), 'Not Provided') AS clean_phone
FROM dim_customer;

-- Safe discount percentage (guard zero gross value)
SELECT sales_id,
       ROUND(discount / NULLIF(quantity_sold * unit_price, 0) * 100, 2) AS discount_pct
FROM fact_sales;

-- Hide a category that equals 'Unknown' by converting it to NULL
SELECT product_name,
       NULLIF(category, 'Unknown') AS category_or_null
FROM dim_product;




-- Conditional Aggregation  (CASE inside SUM / COUNT / AVG)
-- Puts a CASE inside an aggregate so you count/sum only rows matching a
-- condition. Turns row filters into COLUMNS (basis of pivot-style reports).
-- Syntax: SUM(CASE WHEN condition THEN value ELSE 0 END)


-- Count Male vs Female customers in one row (horizontal split)
SELECT SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male_count,
       SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female_count
FROM dim_customer;

-- Per store, revenue from High-Value (>=1000) vs Standard sales
SELECT store_key,
       SUM(CASE WHEN total_amount >= 1000 THEN total_amount ELSE 0 END) AS high_value_rev,
       SUM(CASE WHEN total_amount <  1000 THEN total_amount ELSE 0 END) AS standard_rev
FROM fact_sales
GROUP BY store_key;

-- Count products per price band, all in one row
SELECT COUNT(CASE WHEN unit_price < 200 THEN 1 END)               AS low_priced,
       COUNT(CASE WHEN unit_price BETWEEN 200 AND 600 THEN 1 END) AS mid_priced,
       COUNT(CASE WHEN unit_price > 600 THEN 1 END)               AS high_priced
FROM dim_product;

-- Per category, average price of premium (>500) items only
SELECT category,
       ROUND(AVG(CASE WHEN unit_price > 500 THEN unit_price END), 2) AS avg_premium_price
FROM dim_product
GROUP BY category;

-- Per store, count of weekend vs weekday sales
SELECT fs.store_key,
       SUM(CASE WHEN d.is_weekend = 1 THEN 1 ELSE 0 END) AS weekend_sales,
       SUM(CASE WHEN d.is_weekend = 0 THEN 1 ELSE 0 END) AS weekday_sales
FROM fact_sales fs
JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY fs.store_key;




-- Nested CASE  (CASE inside a branch of another CASE)
-- Applies a second-level rule only after the first condition is met. Useful
-- for multi-dimensional classification.
-- Syntax: CASE WHEN cond THEN (CASE WHEN cond2 THEN .. ELSE .. END) ELSE .. END


-- Price tier that depends on category first, then price
SELECT product_name, category, unit_price,
       CASE
            WHEN category = 'Electronics' THEN
                 CASE WHEN unit_price > 500 THEN 'Premium Electronics'
                      ELSE 'Budget Electronics' END
            ELSE 'Other Category'
       END AS detailed_tier
FROM dim_product;

-- Customer recency, then split new joiners by gender
SELECT customer_key, gender, join_date,
       CASE
            WHEN YEAR(join_date) >= 2024 THEN
                 CASE WHEN gender = 'M' THEN 'New - Male'
                      WHEN gender = 'F' THEN 'New - Female'
                      ELSE 'New - Other' END
            ELSE 'Existing'
       END AS segment
FROM dim_customer;

-- Sale size band, then flag discounted ones within the big band
SELECT sales_id, total_amount, discount,
       CASE
            WHEN total_amount >= 1000 THEN
                 CASE WHEN discount > 0 THEN 'Big - Discounted'
                      ELSE 'Big - Full Price' END
            ELSE 'Small'
       END AS sale_label
FROM fact_sales;

-- Region, then rank store country importance inside it
SELECT store_name, region, country,
       CASE
            WHEN region = 'North' THEN
                 CASE WHEN country = 'Singapore' THEN 'North-Key' ELSE 'North-Std' END
            ELSE 'Other Region'
       END AS store_class
FROM dim_store;

-- Product age, then sub-classify old products by price
SELECT product_name, launch_date, unit_price,
       CASE
            WHEN YEAR(launch_date) < 2022 THEN
                 CASE WHEN unit_price > 500 THEN 'Old & Expensive'
                      ELSE 'Old & Cheap' END
            ELSE 'Recent'
       END AS lifecycle
FROM dim_product;




-- CASE in the WHERE clause  (conditional filtering)
-- Lets the filter rule itself change based on a column's value, or filters on
-- a computed CASE result. Useful when the rule depends on the row's type.
-- Syntax: WHERE col < CASE WHEN cond THEN x ELSE y END


-- Different price ceiling per category (Electronics <800, others <300)
SELECT product_name, category, unit_price
FROM dim_product
WHERE unit_price < CASE WHEN category = 'Electronics' THEN 800 ELSE 300 END;

-- Keep only rows whose computed band is 'High'
SELECT product_name, unit_price
FROM dim_product
WHERE CASE WHEN unit_price > 600 THEN 'High' ELSE 'Low' END = 'High';

-- Weekend sales must clear a higher bar than weekday sales
SELECT fs.sales_id, fs.total_amount, d.is_weekend
FROM fact_sales fs
JOIN dim_date d ON fs.date_key = d.date_key
WHERE fs.total_amount > CASE WHEN d.is_weekend = 1 THEN 1000 ELSE 200 END;

-- Filter customers joined recently OR from a key country
SELECT customer_key, country, join_date
FROM dim_customer
WHERE CASE
          WHEN country = 'United Kingdom' THEN 1
          WHEN YEAR(join_date) >= 2024     THEN 1
          ELSE 0
      END = 1;

-- Keep products only if discount-eligible by their own tier rule
SELECT product_name, unit_price
FROM dim_product
WHERE CASE
          WHEN unit_price > 800 THEN 'yes'
          WHEN unit_price > 500 THEN 'yes'
          ELSE 'no'
      END = 'yes';




-- CASE in GROUP BY  (bucket, then aggregate)
-- Groups rows by a derived category instead of a raw column, so you can
-- aggregate over buckets you invent on the fly.
-- Syntax: SELECT CASE ... END AS bucket, COUNT(*) ... GROUP BY bucket


-- Count products per price band (group by the CASE bucket)
SELECT CASE
            WHEN unit_price < 200 THEN 'Low'
            WHEN unit_price <= 600 THEN 'Medium'
            ELSE 'High'
       END AS price_band,
       COUNT(*) AS product_count
FROM dim_product
GROUP BY price_band;

-- Revenue grouped by sale-size bucket
SELECT CASE WHEN total_amount >= 1000 THEN 'High Value' ELSE 'Standard' END AS bucket,
       ROUND(SUM(total_amount), 2) AS revenue,
       COUNT(*) AS num_sales
FROM fact_sales
GROUP BY bucket;

-- Customers grouped by join-year era
SELECT CASE
            WHEN YEAR(join_date) < 2022 THEN 'Loyal'
            WHEN YEAR(join_date) <= 2023 THEN 'Established'
            ELSE 'New'
       END AS cohort,
       COUNT(*) AS customers
FROM dim_customer
GROUP BY cohort;

-- Products grouped by launch era, averaging price
SELECT CASE WHEN YEAR(launch_date) >= 2024 THEN 'New' ELSE 'Old' END AS era,
       COUNT(*) AS items,
       ROUND(AVG(unit_price), 2) AS avg_price
FROM dim_product
GROUP BY era;

-- Sales grouped by weekend/weekday derived label
SELECT CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
       COUNT(*) AS sales_count,
       ROUND(SUM(fs.total_amount), 2) AS revenue
FROM fact_sales fs
JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY day_type;

 
 


 