-- =====================================================================
-- CONDITIONAL LOGIC — 50 DATA ENGINEER INTERVIEW SOLUTIONS
-- Schema : Real_Sales (star schema) — see Insert_script.sql for full DDL/data
-- Dialect: MySQL 8.0+   |   Questions also in: Conditionals_Questions.sql
-- Layout : full question (comment) + runnable solution query (same C-numbers).
-- =====================================================================

USE Real_Sales;


-- ====================================================================
-- CASE / IF BASICS  (C1–C10)
-- ====================================================================

/* C1  [Beginner | CASE WHEN ranges]
   Finance wants a pricing report that groups products into tiers based on
   unit_price: 'Budget' below 200, 'Standard' from 200 up to 599.99, and
   'Premium' at 600 and above. Return each product with its tier label. */
SELECT product_id, product_name, unit_price,
    CASE
        WHEN unit_price < 200 THEN 'Budget'
        WHEN unit_price < 600 THEN 'Standard'
        ELSE 'Premium'
    END AS price_tier
FROM dim_product;


/* C2  [Beginner | simple CASE]
   The reporting layer stores gender as a single character (M/F) but needs
   readable labels for dashboards. Standardize it so 'M' becomes 'Male',
   'F' becomes 'Female', and anything else becomes 'Unknown'. */
SELECT customer_id, gender,
    CASE gender
        WHEN 'M' THEN 'Male'
        WHEN 'F' THEN 'Female'
        ELSE 'Unknown'
    END AS gender_label
FROM dim_customer;


/* C3  [Beginner | IF()]
   A weekend-promotion report needs each calendar date labelled as either
   'Weekend' or 'Weekday'. The dim_date table already stores is_weekend as
   1/0 — convert that flag into the readable label using IF(). */
SELECT date_key, date, is_weekend,
    IF(is_weekend = 1, 'Weekend', 'Weekday') AS day_type
FROM dim_date;


/* C4  [Beginner | simple CASE]
   The BI team wants each quarter number from dim_date shown as a descriptive
   label ('Q1 Jan-Mar' through 'Q4 Oct-Dec') for report headers. Produce the
   distinct quarter-to-label mapping. */
SELECT DISTINCT quarter,
    CASE quarter
        WHEN 1 THEN 'Q1 Jan-Mar'
        WHEN 2 THEN 'Q2 Apr-Jun'
        WHEN 3 THEN 'Q3 Jul-Sep'
        WHEN 4 THEN 'Q4 Oct-Dec'
    END AS quarter_label
FROM dim_date
ORDER BY quarter;


/* C5  [Beginner | CASE WHEN]
   The merchandising team wants every sale flagged according to whether a
   discount was applied: 'HAS_DISCOUNT' when discount is greater than 0,
   otherwise 'NO_DISCOUNT'. */
SELECT sales_id, discount,
    CASE WHEN discount > 0 THEN 'HAS_DISCOUNT' ELSE 'NO_DISCOUNT' END AS discount_flag
FROM fact_sales;


/* C6  [Beginner | IF()]
   Finance wants large transactions highlighted in the daily feed. Flag each
   sale as 'High' when total_amount is 3000 or more, otherwise 'Normal',
   using IF(). */
SELECT sales_id, total_amount,
    IF(total_amount >= 3000, 'High', 'Normal') AS value_flag
FROM fact_sales;


/* C7  [Beginner | simple CASE]
   Marketing classifies brands into tiers: BrandA and BrandB are 'Premium',
   and every other brand is 'Standard'. Return each product with its brand
   tier. */
SELECT product_id, brand,
    CASE brand
        WHEN 'BrandA' THEN 'Premium'
        WHEN 'BrandB' THEN 'Premium'
        ELSE 'Standard'
    END AS brand_tier
FROM dim_product;


/* C8  [Beginner | CASE WHEN ranges]
   The logistics team wants each sale bucketed by order size: a quantity_sold
   of 1 is 'Single', 2 through 10 is 'Small', and anything above 10 is 'Bulk'.
   Return the bucket for each sale. */
SELECT sales_id, quantity_sold,
    CASE
        WHEN quantity_sold = 1              THEN 'Single'
        WHEN quantity_sold BETWEEN 2 AND 10 THEN 'Small'
        ELSE 'Bulk'
    END AS qty_bucket
FROM fact_sales;


/* C9  [Beginner | CASE WHEN + IN]
   The analytics team wants each month mapped to a season for seasonal trend
   analysis: Dec/Jan/Feb = 'Winter', Mar/Apr/May = 'Spring', Jun/Jul/Aug =
   'Summer', and the rest = 'Fall'. Produce the distinct month-to-season map. */
SELECT DISTINCT month,
    CASE
        WHEN month IN (12, 1, 2)  THEN 'Winter'
        WHEN month IN (3, 4, 5)   THEN 'Spring'
        WHEN month IN (6, 7, 8)   THEN 'Summer'
        ELSE 'Fall'
    END AS season
FROM dim_date
ORDER BY month;


/* C10 [Beginner | CASE + LEFT/UPPER]
   For a simple A/B mailing split, bucket customers by the first letter of
   their last_name: initials A–M go to 'Group1' and N–Z go to 'Group2'.
   Return each customer with its group. */
SELECT customer_id, last_name,
    CASE
        WHEN UPPER(LEFT(last_name, 1)) BETWEEN 'A' AND 'M' THEN 'Group1'
        ELSE 'Group2'
    END AS name_group
FROM dim_customer;


-- ====================================================================
-- NULL HANDLING: IFNULL / COALESCE / NULLIF  (C11–C15)
-- ====================================================================

/* C11 [Beginner | IFNULL]
   A downstream calculation breaks when discount is NULL. Defensively
   guarantee a numeric discount (treat NULL as 0) and use it to compute a
   net unit price (unit_price minus the cleaned discount) for each sale. */
SELECT sales_id, unit_price,
    IFNULL(discount, 0.00)              AS discount_clean,
    unit_price - IFNULL(discount, 0.00) AS net_unit_price
FROM fact_sales;


/* C12 [Intermediate | NULLIF, safe division]
   The pricing team wants each sale's discount expressed as a percentage of
   unit_price, rounded to two decimals. Make the calculation safe against a
   zero unit_price so it returns NULL instead of erroring. */
SELECT sales_id, unit_price, discount,
    ROUND(discount / NULLIF(unit_price, 0) * 100, 2) AS discount_pct
FROM fact_sales;


/* C13 [Intermediate | COALESCE]
   Customer profiles need a single display location. Return the first
   available value among city, state, and country, falling back to 'UNKNOWN'
   when all three are missing. */
SELECT customer_id,
    COALESCE(city, state, country, 'UNKNOWN') AS display_location
FROM dim_customer;


/* C14 [Intermediate | NULLIF + IF]
   The finance team treats a discount of exactly 0 as "no discount". Convert
   a 0 discount into NULL, then label each sale 'NO_DISCOUNT' when it is null
   and 'DISCOUNTED' otherwise. */
SELECT sales_id, discount,
    NULLIF(discount, 0)                                         AS discount_or_null,
    IF(NULLIF(discount, 0) IS NULL, 'NO_DISCOUNT', 'DISCOUNTED') AS discount_status
FROM fact_sales;


/* C15 [Intermediate | COALESCE chain + NULLIF]
   Build a best-contact field for each customer: prefer a non-blank phone,
   else a non-blank email, else the literal 'NO CONTACT'. Treat empty/blank
   strings as missing, not just NULLs. */
SELECT customer_id,
    COALESCE(NULLIF(TRIM(phone), ''), NULLIF(TRIM(email), ''), 'NO CONTACT') AS best_contact
FROM dim_customer;


-- ====================================================================
-- NESTED CASE / MULTI-CONDITION RULES  (C16–C20)
-- ====================================================================

/* C16 [Intermediate | nested CASE + date math]
   The loyalty team wants a tenure segment from join_date: under 1 year 'New',
   1–3 years 'Growing'; for 3–5 years and 5+ years, further split each into a
   Gold/Silver VIP band depending on whether they joined before 2022. */
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


/* C17 [Intermediate | CASE returning numeric]
   Apply a tiered shipping cost based on total_amount: orders under 500 cost
   50, orders from 500 to under 1500 cost 25, and everything else ships free.
   Return the computed shipping cost per sale. */
SELECT sales_id, total_amount,
    CASE
        WHEN total_amount < 500  THEN 50.00
        WHEN total_amount < 1500 THEN 25.00
        ELSE 0.00
    END AS shipping_cost
FROM fact_sales;


/* C18 [Advanced | nested CASE, multi-condition]
   Risk scoring: when the per-unit discount exceeds unit_price, classify the
   sale 'High' if total_amount >= 3000 else 'Medium'; otherwise classify
   'Medium' when total_amount >= 5000, and 'Low' for everything else. */
SELECT sales_id, unit_price, discount, total_amount,
    CASE
        WHEN discount > unit_price THEN
            CASE WHEN total_amount >= 3000 THEN 'High' ELSE 'Medium' END
        WHEN total_amount >= 5000 THEN 'Medium'
        ELSE 'Low'
    END AS risk_level
FROM fact_sales;


/* C19 [Advanced | CASE returning a numeric rate]
   Loyalty points accrue at a tiered rate on total_amount: 5% at 5000+, 3%
   from 2000 to 4999.99, 1% from 500 to 1999.99, and 0% below 500. Return the
   computed points (rounded to 2 decimals) per sale. */
SELECT sales_id, total_amount,
    ROUND(total_amount * CASE
        WHEN total_amount >= 5000 THEN 0.05
        WHEN total_amount >= 2000 THEN 0.03
        WHEN total_amount >= 500  THEN 0.01
        ELSE 0.00
    END, 2) AS loyalty_points
FROM fact_sales;


/* C20 [Intermediate | nested CASE + NULLIF]
   Derive a discount band from the discount-as-%-of-unit_price: 'UNKNOWN' when
   the percentage can't be computed, 'None' at exactly 0%, 'Low' below 10%,
   'Medium' below 30%, and 'High' otherwise. Guard against zero price. */
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


-- ====================================================================
-- CATEGORY / STATUS DERIVATION  (C21–C30)
-- ====================================================================

/* C21 [Intermediate | simple CASE on derived value]
   Segment customers by email provider. Extract the domain (after the @) and
   map 'example.net' -> 'Personal-Net', 'example.org' -> 'Personal-Org',
   'example.com' -> 'Personal-Com', and anything else -> 'Other'. */
SELECT customer_id, email,
    SUBSTRING_INDEX(email, '@', -1) AS email_domain,
    CASE LOWER(SUBSTRING_INDEX(email, '@', -1))
        WHEN 'example.net' THEN 'Personal-Net'
        WHEN 'example.org' THEN 'Personal-Org'
        WHEN 'example.com' THEN 'Personal-Com'
        ELSE 'Other'
    END AS provider_segment
FROM dim_customer;


/* C22 [Intermediate | CASE + date functions]
   Classify each product's life stage from launch_date relative to today:
   future date 'Pre-Launch', under 12 months 'New', under 3 years
   'Established', under 5 years 'Mature', and 5+ years 'Legacy'. */
SELECT product_id, launch_date,
    TIMESTAMPDIFF(YEAR, launch_date, CURDATE()) AS age_years,
    CASE
        WHEN launch_date > CURDATE()                           THEN 'Pre-Launch'
        WHEN TIMESTAMPDIFF(MONTH, launch_date, CURDATE()) < 12 THEN 'New'
        WHEN TIMESTAMPDIFF(YEAR,  launch_date, CURDATE()) < 3  THEN 'Established'
        WHEN TIMESTAMPDIFF(YEAR,  launch_date, CURDATE()) < 5  THEN 'Mature'
        ELSE 'Legacy'
    END AS life_stage
FROM dim_product;


/* C23 [Intermediate | CASE + IN]
   The BI team wants stores rolled up into super-regions: North and East form
   'NE-Zone', South and West form 'SW-Zone', and anything else is 'Central'.
   Return each store with its super-region. */
SELECT store_id, region,
    CASE
        WHEN region IN ('North', 'East') THEN 'NE-Zone'
        WHEN region IN ('South', 'West') THEN 'SW-Zone'
        ELSE 'Central'
    END AS super_region
FROM dim_store;


/* C24 [Intermediate | CASE + IN]
   Standardize the country field against a known list (United Kingdom, United
   States, Singapore, Switzerland, Egypt): keep the value if it is in the
   list, otherwise replace it with 'OTHER'. */
SELECT customer_id, country,
    CASE
        WHEN country IN ('United Kingdom', 'United States', 'Singapore', 'Switzerland', 'Egypt')
            THEN country
        ELSE 'OTHER'
    END AS country_std
FROM dim_customer;


/* C25 [Intermediate | CASE + GROUP BY]
   Bucket each sale by revenue size — Micro (<500), Small (<1500), Medium
   (<3500), Large (>=3500) — then report the number of sales and total
   revenue per bucket, ordered from Micro to Large. */
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


/* C26 [Advanced | CASE + aggregation + LEFT JOIN]
   Segment customers by their lifetime revenue: Platinum (>=50000), Gold
   (>=20000), Silver (>=5000), Bronze (>0), and 'No-Purchase' when they have
   never bought. Include customers with no sales. */
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


/* C27 [Advanced | CASE + recency]
   Build a lifecycle status from each customer's most recent order date:
   'Never-Purchased' if none; otherwise 'Active' (<=90 days), 'At-Risk'
   (<=180), 'Dormant' (<=365), and 'Churned' beyond that. */
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


/* C28 [Advanced | CASE + COUNT + LEFT JOIN]
   Assign a frequency tier from each customer's order count: 'Gold' for 10 or
   more orders, 'Silver' for 3–9, 'Bronze' for 1–2, and 'Inactive' for none.
   Include customers who have never ordered. */
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


/* C29 [Intermediate | CASE comparing to an aggregate]
   The merchandising team wants to spot premium positioning. Flag each product
   as 'Above-Avg' when its unit_price exceeds the average price of its own
   category, otherwise 'At-or-Below-Avg'. */
WITH cat_avg AS (
    SELECT category, AVG(unit_price) AS avg_price FROM dim_product GROUP BY category
)
SELECT p.product_id, p.category, p.unit_price, ROUND(ca.avg_price, 2) AS category_avg,
    CASE WHEN p.unit_price > ca.avg_price THEN 'Above-Avg' ELSE 'At-or-Below-Avg' END AS positioning
FROM dim_product p
JOIN cat_avg ca ON p.category = ca.category;


/* C30 [Advanced | CASE + NULLIF + LEFT JOIN]
   Classify each product's margin health from its effective discount % (total
   discount / gross revenue): 'No-Sales' when it never sold, 'Healthy' below
   5%, 'Watch' from 5–15%, and 'Eroded' above 15%. */
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
        WHEN ps.gross_revenue IS NULL                                   THEN 'No-Sales'
        WHEN 100 * ps.total_discount / NULLIF(ps.gross_revenue, 0) < 5   THEN 'Healthy'
        WHEN 100 * ps.total_discount / NULLIF(ps.gross_revenue, 0) <= 15 THEN 'Watch'
        ELSE 'Eroded'
    END AS margin_band
FROM dim_product p
LEFT JOIN prod_sales ps ON p.product_key = ps.product_key;


-- ====================================================================
-- CONDITIONAL AGGREGATION (MANUAL PIVOTS / CROSS-TABS)  (C31–C38)
-- ====================================================================

/* C31 [Intermediate | SUM(CASE WHEN)]
   Leadership wants a revenue pivot per region with category columns. For each
   store region, produce separate revenue totals for Electronics, Clothing,
   and Books, plus the overall total, sorted by total revenue. */
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


/* C32 [Intermediate | SUM(CASE WHEN)]
   Operations wants to compare weekend vs weekday trading per region. For each
   region, count weekend sales and weekday sales in separate columns, plus the
   overall count. */
SELECT s.region,
    SUM(CASE WHEN d.is_weekend = 1 THEN 1 ELSE 0 END) AS weekend_sales,
    SUM(CASE WHEN d.is_weekend = 0 THEN 1 ELSE 0 END) AS weekday_sales,
    COUNT(*) AS total_sales
FROM fact_sales f
JOIN dim_date  d ON f.date_key  = d.date_key
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.region;


/* C33 [Intermediate | SUM(CASE WHEN)]
   Marketing wants a gender revenue split by product category. For each
   category, show revenue from male customers and from female customers in
   side-by-side columns, plus the category total. */
SELECT p.category,
    ROUND(SUM(CASE WHEN c.gender = 'M' THEN f.total_amount ELSE 0 END), 2) AS male_rev,
    ROUND(SUM(CASE WHEN c.gender = 'F' THEN f.total_amount ELSE 0 END), 2) AS female_rev,
    ROUND(SUM(f.total_amount), 2) AS total_rev
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product  p ON f.product_key  = p.product_key
GROUP BY p.category;


/* C34 [Intermediate | SUM(CASE WHEN)]
   For each store, report total revenue alongside the revenue that came only
   from discounted lines (discount > 0), so the team can see how much of each
   store's sales were on promotion. */
SELECT s.store_id, s.store_name,
    ROUND(SUM(f.total_amount), 2) AS total_rev,
    ROUND(SUM(CASE WHEN f.discount > 0 THEN f.total_amount ELSE 0 END), 2) AS discounted_rev
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.store_id, s.store_name;


/* C35 [Advanced | SUM(CASE WHEN) cross-tab]
   Build a region-by-quarter cross-tab: one row per region with four columns
   (q1–q4) holding the count of sales in each quarter. */
SELECT s.region,
    SUM(CASE WHEN d.quarter = 1 THEN 1 ELSE 0 END) AS q1,
    SUM(CASE WHEN d.quarter = 2 THEN 1 ELSE 0 END) AS q2,
    SUM(CASE WHEN d.quarter = 3 THEN 1 ELSE 0 END) AS q3,
    SUM(CASE WHEN d.quarter = 4 THEN 1 ELSE 0 END) AS q4
FROM fact_sales f
JOIN dim_date  d ON f.date_key  = d.date_key
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.region;


/* C36 [Intermediate | conditional SUM]
   The finance team wants the total discount value (discount × quantity_sold)
   given specifically on Electronics products, shown next to the total
   discount across all categories for comparison. */
SELECT
    ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN f.discount * f.quantity_sold ELSE 0 END), 2)
        AS electronics_discount,
    ROUND(SUM(f.discount * f.quantity_sold), 2) AS all_discount
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key;


/* C37 [Advanced | conditional SUM + NULLIF]
   For each product category, compute the percentage of revenue that came from
   'Bulk' orders (quantity_sold > 10). Guard against categories with zero
   revenue. */
SELECT p.category,
    ROUND(100 * SUM(CASE WHEN f.quantity_sold > 10 THEN f.total_amount ELSE 0 END)
              / NULLIF(SUM(f.total_amount), 0), 2) AS bulk_revenue_pct
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category;


/* C38 [Advanced | window + SUM(CASE WHEN)]
   Build a monthly cohort matrix: for each year-month, count how many order
   lines were a customer's very first order versus a returning order, so the
   team can track new vs repeat activity over time. */
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


-- ====================================================================
-- DATA-QUALITY RULES  (C39–C46)
-- ====================================================================

/* C39 [Intermediate | CASE priority rules]
   Build a row-level data-quality flag for sales, evaluated in priority order:
   'OVER_DISCOUNT' when discount exceeds unit_price, else 'BAD_AMOUNT' when
   total_amount is 0 or negative, else 'OK'. */
SELECT sales_id, unit_price, discount, total_amount,
    CASE
        WHEN discount > unit_price THEN 'OVER_DISCOUNT'
        WHEN total_amount <= 0     THEN 'BAD_AMOUNT'
        ELSE 'OK'
    END AS dq_flag
FROM fact_sales;


/* C40 [Intermediate | CASE with OR]
   Flag invalid sales records: mark a row 'INVALID' when quantity_sold <= 0 OR
   unit_price <= 0 OR discount < 0, otherwise 'VALID'. */
SELECT sales_id, quantity_sold, unit_price, discount,
    CASE
        WHEN quantity_sold <= 0 OR unit_price <= 0 OR discount < 0 THEN 'INVALID'
        ELSE 'VALID'
    END AS record_status
FROM fact_sales;


/* C41 [Advanced | conditional aggregation scorecard]
   Produce a completeness scorecard for dim_customer: total rows, plus counts
   of rows with a well-formed first_name, email, phone (10–15 digits), and a
   valid (non-future) join_date, and the overall % of fully-valid records. */
SELECT COUNT(*) AS total_rows,
    SUM(CASE WHEN first_name IS NOT NULL AND TRIM(first_name) <> '' THEN 1 ELSE 0 END) AS first_name_ok,
    SUM(CASE WHEN email LIKE '%@%.%'                               THEN 1 ELSE 0 END) AS email_ok,
    SUM(CASE WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) BETWEEN 10 AND 15 THEN 1 ELSE 0 END) AS phone_ok,
    SUM(CASE WHEN join_date IS NOT NULL AND join_date <= CURDATE() THEN 1 ELSE 0 END) AS join_date_ok,
    ROUND(100 * SUM(CASE WHEN email LIKE '%@%.%'
                          AND LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) BETWEEN 10 AND 15
                          AND join_date <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_fully_valid
FROM dim_customer;


/* C42 [Intermediate | CASE + LIKE]
   Add a structural email-validity flag: mark 'VALID' when the email matches a
   basic something@something.something pattern, otherwise 'INVALID'. */
SELECT customer_id, email,
    CASE WHEN email LIKE '%_@_%._%' THEN 'VALID' ELSE 'INVALID' END AS email_valid
FROM dim_customer;


/* C43 [Intermediate | CASE + REGEXP/LENGTH]
   Classify phone quality by digit count (after stripping non-digits):
   exactly 10 digits is 'VALID_10', 11–15 digits is 'CHECK_INTL', and anything
   else is 'INVALID'. */
SELECT customer_id, phone,
    LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) AS digit_count,
    CASE
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) = 10 THEN 'VALID_10'
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) BETWEEN 11 AND 15 THEN 'CHECK_INTL'
        ELSE 'INVALID'
    END AS phone_quality
FROM dim_customer;


/* C44 [Advanced | CASE date check]
   Surface a data-quality issue: flag any customer whose join_date is in the
   future (greater than today) as 'FUTURE_JOIN_DATE', otherwise 'OK'. */
SELECT customer_id, join_date,
    CASE WHEN join_date > CURDATE() THEN 'FUTURE_JOIN_DATE' ELSE 'OK' END AS join_dq_flag
FROM dim_customer;


/* C45 [Advanced | CASE + tolerance + GROUP BY]
   Reconcile total_amount against quantity_sold × (unit_price − discount). Bucket
   each row as 'MATCH' (exact), 'ROUNDING' (within 0.01), or 'MISMATCH', and
   report the row count and min/max difference per bucket. */
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


/* C46 [Advanced | CASE + LEFT JOIN referential check]
   Verify referential price integrity: compare each fact_sales unit_price to
   the dim_product unit_price and label 'MISSING_PRODUCT', 'MATCH', or
   'PRICE_DRIFT'. */
SELECT f.sales_id, f.unit_price AS fact_price, p.unit_price AS dim_price,
    CASE
        WHEN p.product_key IS NULL       THEN 'MISSING_PRODUCT'
        WHEN f.unit_price = p.unit_price THEN 'MATCH'
        ELSE 'PRICE_DRIFT'
    END AS price_check
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_key = p.product_key;


-- ====================================================================
-- COMPOSITE / PRODUCTION-STYLE  (C47–C50)
-- ====================================================================

/* C47 [Advanced | CONCAT of multiple CASEs]
   Build a single composite status string per customer in the form
   tier|activity|risk — e.g. revenue tier (HIGH/MID/LOW), activity
   (ACTIVE/INACTIVE by recency), and frequency (FREQUENT/OCCASIONAL). */
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


/* C48 [Advanced | nested CASE on computed margin]
   Derive a per-sale profitability flag assuming cost is 60% of unit_price.
   Compute net margin per unit = (unit_price − discount) − cost, then label
   'LOSS' (<0), 'THIN' (below 10% of price), or 'HEALTHY'. */
SELECT sales_id, unit_price, discount,
    ROUND((unit_price - discount) - (unit_price * 0.60), 2) AS net_margin_per_unit,
    CASE
        WHEN (unit_price - discount) - (unit_price * 0.60) < 0 THEN 'LOSS'
        WHEN (unit_price - discount) - (unit_price * 0.60) < (unit_price * 0.10) THEN 'THIN'
        ELSE 'HEALTHY'
    END AS profitability_flag
FROM fact_sales;


/* C49 [Advanced | CASE bucketing]
   Bucket every product into 100-wide price bands labelled '000-099',
   '100-199', '200-299', '300-499', '500-799', and '800+' based on unit_price. */
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


/* C50 [Advanced | multi-CASE customer 360]
   Build a single customer_360 row per customer combining: order count and
   revenue, a value tier (Platinum/Gold/Silver/Bronze/No-Purchase), a
   lifecycle status by recency, and a data-quality flag — all in one SELECT. */
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
        WHEN a.last_order IS NULL                    THEN 'Never'
        WHEN DATEDIFF(CURDATE(), a.last_order) <= 90  THEN 'Active'
        WHEN DATEDIFF(CURDATE(), a.last_order) <= 365 THEN 'Lapsing'
        ELSE 'Churned'
    END AS lifecycle_status,
    CASE
        WHEN c.join_date > CURDATE()    THEN 'FUTURE_JOIN_DATE'
        WHEN a.last_order < c.join_date THEN 'ORDER_BEFORE_JOIN'
        WHEN a.orders IS NULL           THEN 'NO_ACTIVITY'
        ELSE 'OK'
    END AS dq_flag
FROM dim_customer c
LEFT JOIN agg a ON c.customer_key = a.customer_key
ORDER BY revenue DESC;
