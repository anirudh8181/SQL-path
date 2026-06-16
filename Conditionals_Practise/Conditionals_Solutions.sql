-- =====================================================================
-- CONDITIONAL LOGIC - 50 DATA ENGINEER INTERVIEW SOLUTIONS
-- Schema: Real_Sales (star schema) -- see Insert_script.sql for full DDL/data
-- Questions in: Conditionals_Questions.sql   |   Dialect: MySQL 8.0+
-- =====================================================================

USE Real_Sales;

-- C1. Product price tier
SELECT product_id, product_name, unit_price,
    CASE
        WHEN unit_price < 200 THEN 'Budget'
        WHEN unit_price < 600 THEN 'Standard'
        ELSE 'Premium'
    END AS price_tier
FROM dim_product;


-- C2. Gender standardization
SELECT customer_id, gender,
    CASE gender
        WHEN 'M' THEN 'Male'
        WHEN 'F' THEN 'Female'
        ELSE 'Unknown'
    END AS gender_label
FROM dim_customer;


-- C3. is_weekend to text with IF()
SELECT date_key, date, is_weekend,
    IF(is_weekend = 1, 'Weekend', 'Weekday') AS day_type
FROM dim_date;


-- C4. Quarter label (simple CASE)
SELECT DISTINCT quarter,
    CASE quarter
        WHEN 1 THEN 'Q1 Jan-Mar'
        WHEN 2 THEN 'Q2 Apr-Jun'
        WHEN 3 THEN 'Q3 Jul-Sep'
        WHEN 4 THEN 'Q4 Oct-Dec'
    END AS quarter_label
FROM dim_date
ORDER BY quarter;


-- C5. Discount presence flag
SELECT sales_id, discount,
    CASE WHEN discount > 0 THEN 'HAS_DISCOUNT' ELSE 'NO_DISCOUNT' END AS discount_flag
FROM fact_sales;


-- C6. High-value order flag (IF)
SELECT sales_id, total_amount,
    IF(total_amount >= 3000, 'High', 'Normal') AS value_flag
FROM fact_sales;


-- C7. Brand tier (simple CASE)
SELECT product_id, brand,
    CASE brand
        WHEN 'BrandA' THEN 'Premium'
        WHEN 'BrandB' THEN 'Premium'
        ELSE 'Standard'
    END AS brand_tier
FROM dim_product;


-- C8. Quantity bucket
SELECT sales_id, quantity_sold,
    CASE
        WHEN quantity_sold = 1            THEN 'Single'
        WHEN quantity_sold BETWEEN 2 AND 10 THEN 'Small'
        ELSE 'Bulk'
    END AS qty_bucket
FROM fact_sales;


-- C9. Season from month
SELECT DISTINCT month,
    CASE
        WHEN month IN (12, 1, 2)  THEN 'Winter'
        WHEN month IN (3, 4, 5)   THEN 'Spring'
        WHEN month IN (6, 7, 8)   THEN 'Summer'
        ELSE 'Fall'
    END AS season
FROM dim_date
ORDER BY month;


-- C10. Last-name initial bucket
SELECT customer_id, last_name,
    CASE
        WHEN UPPER(LEFT(last_name, 1)) BETWEEN 'A' AND 'M' THEN 'Group1'
        ELSE 'Group2'
    END AS name_group
FROM dim_customer;


-- C11. Defensive IFNULL discount + net price
SELECT sales_id, unit_price,
    IFNULL(discount, 0.00)              AS discount_clean,
    unit_price - IFNULL(discount, 0.00) AS net_unit_price
FROM fact_sales;


-- C12. NULLIF safe discount %
SELECT sales_id, unit_price, discount,
    ROUND(discount / NULLIF(unit_price, 0) * 100, 2) AS discount_pct
FROM fact_sales;


-- C13. COALESCE display location (first non-null)
SELECT customer_id,
    COALESCE(city, state, country, 'UNKNOWN') AS display_location
FROM dim_customer;


-- C14. Treat discount=0 as no discount via NULLIF
SELECT sales_id, discount,
    NULLIF(discount, 0)                                   AS discount_or_null,
    IF(NULLIF(discount, 0) IS NULL, 'NO_DISCOUNT', 'DISCOUNTED') AS discount_status
FROM fact_sales;


-- C15. COALESCE contact-preference chain (defensive)
SELECT customer_id,
    COALESCE(NULLIF(TRIM(phone), ''), NULLIF(TRIM(email), ''), 'NO CONTACT') AS best_contact
FROM dim_customer;


-- C16. Tenure tier nested CASE + VIP band
SELECT customer_id, join_date,
    TIMESTAMPDIFF(YEAR, join_date, CURDATE()) AS tenure_years,
    CASE
        WHEN TIMESTAMPDIFF(YEAR, join_date, CURDATE()) < 1 THEN 'New'
        WHEN TIMESTAMPDIFF(YEAR, join_date, CURDATE()) < 3 THEN 'Growing'
        WHEN TIMESTAMPDIFF(YEAR, join_date, CURDATE()) < 5 THEN
            CASE WHEN YEAR(join_date) < 2022 THEN 'Loyal-Gold' ELSE 'Loyal-Silver' END
        ELSE
            CASE WHEN YEAR(join_date) < 2022 THEN 'Veteran-Gold' ELSE 'Veteran-Silver' END
    END AS tenure_segment
FROM dim_customer;


-- C17. Tiered shipping cost
SELECT sales_id, total_amount,
    CASE
        WHEN total_amount < 500  THEN 50.00
        WHEN total_amount < 1500 THEN 25.00
        ELSE 0.00
    END AS shipping_cost
FROM fact_sales;


-- C18. Risk level nested CASE
SELECT sales_id, unit_price, discount, total_amount,
    CASE
        WHEN discount > unit_price THEN
            CASE WHEN total_amount >= 3000 THEN 'High' ELSE 'Medium' END
        WHEN total_amount >= 5000 THEN 'Medium'
        ELSE 'Low'
    END AS risk_level
FROM fact_sales;


-- C19. Loyalty points (CASE returns numeric rate)
SELECT sales_id, total_amount,
    ROUND(total_amount * CASE
        WHEN total_amount >= 5000 THEN 0.05
        WHEN total_amount >= 2000 THEN 0.03
        WHEN total_amount >= 500  THEN 0.01
        ELSE 0.00
    END, 2) AS loyalty_points
FROM fact_sales;


-- C20. Discount band from discount_pct (nested + NULLIF)
SELECT sales_id,
    ROUND(discount / NULLIF(unit_price, 0) * 100, 2) AS discount_pct,
    CASE
        WHEN discount / NULLIF(unit_price, 0) * 100 IS NULL THEN 'UNKNOWN'
        WHEN discount / NULLIF(unit_price, 0) * 100 = 0     THEN 'None'
        WHEN discount / NULLIF(unit_price, 0) * 100 < 10    THEN 'Low'
        WHEN discount / NULLIF(unit_price, 0) * 100 < 30    THEN 'Medium'
        ELSE 'High'
    END AS discount_band
FROM fact_sales;


-- C21. Email provider segment (simple CASE)
SELECT customer_id, email,
    SUBSTRING_INDEX(email, '@', -1) AS email_domain,
    CASE LOWER(SUBSTRING_INDEX(email, '@', -1))
        WHEN 'example.net' THEN 'Personal-Net'
        WHEN 'example.org' THEN 'Personal-Org'
        WHEN 'example.com' THEN 'Personal-Com'
        ELSE 'Other'
    END AS provider_segment
FROM dim_customer;


-- C22. Product life stage from launch_date
SELECT product_id, launch_date,
    TIMESTAMPDIFF(YEAR, launch_date, CURDATE()) AS age_years,
    CASE
        WHEN launch_date > CURDATE()                         THEN 'Pre-Launch'
        WHEN TIMESTAMPDIFF(MONTH, launch_date, CURDATE()) < 12 THEN 'New'
        WHEN TIMESTAMPDIFF(YEAR,  launch_date, CURDATE()) < 3  THEN 'Established'
        WHEN TIMESTAMPDIFF(YEAR,  launch_date, CURDATE()) < 5  THEN 'Mature'
        ELSE 'Legacy'
    END AS life_stage
FROM dim_product;


-- C23. Region super-group
SELECT store_id, region,
    CASE
        WHEN region IN ('North', 'East') THEN 'NE-Zone'
        WHEN region IN ('South', 'West') THEN 'SW-Zone'
        ELSE 'Central'
    END AS super_region
FROM dim_store;


-- C24. Country known-list standardization
SELECT customer_id, country,
    CASE
        WHEN country IN ('United Kingdom', 'United States', 'Singapore', 'Switzerland', 'Egypt')
            THEN country
        ELSE 'OTHER'
    END AS country_std
FROM dim_customer;


-- C25. Revenue bucket count + sum
WITH bucketed AS (
    SELECT sales_id, total_amount,
        CASE
            WHEN total_amount < 500  THEN 'Micro'
            WHEN total_amount < 1500 THEN 'Small'
            WHEN total_amount < 3500 THEN 'Medium'
            ELSE 'Large'
        END AS revenue_bucket
    FROM fact_sales
)
SELECT revenue_bucket, COUNT(*) AS num_sales, ROUND(SUM(total_amount), 2) AS bucket_revenue
FROM bucketed
GROUP BY revenue_bucket
ORDER BY FIELD(revenue_bucket, 'Micro', 'Small', 'Medium', 'Large');


-- C26. Customer value segment by lifetime revenue
WITH cust_rev AS (
    SELECT customer_key, ROUND(SUM(total_amount), 2) AS lifetime_revenue
    FROM fact_sales GROUP BY customer_key
)
SELECT c.customer_id, IFNULL(r.lifetime_revenue, 0) AS lifetime_revenue,
    CASE
        WHEN r.lifetime_revenue >= 50000 THEN 'Platinum'
        WHEN r.lifetime_revenue >= 20000 THEN 'Gold'
        WHEN r.lifetime_revenue >= 5000  THEN 'Silver'
        WHEN r.lifetime_revenue > 0      THEN 'Bronze'
        ELSE 'No-Purchase'
    END AS value_segment
FROM dim_customer c
LEFT JOIN cust_rev r ON c.customer_key = r.customer_key;


-- C27. Lifecycle status (RFM-lite recency)
WITH last_order AS (
    SELECT f.customer_key, MAX(d.date) AS last_order_date
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY f.customer_key
)
SELECT c.customer_id, lo.last_order_date,
    DATEDIFF(CURDATE(), lo.last_order_date) AS days_since_last_order,
    CASE
        WHEN lo.last_order_date IS NULL                     THEN 'Never-Purchased'
        WHEN DATEDIFF(CURDATE(), lo.last_order_date) <= 90  THEN 'Active'
        WHEN DATEDIFF(CURDATE(), lo.last_order_date) <= 180 THEN 'At-Risk'
        WHEN DATEDIFF(CURDATE(), lo.last_order_date) <= 365 THEN 'Dormant'
        ELSE 'Churned'
    END AS lifecycle_status
FROM dim_customer c
LEFT JOIN last_order lo ON c.customer_key = lo.customer_key;


-- C28. Order-count tier per customer
WITH oc AS (
    SELECT customer_key, COUNT(*) AS order_count FROM fact_sales GROUP BY customer_key
)
SELECT c.customer_id, IFNULL(oc.order_count, 0) AS order_count,
    CASE
        WHEN IFNULL(oc.order_count, 0) >= 10 THEN 'Gold'
        WHEN IFNULL(oc.order_count, 0) >= 3  THEN 'Silver'
        WHEN IFNULL(oc.order_count, 0) >= 1  THEN 'Bronze'
        ELSE 'Inactive'
    END AS frequency_tier
FROM dim_customer c
LEFT JOIN oc ON c.customer_key = oc.customer_key;


-- C29. Products priced above their category average
WITH cat_avg AS (
    SELECT category, AVG(unit_price) AS avg_price FROM dim_product GROUP BY category
)
SELECT p.product_id, p.category, p.unit_price, ROUND(ca.avg_price, 2) AS category_avg,
    CASE WHEN p.unit_price > ca.avg_price THEN 'Above-Avg' ELSE 'At-or-Below-Avg' END AS positioning
FROM dim_product p
JOIN cat_avg ca ON p.category = ca.category;


-- C30. Product margin band (incl. No-Sales)
WITH prod_sales AS (
    SELECT product_key,
        ROUND(SUM(total_amount), 2)             AS gross_revenue,
        ROUND(SUM(discount * quantity_sold), 2) AS total_discount
    FROM fact_sales GROUP BY product_key
)
SELECT p.product_id, p.category,
    IFNULL(ps.gross_revenue, 0) AS gross_revenue,
    ROUND(100 * IFNULL(ps.total_discount, 0) / NULLIF(ps.gross_revenue, 0), 2) AS eff_discount_pct,
    CASE
        WHEN ps.gross_revenue IS NULL                                 THEN 'No-Sales'
        WHEN 100 * ps.total_discount / NULLIF(ps.gross_revenue, 0) < 5  THEN 'Healthy'
        WHEN 100 * ps.total_discount / NULLIF(ps.gross_revenue, 0) <= 15 THEN 'Watch'
        ELSE 'Eroded'
    END AS margin_band
FROM dim_product p
LEFT JOIN prod_sales ps ON p.product_key = ps.product_key;


-- C31. Pivot revenue per region into category columns
SELECT s.region,
    ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN f.total_amount ELSE 0 END), 2) AS electronics_rev,
    ROUND(SUM(CASE WHEN p.category = 'Clothing'    THEN f.total_amount ELSE 0 END), 2) AS clothing_rev,
    ROUND(SUM(CASE WHEN p.category = 'Books'       THEN f.total_amount ELSE 0 END), 2) AS books_rev,
    ROUND(SUM(f.total_amount), 2) AS total_rev
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store   s ON f.store_key   = s.store_key
GROUP BY s.region
ORDER BY total_rev DESC;


-- C32. Weekend vs weekday sales count per region
SELECT s.region,
    SUM(CASE WHEN d.is_weekend = 1 THEN 1 ELSE 0 END) AS weekend_sales,
    SUM(CASE WHEN d.is_weekend = 0 THEN 1 ELSE 0 END) AS weekday_sales,
    COUNT(*) AS total_sales
FROM fact_sales f
JOIN dim_date  d ON f.date_key  = d.date_key
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.region;


-- C33. Revenue split by gender per category
SELECT p.category,
    ROUND(SUM(CASE WHEN c.gender = 'M' THEN f.total_amount ELSE 0 END), 2) AS male_rev,
    ROUND(SUM(CASE WHEN c.gender = 'F' THEN f.total_amount ELSE 0 END), 2) AS female_rev,
    ROUND(SUM(f.total_amount), 2) AS total_rev
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product  p ON f.product_key  = p.product_key
GROUP BY p.category;


-- C34. Per store: total revenue + discounted-line revenue
SELECT s.store_id, s.store_name,
    ROUND(SUM(f.total_amount), 2) AS total_rev,
    ROUND(SUM(CASE WHEN f.discount > 0 THEN f.total_amount ELSE 0 END), 2) AS discounted_rev
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.store_id, s.store_name;


-- C35. Cross-tab: sales count by region x quarter
SELECT s.region,
    SUM(CASE WHEN d.quarter = 1 THEN 1 ELSE 0 END) AS q1,
    SUM(CASE WHEN d.quarter = 2 THEN 1 ELSE 0 END) AS q2,
    SUM(CASE WHEN d.quarter = 3 THEN 1 ELSE 0 END) AS q3,
    SUM(CASE WHEN d.quarter = 4 THEN 1 ELSE 0 END) AS q4
FROM fact_sales f
JOIN dim_date  d ON f.date_key  = d.date_key
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.region;


-- C36. Total discount given on Electronics only
SELECT
    ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN f.discount * f.quantity_sold ELSE 0 END), 2)
        AS electronics_discount,
    ROUND(SUM(f.discount * f.quantity_sold), 2) AS all_discount
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key;


-- C37. Per category: % of revenue from Bulk (qty>10) orders
SELECT p.category,
    ROUND(100 * SUM(CASE WHEN f.quantity_sold > 10 THEN f.total_amount ELSE 0 END)
              / NULLIF(SUM(f.total_amount), 0), 2) AS bulk_revenue_pct
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category;


-- C38. Cohort matrix: New vs Returning order lines per month
WITH seq AS (
    SELECT f.sales_id, DATE_FORMAT(d.date, '%Y-%m') AS ym,
        ROW_NUMBER() OVER (PARTITION BY f.customer_key ORDER BY d.date, f.sales_id) AS rn
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
)
SELECT ym,
    SUM(CASE WHEN rn = 1 THEN 1 ELSE 0 END) AS new_customer_orders,
    SUM(CASE WHEN rn > 1 THEN 1 ELSE 0 END) AS returning_orders
FROM seq
GROUP BY ym
ORDER BY ym;


-- C39. Row DQ flag (priority ordered)
SELECT sales_id, unit_price, discount, total_amount,
    CASE
        WHEN discount > unit_price THEN 'OVER_DISCOUNT'
        WHEN total_amount <= 0     THEN 'BAD_AMOUNT'
        ELSE 'OK'
    END AS dq_flag
FROM fact_sales;


-- C40. Invalid-record flag
SELECT sales_id, quantity_sold, unit_price, discount,
    CASE
        WHEN quantity_sold <= 0 OR unit_price <= 0 OR discount < 0 THEN 'INVALID'
        ELSE 'VALID'
    END AS record_status
FROM fact_sales;


-- C41. dim_customer completeness scorecard
SELECT COUNT(*) AS total_rows,
    SUM(CASE WHEN first_name IS NOT NULL AND TRIM(first_name) <> '' THEN 1 ELSE 0 END) AS first_name_ok,
    SUM(CASE WHEN email LIKE '%@%.%'                               THEN 1 ELSE 0 END) AS email_ok,
    SUM(CASE WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) BETWEEN 10 AND 15 THEN 1 ELSE 0 END) AS phone_ok,
    SUM(CASE WHEN join_date IS NOT NULL AND join_date <= CURDATE() THEN 1 ELSE 0 END) AS join_date_ok,
    ROUND(100 * SUM(CASE WHEN email LIKE '%@%.%'
                          AND LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) BETWEEN 10 AND 15
                          AND join_date <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_fully_valid
FROM dim_customer;


-- C42. Email structural validity flag
SELECT customer_id, email,
    CASE WHEN email LIKE '%_@_%._%' THEN 'VALID' ELSE 'INVALID' END AS email_valid
FROM dim_customer;


-- C43. Phone validity class
SELECT customer_id, phone,
    LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) AS digit_count,
    CASE
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) = 10 THEN 'VALID_10'
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) BETWEEN 11 AND 15 THEN 'CHECK_INTL'
        ELSE 'INVALID'
    END AS phone_quality
FROM dim_customer;


-- C44. Future-dated join_date flag
SELECT customer_id, join_date,
    CASE WHEN join_date > CURDATE() THEN 'FUTURE_JOIN_DATE' ELSE 'OK' END AS join_dq_flag
FROM dim_customer;


-- C45. total_amount reconciliation summary
WITH checked AS (
    SELECT sales_id, total_amount,
        ROUND(total_amount - quantity_sold * (unit_price - discount), 2) AS diff
    FROM fact_sales
)
SELECT
    CASE
        WHEN ABS(diff) = 0     THEN 'MATCH'
        WHEN ABS(diff) <= 0.01 THEN 'ROUNDING'
        ELSE 'MISMATCH'
    END AS recon_status,
    COUNT(*) AS row_count, ROUND(MIN(diff), 2) AS min_diff, ROUND(MAX(diff), 2) AS max_diff
FROM checked
GROUP BY 1
ORDER BY row_count DESC;


-- C46. Referential price check: fact unit_price vs dim_product unit_price
SELECT f.sales_id, f.unit_price AS fact_price, p.unit_price AS dim_price,
    CASE
        WHEN p.product_key IS NULL                  THEN 'MISSING_PRODUCT'
        WHEN f.unit_price = p.unit_price            THEN 'MATCH'
        ELSE 'PRICE_DRIFT'
    END AS price_check
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_key = p.product_key;


-- C47. Composite status string per customer (tier|activity|risk)
WITH agg AS (
    SELECT f.customer_key, COUNT(*) AS orders, ROUND(SUM(f.total_amount), 2) AS revenue,
        MAX(d.date) AS last_order
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY f.customer_key
)
SELECT c.customer_id,
    CONCAT_WS('|',
        CASE WHEN a.revenue >= 20000 THEN 'HIGH'
             WHEN a.revenue >= 5000  THEN 'MID' ELSE 'LOW' END,
        CASE WHEN DATEDIFF(CURDATE(), a.last_order) <= 90 THEN 'ACTIVE' ELSE 'INACTIVE' END,
        CASE WHEN a.orders >= 10 THEN 'FREQUENT' ELSE 'OCCASIONAL' END
    ) AS customer_status
FROM dim_customer c
JOIN agg a ON c.customer_key = a.customer_key;


-- C48. Per-sale profitability flag (nested CASE on net margin; assume cost=60% of price)
SELECT sales_id, unit_price, discount,
    ROUND((unit_price - discount) - (unit_price * 0.60), 2) AS net_margin_per_unit,
    CASE
        WHEN (unit_price - discount) - (unit_price * 0.60) < 0 THEN 'LOSS'
        WHEN (unit_price - discount) - (unit_price * 0.60) < (unit_price * 0.10) THEN 'THIN'
        ELSE 'HEALTHY'
    END AS profitability_flag
FROM fact_sales;


-- C49. Price-band bucketing of products (100-wide bands)
SELECT product_id, unit_price,
    CASE
        WHEN unit_price < 100 THEN '000-099'
        WHEN unit_price < 200 THEN '100-199'
        WHEN unit_price < 300 THEN '200-299'
        WHEN unit_price < 500 THEN '300-499'
        WHEN unit_price < 800 THEN '500-799'
        ELSE '800+'
    END AS price_band
FROM dim_product;


-- C50. customer_360: tier + lifecycle + value band + dq_flag together
WITH agg AS (
    SELECT f.customer_key, COUNT(*) AS orders, ROUND(SUM(f.total_amount), 2) AS revenue,
        MAX(d.date) AS last_order
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY f.customer_key
)
SELECT c.customer_id,
    IFNULL(a.orders, 0)  AS orders,
    IFNULL(a.revenue, 0) AS revenue,
    CASE
        WHEN a.revenue >= 50000 THEN 'Platinum'
        WHEN a.revenue >= 20000 THEN 'Gold'
        WHEN a.revenue >= 5000  THEN 'Silver'
        WHEN a.revenue > 0      THEN 'Bronze'
        ELSE 'No-Purchase'
    END AS value_tier,
    CASE
        WHEN a.last_order IS NULL                       THEN 'Never'
        WHEN DATEDIFF(CURDATE(), a.last_order) <= 90     THEN 'Active'
        WHEN DATEDIFF(CURDATE(), a.last_order) <= 365    THEN 'Lapsing'
        ELSE 'Churned'
    END AS lifecycle_status,
    CASE
        WHEN c.join_date > CURDATE()                     THEN 'FUTURE_JOIN_DATE'
        WHEN a.last_order < c.join_date                  THEN 'ORDER_BEFORE_JOIN'
        WHEN a.orders IS NULL                            THEN 'NO_ACTIVITY'
        ELSE 'OK'
    END AS dq_flag
FROM dim_customer c
LEFT JOIN agg a ON c.customer_key = a.customer_key
ORDER BY revenue DESC;
