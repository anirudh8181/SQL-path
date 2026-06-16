-- =====================================================================
-- SQL WINDOW FUNCTIONS - INTERVIEW QUESTIONS ONLY
-- Schema: Real_Sales (star schema) -- see Insert_script.sql for full DDL/data
--   fact_sales(sales_id, date_key, customer_key, product_key, store_key,
--              quantity_sold, unit_price, discount, total_amount)
--   dim_date(date_key, date, day, month, month_name, quarter, year, is_weekend)
--   dim_customer(customer_key, customer_id, first_name, last_name, gender,
--                email, phone, country, state, city, join_date)
--   dim_product(product_key, product_id, product_name, category, brand,
--               unit_price, launch_date)
--   dim_store(store_key, store_id, store_name, region, country, city)
--
-- Practice file: write the query for each question yourself.
-- Solutions are in Window_Functions_Interview_Queries.sql
-- =====================================================================


-- =====================================================================
-- BEGINNER (Q1 - Q14)
-- =====================================================================

-- Q1. Window function vs aggregate: For every individual sale line, also show
--     the grand total this customer has spent across all of their purchases
--     (keep every detail row -- do not collapse with GROUP BY).


-- Q2. Number each customer's purchases in chronological order: label each
--     customer's 1st, 2nd, 3rd ... purchase in the order they happened.


-- Q3. Percentage of grand total: for each sale, what percentage of the
--     company's overall revenue does that single sale represent?


-- Q4. ROW_NUMBER vs RANK vs DENSE_RANK: rank sales by amount (highest first)
--     and show all three ranking functions side by side to compare how each
--     treats ties.


-- Q5. Latest record per customer: pull the single most recent purchase (the
--     full row) for each customer.


-- Q6. PARTITION BY vs GROUP BY: for each sale, show both the total this
--     customer has spent AND the total revenue this product has generated, on
--     the same row.


-- Q7. Running total of revenue ordered by date for the whole company: each
--     day's row carries the cumulative revenue up to and including it.


-- Q8. Per-customer running total: a cumulative spend that resets per customer
--     and grows with every successive purchase (running balance).


-- Q9. Each sale vs customer average: for each sale, how far above or below is
--     it compared to that customer's average purchase size?


-- Q10. COUNT() OVER: for each customer show both their TOTAL number of
--      purchases and a running count (purchases so far up to this row).


-- Q11. Previous sale amount per customer (LAG): for each purchase, what was the
--      amount of this customer's immediately preceding purchase?


-- Q12. Next sale amount per customer (LEAD): for each purchase, what will this
--      customer's next purchase amount be?


-- Q13. LAG with offset and default: for each purchase, fetch the amount 1
--      purchase back and 2 purchases back, showing 0 instead of NULL when there
--      is no such prior row.


-- Q14. Reusable named WINDOW clause: compute a per-customer running sum AND
--      running average without repeating the same window definition twice.


-- =====================================================================
-- INTERMEDIATE (Q15 - Q32)
-- =====================================================================

-- Q15. Top 2 products by revenue within each category: which 2 products earned
--      the most total revenue in every category?


-- Q16. 3-day moving average of daily revenue: smooth daily revenue using today
--      plus the two days before.


-- Q17. Day-over-day revenue change and % growth: how much did daily revenue
--      change versus the previous day, in absolute terms and as a percentage?


-- Q18. Customer spending quartiles (NTILE): split customers into 4 equal-sized
--      spending buckets (1 = top spenders ... 4 = bottom).


-- Q19. First and last purchase date per customer using FIRST_VALUE / LAST_VALUE
--      (mind the default-frame trap on LAST_VALUE).


-- Q20. Same as Q19 but using the safe MIN/MAX OVER idiom (no frame trap):
--      first and last purchase date per customer.


-- Q21. 2nd purchase amount per customer (NTH_VALUE): what was the amount of each
--      customer's SECOND purchase?


-- Q22. Each store's % contribution to its region revenue: within each region,
--      what share of the region's total revenue does each store contribute?


-- Q23. Rank months by revenue within each year: within each year, rank the
--      calendar months from best to worst revenue.


-- Q24. Weekly revenue vs last week vs 2 weeks ago: for each week show this
--      week's revenue alongside last week's and the week before (multi-offset LAG).


-- Q25. Sales above their store's average: which individual sales exceeded the
--      average sale size of the store they happened in?


-- Q26. PERCENT_RANK and CUME_DIST on customer spend: where does each customer
--      sit in the spending distribution (relative rank and cumulative position)?


-- Q27. Running MIN and MAX revenue to date: as sales happen over time, track the
--      smallest and largest single-sale amount seen so far.


-- Q28. Global vs per-region row numbering: rank every sale by amount both across
--      the ENTIRE company and separately WITHIN its own region, on the same row.


-- Q29. Aggregate vs window (conceptual): show how a plain GROUP BY collapses each
--      customer into ONE summary row (count + total), losing the detail rows.


-- Q30. ROWS vs RANGE running total: build a running total two ways and observe
--      how they differ when several sales share the SAME date.


-- Q31. Centered window: smooth daily revenue using a window centered on each day
--      (the day itself plus one day before and one day after).


-- Q32. Trailing window excluding current row: for each purchase, the customer's
--      average spend over their previous 3 purchases (NOT counting the current).


-- =====================================================================
-- ADVANCED (Q33 - Q44)
-- =====================================================================

-- Q33. Gap detection in a customer's daily purchasing: find consecutive
--      purchases more than 1 day apart and report the gap in days.


-- Q34. Sessionization: group each customer's purchases into sessions, starting a
--      new session whenever there is a gap of more than 1 day since the last
--      purchase (flag + cumulative SUM to assign a session id).


-- Q35. Deduplicate fact_sales by natural key (date+customer+product+store),
--      keeping only the latest copy (highest sales_id) of each.


-- Q36. Identify duplicate records and copy counts: list rows duplicated on the
--      natural key and show how many copies each duplicated key has.


-- Q37. Month-to-date (MTD) and year-to-date (YTD) running revenue: for each day,
--      show cumulative revenue since the start of the month and since the start
--      of the year.


-- Q38. Last-observation-carried-forward (LOCF) gap fill: given a sparse daily
--      series with missing values, fill each gap by carrying the most recent
--      non-null observation forward.


-- Q39. Difference between each sale and the customer's first sale: for each
--      purchase, how much bigger or smaller is it than that customer's very
--      first purchase (FIRST_VALUE baseline)?


-- Q40. Largest single-day revenue drop per store: for each store, find the day
--      on which revenue fell the most compared to the prior active day.


-- Q41. Weighted running total: per-customer running total of gross value where
--      each row's contribution is quantity_sold * unit_price.


-- Q42. Stable, reproducible ranking: produce a deterministic ranking of sales by
--      amount that yields the exact same order on every re-run, even across ties
--      (use unique tiebreakers).


-- Q43. Performance / window reuse: compute three running metrics (sum, avg,
--      count) per customer efficiently by defining the window once (WINDOW clause).


-- Q44. Control NULL ordering: rank sales by discount (highest first) but always
--      push rows with a NULL discount to the bottom (force NULLs last in MySQL).


-- =====================================================================
-- SCENARIO-BASED (Q45 - Q52)
-- =====================================================================

-- Q45. Churn signal: flag customers as a churn risk if their most recent
--      purchase was more than 90 days ago (use a fixed reference date for
--      reproducibility).


-- Q46. Running account balance: maintain a per-customer running balance where
--      each sale adds a credit (total_amount) and subtracts a debit (discount).


-- Q47. Best-selling product per region (Top-1): in each region, which product
--      generated the most revenue? Keep all products if there is a tie (RANK).


-- Q48. VIP segmentation by spend percentile: segment customers into VIP / Mid /
--      Low tiers based on where their lifetime spend falls in the percentile
--      distribution (PERCENT_RANK).


-- Q49. First purchase by category per customer (cross-sell): for each customer,
--      identify the first product they ever bought in each category.


-- Q50. Each store's revenue vs the best store in its region: show each store's
--      revenue as a percentage of the regional leader's revenue.


-- Q51. Consecutive growth streaks in daily revenue: group consecutive days of
--      revenue growth into streaks so each unbroken run shares one streak id
--      (gaps-and-islands).


-- Q52. Dedup customers by normalized email: keep one row per email
--      (case/whitespace-insensitive), retaining the earliest join_date.


-- =====================================================================
-- PRODUCTION / DATA ENGINEERING USE CASES (Q53 - Q60)
-- =====================================================================

-- Q53. SCD Type 2: from a stream of attribute-change events per customer, build
--      the valid_from / valid_to validity intervals and flag the current version
--      (LEAD). Assumes a cust_changes(customer_key, change_date, city) table.


-- Q54. CDC: from a change-data-capture feed, materialize the current state --
--      keep the latest version of each key and drop rows whose last operation was
--      a delete. Assumes staging.cdc_sales(sales_id, ..., op, load_ts).


-- Q55. Bronze -> Silver dedup: promote raw Bronze data to a clean Silver table,
--      keeping only the most recently ingested copy of each sales_id (uses
--      bronze.fact_sales with _ingest_ts).


-- Q56. Late-arriving data / idempotent re-sequencing: assign each customer a
--      per-event sequence number that stays correct even after late rows are
--      backfilled and the query is re-run.


-- Q57. Rolling 7-day active metrics for a dashboard: for each day, compute 7-day
--      total revenue and 7-day average revenue (trailing window), plus daily
--      active customers.


-- Q58. Data quality - windowed z-score outlier detection: flag sales whose amount
--      is more than 3 standard deviations from the mean WITHIN their product
--      category.


-- Q59. Data quality - control total reconciliation: verify that the final running
--      total of revenue equals the independently computed grand total (OK /
--      MISMATCH).


-- Q60. RFM feature row per customer: build one feature row per customer for an
--      ML/marketing mart -- Recency (most recent purchase), Frequency (count of
--      purchases), Monetary (total spend).


-- =====================================================================
-- END OF FILE
-- =====================================================================
