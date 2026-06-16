-- =====================================================================
-- DATA TRANSFORMATIONS - 50 DATA ENGINEER INTERVIEW SOLUTIONS
-- Schema: Real_Sales (star schema) -- see Insert_script.sql for full DDL/data
-- Questions in: Transformations_Questions.sql   |   Dialect: MySQL 8.0+
-- =====================================================================

USE Real_Sales;

-- ===== STRING (T1 - T20) ============================================

-- T1. Proper-case name + email domain
SELECT customer_id,
    CONCAT(
        UPPER(LEFT(TRIM(first_name), 1)), LOWER(SUBSTRING(TRIM(first_name), 2)), ' ',
        UPPER(LEFT(TRIM(last_name),  1)), LOWER(SUBSTRING(TRIM(last_name),  2))
    )                                      AS clean_name,
    LOWER(SUBSTRING_INDEX(email, '@', -1)) AS email_domain
FROM dim_customer;


-- T2. Uppercase country and city
SELECT customer_id,
    UPPER(TRIM(country)) AS country_upper,
    UPPER(TRIM(city))    AS city_upper
FROM dim_customer;


-- T3. Canonical lowercase email
SELECT customer_id, email,
    LOWER(TRIM(email)) AS email_canonical
FROM dim_customer;


-- T4. Customer initials
SELECT customer_id, first_name, last_name,
    CONCAT(UPPER(LEFT(first_name, 1)), UPPER(LEFT(last_name, 1))) AS initials
FROM dim_customer;


-- T5. "Last, First" name
SELECT customer_id,
    CONCAT(last_name, ', ', first_name) AS sortable_name
FROM dim_customer;


-- T6. Mailing address via CONCAT_WS (skips NULLs)
SELECT customer_id,
    CONCAT_WS(', ', city, state, country) AS mailing_address
FROM dim_customer;


-- T7. Phone digits-only + digit count
SELECT customer_id, phone,
    REGEXP_REPLACE(phone, '[^0-9]', '')         AS phone_digits,
    LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) AS digit_count
FROM dim_customer;


-- T8. Composite key REGION|CATEGORY|YYYYMM
SELECT f.sales_id,
    CONCAT_WS('|',
        UPPER(s.region),
        UPPER(REPLACE(p.category, ' ', '_')),
        DATE_FORMAT(d.date, '%Y%m')
    ) AS report_grain_key
FROM fact_sales f
JOIN dim_store   s ON f.store_key   = s.store_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date    d ON f.date_key    = d.date_key;


-- T9. Email local / domain / TLD
SELECT customer_id, email,
    SUBSTRING_INDEX(email, '@', 1)                       AS email_local,
    SUBSTRING_INDEX(email, '@', -1)                      AS email_domain,
    SUBSTRING_INDEX(email, '.', -1)                      AS email_tld
FROM dim_customer;


-- T10. Strip 'CUST' prefix -> numeric id
SELECT customer_id,
    CAST(REGEXP_REPLACE(customer_id, '[^0-9]', '') AS UNSIGNED) AS customer_num
FROM dim_customer;


-- T11. Strip PROD/STORE prefixes -> numeric ids (per table, stacked with UNION ALL)
SELECT 'product' AS entity, product_id AS business_id,
    CAST(REGEXP_REPLACE(product_id, '[^0-9]', '') AS UNSIGNED) AS numeric_id
FROM dim_product
UNION ALL
SELECT 'store' AS entity, store_id,
    CAST(REGEXP_REPLACE(store_id, '[^0-9]', '') AS UNSIGNED)
FROM dim_store;


-- T12. Clean category
SELECT DISTINCT category,
    REPLACE(REPLACE(category, ' & ', ' and '), ' ', '_') AS category_clean
FROM dim_product;


-- T13. URL slug from product_name
SELECT product_id, product_name,
    LOWER(REPLACE(TRIM(product_name), ' ', '-')) AS product_slug
FROM dim_product;


-- T14. Country code = first 3 letters, upper, right-padded
SELECT DISTINCT country,
    RPAD(UPPER(LEFT(country, 3)), 3, 'X') AS country_code
FROM dim_customer;


-- T15. LENGTH vs CHAR_LENGTH
SELECT customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    LENGTH(CONCAT(first_name, ' ', last_name))      AS byte_length,
    CHAR_LENGTH(CONCAT(first_name, ' ', last_name)) AS char_length
FROM dim_customer;


-- T16. Keep only alphabetic chars in city
SELECT customer_id, city,
    REGEXP_REPLACE(city, '[^A-Za-z]', '') AS city_alpha
FROM dim_customer;


-- T17. Mask email for PII
SELECT customer_id, email,
    CONCAT(LEFT(email, 1), '***@', SUBSTRING_INDEX(email, '@', -1)) AS email_masked
FROM dim_customer;


-- T18. Mask phone (last 4 digits)
SELECT customer_id, phone,
    CONCAT(
        REPEAT('*', GREATEST(LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) - 4, 0)),
        RIGHT(REGEXP_REPLACE(phone, '[^0-9]', ''), 4)
    ) AS phone_masked
FROM dim_customer;


-- T19. Area code + subscriber number
SELECT customer_id,
    LEFT(REGEXP_REPLACE(phone, '[^0-9]', ''), 3)       AS area_code,
    SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', ''), 4)  AS subscriber_number
FROM dim_customer;


-- T20. Username = first initial + last name, letters only, lowercase
SELECT customer_id,
    LOWER(REGEXP_REPLACE(CONCAT(LEFT(first_name, 1), last_name), '[^A-Za-z]', '')) AS username
FROM dim_customer;


-- ===== NUMERIC (T21 - T35) ==========================================

-- T21. ROUND / CEILING / FLOOR
SELECT sales_id, total_amount,
    ROUND(total_amount, 2) AS amount_2dp,
    CEILING(total_amount)  AS amount_ceiling,
    FLOOR(total_amount)    AS amount_floor
FROM fact_sales;


-- T22. Gross revenue
SELECT sales_id, quantity_sold, unit_price,
    ROUND(quantity_sold * unit_price, 2) AS gross_revenue
FROM fact_sales;


-- T23. Net revenue
SELECT sales_id,
    ROUND(quantity_sold * (unit_price - discount), 2) AS net_revenue
FROM fact_sales;


-- T24. Discount % of unit price (safe)
SELECT sales_id, unit_price, discount,
    ROUND(discount / NULLIF(unit_price, 0) * 100, 2) AS discount_pct
FROM fact_sales;


-- T25. ABS reconciliation diff
SELECT sales_id, total_amount,
    ROUND(quantity_sold * (unit_price - discount), 2)                      AS expected_amount,
    ABS(ROUND(total_amount - quantity_sold * (unit_price - discount), 2))  AS abs_diff
FROM fact_sales;


-- T26. Hash partition into 8 buckets
SELECT sales_id,
    MOD(sales_id, 8) AS partition_bucket
FROM fact_sales;


-- T27. Even/odd customer_key flag
SELECT customer_key, customer_id,
    IF(MOD(customer_key, 2) = 0, 'Even', 'Odd') AS parity
FROM dim_customer;


-- T28. Round revenue to nearest 100 and 10
SELECT sales_id, total_amount,
    ROUND(total_amount, -2) AS nearest_100,
    ROUND(total_amount, -1) AS nearest_10
FROM fact_sales;


-- T29. Psychological .99 pricing
SELECT product_id, unit_price,
    FLOOR(unit_price) + 0.99 AS charm_price
FROM dim_product;


-- T30. Net margin per unit (cost = 60% of price)
SELECT sales_id, unit_price, discount,
    ROUND((unit_price - discount) - (unit_price * 0.60), 2) AS net_margin_per_unit
FROM fact_sales;


-- T31. Tax at 8% rounded UP
SELECT sales_id, total_amount,
    CEILING(total_amount * 0.08) AS tax_due
FROM fact_sales;


-- T32. Average order value per customer
SELECT customer_key,
    COUNT(*)                          AS orders,
    ROUND(AVG(total_amount), 2)       AS avg_order_value
FROM fact_sales
GROUP BY customer_key;


-- T33. Effective revenue per unit after discount
SELECT sales_id, total_amount, quantity_sold,
    ROUND(total_amount / NULLIF(quantity_sold, 0), 2) AS revenue_per_unit
FROM fact_sales;


-- T34. Each product's revenue as % of grand total (window ratio)
WITH prod_rev AS (
    SELECT product_key, SUM(total_amount) AS revenue
    FROM fact_sales GROUP BY product_key
)
SELECT p.product_id,
    ROUND(pr.revenue, 2) AS revenue,
    ROUND(100 * pr.revenue / SUM(pr.revenue) OVER (), 4) AS pct_of_total
FROM prod_rev pr
JOIN dim_product p ON pr.product_key = p.product_key
ORDER BY pct_of_total DESC;


-- T35. Price-band lower bound
SELECT product_id, unit_price,
    FLOOR(unit_price / 100) * 100 AS price_band_floor
FROM dim_product;


-- ===== DATE (T36 - T47) =============================================

-- T36. Extract year/month/quarter/day from sale date
SELECT f.sales_id, d.date,
    YEAR(d.date)    AS yr,
    MONTH(d.date)   AS mo,
    QUARTER(d.date) AS qtr,
    DAY(d.date)     AS dy
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- T37. Tenure months + bucket
SELECT customer_id, join_date,
    TIMESTAMPDIFF(MONTH, join_date, CURDATE()) AS tenure_months,
    CASE
        WHEN TIMESTAMPDIFF(MONTH, join_date, CURDATE()) < 6  THEN '0-6m'
        WHEN TIMESTAMPDIFF(MONTH, join_date, CURDATE()) < 12 THEN '6-12m'
        WHEN TIMESTAMPDIFF(MONTH, join_date, CURDATE()) < 24 THEN '1-2y'
        ELSE '2y+'
    END AS tenure_bucket
FROM dim_customer;


-- T38. Fiscal quarter (FY starts April) + calendar period
SELECT f.sales_id, d.date,
    CASE
        WHEN MONTH(d.date) BETWEEN 4 AND 6   THEN 'FQ1'
        WHEN MONTH(d.date) BETWEEN 7 AND 9   THEN 'FQ2'
        WHEN MONTH(d.date) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END                                         AS fiscal_quarter,
    CONCAT(YEAR(d.date), '-Q', QUARTER(d.date)) AS calendar_period
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- T39. Days since product launch
SELECT product_id, launch_date,
    DATEDIFF(CURDATE(), launch_date) AS days_since_launch
FROM dim_product;


-- T40. DATE_FORMAT showcase
SELECT f.sales_id, d.date,
    DATE_FORMAT(d.date, '%Y-%m')   AS ym,
    DATE_FORMAT(d.date, '%M %Y')   AS month_year,
    DATE_FORMAT(d.date, '%d-%b-%Y') AS dmy
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- T41. Day name + weekend flag
SELECT f.sales_id, d.date,
    DAYNAME(d.date)                              AS day_name,
    IF(d.is_weekend = 1, 'Weekend', 'Weekday')   AS day_type
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- T42. Week of year
SELECT f.sales_id, d.date,
    WEEK(d.date, 3)     AS iso_week,
    WEEKOFYEAR(d.date)  AS week_of_year
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- T43. Product age in whole years
SELECT product_id, launch_date,
    TIMESTAMPDIFF(YEAR, launch_date, CURDATE()) AS age_years
FROM dim_product;


-- T44. Days from join_date to first order
WITH first_order AS (
    SELECT f.customer_key, MIN(d.date) AS first_order_date
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY f.customer_key
)
SELECT c.customer_id, c.join_date, fo.first_order_date,
    DATEDIFF(fo.first_order_date, c.join_date) AS days_to_first_order
FROM dim_customer c
LEFT JOIN first_order fo ON c.customer_key = fo.customer_key;


-- T45. Fiscal-year label (April start) + reporting period
SELECT f.sales_id, d.date,
    CONCAT('FY', IF(MONTH(d.date) >= 4, YEAR(d.date) + 1, YEAR(d.date))) AS fiscal_year,
    DATE_FORMAT(d.date, '%Y-%m') AS report_period
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- T46. Month-end and first-of-month
SELECT f.sales_id, d.date,
    DATE_FORMAT(d.date, '%Y-%m-01') AS first_of_month,
    LAST_DAY(d.date)                AS month_end
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- T47. Customer cohort label (join year-month)
SELECT customer_id, join_date,
    DATE_FORMAT(join_date, '%Y-%m') AS cohort_month
FROM dim_customer;


-- ===== ETL PIPELINES (T48 - T50) ====================================

-- T48. End-to-end customer reporting table (Silver -> Gold)
WITH customer_revenue AS (
    SELECT f.customer_key,
        COUNT(*)                      AS order_count,
        ROUND(SUM(f.total_amount), 2) AS lifetime_revenue,
        MAX(d.date)                   AS last_order_date
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY f.customer_key
),
enriched AS (
    SELECT c.customer_key, c.customer_id,
        CONCAT(
            UPPER(LEFT(TRIM(c.first_name), 1)), LOWER(SUBSTRING(TRIM(c.first_name), 2)), ' ',
            UPPER(LEFT(TRIM(c.last_name),  1)), LOWER(SUBSTRING(TRIM(c.last_name),  2))
        )                                            AS clean_name,
        LOWER(SUBSTRING_INDEX(c.email, '@', -1))     AS email_domain,
        IFNULL(r.order_count, 0)                     AS order_count,
        IFNULL(r.lifetime_revenue, 0)                AS lifetime_revenue,
        TIMESTAMPDIFF(MONTH, c.join_date, CURDATE()) AS tenure_months,
        r.last_order_date, c.join_date
    FROM dim_customer c
    LEFT JOIN customer_revenue r ON c.customer_key = r.customer_key
)
SELECT customer_id, clean_name, email_domain, order_count, lifetime_revenue,
    CASE
        WHEN lifetime_revenue >= 50000 THEN 'Platinum'
        WHEN lifetime_revenue >= 20000 THEN 'Gold'
        WHEN lifetime_revenue >= 5000  THEN 'Silver'
        WHEN lifetime_revenue > 0      THEN 'Bronze'
        ELSE 'No-Purchase'
    END AS customer_category,
    CASE
        WHEN tenure_months < 6  THEN '0-6m'
        WHEN tenure_months < 12 THEN '6-12m'
        WHEN tenure_months < 24 THEN '1-2y'
        ELSE '2y+'
    END AS tenure_bucket,
    CASE
        WHEN lifetime_revenue >= 20000 THEN 'High-Value'
        WHEN lifetime_revenue >= 5000  THEN 'Mid-Value'
        ELSE 'Low-Value'
    END AS revenue_band,
    CASE
        WHEN order_count = 0             THEN 'NO_ACTIVITY'
        WHEN join_date > CURDATE()       THEN 'FUTURE_JOIN_DATE'
        WHEN last_order_date < join_date THEN 'ORDER_BEFORE_JOIN'
        ELSE 'OK'
    END AS dq_flag
FROM enriched
ORDER BY lifetime_revenue DESC;


-- T49. Monthly sales reporting layer (pivot + MoM growth)
WITH monthly AS (
    SELECT DATE_FORMAT(d.date, '%Y-%m') AS ym,
        ROUND(SUM(f.total_amount), 2) AS total_rev,
        ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN f.total_amount ELSE 0 END), 2) AS electronics_rev,
        ROUND(SUM(CASE WHEN p.category = 'Clothing'    THEN f.total_amount ELSE 0 END), 2) AS clothing_rev,
        ROUND(SUM(CASE WHEN p.category = 'Books'       THEN f.total_amount ELSE 0 END), 2) AS books_rev
    FROM fact_sales f
    JOIN dim_date    d ON f.date_key    = d.date_key
    JOIN dim_product p ON f.product_key = p.product_key
    GROUP BY DATE_FORMAT(d.date, '%Y-%m')
)
SELECT ym, total_rev, electronics_rev, clothing_rev, books_rev,
    LAG(total_rev) OVER (ORDER BY ym) AS prev_month_rev,
    ROUND(100 * (total_rev - LAG(total_rev) OVER (ORDER BY ym))
              / NULLIF(LAG(total_rev) OVER (ORDER BY ym), 0), 2) AS mom_growth_pct,
    CASE
        WHEN LAG(total_rev) OVER (ORDER BY ym) IS NULL     THEN 'BASELINE'
        WHEN total_rev > LAG(total_rev) OVER (ORDER BY ym) THEN 'UP'
        WHEN total_rev < LAG(total_rev) OVER (ORDER BY ym) THEN 'DOWN'
        ELSE 'FLAT'
    END AS trend
FROM monthly
ORDER BY ym;


-- T50. Product launch-cohort table (clean attributes + aggregates)
WITH prod_sales AS (
    SELECT product_key,
        SUM(quantity_sold)          AS units_sold,
        ROUND(SUM(total_amount), 2) AS revenue
    FROM fact_sales GROUP BY product_key
)
SELECT
    YEAR(p.launch_date)                                       AS launch_cohort_year,
    p.product_id,
    LOWER(REPLACE(TRIM(p.product_name), ' ', '-'))            AS product_slug,
    REPLACE(REPLACE(p.category, ' & ', ' and '), ' ', '_')    AS category_clean,
    IFNULL(ps.units_sold, 0)                                  AS units_sold,
    IFNULL(ps.revenue, 0)                                     AS revenue,
    ROUND(IFNULL(ps.revenue, 0) / NULLIF(ps.units_sold, 0), 2) AS avg_selling_price
FROM dim_product p
LEFT JOIN prod_sales ps ON p.product_key = ps.product_key
ORDER BY launch_cohort_year, revenue DESC;
