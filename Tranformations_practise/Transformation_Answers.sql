/* ============================================================================
   SQL TRANSFORMATION PRACTICE — QUESTIONS WITH ANSWERS

s

   SCHEMA QUICK REFERENCE
   ----------------------------------------------------------------------------
   dim_date      date_key (INT e.g. 20250405), date, day, month, month_name,
                  quarter, year, is_weekend (0/1)
   dim_customer  customer_key, customer_id (CUST0001), first_name, last_name,
                  gender (M/F), email, phone, country, state, city, join_date
   dim_product   product_key, product_id (PROD0001), product_name, category,
                  brand (BrandA-BrandE), unit_price, launch_date
   dim_store     store_key, store_id (STORE001), store_name, region, country, city
   fact_sales    sales_id, date_key, customer_key, product_key, store_key,
                  quantity_sold, unit_price, discount, total_amount
   ============================================================================ */

USE Real_Sales;


/* ===========================================================================
   BEGINNER (1–20)
   =========================================================================== */

/* Q1  [CONCAT]
   The CRM team wants a single clean "display name" column for every customer
   record so it can be shown directly on dashboards. Combine each customer's
   first_name and last_name into one full-name field separated by a single space. */
SELECT customer_key,
       CONCAT(first_name, ' ', last_name) AS full_name
FROM dim_customer;


/* Q2  [CASE WHEN]
   The analytics layer stores gender as a single character (M/F), but the
   reporting team needs readable labels for their charts. Write a query that
   outputs 'Male', 'Female', or 'Unknown' for any other or blank value. */
SELECT customer_key, gender,
       CASE gender
            WHEN 'M' THEN 'Male'
            WHEN 'F' THEN 'Female'
            ELSE 'Unknown'
       END AS gender_label
FROM dim_customer;


/* Q3  [IF]
   Finance classifies every sale as "High Value" when its total_amount is 1000
   or more, and "Standard" otherwise. Produce a column on fact_sales that tags
   each transaction accordingly for the daily sales summary. */
SELECT sales_id, total_amount,
       IF(total_amount >= 1000, 'High Value', 'Standard') AS value_segment
FROM fact_sales;


/* Q4  [CONCAT_WS, NULL-safe]
   After upstream ingestion, some customer records may be missing either a
   first_name or a last_name. Build a robust full-name column that still
   produces a clean result when one of the name parts is NULL. */
SELECT customer_key,
       CONCAT_WS(' ', first_name, last_name) AS full_name
FROM dim_customer;


/* Q5  [LOWER]
   The email marketing tool treats John@X.com and john@x.com as different
   addresses, causing duplicate sends. Standardize the email column to
   lowercase so the export contains only consistent, case-folded values. */
SELECT customer_key,
       email AS original_email,
       LOWER(email) AS clean_email
FROM dim_customer;


/* Q6  [UPPER]
   The fulfilment team wants product categories printed in uppercase on
   shipping labels for better visibility on the warehouse floor. Return each
   product along with its category converted to uppercase. */
SELECT product_key, product_name,
       UPPER(category) AS category_label
FROM dim_product;


/* Q7  [TRIM]
   Some city values were loaded with leading or trailing spaces, which makes
   the same city appear as two separate buckets in group-bys. Produce a cleaned
   city column with the surrounding whitespace removed. */
SELECT customer_key,
       city AS raw_city,
       TRIM(city) AS clean_city
FROM dim_customer;


/* Q8  [LTRIM]
   A legacy feed sometimes pads the state field with leading spaces only. The
   reporting team wants those leading spaces removed while preserving any
   meaningful trailing content. Return the left-trimmed state value. */
SELECT customer_key,
       state AS raw_state,
       LTRIM(state) AS left_trimmed_state
FROM dim_customer;


/* Q9  [LEFT]
   The product team wants a quick "short code" for each product, built from the
   first 4 characters of product_id (e.g. PROD from PROD0001). Generate this
   prefix for use in a compact UI badge. */
SELECT product_key, product_id,
       LEFT(product_id, 4) AS id_prefix
FROM dim_product;


/* Q10 [RIGHT]
   Operations needs only the numeric portion of customer_id — the last 4 digits
   of CUST0001 becomes 0001 — to match records against an external 4-digit
   legacy system. Extract that suffix for every customer. */
SELECT customer_key, customer_id,
       RIGHT(customer_id, 4) AS legacy_code
FROM dim_customer;


/* Q11 [LENGTH / CHAR_LENGTH]
   Data governance is auditing phone-number quality. As a first profiling step,
   report the character length of each customer's phone value so analysts can
   quickly spot abnormally short or long entries. */
SELECT customer_key, phone,
       CHAR_LENGTH(phone) AS phone_char_len,
       LENGTH(phone)      AS phone_byte_len
FROM dim_customer
ORDER BY phone_char_len;


/* Q12 [REPLACE]
   Some product_name values contain accidental double spaces, which look untidy
   in the catalog. Produce a cleaned product name where any double space is
   replaced with a single space. */
SELECT product_key, product_name,
       REPLACE(product_name, '  ', ' ') AS clean_product_name
FROM dim_product;


/* Q13 [ROUND]
   Finance is preparing an executive summary that should not show paise/cents.
   Return the total_amount of every sale rounded to the nearest whole currency
   value. */
SELECT sales_id, total_amount,
       ROUND(total_amount, 0) AS rounded_amount
FROM fact_sales;


/* Q14 [CEIL]
   For capacity planning, the warehouse team wants total_amount always rounded
   UP to the next whole number, because partial units must be provisioned as
   full units. Return each sale's amount rounded up. */
SELECT sales_id, total_amount,
       CEIL(total_amount) AS rounded_up_amount
FROM fact_sales;


/* Q15 [FLOOR]
   The discount accounting policy is conservative any discount value must be
   rounded DOWN to whole currency before it is posted to the ledger. Return
   each sale's discount rounded down. */
SELECT sales_id, discount,
       FLOOR(discount) AS floored_discount
FROM fact_sales;


/* Q16 [ABS]
   A migration audit found some price-variance values came through negative due
   to sign flips, but reconciliation only cares about the size of the gap. Show
   the absolute difference between fact_sales.unit_price and
   dim_product.unit_price for each sale. */
SELECT fs.sales_id,
       fs.unit_price AS fact_price,
       dp.unit_price AS dim_price,
       ABS(fs.unit_price - dp.unit_price) AS price_gap
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key;


/* Q17 [MOD]
   The logistics team packs products into boxes of 5 units each. For every
   sale, calculate how many leftover units remain after filling as many
   complete boxes as possible from quantity_sold. */
SELECT sales_id, quantity_sold,
       MOD(quantity_sold, 5) AS leftover_units
FROM fact_sales;


/* Q18 [CASE WHEN]
   A weekend-promotion report needs every date labelled as either 'Weekend' or
   'Weekday'. The dim_date table already stores is_weekend as 1/0; convert that
   flag into the readable label. */
SELECT date_key, date,
       CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type
FROM dim_date;


/* Q19 [CONCAT_WS]
   The reporting layer needs one human-readable address line per store,
   combining city, region, and country separated by commas, gracefully skipping
   any part that is missing without leaving dangling commas. */
SELECT store_key, store_name,
       CONCAT_WS(', ', city, region, country) AS full_address
FROM dim_store;


/* Q20 [ROUND + IF]
   The pricing team wants the catalog to show each unit_price as a clean
   two-decimal value, and also tag every product as 'Premium' when the price is
   above 500, or 'Affordable' otherwise. Produce both columns in one query. */
SELECT product_key, product_name,
       ROUND(unit_price, 2) AS display_price,
       IF(unit_price > 500, 'Premium', 'Affordable') AS price_tier
FROM dim_product;



/* ===========================================================================
   INTERMEDIATE (21–45)
   =========================================================================== */

/* Q21 [SUBSTRING, LOCATE/INSTR, SUBSTRING_INDEX]
   The deliverability team wants to analyze customers by their email provider.
   Extract the domain portion — everything after the @ symbol — from each email
   value so they can group customers by provider later. */
SELECT customer_key, email,
       SUBSTRING_INDEX(email, '@', -1)          AS domain_simple,
       SUBSTRING(email, LOCATE('@', email) + 1) AS domain_positional
FROM dim_customer;


/* Q22 [SUBSTRING_INDEX + CONCAT, masking]
   Security needs masked emails in a non-production extract so real provider
   domains are hidden. Keep only the username (the part before the @) and append
   a fixed '@masked.com' to produce a privacy-safe address. */
SELECT customer_key, email,
       CONCAT(SUBSTRING_INDEX(email, '@', 1), '@masked.com') AS masked_email
FROM dim_customer;


/* Q23 [RIGHT, CHAR_LENGTH]
   Phone numbers were ingested with inconsistent country-code noise and varying
   lengths. Treat the LAST 10 digits of every phone as the canonical national
   number, regardless of how long the stored value is. */
SELECT customer_key,
       phone AS raw_phone,
       CHAR_LENGTH(phone) AS raw_len,
       RIGHT(phone, 10)   AS national_number
FROM dim_customer;


/* Q24 [TRIM LEADING]
   A telephony vendor needs phone numbers stripped of their leading-zero
   international-prefix noise before they can be compared cleanly. As a first
   step, remove all leading zeros from each phone value. */
SELECT customer_key,
       phone AS raw_phone,
       TRIM(LEADING '0' FROM phone) AS no_leading_zeros
FROM dim_customer;


/* Q25 [INSTR/POSITION + CASE]
   The data-quality team wants to profile email structure. Report the position
   of the @ symbol in each email, and flag any record where the @ is missing
   entirely (position 0) as 'Invalid'. */
SELECT customer_key, email,
       INSTR(email, '@') AS at_position,
       CASE WHEN INSTR(email, '@') = 0 THEN 'Invalid' ELSE 'Valid' END AS email_status
FROM dim_customer;


/* Q26 [REVERSE]
   A loyalty-program prototype assigns each customer a quirky referral token
   created by reversing their customer_id. Generate that reversed token for
   every customer in the dimension. */
SELECT customer_key, customer_id,
       REVERSE(customer_id) AS referral_token
FROM dim_customer;


/* Q27 [UPPER/LOWER/LEFT/SUBSTRING/CONCAT]
   The naming standard requires names like JOHN or john to display as 'John'.
   Since MySQL has no built-in proper-case function, produce a properly cased
   first_name first letter uppercase, remaining letters lowercase. */
SELECT customer_key, first_name,
       CONCAT(UPPER(LEFT(first_name, 1)), LOWER(SUBSTRING(first_name, 2))) AS proper_first_name
FROM dim_customer;


/* Q28 [CAST + STR_TO_DATE]
   The warehouse stores dim_date.date_key as an integer like 20250405 rather
   than a real date. Convert it into an actual DATE type so the downstream team
   can perform proper date arithmetic on it. */
SELECT date_key,
       STR_TO_DATE(CAST(date_key AS CHAR), '%Y%m%d') AS converted_date
FROM dim_date;


/* Q29 [CAST / CONVERT / FORMAT]
   Finance wants total_amount written as text into a flat-file export, formatted
   as a clean fixed-precision string. Convert the decimal amount into a CHAR
   representation that always shows exactly two decimal places. */
SELECT sales_id, total_amount,
       CAST(total_amount AS CHAR)  AS amount_as_text,
       CONVERT(total_amount, CHAR) AS amount_convert,
       FORMAT(total_amount, 2)     AS amount_formatted
FROM fact_sales;


/* Q30 [DATEDIFF + CURDATE]
   The analytics team needs a customer tenure report. For each customer, compute
   how many full days have passed since their join_date as of today. */
SELECT customer_key, join_date,
       DATEDIFF(CURDATE(), join_date) AS tenure_days
FROM dim_customer;


/* Q31 [DATE_FORMAT]
   A cohort dashboard groups customers along a Month-Year axis. For each
   customer, render the join_date as a readable label such as 'Sep-2021' to be
   used as the grouping key. */
SELECT customer_key, join_date,
       DATE_FORMAT(join_date, '%b-%Y') AS join_month_year
FROM dim_customer;


/* Q32 [CASE WHEN ranges]
   The merchandising team wants each product placed into a price band 'Low' for
   prices below 200, 'Medium' for 200 through 600, and 'High' above 600. Derive
   this band from unit_price. */
SELECT product_key, product_name, unit_price,
       CASE
            WHEN unit_price < 200  THEN 'Low'
            WHEN unit_price <= 600 THEN 'Medium'
            ELSE 'High'
       END AS price_band
FROM dim_product;


/* Q33 [NULLIF, safe division]
   A reconciliation job divides total_amount by discount to compute a ratio, but
   some sales have a discount of 0, causing divide-by-zero errors. Make the
   calculation safe so zero-discount rows return NULL instead of failing. */
SELECT sales_id, total_amount, discount,
       total_amount / NULLIF(discount, 0) AS amount_to_discount_ratio
FROM fact_sales;


/* Q34 [NULLIF + IFNULL]
   After a system merge, treat any customer phone equal to the placeholder
   '0000000000' as missing convert that placeholder to a real null and then
   display it as 'Not Provided'. */
SELECT customer_key, phone,
       IFNULL(NULLIF(phone, '0000000000'), 'Not Provided') AS clean_phone
FROM dim_customer;


/* Q35 [SUM/AVG/MAX + ROUND]
   A regional sales summary needs key metrics per store_key from fact_sales.
   Return the total revenue, the average sale value, and the highest single
   sale for each store, all rounded to two decimal places. */
SELECT store_key,
       ROUND(SUM(total_amount), 2) AS total_revenue,
       ROUND(AVG(total_amount), 2) AS avg_sale_value,
       ROUND(MAX(total_amount), 2) AS top_sale
FROM fact_sales
GROUP BY store_key
ORDER BY total_revenue DESC;


/* Q36 [Conditional aggregation]
   Leadership wants a single-row gender split for the whole customer base in a
   horizontal layout, not two rows. Count Male and Female customers in separate
   columns, alongside the overall total. */
SELECT SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male_count,
       SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female_count,
       COUNT(*) AS total_customers
FROM dim_customer;


/* Q37 [Conditional aggregation]
   The finance team wants to compare, per store, how much revenue comes from
   High-Value sales (total_amount >= 1000) versus Standard sales. Produce the
   two revenue figures as side-by-side columns for each store_key. */
SELECT store_key,
       ROUND(SUM(CASE WHEN total_amount >= 1000 THEN total_amount ELSE 0 END), 2) AS high_value_revenue,
       ROUND(SUM(CASE WHEN total_amount <  1000 THEN total_amount ELSE 0 END), 2) AS standard_revenue
FROM fact_sales
GROUP BY store_key;


/* Q38 [SQRT / POWER / ROUND]
   The analytics team is testing a "price index" metric to compress the price
   scale for a visualization. Define it as the square root of unit_price times
   10, rounded to two decimals, and compute it for every product. */
SELECT product_key, unit_price,
       ROUND(SQRT(unit_price) * 10, 2)       AS price_index,
       ROUND(POWER(unit_price, 0.5) * 10, 2) AS price_index_alt
FROM dim_product;


/* Q39 [RAND, sampling]
   The QA team wants a reproducible 10% random sample of products for a manual
   review. Assign each product a random number, select roughly the bottom 10%,
   and ensure the sample can be regenerated identically on a later run. */
SELECT product_key, product_name,
       ROUND(RAND(42), 4) AS rand_value
FROM dim_product
WHERE RAND(42) < 0.1
ORDER BY rand_value;


/* Q40 [CONCAT, UPPER, TRIM]
   The catalog standard requires a clean SKU label formatted as
   CATEGORY-BRAND-PRODUCTID, in uppercase with no stray spaces
   (e.g. CLOTHING-BRANDC-PROD0001). Generate this standardized SKU per product. */
SELECT product_key,
       UPPER(CONCAT_WS('-', TRIM(category), TRIM(brand), TRIM(product_id))) AS sku_label
FROM dim_product;


/* Q41 [nested REPLACE + TRIM]
   Store names such as 'Tucker, Stanton and Reilly' contain commas that break a
   downstream CSV feed. Produce a CSV-safe store name where every comma is
   replaced with a space and any resulting double spaces are collapsed to one. */
SELECT store_key, store_name,
       TRIM(REPLACE(REPLACE(store_name, ',', ' '), '  ', ' ')) AS csv_safe_name
FROM dim_store;


/* Q42 [RANK + PARTITION BY]
   The merchandising team wants the top-priced items within each category. Rank
   every product by unit_price within its own category, with the most expensive
   product getting rank 1. */
SELECT product_key, category, product_name, unit_price,
       RANK() OVER (PARTITION BY category ORDER BY unit_price DESC) AS price_rank
FROM dim_product;


/* Q43 [ROW_NUMBER / RANK / DENSE_RANK]
   The same report needs to compare ranking behaviours. Within each category
   ordered by price, return a strict row-by-row sequence number, a gapped rank,
   and a gap-free rank side by side so the differences on ties are visible. */
SELECT product_key, category, unit_price,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY unit_price DESC) AS row_seq,
       RANK()       OVER (PARTITION BY category ORDER BY unit_price DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY unit_price DESC) AS dense_rank_no_gaps
FROM dim_product;


/* Q44 [CASE + YEAR]
   Marketing wants a customer segment derived from join year joined before 2022
   = 'Loyal', joined 2022–2023 = 'Established', and 2024 onward = 'New'. Build
   this segment label from join_date. */
SELECT customer_key, join_date,
       CASE
            WHEN YEAR(join_date) < 2022  THEN 'Loyal'
            WHEN YEAR(join_date) <= 2023 THEN 'Established'
            ELSE 'New'
       END AS customer_segment
FROM dim_customer;


/* Q45 [NULLIF + ROUND]
   The finance team wants each sale's effective discount PERCENTAGE, defined as
   discount / (quantity_sold * unit_price) * 100, rounded to one decimal. Safely
   handle any sale where the gross line value works out to zero. */
SELECT sales_id, quantity_sold, unit_price, discount,
       ROUND(discount / NULLIF(quantity_sold * unit_price, 0) * 100, 1) AS discount_pct
FROM fact_sales;



/* ===========================================================================
   ADVANCED (46–60)
   =========================================================================== */

/* Q46 [SUM() OVER, running total]
   The revenue team wants to see how each store's revenue accumulates over its
   transaction sequence. Produce a running (cumulative) total of total_amount,
   ordered by sales_id, that resets for each store_key. */
SELECT store_key, sales_id, total_amount,
       ROUND(SUM(total_amount) OVER (
                 PARTITION BY store_key
                 ORDER BY sales_id
                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
             ), 2) AS running_revenue
FROM fact_sales;


/* Q47 [AVG() OVER, moving average]
   For trend smoothing, the analytics team wants a 3-sale moving average of
   total_amount per store, ordered by sales_id within each store_key, using the
   current sale plus the two preceding sales. */
SELECT store_key, sales_id, total_amount,
       ROUND(AVG(total_amount) OVER (
                 PARTITION BY store_key
                 ORDER BY sales_id
                 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
             ), 2) AS moving_avg_3
FROM fact_sales;


/* Q48 [LAG + DATEDIFF]
   The retention team wants to understand purchase frequency. For each customer,
   compute the number of days between consecutive purchases — the gap from the
   previous purchase date — using fact_sales joined to dim_date. */
SELECT fs.customer_key,
       d.date AS purchase_date,
       LAG(d.date) OVER (PARTITION BY fs.customer_key ORDER BY d.date) AS prev_purchase_date,
       DATEDIFF(d.date,
                LAG(d.date) OVER (PARTITION BY fs.customer_key ORDER BY d.date)) AS days_since_prev_purchase
FROM fact_sales fs
JOIN dim_date d ON fs.date_key = d.date_key;


/* Q49 [LEAD]
   The pricing team wants to study the price ladder within each category. For
   each product (ordered by unit_price within its category), show the price of
   the next more-expensive product and the gap up to it. */
SELECT category, product_name, unit_price,
       LEAD(unit_price) OVER (PARTITION BY category ORDER BY unit_price) AS next_higher_price,
       ROUND(LEAD(unit_price) OVER (PARTITION BY category ORDER BY unit_price) - unit_price, 2) AS price_gap_to_next
FROM dim_product;


/* Q50 [FIRST_VALUE / LAST_VALUE, frame handling]
   The merchandising team wants to know where each product sits within its
   category's price range. For each category, show every product alongside the
   cheapest and the most expensive price in that same category on the same row.
   NOTE: LAST_VALUE needs the full-partition frame to return the true maximum. */
SELECT category, product_name, unit_price,
       FIRST_VALUE(unit_price) OVER (
           PARTITION BY category ORDER BY unit_price
       ) AS cheapest_in_category,
       LAST_VALUE(unit_price) OVER (
           PARTITION BY category ORDER BY unit_price
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS most_expensive_in_category
FROM dim_product;


/* Q51 [ROW_NUMBER, deduplication]
   A dedup job found that dim_customer may contain repeated customers sharing the
   same lowercased email. Keep only one row per email (the lowest customer_key)
   and flag every other row as a duplicate to be purged. */
WITH ranked AS (
    SELECT customer_key, email,
           ROW_NUMBER() OVER (
               PARTITION BY LOWER(TRIM(email))
               ORDER BY customer_key
           ) AS rn
    FROM dim_customer
)
SELECT customer_key, email, rn,
       CASE WHEN rn = 1 THEN 'Keep' ELSE 'Duplicate - Purge' END AS dedup_action
FROM ranked
ORDER BY email, rn;


/* Q52 [SUM() OVER (PARTITION BY), ratio-to-total]
   The category team wants to identify products that dominate their category. For
   each product, compute its revenue contribution PERCENTAGE within its category
   — its total sales as a share of the whole category's total sales. */
WITH product_rev AS (
    SELECT dp.category, dp.product_key, dp.product_name,
           SUM(fs.total_amount) AS product_revenue
    FROM fact_sales fs
    JOIN dim_product dp ON fs.product_key = dp.product_key
    GROUP BY dp.category, dp.product_key, dp.product_name
)
SELECT category, product_name,
       ROUND(product_revenue, 2) AS product_revenue,
       ROUND(product_revenue / SUM(product_revenue) OVER (PARTITION BY category) * 100, 2) AS pct_of_category
FROM product_rev
ORDER BY category, pct_of_category DESC;


/* Q53 [Pivot via conditional aggregation]
   Leadership wants a quarterly revenue pivot from fact_sales joined to dim_date.
   Produce one row per year, with separate columns holding the Q1, Q2, Q3, and
   Q4 revenue for that year. */
SELECT d.year,
       ROUND(SUM(CASE WHEN d.quarter = 1 THEN fs.total_amount ELSE 0 END), 2) AS q1_revenue,
       ROUND(SUM(CASE WHEN d.quarter = 2 THEN fs.total_amount ELSE 0 END), 2) AS q2_revenue,
       ROUND(SUM(CASE WHEN d.quarter = 3 THEN fs.total_amount ELSE 0 END), 2) AS q3_revenue,
       ROUND(SUM(CASE WHEN d.quarter = 4 THEN fs.total_amount ELSE 0 END), 2) AS q4_revenue
FROM fact_sales fs
JOIN dim_date d ON fs.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;


/* Q54 [DENSE_RANK, top-N per group]
   The BI team wants to highlight regional leaders. For every region, identify
   and return the top 3 stores by total revenue, presented as a ranked list
   within each region. */
WITH store_rev AS (
    SELECT ds.region, ds.store_name,
           SUM(fs.total_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_store ds ON fs.store_key = ds.store_key
    GROUP BY ds.region, ds.store_name
),
ranked AS (
    SELECT region, store_name, revenue,
           DENSE_RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS region_rank
    FROM store_rev
)
SELECT region, store_name, ROUND(revenue, 2) AS revenue, region_rank
FROM ranked
WHERE region_rank <= 3
ORDER BY region, region_rank;


/* Q55 [JSON_OBJECT]
   The data platform team is building an API feed and needs each product
   serialized as a JSON object containing the product's id, name, category, and
   price, ready for direct consumption by a downstream service. */
SELECT product_key,
       JSON_OBJECT(
           'product_id',   product_id,
           'product_name', product_name,
           'category',     category,
           'unit_price',   unit_price
       ) AS product_json
FROM dim_product;


/* Q56 [GROUP_CONCAT, array-like rollup]
   The analytics team wants a summary tile listing the brands present in each
   category. For every category, produce a single comma-separated list of all
   brand names that appear in it, deduplicated and sorted alphabetically. */
SELECT category,
       GROUP_CONCAT(DISTINCT brand ORDER BY brand SEPARATOR ', ') AS brands_in_category
FROM dim_product
GROUP BY category;


/* Q57 [FIRST_VALUE]
   The growth team wants to compare each transaction against a customer's opening
   purchase. For every customer, show their first-ever purchase amount next to
   each of their sales, plus the difference between that sale and their first. */
SELECT fs.customer_key,
       d.date AS purchase_date,
       fs.total_amount,
       FIRST_VALUE(fs.total_amount) OVER (
           PARTITION BY fs.customer_key
           ORDER BY d.date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS first_purchase_amount,
       ROUND(fs.total_amount - FIRST_VALUE(fs.total_amount) OVER (
                 PARTITION BY fs.customer_key ORDER BY d.date
                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
             ), 2) AS diff_vs_first
FROM fact_sales fs
JOIN dim_date d ON fs.date_key = d.date_key;


/* Q58 [multi-function cleaning pipeline]
   The data-quality team wants a master "customer health" extract in a single
   query a proper-cased full name, a masked email, a normalized 10-digit phone
   (placeholder 0000000000 shown as 'Not Provided'), and tenure in whole years. */
SELECT customer_key,
       CONCAT(
           UPPER(LEFT(first_name, 1)), LOWER(SUBSTRING(first_name, 2)),
           ' ',
           UPPER(LEFT(last_name, 1)),  LOWER(SUBSTRING(last_name, 2))
       ) AS full_name,
       CONCAT(SUBSTRING_INDEX(email, '@', 1), '@masked.com') AS masked_email,
       IFNULL(NULLIF(RIGHT(phone, 10), '0000000000'), 'Not Provided') AS clean_phone,
       TIMESTAMPDIFF(YEAR, join_date, CURDATE()) AS tenure_years
FROM dim_customer;


/* Q59 [LAG + NULLIF]
   Finance wants a month-over-month revenue change report. For each year/month,
   return the total monthly revenue, the previous month's revenue, and the
   percentage growth — handling the very first month (no prior) safely. */
WITH monthly AS (
    SELECT d.year, d.month,
           SUM(fs.total_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_date d ON fs.date_key = d.date_key
    GROUP BY d.year, d.month
)
SELECT year, month,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY year, month), 2) AS prev_month_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY year, month))
             / NULLIF(LAG(revenue) OVER (ORDER BY year, month), 0) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY year, month;


/* Q60 [capstone aggregation + window ranking + JSON_OBJECT + NULLIF]
   The executive scorecard needs one summary row per category total revenue,
   total units sold, average discount percentage, the single best-selling
   product name (by revenue), and a JSON blob bundling the three headline
   metrics into one tile. */
WITH product_rev AS (
    SELECT dp.category, dp.product_name,
           SUM(fs.total_amount)                  AS revenue,
           SUM(fs.quantity_sold)                 AS units,
           SUM(fs.discount)                      AS total_discount,
           SUM(fs.quantity_sold * fs.unit_price) AS gross
    FROM fact_sales fs
    JOIN dim_product dp ON fs.product_key = dp.product_key
    GROUP BY dp.category, dp.product_name
),
ranked AS (
    SELECT pr.*,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rev_rank
    FROM product_rev pr
)
SELECT category,
       ROUND(SUM(revenue), 2) AS total_revenue,
       SUM(units)             AS total_units,
       ROUND(SUM(total_discount) / NULLIF(SUM(gross), 0) * 100, 2) AS avg_discount_pct,
       MAX(CASE WHEN rev_rank = 1 THEN product_name END)           AS top_product,
       JSON_OBJECT(
           'total_revenue', ROUND(SUM(revenue), 2),
           'total_units',   SUM(units),
           'top_product',   MAX(CASE WHEN rev_rank = 1 THEN product_name END)
       ) AS category_summary_json
FROM ranked
GROUP BY category
ORDER BY total_revenue DESC;


/* ======================= END OF QUESTIONS WITH ANSWERS ===================== */
