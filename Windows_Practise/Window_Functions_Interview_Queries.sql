-- =====================================================================
-- SQL WINDOW FUNCTIONS - INTERVIEW PRACTICE QUERIES
-- Schema: Real_Sales (star schema) -- see Insert_script.sql for full DDL/data
--   fact_sales(sales_id, date_key, customer_key, product_key, store_key,
--              quantity_sold, unit_price, discount, total_amount)
--   dim_date(date_key, date, day, month, month_name, quarter, year, is_weekend)
--   dim_customer(customer_key, customer_id, first_name, last_name, gender,
--                email, phone, country, state, city, join_date)
--   dim_product(product_key, product_id, product_name, category, brand,
--               unit_price, launch_date)
--   dim_store(store_key, store_id, store_name, region, country, city)
-- =====================================================================

USE Real_Sales;

-- =====================================================================
-- BEGINNER (Q1 - Q14)
-- =====================================================================

-- Q1. Window function vs aggregate: customer total beside every detail row
-- Business question: For every individual sale line, also show the grand total
--   that this customer has spent across all of their purchases.
-- What to return: sales_id, customer_key, total_amount, and customer_total.
-- Concept: SUM(...) OVER (PARTITION BY ...) computes an aggregate per partition
--   but WITHOUT collapsing rows -- unlike GROUP BY, every detail row is kept and
--   the partition total is repeated on each of that customer's rows.
SELECT
    f.sales_id,
    f.customer_key,
    f.total_amount,
    SUM(f.total_amount) OVER (PARTITION BY f.customer_key) AS customer_total
FROM fact_sales f;


-- Q2. Number each customer's purchases in chronological order
-- Business question: Within each customer, label their 1st, 2nd, 3rd ... purchase
--   in the order the purchases happened over time.
-- What to return: sales_id, customer_key, sale_date, and a 1-based purchase_seq.
-- Concept: ROW_NUMBER() assigns a gap-free unique integer per partition, driven
--   by ORDER BY inside the OVER clause. PARTITION BY restarts the count for each
--   new customer.
SELECT
    f.sales_id,
    f.customer_key,
    d.date AS sale_date,
    ROW_NUMBER() OVER (PARTITION BY f.customer_key ORDER BY d.date) AS purchase_seq
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- Q3. OVER() empty = whole result set: % of grand total
-- Business question: For each sale, what percentage of the company's overall
--   revenue does that single sale represent?
-- What to return: sales_id, total_amount, grand_total, pct_of_total.
-- Concept: An empty OVER () makes the whole result set ONE partition, so the
--   aggregate is the grand total. Dividing the row value by it gives a share-of-total.
SELECT
    f.sales_id,
    f.total_amount,
    SUM(f.total_amount) OVER () AS grand_total,
    ROUND(f.total_amount / SUM(f.total_amount) OVER () * 100, 2) AS pct_of_total
FROM fact_sales f;


-- Q4. ROW_NUMBER vs RANK vs DENSE_RANK on product revenue
-- Business question: Rank sales by amount (highest first) and compare how the
--   three ranking functions treat ties.
-- What to return: product_key, total_amount, and rn / rnk / dns side by side.
-- Concept: ROW_NUMBER = always unique (ties broken arbitrarily); RANK = ties share
--   a rank then SKIP the next numbers (1,1,3); DENSE_RANK = ties share a rank with
--   NO gaps (1,1,2). Run it and watch the columns diverge on tied amounts.
SELECT
    f.product_key,
    f.total_amount,
    ROW_NUMBER()  OVER (ORDER BY f.total_amount DESC) AS rn,
    RANK()        OVER (ORDER BY f.total_amount DESC) AS rnk,
    DENSE_RANK()  OVER (ORDER BY f.total_amount DESC) AS dns
FROM fact_sales f;


-- Q5. Latest record per customer (most recent sale)
-- Business question: Pull the single most recent purchase for each customer
--   (the full row, not just the date).
-- What to return: every column of the latest fact_sales row per customer.
-- Concept: The classic "top-1-per-group" pattern -- ROW_NUMBER() ordered DESC in a
--   subquery, then filter WHERE rn = 1 in the outer query (you cannot filter a
--   window function directly in WHERE). sales_id DESC is a deterministic tiebreaker.
SELECT *
FROM (
    SELECT
        f.*,
        d.date AS sale_date,
        ROW_NUMBER() OVER (PARTITION BY f.customer_key
                           ORDER BY d.date DESC, f.sales_id DESC) AS rn
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
) t
WHERE rn = 1;


-- Q6. PARTITION BY vs GROUP BY: two independent partitions in one query
-- Business question: For each sale, show both the total this customer has spent
--   AND the total revenue this product has generated -- on the same row.
-- What to return: sales_id, customer_key, product_key, by_customer, by_product.
-- Concept: You can have MULTIPLE window functions each with a DIFFERENT
--   PARTITION BY in one SELECT. A single GROUP BY could never produce both
--   totals at the detail grain at once.
SELECT
    f.sales_id,
    f.customer_key,
    f.product_key,
    SUM(f.total_amount) OVER (PARTITION BY f.customer_key) AS by_customer,
    SUM(f.total_amount) OVER (PARTITION BY f.product_key)  AS by_product
FROM fact_sales f;


-- Q7. Running total of revenue ordered by date (whole company)
-- Business question: Show a cumulative revenue line for the whole company -- each
--   day's row carries the running sum of all revenue up to and including it.
-- What to return: sale_date, total_amount, running_total.
-- Concept: SUM(...) OVER (ORDER BY ...) without PARTITION BY = a running/cumulative
--   total over the whole set. Adding sales_id to ORDER BY breaks ties deterministically.
SELECT
    d.date AS sale_date,
    f.total_amount,
    SUM(f.total_amount) OVER (ORDER BY d.date, f.sales_id) AS running_total
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- Q8. Per-customer running total (running balance)
-- Business question: Maintain a per-customer cumulative spend that resets for each
--   customer and grows with every successive purchase (like a running balance).
-- What to return: customer_key, sale_date, total_amount, cust_running_total.
-- Concept: Combine PARTITION BY (resets per customer) with ORDER BY (accumulates
--   within the partition). This is the building block for statements, ledgers, MTD/YTD.
SELECT
    f.customer_key,
    d.date AS sale_date,
    f.total_amount,
    SUM(f.total_amount) OVER (PARTITION BY f.customer_key
                              ORDER BY d.date, f.sales_id) AS cust_running_total
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- Q9. Each sale vs customer average
-- Business question: For each sale, how far above or below is it compared to that
--   customer's average purchase size?
-- What to return: customer_key, sales_id, total_amount, cust_avg, diff_from_avg.
-- Concept: AVG(...) OVER (PARTITION BY ...) puts the customer's average on every
--   row, so you can subtract it from the row value to get a per-row deviation.
SELECT
    f.customer_key,
    f.sales_id,
    f.total_amount,
    ROUND(AVG(f.total_amount) OVER (PARTITION BY f.customer_key), 2) AS cust_avg,
    ROUND(f.total_amount - AVG(f.total_amount) OVER (PARTITION BY f.customer_key), 2) AS diff_from_avg
FROM fact_sales f;


-- Q10. COUNT() OVER: total purchases and running count per customer
-- Business question: For each customer show both their TOTAL number of purchases
--   and a running count (how many purchases so far up to this row).
-- What to return: customer_key, sales_id, total_purchases, purchases_so_far.
-- Concept: COUNT(*) OVER (PARTITION BY ...) with NO order = whole-partition count;
--   adding ORDER BY turns it into a running count. Same function, two behaviours
--   depending on whether an ORDER BY (i.e. a frame) is present.
SELECT
    f.customer_key,
    f.sales_id,
    COUNT(*) OVER (PARTITION BY f.customer_key) AS total_purchases,
    COUNT(*) OVER (PARTITION BY f.customer_key ORDER BY f.sales_id) AS purchases_so_far
FROM fact_sales f;


-- Q11. Previous sale amount per customer (LAG)
-- Business question: For each purchase, what was the amount of this customer's
--   immediately preceding purchase?
-- What to return: customer_key, sale_date, total_amount, prev_amount.
-- Concept: LAG(col) OVER (PARTITION BY ... ORDER BY ...) looks BACKWARD one row in
--   the ordered partition. The first row per customer has no predecessor -> NULL.
SELECT
    f.customer_key,
    d.date AS sale_date,
    f.total_amount,
    LAG(f.total_amount) OVER (PARTITION BY f.customer_key ORDER BY d.date) AS prev_amount
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- Q12. Next sale amount per customer (LEAD)
-- Business question: For each purchase, what will this customer's NEXT purchase
--   amount be?
-- What to return: customer_key, sale_date, total_amount, next_amount.
-- Concept: LEAD(col) is the mirror of LAG -- it looks FORWARD one row. The last
--   row per customer has no successor -> NULL. Useful for "time-to-next-event".
SELECT
    f.customer_key,
    d.date AS sale_date,
    f.total_amount,
    LEAD(f.total_amount) OVER (PARTITION BY f.customer_key ORDER BY d.date) AS next_amount
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- Q13. LAG with offset and default value
-- Business question: For each purchase, fetch the amount 1 purchase back and 2
--   purchases back, but show 0 instead of NULL when there is no such prior row.
-- What to return: customer_key, sales_id, total_amount, prev_or_zero, two_back.
-- Concept: LAG(col, offset, default) -- the 2nd arg jumps N rows back, the 3rd arg
--   supplies a fallback so early rows return 0 rather than NULL (handy for math).
SELECT
    f.customer_key,
    f.sales_id,
    f.total_amount,
    LAG(f.total_amount, 1, 0) OVER (PARTITION BY f.customer_key ORDER BY f.sales_id) AS prev_or_zero,
    LAG(f.total_amount, 2, 0) OVER (PARTITION BY f.customer_key ORDER BY f.sales_id) AS two_back
FROM fact_sales f;


-- Q14. Reusable named WINDOW clause
-- Business question: Compute a per-customer running sum AND running average without
--   repeating the same window definition twice.
-- What to return: customer_key, sales_id, running, run_avg.
-- Concept: The WINDOW clause names a window spec once (w AS (...)) so multiple
--   functions can reuse it via OVER w. Cleaner and less error-prone than copy-paste.
SELECT
    f.customer_key,
    f.sales_id,
    SUM(f.total_amount) OVER w AS running,
    AVG(f.total_amount) OVER w AS run_avg
FROM fact_sales f
WINDOW w AS (PARTITION BY f.customer_key ORDER BY f.sales_id);


-- =====================================================================
-- INTERMEDIATE (Q15 - Q32)
-- =====================================================================

-- Q15. Top 2 products by revenue within each category
-- Business question: Within every product category, which 2 products earned the
--   most total revenue?
-- What to return: category, product_key, product_revenue, rnk (1 or 2).
-- Concept: First aggregate revenue per product with GROUP BY, then RANK() the
--   products WITHIN each category (PARTITION BY category) and keep rnk <= 2.
--   RANK is used so genuine ties both qualify ("top-N-per-group").
SELECT category, product_key, product_revenue, rnk
FROM (
    SELECT
        p.category,
        f.product_key,
        SUM(f.total_amount) AS product_revenue,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(f.total_amount) DESC) AS rnk
    FROM fact_sales f
    JOIN dim_product p ON f.product_key = p.product_key
    GROUP BY p.category, f.product_key
) t
WHERE rnk <= 2;


-- Q16. 3-day moving average of daily revenue
-- Business question: Smooth out daily revenue noise by computing a 3-day moving
--   average (today plus the two days before).
-- What to return: sale_date, daily_rev, mov_avg_3d.
-- Concept: A frame clause "ROWS BETWEEN 2 PRECEDING AND CURRENT ROW" limits the
--   window to a sliding span of rows. AVG over that frame = moving average. First
--   build daily totals in a CTE so each row is one calendar day.
WITH daily AS (
    SELECT d.date AS sale_date, SUM(f.total_amount) AS daily_rev
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.date
)
SELECT
    sale_date,
    daily_rev,
    ROUND(AVG(daily_rev) OVER (ORDER BY sale_date
                               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS mov_avg_3d
FROM daily;


-- Q17. Day-over-day revenue change and % growth
-- Business question: How much did daily revenue change versus the previous day,
--   in both absolute terms and percentage growth?
-- What to return: sale_date, daily_rev, prev_day, abs_change, pct_change.
-- Concept: LAG fetches yesterday's revenue; subtract for absolute change; divide by
--   yesterday for % growth. NULLIF(...,0) guards against divide-by-zero when the
--   prior day was 0 or missing.
WITH daily AS (
    SELECT d.date AS sale_date, SUM(f.total_amount) AS daily_rev
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.date
)
SELECT
    sale_date,
    daily_rev,
    LAG(daily_rev) OVER (ORDER BY sale_date) AS prev_day,
    daily_rev - LAG(daily_rev) OVER (ORDER BY sale_date) AS abs_change,
    ROUND( (daily_rev - LAG(daily_rev) OVER (ORDER BY sale_date))
           / NULLIF(LAG(daily_rev) OVER (ORDER BY sale_date), 0) * 100, 2) AS pct_change
FROM daily;


-- Q18. Customer spending quartiles (NTILE)
-- Business question: Split customers into 4 equal-sized spending buckets so we can
--   target the top quartile differently from the bottom.
-- What to return: customer_key, lifetime_value, spend_quartile (1=top..4=bottom).
-- Concept: NTILE(4) divides the ordered rows into 4 as-equal-as-possible groups.
--   Ordering by lifetime_value DESC makes bucket 1 the biggest spenders.
WITH cust AS (
    SELECT customer_key, SUM(total_amount) AS lifetime_value
    FROM fact_sales GROUP BY customer_key
)
SELECT
    customer_key,
    lifetime_value,
    NTILE(4) OVER (ORDER BY lifetime_value DESC) AS spend_quartile
FROM cust;


-- Q19. First and last purchase date per customer (FIRST_VALUE / LAST_VALUE)
-- Business question: For each customer, on what date did they first and last buy?
-- What to return: distinct customer_key, first_purchase, last_purchase.
-- Concept: FIRST_VALUE / LAST_VALUE read a value at the edge of the frame. WATCH
--   THE TRAP: the default frame ends at CURRENT ROW, so LAST_VALUE would just give
--   the current row. You MUST widen the frame to UNBOUNDED PRECEDING AND UNBOUNDED
--   FOLLOWING to get the true last value. (Q20 shows the safer MIN/MAX idiom.)
SELECT DISTINCT
    f.customer_key,
    FIRST_VALUE(d.date) OVER (PARTITION BY f.customer_key ORDER BY d.date
                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_purchase,
    LAST_VALUE(d.date)  OVER (PARTITION BY f.customer_key ORDER BY d.date
                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_purchase
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- Q20. Same as Q19, safe idiom with MIN/MAX OVER (no frame trap)
-- Business question: Same as Q19 -- first and last purchase date per customer.
-- What to return: distinct customer_key, first_purchase, last_purchase.
-- Concept: MIN()/MAX() OVER (PARTITION BY ...) with NO ORDER BY scans the whole
--   partition and sidesteps the LAST_VALUE frame trap entirely. Prefer this idiom
--   for "earliest/latest within group" -- it is simpler and harder to get wrong.
SELECT DISTINCT
    f.customer_key,
    MIN(d.date) OVER (PARTITION BY f.customer_key) AS first_purchase,
    MAX(d.date) OVER (PARTITION BY f.customer_key) AS last_purchase
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key;


-- Q21. 2nd purchase amount per customer (NTH_VALUE)
-- Business question: What was the amount of each customer's SECOND purchase?
-- What to return: distinct customer_key, second_purchase_amt.
-- Concept: NTH_VALUE(col, N) returns the value from the N-th row of the frame.
--   As with LAST_VALUE you must open the frame to UNBOUNDED ... UNBOUNDED so the
--   2nd row is visible regardless of the current row position.
SELECT DISTINCT
    f.customer_key,
    NTH_VALUE(f.total_amount, 2) OVER (
        PARTITION BY f.customer_key ORDER BY f.sales_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_purchase_amt
FROM fact_sales f;


-- Q22. Each store's % contribution to its region revenue
-- Business question: Within each region, what share of the region's total revenue
--   does each individual store contribute?
-- What to return: region, store_key, store_revenue, pct_of_region.
-- Concept: Aggregate revenue per store, then divide by SUM(...) OVER
--   (PARTITION BY region) -- the per-region denominator sits on every store row, so
--   each store's slice of its region is easy to compute.
WITH store_rev AS (
    SELECT s.region, f.store_key, SUM(f.total_amount) AS store_revenue
    FROM fact_sales f
    JOIN dim_store s ON f.store_key = s.store_key
    GROUP BY s.region, f.store_key
)
SELECT
    region, store_key, store_revenue,
    ROUND(store_revenue / SUM(store_revenue) OVER (PARTITION BY region) * 100, 2) AS pct_of_region
FROM store_rev;


-- Q23. Rank months by revenue within each year
-- Business question: Within each year, rank the calendar months from best to worst
--   revenue.
-- What to return: year, month, month_name, monthly_rev, month_rank.
-- Concept: Aggregate revenue per (year, month), then DENSE_RANK() PARTITION BY year
--   ORDER BY revenue DESC. You can ORDER BY an aggregate (SUM) directly inside the
--   OVER clause when the query is already grouped.
SELECT
    d.year, d.month, d.month_name,
    SUM(f.total_amount) AS monthly_rev,
    DENSE_RANK() OVER (PARTITION BY d.year ORDER BY SUM(f.total_amount) DESC) AS month_rank
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, month_rank;


-- Q24. Weekly revenue vs last week vs 2 weeks ago (multi-offset LAG)
-- Business question: For each week show this week's revenue alongside last week's
--   and the week before that, to spot short-term trends.
-- What to return: year, wk, rev, last_wk, two_wk_ago.
-- Concept: Two LAG calls with different offsets (1 and 2) read back one and two
--   rows in the weekly series. WEEK(date) buckets dates into ISO-style week numbers.
WITH weekly AS (
    SELECT d.year, WEEK(d.date) AS wk, SUM(f.total_amount) AS rev
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.year, WEEK(d.date)
)
SELECT
    year, wk, rev,
    LAG(rev, 1) OVER (ORDER BY year, wk) AS last_wk,
    LAG(rev, 2) OVER (ORDER BY year, wk) AS two_wk_ago
FROM weekly;


-- Q25. Sales above their store's average (filter on window result)
-- Business question: Which individual sales exceeded the average sale size of the
--   store they happened in?
-- What to return: sales_id, store_key, total_amount, store_avg (only above-avg rows).
-- Concept: You cannot reference a window function in WHERE on the same level, so
--   compute store_avg in a subquery and filter total_amount > store_avg in the
--   outer query.
SELECT *
FROM (
    SELECT
        f.sales_id, f.store_key, f.total_amount,
        AVG(f.total_amount) OVER (PARTITION BY f.store_key) AS store_avg
    FROM fact_sales f
) t
WHERE total_amount > store_avg;


-- Q26. PERCENT_RANK and CUME_DIST on customer spend
-- Business question: Where does each customer sit in the spending distribution --
--   their relative rank and their cumulative position?
-- What to return: customer_key, ltv, pct_rank, cume_dist.
-- Concept: PERCENT_RANK() = (rank-1)/(rows-1), a 0..1 relative standing.
--   CUME_DIST() = fraction of rows with a value <= the current value. Both describe
--   distribution position; useful for percentile-based segmentation.
WITH cust AS (
    SELECT customer_key, SUM(total_amount) AS ltv
    FROM fact_sales GROUP BY customer_key
)
SELECT
    customer_key, ltv,
    ROUND(PERCENT_RANK() OVER (ORDER BY ltv), 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY ltv), 4) AS cume_dist
FROM cust;


-- Q27. Running MIN and MAX revenue to date
-- Business question: As sales happen over time, track the smallest and largest
--   single-sale amount seen so far (a running low/high watermark).
-- What to return: sale_date, total_amount, running_min, running_max.
-- Concept: MIN()/MAX() OVER (ORDER BY ...) accumulate over the running frame
--   (UNBOUNDED PRECEDING .. CURRENT ROW by default), giving the extreme value
--   observed up to each row.
SELECT
    d.date AS sale_date, f.total_amount,
    MIN(f.total_amount) OVER (ORDER BY d.date, f.sales_id) AS running_min,
    MAX(f.total_amount) OVER (ORDER BY d.date, f.sales_id) AS running_max
FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key;


-- Q28. Global vs per-region row numbering
-- Business question: Rank every sale by amount both across the ENTIRE company and
--   separately WITHIN its own region, on the same row.
-- What to return: region, sales_id, total_amount, global_rn, region_rn.
-- Concept: Two ROW_NUMBER() calls -- one with no PARTITION (global ordering) and one
--   PARTITION BY region (resets per region). Shows how PARTITION BY scopes a window.
SELECT
    s.region, f.sales_id, f.total_amount,
    ROW_NUMBER() OVER (ORDER BY f.total_amount DESC) AS global_rn,
    ROW_NUMBER() OVER (PARTITION BY s.region ORDER BY f.total_amount DESC) AS region_rn
FROM fact_sales f JOIN dim_store s ON f.store_key = s.store_key;


-- Q29. (Conceptual: aggregate vs window - see guide. Demo query below.)
-- Business question: Show the contrast -- a plain GROUP BY collapses each customer
--   into ONE summary row (count + total), losing the individual sales.
-- What to return: customer_key, cnt_grouped, total_grouped (one row per customer).
-- Concept: GROUP BY reduces N detail rows to 1 per group. Compare with Q1/Q6 where
--   window functions keep all detail rows. Choose GROUP BY when you only need the
--   summary, window functions when you need detail AND summary together.
SELECT
    f.customer_key,
    COUNT(*)            AS cnt_grouped,        -- collapses
    SUM(f.total_amount) AS total_grouped
FROM fact_sales f
GROUP BY f.customer_key;


-- Q30. ROWS vs RANGE running total (note tied dates)
-- Business question: Build a running total two ways and see how they differ when
--   several sales share the SAME date.
-- What to return: sale_date, sales_id, total_amount, rows_running, range_running.
-- Concept: ROWS counts physical rows (each row advances the frame). RANGE treats all
--   rows with the SAME ORDER BY value as one logical step -- so tied dates all show
--   the same RANGE running total (the end-of-day cumulative). Key gotcha question.
SELECT
    d.date AS sale_date, f.sales_id, f.total_amount,
    SUM(f.total_amount) OVER (ORDER BY d.date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  AS rows_running,
    SUM(f.total_amount) OVER (ORDER BY d.date
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS range_running
FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key;


-- Q31. Centered window (current row +/- 1 row)
-- Business question: Smooth daily revenue using a window centered on each day
--   (the day itself plus one day before and one day after).
-- What to return: sale_date, rev, centered_avg.
-- Concept: A frame of "ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING" looks both
--   backward and forward, producing a centered (not trailing) moving average.
WITH daily AS (
    SELECT d.date AS sale_date, SUM(f.total_amount) AS rev
    FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key
    GROUP BY d.date
)
SELECT
    sale_date, rev,
    ROUND(AVG(rev) OVER (ORDER BY sale_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING), 2) AS centered_avg
FROM daily;


-- Q32. Trailing window excluding current row (avg of prior 3)
-- Business question: For each purchase, what was the customer's average spend over
--   their previous 3 purchases (NOT counting the current one)?
-- What to return: customer_key, sales_id, total_amount, avg_prev_3.
-- Concept: A frame of "ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING" looks strictly
--   backward and EXCLUDES the current row -- useful for "compare me to my recent past"
--   without leaking the current value into the baseline.
SELECT
    f.customer_key, f.sales_id, f.total_amount,
    AVG(f.total_amount) OVER (PARTITION BY f.customer_key ORDER BY f.sales_id
        ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS avg_prev_3
FROM fact_sales f;


-- =====================================================================
-- ADVANCED (Q33 - Q44)
-- =====================================================================

-- Q33. Gap detection in a customer's daily purchasing
-- Business question: Find places where a customer skipped days between purchases --
--   i.e. consecutive purchases more than 1 day apart.
-- What to return: customer_key, prev_date, sale_date, gap_days (only gaps > 1 day).
-- Concept: LAG fetches the previous purchase date per customer; DATEDIFF measures
--   the gap; filter to gaps > 1. Foundation of sessionization (Q34) and churn (Q45).
WITH ordered AS (
    SELECT
        f.customer_key, d.date AS sale_date,
        LAG(d.date) OVER (PARTITION BY f.customer_key ORDER BY d.date) AS prev_date
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
)
SELECT
    customer_key, prev_date, sale_date,
    DATEDIFF(sale_date, prev_date) AS gap_days
FROM ordered
WHERE prev_date IS NOT NULL
  AND DATEDIFF(sale_date, prev_date) > 1;


-- Q34. Sessionization (new session when gap > 1 day): flag + cumulative SUM
-- Business question: Group each customer's purchases into "sessions", starting a new
--   session whenever there is a gap of more than 1 day since the last purchase.
-- What to return: customer_key, sales_id, sale_date, session_id (1,2,3... per customer).
-- Concept: The two-step "flag then cumulative-sum" trick: mark a 1 at each session
--   boundary (gap > 1 day or first row), then SUM that flag as a running total --
--   the cumulative count of boundaries IS the session id. Core gaps-and-islands pattern.
WITH ev AS (
    SELECT
        f.customer_key, f.sales_id, d.date AS sale_date,
        LAG(d.date) OVER (PARTITION BY f.customer_key ORDER BY d.date, f.sales_id) AS prev_date
    FROM fact_sales f JOIN dim_date d ON f.date_key = d.date_key
),
flagged AS (
    SELECT *,
        CASE WHEN prev_date IS NULL OR DATEDIFF(sale_date, prev_date) > 1
             THEN 1 ELSE 0 END AS new_session
    FROM ev
)
SELECT
    customer_key, sales_id, sale_date,
    SUM(new_session) OVER (PARTITION BY customer_key ORDER BY sale_date, sales_id) AS session_id
FROM flagged;


-- Q35. Deduplicate fact_sales by natural key, keep latest (ROW_NUMBER)
-- Business question: The fact table may contain duplicate rows for the same natural
--   key (date+customer+product+store). Keep only the latest copy of each.
-- What to return: one surviving row per natural key (the highest sales_id).
-- Concept: ROW_NUMBER() PARTITION BY the natural key, ORDER BY sales_id DESC, then
--   keep rn = 1. The commented DELETE shows how to PHYSICALLY remove the duplicates
--   (rn > 1) -- review carefully before running against real data.
WITH ranked AS (
    SELECT
        f.*,
        ROW_NUMBER() OVER (
            PARTITION BY date_key, customer_key, product_key, store_key
            ORDER BY sales_id DESC
        ) AS rn
    FROM fact_sales f
)
SELECT * FROM ranked WHERE rn = 1;
-- Physical delete of dupes (review before running):
-- DELETE FROM fact_sales
-- WHERE sales_id IN (
--     SELECT sales_id FROM (
--         SELECT sales_id,
--                ROW_NUMBER() OVER (PARTITION BY date_key, customer_key, product_key, store_key
--                                   ORDER BY sales_id DESC) AS rn
--         FROM fact_sales
--     ) x WHERE rn > 1
-- );


-- Q36. Identify duplicate records and copy counts (COUNT OVER)
-- Business question: Audit the fact table -- list the rows that are duplicated on the
--   natural key and show HOW MANY copies each duplicated key has.
-- What to return: all columns plus dup_count and rn, only for keys with dup_count > 1.
-- Concept: COUNT(*) OVER (PARTITION BY natural key) gives the copy count on every row
--   WITHOUT collapsing; filter dup_count > 1 to surface only the offenders. ROW_NUMBER
--   labels the copies. This is the diagnostic step before the Q35 cleanup.
SELECT *
FROM (
    SELECT
        f.*,
        COUNT(*) OVER (PARTITION BY date_key, customer_key, product_key, store_key) AS dup_count,
        ROW_NUMBER() OVER (PARTITION BY date_key, customer_key, product_key, store_key
                           ORDER BY sales_id) AS rn
    FROM fact_sales f
) t
WHERE dup_count > 1
ORDER BY date_key, customer_key, product_key, store_key, rn;


-- Q37. Month-to-date (MTD) and year-to-date (YTD) running revenue
-- Business question: For each day, show cumulative revenue since the start of the
--   month (MTD) and since the start of the year (YTD).
-- What to return: sale_date, rev, mtd_rev, ytd_rev.
-- Concept: Two running SUMs over the same date order but DIFFERENT partitions:
--   PARTITION BY (year, month) resets every month for MTD; PARTITION BY year resets
--   every year for YTD. Classic finance/reporting requirement.
WITH daily AS (
    SELECT d.year, d.month, d.date AS sale_date, SUM(f.total_amount) AS rev
    FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key
    GROUP BY d.year, d.month, d.date
)
SELECT
    sale_date, rev,
    SUM(rev) OVER (PARTITION BY year, month ORDER BY sale_date) AS mtd_rev,
    SUM(rev) OVER (PARTITION BY year        ORDER BY sale_date) AS ytd_rev
FROM daily;


-- Q38. Last-observation-carried-forward (LOCF) gap fill
-- Business question: Given a sparse daily series with missing values, fill each gap
--   by carrying the most recent non-null observation forward.
-- What to return: sale_date, rev, rev_filled.
-- Concept: The "grouped fill" trick -- COUNT(non-null) OVER (ORDER BY date) creates a
--   group id that increments only when a real value appears, so all NULLs after a value
--   share its group; MAX OVER that group then back-fills the carried value. Pattern is
--   commented as a template -- swap in your own sparse series.
-- WITH t AS (
--     SELECT sale_date, rev,
--            COUNT(rev) OVER (ORDER BY sale_date) AS grp
--     FROM some_daily_series
-- )
-- SELECT sale_date, rev, MAX(rev) OVER (PARTITION BY grp) AS rev_filled
-- FROM t;


-- Q39. Difference between each sale and the customer's first sale (FIRST_VALUE baseline)
-- Business question: For each purchase, how much bigger or smaller is it than that
--   customer's very first purchase (the baseline)?
-- What to return: customer_key, sale_date, total_amount, first_amt, delta_vs_first.
-- Concept: FIRST_VALUE pins the customer's first purchase amount onto every row;
--   subtracting it gives a "growth vs baseline" measure. (Default frame is fine here
--   because the first value never moves.)
SELECT
    f.customer_key, d.date AS sale_date, f.total_amount,
    FIRST_VALUE(f.total_amount) OVER (PARTITION BY f.customer_key ORDER BY d.date) AS first_amt,
    f.total_amount - FIRST_VALUE(f.total_amount) OVER (PARTITION BY f.customer_key ORDER BY d.date) AS delta_vs_first
FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key;


-- Q40. Largest single-day revenue drop per store
-- Business question: For each store, find the single day on which revenue fell the
--   most compared to the prior active day.
-- What to return: one row per store -- the day with the most negative day_change.
-- Concept: Layered windows: (1) daily revenue per store, (2) LAG to get the
--   day-over-day change, (3) ROW_NUMBER ORDER BY day_change ASC so the biggest DROP
--   (most negative) is rn = 1. Demonstrates chaining CTEs of window functions.
WITH daily AS (
    SELECT f.store_key, d.date AS sale_date, SUM(f.total_amount) AS rev
    FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key
    GROUP BY f.store_key, d.date
),
delta AS (
    SELECT store_key, sale_date, rev,
           rev - LAG(rev) OVER (PARTITION BY store_key ORDER BY sale_date) AS day_change
    FROM daily
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY store_key ORDER BY day_change ASC) AS rn
    FROM delta WHERE day_change IS NOT NULL
) x
WHERE rn = 1;


-- Q41. Weighted running total (quantity_sold * unit_price)
-- Business question: Build a per-customer running total of GROSS value, where each
--   row's contribution is quantity x unit_price (before discounts).
-- What to return: customer_key, sales_id, quantity_sold, unit_price, running_gross.
-- Concept: The argument to SUM can be an EXPRESSION, not just a column -- here a
--   weighted product. Window functions evaluate the expression per row then accumulate.
SELECT
    f.customer_key, f.sales_id,
    f.quantity_sold, f.unit_price,
    SUM(f.quantity_sold * f.unit_price)
        OVER (PARTITION BY f.customer_key ORDER BY f.sales_id) AS running_gross
FROM fact_sales f;


-- Q42. Stable, reproducible ranking with tiebreakers
-- Business question: Produce a ranking of sales by amount that is DETERMINISTIC --
--   re-running it always yields the exact same order, even across ties.
-- What to return: product_key, total_amount, rn.
-- Concept: ROW_NUMBER on amount alone breaks ties arbitrarily (non-reproducible).
--   Adding unique tiebreakers (product_key, then sales_id) to ORDER BY guarantees a
--   stable, repeatable ordering -- important for pagination and reconciliation.
SELECT
    f.product_key, f.total_amount,
    ROW_NUMBER() OVER (ORDER BY f.total_amount DESC, f.product_key ASC, f.sales_id ASC) AS rn
FROM fact_sales f;


-- Q43. (Performance: conceptual - see guide. Example reusing one window via WINDOW clause.)
-- Business question: Compute three running metrics (sum, avg, count) per customer
--   efficiently, without redefining the window three times.
-- What to return: customer_key, sales_id, running_sum, running_avg, running_cnt.
-- Concept: Defining the window once in a WINDOW clause and reusing it via OVER w lets
--   the engine compute all three over a SINGLE window pass -- cleaner and typically
--   cheaper than three separate inline OVER (...) specs.
SELECT
    f.customer_key, f.sales_id,
    SUM(f.total_amount) OVER w AS running_sum,
    AVG(f.total_amount) OVER w AS running_avg,
    COUNT(*)            OVER w AS running_cnt
FROM fact_sales f
WINDOW w AS (PARTITION BY f.customer_key ORDER BY f.sales_id);


-- Q44. Control NULL ordering (force NULLs last in MySQL)
-- Business question: Rank sales by discount (highest first) but always push rows with
--   a NULL discount to the BOTTOM.
-- What to return: customer_key, discount, rn.
-- Concept: MySQL lacks NULLS LAST, so the idiom is to ORDER BY a boolean expression
--   "(discount IS NULL)" first -- it sorts 0 (not null) before 1 (null) -- then by the
--   real column. This explicitly controls where NULLs land in the ordering.
SELECT
    f.customer_key, f.discount,
    ROW_NUMBER() OVER (ORDER BY (f.discount IS NULL), f.discount DESC) AS rn
FROM fact_sales f;


-- =====================================================================
-- SCENARIO-BASED (Q45 - Q52)
-- =====================================================================

-- Q45. Churn signal: gap since last purchase > 90 days (fixed "today" for reproducibility)
-- Business question: Flag customers as a churn risk if their most recent purchase was
--   more than 90 days ago (relative to a fixed reference date).
-- What to return: customer_key, last_purchase, days_since_last, status (CHURN_RISK/ACTIVE).
-- Concept: Find each customer's latest purchase, DATEDIFF it against a FIXED "today"
--   ('2026-06-08') so the result is reproducible, then bucket via CASE. Fixing the date
--   (instead of NOW()) keeps interview answers/tests stable.
WITH last_two AS (
    SELECT
        f.customer_key, d.date AS sale_date,
        ROW_NUMBER() OVER (PARTITION BY f.customer_key ORDER BY d.date DESC) AS rn
    FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key
)
SELECT customer_key,
       MAX(sale_date) AS last_purchase,
       DATEDIFF('2026-06-08', MAX(sale_date)) AS days_since_last,
       CASE WHEN DATEDIFF('2026-06-08', MAX(sale_date)) > 90 THEN 'CHURN_RISK' ELSE 'ACTIVE' END AS status
FROM last_two
GROUP BY customer_key;


-- Q46. Running account balance (credits - debits)
-- Business question: Maintain a per-customer running balance where each sale adds a
--   credit (total_amount) and subtracts a debit (discount).
-- What to return: customer_key, sale_date, credit, debit, balance.
-- Concept: SUM of a signed expression (total_amount - discount) over an ordered,
--   per-customer window produces a ledger-style running balance. Same idea as Q8 but
--   with a net amount per row.
SELECT
    f.customer_key, d.date AS sale_date,
    f.total_amount AS credit, f.discount AS debit,
    SUM(f.total_amount - f.discount)
        OVER (PARTITION BY f.customer_key ORDER BY d.date, f.sales_id) AS balance
FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key;


-- Q47. Best-selling product per region (Top-1, ties via RANK)
-- Business question: In each region, which product generated the most revenue?
--   If there is a tie, keep all tied products.
-- What to return: region, product_key, revenue (the rnk = 1 rows).
-- Concept: Aggregate revenue per (region, product), RANK() PARTITION BY region, keep
--   rnk = 1. Using RANK (not ROW_NUMBER) is deliberate so genuine ties for #1 all show.
WITH rev AS (
    SELECT s.region, f.product_key, SUM(f.total_amount) AS revenue
    FROM fact_sales f JOIN dim_store s ON f.store_key=s.store_key
    GROUP BY s.region, f.product_key
)
SELECT region, product_key, revenue
FROM (
    SELECT *, RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS rnk
    FROM rev
) t
WHERE rnk = 1;


-- Q48. VIP segmentation by spend percentile (PERCENT_RANK)
-- Business question: Segment customers into VIP / Mid / Low tiers based on where their
--   lifetime spend falls in the percentile distribution.
-- What to return: customer_key, ltv, spend_percentile, segment.
-- Concept: PERCENT_RANK() yields a 0..1 position; thresholds (>=0.9 VIP, >=0.5 Mid,
--   else Low) bucket customers. Percentile-based cutoffs adapt to the data better than
--   fixed dollar thresholds.
WITH cust AS (
    SELECT customer_key, SUM(total_amount) AS ltv FROM fact_sales GROUP BY customer_key
)
SELECT customer_key, ltv,
       ROUND(PERCENT_RANK() OVER (ORDER BY ltv) * 100, 1) AS spend_percentile,
       CASE WHEN PERCENT_RANK() OVER (ORDER BY ltv) >= 0.9 THEN 'VIP'
            WHEN PERCENT_RANK() OVER (ORDER BY ltv) >= 0.5 THEN 'Mid'
            ELSE 'Low' END AS segment
FROM cust;


-- Q49. First purchase by category per customer (cross-sell)
-- Business question: For each customer, identify the FIRST product they ever bought in
--   each category (useful for cross-sell / category-entry analysis).
-- What to return: customer_key, category, product_key, sale_date (the rn = 1 rows).
-- Concept: ROW_NUMBER() PARTITION BY (customer_key, category) ORDER BY date -- a
--   two-column partition -- then keep rn = 1 to get the earliest purchase per
--   customer-category combination.
SELECT *
FROM (
    SELECT
        f.customer_key, p.category, f.product_key, d.date AS sale_date,
        ROW_NUMBER() OVER (PARTITION BY f.customer_key, p.category
                           ORDER BY d.date, f.sales_id) AS rn
    FROM fact_sales f
    JOIN dim_product p ON f.product_key=p.product_key
    JOIN dim_date d ON f.date_key=d.date_key
) t
WHERE rn = 1;


-- Q50. Each store's revenue vs best store in its region
-- Business question: Benchmark every store against the TOP store in its region -- show
--   its revenue as a percentage of the regional leader's revenue.
-- What to return: region, store_key, store_rev, region_best, pct_of_best.
-- Concept: MAX(store_rev) OVER (PARTITION BY region) places the regional maximum on
--   every store row; divide to get "% of best". Note the best store itself shows 100%.
WITH rev AS (
    SELECT s.region, f.store_key, SUM(f.total_amount) AS store_rev
    FROM fact_sales f JOIN dim_store s ON f.store_key=s.store_key
    GROUP BY s.region, f.store_key
)
SELECT
    region, store_key, store_rev,
    MAX(store_rev) OVER (PARTITION BY region) AS region_best,
    ROUND(store_rev / MAX(store_rev) OVER (PARTITION BY region) * 100, 1) AS pct_of_best
FROM rev;


-- Q51. Consecutive growth streaks in daily revenue (gaps-and-islands)
-- Business question: Group consecutive days of revenue growth into "streaks" so each
--   unbroken run of growing days shares one streak id.
-- What to return: sale_date, rev, streak_id.
-- Concept: Gaps-and-islands again: mark a 1 each time the streak BREAKS (today not
--   greater than yesterday), then a running SUM of those break-flags assigns a new id
--   every time the growth run ends. Days within the same growth run share an id.
WITH daily AS (
    SELECT d.date AS sale_date, SUM(f.total_amount) AS rev
    FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key
    GROUP BY d.date
),
flagged AS (
    SELECT sale_date, rev,
        CASE WHEN rev > LAG(rev) OVER (ORDER BY sale_date) THEN 0 ELSE 1 END AS streak_break
    FROM daily
)
SELECT sale_date, rev,
       SUM(streak_break) OVER (ORDER BY sale_date) AS streak_id
FROM flagged;


-- Q52. Dedup customers by normalized email, keep earliest join_date
-- Business question: The customer dimension may have the same person under multiple
--   rows with the same email (differing only by case/spacing). Keep one row per email
--   -- the earliest joiner.
-- What to return: one surviving customer row per normalized email.
-- Concept: PARTITION BY LOWER(TRIM(email)) NORMALIZES the key so 'A@x.com ' and
--   'a@x.com' collide; ORDER BY join_date ASC then keep rn = 1 to retain the earliest.
--   customer_key ASC is a deterministic tiebreaker.
SELECT *
FROM (
    SELECT c.*,
        ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email))
                           ORDER BY join_date ASC, customer_key ASC) AS rn
    FROM dim_customer c
) t
WHERE rn = 1;


-- =====================================================================
-- PRODUCTION / DATA ENGINEERING USE CASES (Q53 - Q60)
-- =====================================================================

-- Q53. SCD Type 2 valid_from / valid_to from change events (LEAD)
-- Business question: From a stream of attribute-change events per customer, build the
--   Slowly-Changing-Dimension Type 2 validity intervals (when each version was active).
-- What to return: customer_key, city, valid_from, valid_to, is_current.
-- Concept: LEAD(change_date) gives the NEXT change date, which becomes this version's
--   valid_to; the latest version has no successor (LEAD = NULL) so it is flagged
--   is_current = 1. Template assumes a cust_changes change table.
-- Requires a change table: cust_changes(customer_key, change_date, city)
-- SELECT
--     customer_key, city,
--     change_date AS valid_from,
--     LEAD(change_date) OVER (PARTITION BY customer_key ORDER BY change_date) AS valid_to,
--     CASE WHEN LEAD(change_date) OVER (PARTITION BY customer_key ORDER BY change_date) IS NULL
--          THEN 1 ELSE 0 END AS is_current
-- FROM cust_changes;


-- Q54. CDC: latest version per key, drop deletes
-- Business question: From a change-data-capture feed, materialize the current state --
--   keep the latest version of each row and drop rows whose last operation was a delete.
-- What to return: latest non-deleted row per sales_id.
-- Concept: ROW_NUMBER() PARTITION BY sales_id ORDER BY load_ts DESC picks the newest
--   version; keep rn = 1 AND op <> 'D' to honor deletes. Standard CDC "merge to current".
-- Requires staging.cdc_sales(sales_id, ..., op, load_ts)
-- SELECT *
-- FROM (
--     SELECT s.*,
--         ROW_NUMBER() OVER (PARTITION BY sales_id ORDER BY load_ts DESC) AS rn
--     FROM staging.cdc_sales s
-- ) t
-- WHERE rn = 1 AND op <> 'D';


-- Q55. Bronze -> Silver dedup with ingest timestamp
-- Business question: Promote raw Bronze data to a clean Silver table, keeping only the
--   most recently ingested copy of each sales_id.
-- What to return: deduplicated, typed columns written to silver.fact_sales.
-- Concept: The Medallion-architecture dedup step -- ROW_NUMBER() PARTITION BY sales_id
--   ORDER BY _ingest_ts DESC, keep rn = 1, project only the business columns. Shows
--   window dedup inside a CREATE TABLE AS.
-- Requires bronze.fact_sales with _ingest_ts
-- CREATE TABLE silver.fact_sales AS
-- SELECT sales_id, date_key, customer_key, product_key, store_key,
--        quantity_sold, unit_price, discount, total_amount
-- FROM (
--     SELECT b.*,
--         ROW_NUMBER() OVER (PARTITION BY sales_id ORDER BY _ingest_ts DESC) AS rn
--     FROM bronze.fact_sales b
-- ) t
-- WHERE rn = 1;


-- Q56. (Conceptual: late-arriving data / idempotent re-sequencing - see guide.)
-- Business question: Assign each customer a per-event sequence number that stays
--   CORRECT even after late-arriving rows are backfilled and the query is re-run.
-- What to return: customer_key, sales_id, sale_date, event_seq.
-- Concept: Because ROW_NUMBER() is computed from the ORDER BY at query time, simply
--   re-running it after a backfill RE-SEQUENCES everything correctly -- the operation
--   is idempotent. No manual renumbering needed when history changes.
SELECT
    f.customer_key, f.sales_id, d.date AS sale_date,
    ROW_NUMBER() OVER (PARTITION BY f.customer_key ORDER BY d.date, f.sales_id) AS event_seq
FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key;


-- Q57. Rolling 7-day active metrics for a dashboard
-- Business question: Power a dashboard with rolling 7-day metrics -- 7-day total
--   revenue and 7-day average revenue for each day.
-- What to return: sale_date, daily_active, daily_rev, rev_7d, avg_7d.
-- Concept: A "ROWS BETWEEN 6 PRECEDING AND CURRENT ROW" frame spans a trailing 7-day
--   window (today + 6 prior days). SUM and AVG over that frame give rolling totals.
--   COUNT(DISTINCT) in the CTE gives daily active customers.
WITH daily AS (
    SELECT d.date AS sale_date,
           COUNT(DISTINCT f.customer_key) AS daily_active,
           SUM(f.total_amount) AS daily_rev
    FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key
    GROUP BY d.date
)
SELECT
    sale_date,
    daily_active,
    daily_rev,
    SUM(daily_rev) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rev_7d,
    ROUND(AVG(daily_rev) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg_7d
FROM daily;


-- Q58. Data quality: windowed z-score outlier detection per category
-- Business question: Flag sales whose amount is a statistical outlier WITHIN their
--   product category (more than 3 standard deviations from the category mean).
-- What to return: sales_id, category, total_amount, z_score (only |z| > 3).
-- Concept: z = (value - category_mean) / category_stddev, with both mean and stddev
--   computed via OVER (PARTITION BY category). NULLIF guards a zero stddev. A reusable
--   anomaly-detection pattern for data-quality checks.
SELECT *
FROM (
    SELECT
        f.sales_id, p.category, f.total_amount,
        ROUND( (f.total_amount - AVG(f.total_amount) OVER (PARTITION BY p.category))
               / NULLIF(STDDEV(f.total_amount) OVER (PARTITION BY p.category), 0), 2) AS z_score
    FROM fact_sales f
    JOIN dim_product p ON f.product_key=p.product_key
) t
WHERE ABS(z_score) > 3;


-- Q59. Data quality: reconcile running total vs grand total (control total)
-- Business question: Sanity-check the pipeline -- does the final running total of
--   revenue equal the independently computed grand total?
-- What to return: final_running, grand_total, reconciliation (OK / MISMATCH).
-- Concept: Compute a running SUM (ORDER BY) and a grand SUM (empty OVER) side by side;
--   the LAST running value must equal the grand total. Comparing them is a "control
--   total" reconciliation -- a common automated data-quality assertion.
WITH chk AS (
    SELECT date_key,
           SUM(total_amount) OVER (ORDER BY date_key) AS running,
           SUM(total_amount) OVER () AS grand
    FROM fact_sales
)
SELECT MAX(running) AS final_running, MAX(grand) AS grand_total,
       CASE WHEN MAX(running) = MAX(grand) THEN 'OK' ELSE 'MISMATCH' END AS reconciliation
FROM chk;


-- Q60. (Conceptual: where window functions live across the platform - see guide.)
-- Business question: Build one feature row per customer for an ML/marketing mart --
--   RFM style: Recency (most recent purchase), Frequency (count), Monetary (total spend).
-- What to return: customer_key, most_recent_purchase, frequency, monetary.
-- Concept: Combine several window functions in one pass -- ROW_NUMBER (recency_rank)
--   to find the latest purchase, COUNT OVER for frequency, SUM OVER for monetary --
--   then keep recency_rank = 1 to collapse to one feature row per customer.
WITH base AS (
    SELECT
        f.customer_key, d.date AS sale_date, f.total_amount,
        ROW_NUMBER() OVER (PARTITION BY f.customer_key ORDER BY d.date DESC) AS recency_rank,
        COUNT(*)     OVER (PARTITION BY f.customer_key) AS frequency,
        SUM(f.total_amount) OVER (PARTITION BY f.customer_key) AS monetary
    FROM fact_sales f JOIN dim_date d ON f.date_key=d.date_key
)
SELECT customer_key, sale_date AS most_recent_purchase, frequency, monetary
FROM base
WHERE recency_rank = 1;


-- =====================================================================
-- END OF FILE
-- =====================================================================
