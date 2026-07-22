/* ============================================================================
   SQL TRANSFORMATION PRACTICE

   Scope     SQL Transformations only.


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



/* Q2  [CASE WHEN]
   The analytics layer stores gender as a single character (M/F), but the
   reporting team needs readable labels for their charts. Write a query that
   outputs 'Male', 'Female', or 'Unknown' for any other or blank value. */



/* Q3  [IF]
   Finance classifies every sale as "High Value" when its total_amount is 1000
   or more, and "Standard" otherwise. Produce a column on fact_sales that tags
   each transaction accordingly for the daily sales summary. */



/* Q4  [CONCAT_WS, NULL-safe]
   After upstream ingestion, some customer records may be missing either a
   first_name or a last_name. Build a robust full-name column that still
   produces a clean result when one of the name parts is NULL. */



/* Q5  [LOWER]
   The email marketing tool treats John@X.com and john@x.com as different
   addresses, causing duplicate sends. Standardize the email column to
   lowercase so the export contains only consistent, case-folded values. */



/* Q6  [UPPER]
   The fulfilment team wants product categories printed in uppercase on
   shipping labels for better visibility on the warehouse floor. Return each
   product along with its category converted to uppercase. */



/* Q7  [TRIM]
   Some city values were loaded with leading or trailing spaces, which makes
   the same city appear as two separate buckets in group-bys. Produce a cleaned
   city column with the surrounding whitespace removed. */



/* Q8  [LTRIM]
   A legacy feed sometimes pads the state field with leading spaces only. The
   reporting team wants those leading spaces removed while preserving any
   meaningful trailing content. Return the left-trimmed state value. */



/* Q9  [LEFT]
   The product team wants a quick "short code" for each product, built from the
   first 4 characters of product_id (e.g. PROD from PROD0001). Generate this
   prefix for use in a compact UI badge. */



/* Q10 [RIGHT]
   Operations needs only the numeric portion of customer_id — the last 4 digits
   of CUST0001 becomes 0001 — to match records against an external 4-digit
   legacy system. Extract that suffix for every customer. */



/* Q11 [LENGTH / CHAR_LENGTH]
   Data governance is auditing phone-number quality. As a first profiling step,
   report the character length of each customer's phone value so analysts can
   quickly spot abnormally short or long entries. */



/* Q12 [REPLACE]
   Some product_name values contain accidental double spaces, which look untidy
   in the catalog. Produce a cleaned product name where any double space is
   replaced with a single space. */



/* Q13 [ROUND]
   Finance is preparing an executive summary that should not show paise/cents.
   Return the total_amount of every sale rounded to the nearest whole currency
   value. */



/* Q14 [CEIL]
   For capacity planning, the warehouse team wants total_amount always rounded
   UP to the next whole number, because partial units must be provisioned as
   full units. Return each sale's amount rounded up. */



/* Q15 [FLOOR]
   The discount accounting policy is conservative any discount value must be
   rounded DOWN to whole currency before it is posted to the ledger. Return
   each sale's discount rounded down. */



/* Q16 [ABS]
   A migration audit found some price-variance values came through negative due
   to sign flips, but reconciliation only cares about the size of the gap. Show
   the absolute difference between fact_sales.unit_price and
   dim_product.unit_price for each sale. */



/* Q17 [MOD]
   The logistics team packs products into boxes of 5 units each. For every
   sale, calculate how many leftover units remain after filling as many
   complete boxes as possible from quantity_sold. */



/* Q18 [CASE WHEN]
   A weekend-promotion report needs every date labelled as either 'Weekend' or
   'Weekday'. The dim_date table already stores is_weekend as 1/0; convert that
   flag into the readable label. */



/* Q19 [CONCAT_WS]
   The reporting layer needs one human-readable address line per store,
   combining city, region, and country separated by commas, gracefully skipping
   any part that is missing without leaving dangling commas. */



/* Q20 [ROUND + IF]
   The pricing team wants the catalog to show each unit_price as a clean
   two-decimal value, and also tag every product as 'Premium' when the price is
   above 500, or 'Affordable' otherwise. Produce both columns in one query. */




/* ===========================================================================
   INTERMEDIATE (21–45)
   =========================================================================== */

/* Q21 [SUBSTRING, LOCATE/INSTR, SUBSTRING_INDEX]
   The deliverability team wants to analyze customers by their email provider.
   Extract the domain portion — everything after the @ symbol — from each email
   value so they can group customers by provider later. */



/* Q22 [SUBSTRING_INDEX + CONCAT, masking]
   Security needs masked emails in a non-production extract so real provider
   domains are hidden. Keep only the username (the part before the @) and append
   a fixed '@masked.com' to produce a privacy-safe address. */



/* Q23 [RIGHT, CHAR_LENGTH]
   Phone numbers were ingested with inconsistent country-code noise and varying
   lengths. Treat the LAST 10 digits of every phone as the canonical national
   number, regardless of how long the stored value is. */



/* Q24 [TRIM LEADING]
   A telephony vendor needs phone numbers stripped of their leading-zero
   international-prefix noise before they can be compared cleanly. As a first
   step, remove all leading zeros from each phone value. */



/* Q25 [INSTR/POSITION + CASE]
   The data-quality team wants to profile email structure. Report the position
   of the @ symbol in each email, and flag any record where the @ is missing
   entirely (position 0) as 'Invalid'. */



/* Q26 [REVERSE]
   A loyalty-program prototype assigns each customer a quirky referral token
   created by reversing their customer_id. Generate that reversed token for
   every customer in the dimension. */



/* Q27 [UPPER/LOWER/LEFT/SUBSTRING/CONCAT]
   The naming standard requires names like JOHN or john to display as 'John'.
   Since MySQL has no built-in proper-case function, produce a properly cased
   first_name first letter uppercase, remaining letters lowercase. */



/* Q28 [CAST + STR_TO_DATE]
   The warehouse stores dim_date.date_key as an integer like 20250405 rather
   than a real date. Convert it into an actual DATE type so the downstream team
   can perform proper date arithmetic on it. */



/* Q29 [CAST / CONVERT / FORMAT]
   Finance wants total_amount written as text into a flat-file export, formatted
   as a clean fixed-precision string. Convert the decimal amount into a CHAR
   representation that always shows exactly two decimal places. */



/* Q30 [DATEDIFF + CURDATE]
   The analytics team needs a customer tenure report. For each customer, compute
   how many full days have passed since their join_date as of today. */



/* Q31 [DATE_FORMAT]
   A cohort dashboard groups customers along a Month-Year axis. For each
   customer, render the join_date as a readable label such as 'Sep-2021' to be
   used as the grouping key. */



/* Q32 [CASE WHEN ranges]
   The merchandising team wants each product placed into a price band 'Low' for
   prices below 200, 'Medium' for 200 through 600, and 'High' above 600. Derive
   this band from unit_price. */



/* Q33 [NULLIF, safe division]
   A reconciliation job divides total_amount by discount to compute a ratio, but
   some sales have a discount of 0, causing divide-by-zero errors. Make the
   calculation safe so zero-discount rows return NULL instead of failing. */



/* Q34 [NULLIF + IFNULL]
   After a system merge, treat any customer phone equal to the placeholder
   '0000000000' as missing convert that placeholder to a real null and then
   display it as 'Not Provided'. */



/* Q35 [SUM/AVG/MAX + ROUND]
   A regional sales summary needs key metrics per store_key from fact_sales.
   Return the total revenue, the average sale value, and the highest single
   sale for each store, all rounded to two decimal places. */



/* Q36 [Conditional aggregation]
   Leadership wants a single-row gender split for the whole customer base in a
   horizontal layout, not two rows. Count Male and Female customers in separate
   columns, alongside the overall total. */



/* Q37 [Conditional aggregation]
   The finance team wants to compare, per store, how much revenue comes from
   High-Value sales (total_amount >= 1000) versus Standard sales. Produce the
   two revenue figures as side-by-side columns for each store_key. */



/* Q38 [SQRT / POWER / ROUND]
   The analytics team is testing a "price index" metric to compress the price
   scale for a visualization. Define it as the square root of unit_price times
   10, rounded to two decimals, and compute it for every product. */



/* Q39 [RAND, sampling]
   The QA team wants a reproducible 10% random sample of products for a manual
   review. Assign each product a random number, select roughly the bottom 10%,
   and ensure the sample can be regenerated identically on a later run. */



/* Q40 [CONCAT, UPPER, TRIM]
   The catalog standard requires a clean SKU label formatted as
   CATEGORY-BRAND-PRODUCTID, in uppercase with no stray spaces
   (e.g. CLOTHING-BRANDC-PROD0001). Generate this standardized SKU per product. */



/* Q41 [nested REPLACE + TRIM]
   Store names such as 'Tucker, Stanton and Reilly' contain commas that break a
   downstream CSV feed. Produce a CSV-safe store name where every comma is
   replaced with a space and any resulting double spaces are collapsed to one. */



/* Q42 [RANK + PARTITION BY]
   The merchandising team wants the top-priced items within each category. Rank
   every product by unit_price within its own category, with the most expensive
   product getting rank 1. */



/* Q43 [ROW_NUMBER / RANK / DENSE_RANK]
   The same report needs to compare ranking behaviours. Within each category
   ordered by price, return a strict row-by-row sequence number, a gapped rank,
   and a gap-free rank side by side so the differences on ties are visible. */



/* Q44 [CASE + YEAR]
   Marketing wants a customer segment derived from join year joined before 2022
   = 'Loyal', joined 2022–2023 = 'Established', and 2024 onward = 'New'. Build
   this segment label from join_date. */



/* Q45 [NULLIF + ROUND]
   The finance team wants each sale's effective discount PERCENTAGE, defined as
   discount / (quantity_sold * unit_price) * 100, rounded to one decimal. Safely
   handle any sale where the gross line value works out to zero. */




/* ===========================================================================
   ADVANCED (46–60)
   =========================================================================== */

/* Q46 [SUM() OVER, running total]
   The revenue team wants to see how each store's revenue accumulates over its
   transaction sequence. Produce a running (cumulative) total of total_amount,
   ordered by sales_id, that resets for each store_key. */



/* Q47 [AVG() OVER, moving average]
   For trend smoothing, the analytics team wants a 3-sale moving average of
   total_amount per store, ordered by sales_id within each store_key, using the
   current sale plus the two preceding sales. */



/* Q48 [LAG + DATEDIFF]
   The retention team wants to understand purchase frequency. For each customer,
   compute the number of days between consecutive purchases — the gap from the
   previous purchase date — using fact_sales joined to dim_date. */



/* Q49 [LEAD]
   The pricing team wants to study the price ladder within each category. For
   each product (ordered by unit_price within its category), show the price of
   the next more-expensive product and the gap up to it. */



/* Q50 [FIRST_VALUE / LAST_VALUE, frame handling]
   The merchandising team wants to know where each product sits within its
   category's price range. For each category, show every product alongside the
   cheapest and the most expensive price in that same category on the same row. */



/* Q51 [ROW_NUMBER, deduplication]
   A dedup job found that dim_customer may contain repeated customers sharing the
   same lowercased email. Keep only one row per email (the lowest customer_key)
   and flag every other row as a duplicate to be purged. */



/* Q52 [SUM() OVER (PARTITION BY), ratio-to-total]
   The category team wants to identify products that dominate their category. For
   each product, compute its revenue contribution PERCENTAGE within its category
   — its total sales as a share of the whole category's total sales. */



/* Q53 [Pivot via conditional aggregation]
   Leadership wants a quarterly revenue pivot from fact_sales joined to dim_date.
   Produce one row per year, with separate columns holding the Q1, Q2, Q3, and
   Q4 revenue for that year. */



/* Q54 [DENSE_RANK, top-N per group]
   The BI team wants to highlight regional leaders. For every region, identify
   and return the top 3 stores by total revenue, presented as a ranked list
   within each region. */



/* Q55 [JSON_OBJECT]
   The data platform team is building an API feed and needs each product
   serialized as a JSON object containing the product's id, name, category, and
   price, ready for direct consumption by a downstream service. */



/* Q56 [GROUP_CONCAT, array-like rollup]
   The analytics team wants a summary tile listing the brands present in each
   category. For every category, produce a single comma-separated list of all
   brand names that appear in it, deduplicated and sorted alphabetically. */



/* Q57 [FIRST_VALUE]
   The growth team wants to compare each transaction against a customer's opening
   purchase. For every customer, show their first-ever purchase amount next to
   each of their sales, plus the difference between that sale and their first. */



/* Q58 [multi-function cleaning pipeline]
   The data-quality team wants a master "customer health" extract in a single
   query a proper-cased full name, a masked email, a normalized 10-digit phone
   (placeholder 0000000000 shown as 'Not Provided'), and tenure in whole years. */



/* Q59 [LAG + NULLIF]
   Finance wants a month-over-month revenue change report. For each year/month,
   return the total monthly revenue, the previous month's revenue, and the
   percentage growth — handling the very first month (no prior) safely. */



/* Q60 [capstone aggregation + window ranking + JSON_OBJECT + NULLIF]
   The executive scorecard needs one summary row per category total revenue,
   total units sold, average discount percentage, the single best-selling
   product name (by revenue), and a JSON blob bundling the three headline
   metrics into one tile. */



/* ============================ END OF QUESTIONS ============================ */
