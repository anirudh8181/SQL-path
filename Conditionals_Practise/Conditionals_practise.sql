

-- Question 1: How would you categorize customers as either "Northeast" or "Other" if the states New York and New Hampshire are the primary focus?
SELECT first_name, state, 
CASE WHEN state IN ('New York', 'New Hampshire') THEN 'Northeast' 
ELSE 'Other' END AS region_tier 
FROM dim_customer;


-- Question 2: Based on the phone column, how can we distinguish between international contacts (starting with '00') and local ones?
SELECT customer_id, phone, 
IF(phone LIKE '00%', 'International', 'Local') AS contact_type   -- IF(CONDITION , Value_If_True, Value_if_false)
FROM dim_customer;



-- Question 3: If a customer joined before 2022, they are "Legacy"; otherwise, they are "New." How is this written using the join_date?
SELECT customer_id, join_date, 
CASE WHEN join_date < '2022-01-01' THEN 'Legacy' 
ELSE 'New' END AS membership_status 
FROM dim_customer;



-- Question 4: For the stores, label those in the 'North' or 'South' regions as "Vertical Axis" and all others as "Central/Misc."
SELECT store_name, region, 
CASE WHEN region IN ('North', 'South') THEN 'Vertical Axis' 
ELSE 'Central/Misc' END AS alignment 
FROM dim_store;



-- Question 5: How would you flag customers using 'example.net' as "Internal Test" vs "External" in the dim_customer table?
SELECT email, 
IF(email LIKE '%@example.net', 'Internal Test', 'External') AS user_type 
FROM dim_customer;


-- Question 6: Using the unit_price, classify products over 500.00 as "High-End" and those below as "Standard."
SELECT product_name, unit_price, 
CASE WHEN unit_price > 500 THEN 'High-End' 
ELSE 'Standard' END AS price_class 
FROM dim_product;


-- Question 7: How do you label 'Clothing' and 'Electronics' as "Technical/Wearable" and everything else as "General Inventory"?
SELECT product_name, category, 
CASE WHEN category IN ('Clothing', 'Electronics') THEN 'Technical/Wearable' 
ELSE 'General Inventory' END AS inventory_group 
FROM dim_product;



-- Question 8: If the brand is 'BrandA' or 'BrandB', it is "Premium Brand"; otherwise, it is "Third Party." Use the dim_product table.
SELECT product_name, brand, 
IF(brand IN ('BrandA', 'BrandB'), 'Premium Brand', 'Third Party') AS brand_tier 
FROM dim_product;



-- Question 9: In the fact_sales table, identify transactions where quantity_sold is greater than 5 as "Bulk Order."
SELECT sales_id, quantity_sold, 
CASE WHEN quantity_sold > 5 THEN 'Bulk Order' 
ELSE 'Retail' END AS order_type 
FROM fact_sales;



-- Question 10: How would you flag a sale as "Deep Discount" if the discount is greater than 40.00?
SELECT sales_id, discount, 
IF(discount > 40.00, 'Deep Discount', 'Standard') AS margin_flag 
FROM fact_sales;



-- Question 11: Categorize sales based on total_amount: over 5000 is "Enterprise," 1000-5000 is "Mid-Market," and under 1000 is "Consumer."
SELECT sales_id, total_amount, 
CASE 
  WHEN total_amount > 5000 THEN 'Enterprise' 
  WHEN total_amount BETWEEN 1000 AND 5000 THEN 'Mid-Market' 
  ELSE 'Consumer' 
END AS account_segment 
FROM fact_sales;


-- Question 12: Create a column that shows 'Yes' if a discount was applied and 'No' if it was 0.
SELECT sales_id, discount, 
IF(discount > 0, 'Yes', 'No') AS is_discounted 
FROM fact_sales;



-- Question 13: Using dim_date, label sales in 'October', 'November', and 'December' as "Q4 Peak" and others as "Off-Peak."
SELECT date, month_name, 
CASE WHEN month_name IN ('October', 'November', 'December') THEN 'Q4 Peak' 
ELSE 'Off-Peak' END AS seasonality 
FROM dim_date;



-- Question 14: If a sale occurs on a weekend (is_weekend = 1), label it "Premium Window," otherwise "Standard Window."
SELECT date, is_weekend, 
IF(is_weekend = 1, 'Premium Window', 'Standard Window') AS pricing_window 
FROM dim_date;



-- Question 15: Group the quarters so that Quarters 1 and 2 are "First Half" and 3 and 4 are "Second Half."
SELECT date, quarter, 
CASE WHEN quarter <= 2 THEN 'First Half' 
ELSE 'Second Half' END AS annual_split 
FROM dim_date;