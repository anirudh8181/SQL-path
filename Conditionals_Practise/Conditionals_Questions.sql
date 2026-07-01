-- =====================================================================
-- CONDITIONAL LOGIC — 50 DATA ENGINEER INTERVIEW QUESTIONS
-- Schema : Real_Sales (star schema) — see Insert_script.sql for full DDL/data
-- Dialect: MySQL 8.0+
-- Topics : CASE WHEN, simple CASE, nested CASE, IF(), IFNULL(), COALESCE(),
--          NULLIF(), conditional aggregation (manual pivots/cross-tabs),
--          business-rule mapping, category/status derivation, data-quality rules.
-- Format : [Difficulty | skills]  then a 2–3 line business requirement.
-- Answers: Conditionals_Solutions.sql  (same C-numbers)
-- =====================================================================

USE Real_Sales;


-- ====================================================================
-- CASE / IF BASICS  (C1–C10)
-- ====================================================================

/* C1  [Beginner | CASE WHEN ranges]
   Finance wants a pricing report that groups products into tiers based on
   unit_price: 'Budget' below 200, 'Standard' from 200 up to 599.99, and
   'Premium' at 600 and above. Return each product with its tier label. */


/* C2  [Beginner | simple CASE]
   The reporting layer stores gender as a single character (M/F) but needs
   readable labels for dashboards. Standardize it so 'M' becomes 'Male',
   'F' becomes 'Female', and anything else becomes 'Unknown'. */


/* C3  [Beginner | IF()]
   A weekend-promotion report needs each calendar date labelled as either
   'Weekend' or 'Weekday'. The dim_date table already stores is_weekend as
   1/0 — convert that flag into the readable label using IF(). */


/* C4  [Beginner | simple CASE]
   The BI team wants each quarter number from dim_date shown as a descriptive
   label ('Q1 Jan-Mar' through 'Q4 Oct-Dec') for report headers. Produce the
   distinct quarter-to-label mapping. */


/* C5  [Beginner | CASE WHEN]
   The merchandising team wants every sale flagged according to whether a
   discount was applied: 'HAS_DISCOUNT' when discount is greater than 0,
   otherwise 'NO_DISCOUNT'. */


/* C6  [Beginner | IF()]
   Finance wants large transactions highlighted in the daily feed. Flag each
   sale as 'High' when total_amount is 3000 or more, otherwise 'Normal',
   using IF(). */


/* C7  [Beginner | simple CASE]
   Marketing classifies brands into tiers: BrandA and BrandB are 'Premium',
   and every other brand is 'Standard'. Return each product with its brand
   tier. */


/* C8  [Beginner | CASE WHEN ranges]
   The logistics team wants each sale bucketed by order size: a quantity_sold
   of 1 is 'Single', 2 through 10 is 'Small', and anything above 10 is 'Bulk'.
   Return the bucket for each sale. */


/* C9  [Beginner | CASE WHEN + IN]
   The analytics team wants each month mapped to a season for seasonal trend
   analysis: Dec/Jan/Feb = 'Winter', Mar/Apr/May = 'Spring', Jun/Jul/Aug =
   'Summer', and the rest = 'Fall'. Produce the distinct month-to-season map. */


/* C10 [Beginner | CASE + LEFT/UPPER]
   For a simple A/B mailing split, bucket customers by the first letter of
   their last_name: initials A–M go to 'Group1' and N–Z go to 'Group2'.
   Return each customer with its group. */


-- ====================================================================
-- NULL HANDLING: IFNULL / COALESCE / NULLIF  (C11–C15)
-- ====================================================================

/* C11 [Beginner | IFNULL]
   A downstream calculation breaks when discount is NULL. Defensively
   guarantee a numeric discount (treat NULL as 0) and use it to compute a
   net unit price (unit_price minus the cleaned discount) for each sale. */


/* C12 [Intermediate | NULLIF, safe division]
   The pricing team wants each sale's discount expressed as a percentage of
   unit_price, rounded to two decimals. Make the calculation safe against a
   zero unit_price so it returns NULL instead of erroring. */


/* C13 [Intermediate | COALESCE]
   Customer profiles need a single display location. Return the first
   available value among city, state, and country, falling back to 'UNKNOWN'
   when all three are missing. */


/* C14 [Intermediate | NULLIF + IF]
   The finance team treats a discount of exactly 0 as "no discount". Convert
   a 0 discount into NULL, then label each sale 'NO_DISCOUNT' when it is null
   and 'DISCOUNTED' otherwise. */


/* C15 [Intermediate | COALESCE chain + NULLIF]
   Build a best-contact field for each customer: prefer a non-blank phone,
   else a non-blank email, else the literal 'NO CONTACT'. Treat empty/blank
   strings as missing, not just NULLs. */


-- ====================================================================
-- NESTED CASE / MULTI-CONDITION RULES  (C16–C20)
-- ====================================================================

/* C16 [Intermediate | nested CASE + date math]
   The loyalty team wants a tenure segment from join_date: under 1 year 'New',
   1–3 years 'Growing'; for 3–5 years and 5+ years, further split each into a
   Gold/Silver VIP band depending on whether they joined before 2022. */


/* C17 [Intermediate | CASE returning numeric]
   Apply a tiered shipping cost based on total_amount: orders under 500 cost
   50, orders from 500 to under 1500 cost 25, and everything else ships free.
   Return the computed shipping cost per sale. */


/* C18 [Advanced | nested CASE, multi-condition]
   Risk scoring: when the per-unit discount exceeds unit_price, classify the
   sale 'High' if total_amount >= 3000 else 'Medium'; otherwise classify
   'Medium' when total_amount >= 5000, and 'Low' for everything else. */


/* C19 [Advanced | CASE returning a numeric rate]
   Loyalty points accrue at a tiered rate on total_amount: 5% at 5000+, 3%
   from 2000 to 4999.99, 1% from 500 to 1999.99, and 0% below 500. Return the
   computed points (rounded to 2 decimals) per sale. */


/* C20 [Intermediate | nested CASE + NULLIF]
   Derive a discount band from the discount-as-%-of-unit_price: 'UNKNOWN' when
   the percentage can't be computed, 'None' at exactly 0%, 'Low' below 10%,
   'Medium' below 30%, and 'High' otherwise. Guard against zero price. */


-- ====================================================================
-- CATEGORY / STATUS DERIVATION  (C21–C30)
-- ====================================================================

/* C21 [Intermediate | simple CASE on derived value]
   Segment customers by email provider. Extract the domain (after the @) and
   map 'example.net' -> 'Personal-Net', 'example.org' -> 'Personal-Org',
   'example.com' -> 'Personal-Com', and anything else -> 'Other'. */


/* C22 [Intermediate | CASE + date functions]
   Classify each product's life stage from launch_date relative to today:
   future date 'Pre-Launch', under 12 months 'New', under 3 years
   'Established', under 5 years 'Mature', and 5+ years 'Legacy'. */


/* C23 [Intermediate | CASE + IN]
   The BI team wants stores rolled up into super-regions: North and East form
   'NE-Zone', South and West form 'SW-Zone', and anything else is 'Central'.
   Return each store with its super-region. */


/* C24 [Intermediate | CASE + IN]
   Standardize the country field against a known list (United Kingdom, United
   States, Singapore, Switzerland, Egypt): keep the value if it is in the
   list, otherwise replace it with 'OTHER'. */


/* C25 [Intermediate | CASE + GROUP BY]
   Bucket each sale by revenue size — Micro (<500), Small (<1500), Medium
   (<3500), Large (>=3500) — then report the number of sales and total
   revenue per bucket, ordered from Micro to Large. */


/* C26 [Advanced | CASE + aggregation + LEFT JOIN]
   Segment customers by their lifetime revenue: Platinum (>=50000), Gold
   (>=20000), Silver (>=5000), Bronze (>0), and 'No-Purchase' when they have
   never bought. Include customers with no sales. */


/* C27 [Advanced | CASE + recency]
   Build a lifecycle status from each customer's most recent order date:
   'Never-Purchased' if none; otherwise 'Active' (<=90 days), 'At-Risk'
   (<=180), 'Dormant' (<=365), and 'Churned' beyond that. */


/* C28 [Advanced | CASE + COUNT + LEFT JOIN]
   Assign a frequency tier from each customer's order count: 'Gold' for 10 or
   more orders, 'Silver' for 3–9, 'Bronze' for 1–2, and 'Inactive' for none.
   Include customers who have never ordered. */


/* C29 [Intermediate | CASE comparing to an aggregate]
   The merchandising team wants to spot premium positioning. Flag each product
   as 'Above-Avg' when its unit_price exceeds the average price of its own
   category, otherwise 'At-or-Below-Avg'. */


/* C30 [Advanced | CASE + NULLIF + LEFT JOIN]
   Classify each product's margin health from its effective discount % (total
   discount / gross revenue): 'No-Sales' when it never sold, 'Healthy' below
   5%, 'Watch' from 5–15%, and 'Eroded' above 15%. */


-- ====================================================================
-- CONDITIONAL AGGREGATION (MANUAL PIVOTS / CROSS-TABS)  (C31–C38)
-- ====================================================================

/* C31 [Intermediate | SUM(CASE WHEN)]
   Leadership wants a revenue pivot per region with category columns. For each
   store region, produce separate revenue totals for Electronics, Clothing,
   and Books, plus the overall total, sorted by total revenue. */


/* C32 [Intermediate | SUM(CASE WHEN)]
   Operations wants to compare weekend vs weekday trading per region. For each
   region, count weekend sales and weekday sales in separate columns, plus the
   overall count. */


/* C33 [Intermediate | SUM(CASE WHEN)]
   Marketing wants a gender revenue split by product category. For each
   category, show revenue from male customers and from female customers in
   side-by-side columns, plus the category total. */


/* C34 [Intermediate | SUM(CASE WHEN)]
   For each store, report total revenue alongside the revenue that came only
   from discounted lines (discount > 0), so the team can see how much of each
   store's sales were on promotion. */


/* C35 [Advanced | SUM(CASE WHEN) cross-tab]
   Build a region-by-quarter cross-tab: one row per region with four columns
   (q1–q4) holding the count of sales in each quarter. */


/* C36 [Intermediate | conditional SUM]
   The finance team wants the total discount value (discount × quantity_sold)
   given specifically on Electronics products, shown next to the total
   discount across all categories for comparison. */


/* C37 [Advanced | conditional SUM + NULLIF]
   For each product category, compute the percentage of revenue that came from
   'Bulk' orders (quantity_sold > 10). Guard against categories with zero
   revenue. */


/* C38 [Advanced | window + SUM(CASE WHEN)]
   Build a monthly cohort matrix: for each year-month, count how many order
   lines were a customer's very first order versus a returning order, so the
   team can track new vs repeat activity over time. */


-- ====================================================================
-- DATA-QUALITY RULES  (C39–C46)
-- ====================================================================

/* C39 [Intermediate | CASE priority rules]
   Build a row-level data-quality flag for sales, evaluated in priority order:
   'OVER_DISCOUNT' when discount exceeds unit_price, else 'BAD_AMOUNT' when
   total_amount is 0 or negative, else 'OK'. */


/* C40 [Intermediate | CASE with OR]
   Flag invalid sales records: mark a row 'INVALID' when quantity_sold <= 0 OR
   unit_price <= 0 OR discount < 0, otherwise 'VALID'. */


/* C41 [Advanced | conditional aggregation scorecard]
   Produce a completeness scorecard for dim_customer: total rows, plus counts
   of rows with a well-formed first_name, email, phone (10–15 digits), and a
   valid (non-future) join_date, and the overall % of fully-valid records. */


/* C42 [Intermediate | CASE + LIKE]
   Add a structural email-validity flag: mark 'VALID' when the email matches a
   basic something@something.something pattern, otherwise 'INVALID'. */


/* C43 [Intermediate | CASE + REGEXP/LENGTH]
   Classify phone quality by digit count (after stripping non-digits):
   exactly 10 digits is 'VALID_10', 11–15 digits is 'CHECK_INTL', and anything
   else is 'INVALID'. */


/* C44 [Advanced | CASE date check]
   Surface a data-quality issue: flag any customer whose join_date is in the
   future (greater than today) as 'FUTURE_JOIN_DATE', otherwise 'OK'. */


/* C45 [Advanced | CASE + tolerance + GROUP BY]
   Reconcile total_amount against quantity_sold × (unit_price − discount). Bucket
   each row as 'MATCH' (exact), 'ROUNDING' (within 0.01), or 'MISMATCH', and
   report the row count and min/max difference per bucket. */


/* C46 [Advanced | CASE + LEFT JOIN referential check]
   Verify referential price integrity: compare each fact_sales unit_price to
   the dim_product unit_price and label 'MISSING_PRODUCT', 'MATCH', or
   'PRICE_DRIFT'. */


-- ====================================================================
-- COMPOSITE / PRODUCTION-STYLE  (C47–C50)
-- ====================================================================

/* C47 [Advanced | CONCAT of multiple CASEs]
   Build a single composite status string per customer in the form
   tier|activity|risk — e.g. revenue tier (HIGH/MID/LOW), activity
   (ACTIVE/INACTIVE by recency), and frequency (FREQUENT/OCCASIONAL). */


/* C48 [Advanced | nested CASE on computed margin]
   Derive a per-sale profitability flag assuming cost is 60% of unit_price.
   Compute net margin per unit = (unit_price − discount) − cost, then label
   'LOSS' (<0), 'THIN' (below 10% of price), or 'HEALTHY'. */


/* C49 [Advanced | CASE bucketing]
   Bucket every product into 100-wide price bands labelled '000-099',
   '100-199', '200-299', '300-499', '500-799', and '800+' based on unit_price. */


/* C50 [Advanced | multi-CASE customer 360]
   Build a single customer_360 row per customer combining: order count and
   revenue, a value tier (Platinum/Gold/Silver/Bronze/No-Purchase), a
   lifecycle status by recency, and a data-quality flag — all in one SELECT. */
