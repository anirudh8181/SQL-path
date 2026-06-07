
-- ============================================================================
-- SECTION A: BASIC (Questions 1-20)
-- Single CTE, simple aggregations, basic joins
-- ============================================================================

-- Question 1:
-- Using a CTE, compute total revenue per product category and order results
-- from highest to lowest

SELECT * FROM dim_product;
SELECT * FROM dim_customer;
SELECT * FROM fact_sales;


WITH CTE_TABLE AS
(
SELECT p.category, SUM(f.total_amount) AS Total_Revenue
FROM fact_sales f
JOIN dim_product p
ON f.product_key=p.product_key
GROUP BY p.category
)
SELECT * FROM CTE_TABLE
ORDER BY Total_Revenue DESC;



-- Question 2:
-- Using a CTE, return the top 5 customers by lifetime spend. Show full name,
-- country, total revenue and total order count.

-- Question 3:
-- With a CTE that aggregates revenue by year-month, return monthly revenue
-- ordered chronologically.

-- Question 4:
-- Using a CTE that computes the average unit_price across dim_product, list
-- every product whose unit_price exceeds the global average.

-- Question 5:
-- Using a CTE, return the number of customers per country, ordered by count
-- descending.

-- Question 6:
-- Using a CTE, find the total quantity sold per product brand. Order by total
-- quantity descending.

-- Question 7:
-- Using a CTE, compute the average order value (avg of total_amount) per store
-- region. Round to 2 decimals.

-- Question 8:
-- Using a CTE, return the number of unique customers per store. Show store
-- name, region, and unique customer count.

-- Question 9:
-- Using a CTE, compute total revenue and total transactions per customer
-- gender. Show both values side by side.

-- Question 10:
-- Using a CTE, return the top 10 most-sold products by total quantity sold.
-- Include product name and category.

-- Question 11:
-- Using a CTE, list all customers who joined in calendar year 2024. Show
-- customer_id, full name, country and join_date.

-- Question 12:
-- Using a CTE, return total number of sales transactions per quarter across
-- all years. Show year, quarter and count.

-- Question 13:
-- Using a CTE, compute the average discount per product category. Round to
-- two decimals. Order by average discount descending.

-- Question 14:
-- Using a CTE, return the number of products per brand. Show brand and
-- product count ordered descending.

-- Question 15:
-- Using a CTE, return the top 5 stores by transaction count. Show store name,
-- region and number of transactions.

-- Question 16:
-- Using a CTE, compute total revenue per year. Show year and revenue ordered
-- chronologically.

-- Question 17:
-- Using a CTE, return number of customers per US state. Limit to customers
-- located in the United States of America if such country exists; otherwise
-- show counts per state for all customers.

-- Question 18:
-- Using a CTE, list all products that were launched in 2023. Show product_id,
-- product_name, category and launch_date.

-- Question 19:
-- Using a CTE, compute the average daily revenue across the entire dataset.
-- Hint: aggregate to daily first, then average.

-- Question 20:
-- Using a CTE, return the top 5 countries by customer count. Show country
-- and customer count.


-- ============================================================================
-- SECTION B: INTERMEDIATE (Questions 21-40)
-- Multiple CTEs, window functions, ranking, running totals
-- ============================================================================

-- Question 21:
-- Build month-over-month revenue growth percentage using two chained CTEs
-- (aggregation, then LAG window function). Handle divide-by-zero safely.

-- Question 22:
-- Using a CTE pipeline, return the top 3 products by revenue within each
-- category using DENSE_RANK. Output category, product, revenue and rank.

-- Question 23:
-- Compute a running revenue total per region ordered by date using a CTE plus
-- a windowed SUM with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.

-- Question 24:
-- Segment customers into Platinum/Gold/Silver/Bronze quartiles by lifetime
-- value using NTILE(4). Return segment, customer count, avg LTV, total
-- revenue.

-- Question 25:
-- Compare weekend vs weekday sales: total revenue, average daily revenue and
-- total transactions, using dim_date.is_weekend. Aggregate to daily first.

-- Question 26:
-- Compute a 7-day rolling average of daily revenue using a CTE and a window
-- function with ROWS BETWEEN 6 PRECEDING AND CURRENT ROW.

-- Question 27:
-- For each product, compute revenue and units sold during the first 30 days
-- after its launch_date. Use a CTE to derive launch windows, then join.

-- Question 28:
-- For each customer, find their first purchase date and the number of days
-- between join_date and first purchase. Flag any pre-join anomalies.

-- Question 29:
-- Bucket sales into discount bands (No Discount, 0-10, 10-25, 25-40, 40+)
-- using a CTE. Report transaction count, total revenue, avg revenue per band.

-- Question 30:
-- Rank stores within their region by revenue using RANK(), and also produce a
-- global rank. Include unique customer count and transaction count per store.

-- Question 31:
-- Compute Year-over-Year quarterly revenue growth using LAG with offset 4.
-- Show year, quarter, current revenue, previous year revenue and YoY %.

-- Question 32:
-- For each store and each year-quarter, identify the single top-selling
-- product by revenue using ROW_NUMBER() partitioned by (store, year, quarter).

-- Question 33:
-- Compute customer lifetime value with country-level rank and global
-- percentile using RANK() and PERCENT_RANK(). Include average order value.

-- Question 34:
-- For each customer with 2+ purchases, compute the average number of days
-- between consecutive purchases. Use LAG inside a CTE.

-- Question 35:
-- For each product, determine the calendar month (YYYY-MM) in which it had
-- the highest revenue. Use ROW_NUMBER partitioned by product.

-- Question 36:
-- Segment customers by purchase frequency: Low (1-2 orders), Medium (3-5
-- orders), High (6+ orders). Show count, avg revenue and total revenue per
-- segment.

-- Question 37:
-- For each category, compute each brand's revenue contribution as a
-- percentage of category revenue. Use a windowed SUM partitioned by category.

-- Question 38:
-- Return the top 5 customers (by lifetime value) within each country. Use
-- ROW_NUMBER partitioned by country.

-- Question 39:
-- Compute quarterly revenue, previous quarter revenue, and QoQ growth
-- percentage using LAG ordered by (year, quarter).

-- Question 40:
-- For each month, compute each product category's share of total monthly
-- revenue as a percentage. Use a windowed SUM partitioned by month.


-- ============================================================================
-- SECTION C: ADVANCED (Questions 41-50)
-- Complex pipelines, recursion, anomaly detection, data quality
-- ============================================================================

-- Question 41:
-- Build a customer cohort analysis: group customers by join_date month, then
-- for each cohort show how many active customers transacted in each
-- subsequent month offset.

-- Question 42:
-- Detect potential duplicate sales: same customer_key + product_key +
-- store_key + date with more than one fact_sales row. Return all duplicates
-- flagged with a duplicate_count and sequence number.

-- Question 43:
-- Find customers who purchased in 2 or more consecutive calendar months. Use
-- a CTE of distinct customer-purchase months, LAG to find previous month and
-- PERIOD_DIFF to count gap = 1 occurrences.

-- Question 44:
-- Identify dates in dim_date that have zero fact_sales activity (gap
-- analysis). Restrict to dates on or before the latest observed sales date.

-- Question 45:
-- Build an RFM (Recency, Frequency, Monetary) score per customer using
-- NTILE(5) on each dimension. Tag customers as Champion / Loyal / At Risk /
-- Regular.

-- Question 46:
-- Perform Pareto (80/20) analysis on products: sort by revenue, compute
-- cumulative revenue percentage and tag each product as "Top 80%" or
-- "Long Tail".

-- Question 47:
-- Identify "churned" customers: those whose last purchase occurred more than
-- 90 days before the latest date in the dataset. Show days since last
-- purchase.

-- Question 48:
-- Using a RECURSIVE CTE, generate every calendar date between MIN(date) and
-- MAX(date) in dim_date and identify any missing calendar dates in dim_date.

-- Question 49:
-- Build a data quality audit pipeline using multiple CTEs: detect orphan
-- foreign keys in fact_sales (missing customer/product/store/date), negative
-- totals, zero/negative quantity, and discount > unit_price. Return issue
-- type and count.

-- Question 50:
-- Detect anomalous transactions per product: rows whose total_amount is more
-- than 3 standard deviations from that product's mean. Use a CTE for
-- product-level stats, join back to fact_sales, return z-score.
