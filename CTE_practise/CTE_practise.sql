-- ============================================================================
-- Real_Sales | CTE Practice 
-- ============================================================================
-- Structure : 20 Basic | 20 Intermediate | 10 Advanced
-- ============================================================================
USE Real_Sales;


-- ============================================================================
-- SECTION A: BASIC (Questions 1-20)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 1: Total revenue per category, ordered descending.
-- Concept: Single CTE + aggregation.
-- ----------------------------------------------------------------------------

WITH category_revenue AS (
    SELECT  p.category,
            SUM(f.total_amount) AS total_revenue
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT  category,
        ROUND(total_revenue, 2) AS total_revenue
FROM    category_revenue
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- Question 2: Top 5 customers by lifetime spend.
-- Concept: CTE + GROUP BY + LIMIT.
-- ----------------------------------------------------------------------------

WITH customer_spend AS (
    SELECT  c.customer_key,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            c.country,
            SUM(f.total_amount)                    AS lifetime_value,
            COUNT(*)                               AS order_count
    FROM    fact_sales f
    JOIN    dim_customer c ON c.customer_key = f.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name, c.country
)
SELECT  customer_name, country,
        ROUND(lifetime_value, 2) AS lifetime_value,
        order_count
FROM    customer_spend
ORDER BY lifetime_value DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- Question 3: Monthly revenue trend chronologically.
-- Concept: CTE + date dimension aggregation.
-- ----------------------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT  d.year, d.month, d.month_name,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_date d ON d.date_key = f.date_key
    GROUP BY d.year, d.month, d.month_name
)
SELECT  year, month, month_name,
        ROUND(revenue, 2) AS revenue
FROM    monthly_revenue
ORDER BY year, month;


-- ----------------------------------------------------------------------------
-- Question 4: Products with unit_price above the global average.
-- Concept: Scalar CTE + CROSS JOIN.
-- ----------------------------------------------------------------------------
WITH price_stats AS (
    SELECT AVG(unit_price) AS avg_price FROM dim_product
)
SELECT  p.product_id, p.product_name, p.category,
        p.unit_price,
        ROUND(ps.avg_price, 2) AS global_avg_price
FROM    dim_product p
CROSS JOIN price_stats ps
WHERE   p.unit_price > ps.avg_price
ORDER BY p.unit_price DESC;


-- ----------------------------------------------------------------------------
-- Question 5: Customers per country.
-- Concept: CTE + aggregation.
-- ----------------------------------------------------------------------------
WITH country_count AS (
    SELECT  country, COUNT(*) AS customer_count
    FROM    dim_customer
    GROUP BY country
)
SELECT  country, customer_count
FROM    country_count
ORDER BY customer_count DESC;


-- ----------------------------------------------------------------------------
-- Question 6: Total quantity sold per product brand.
-- Concept: CTE + JOIN + SUM.
-- ----------------------------------------------------------------------------
WITH brand_units AS (
    SELECT  p.brand,
            SUM(f.quantity_sold) AS total_units
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    GROUP BY p.brand
)
SELECT  brand, total_units
FROM    brand_units
ORDER BY total_units DESC;


-- ----------------------------------------------------------------------------
-- Question 7: Average order value per region.
-- Concept: CTE + AVG + ROUND.
-- ----------------------------------------------------------------------------
WITH region_aov AS (
    SELECT  s.region,
            ROUND(AVG(f.total_amount), 2) AS avg_order_value,
            COUNT(*)                      AS transaction_count
    FROM    fact_sales f
    JOIN    dim_store s ON s.store_key = f.store_key
    GROUP BY s.region
)
SELECT  region, avg_order_value, transaction_count
FROM    region_aov
ORDER BY avg_order_value DESC;


-- ----------------------------------------------------------------------------
-- Question 8: Unique customers per store.
-- Concept: CTE + COUNT(DISTINCT).
-- ----------------------------------------------------------------------------
WITH store_customers AS (
    SELECT  s.store_id, s.store_name, s.region,
            COUNT(DISTINCT f.customer_key) AS unique_customers
    FROM    fact_sales f
    JOIN    dim_store s ON s.store_key = f.store_key
    GROUP BY s.store_id, s.store_name, s.region
)
SELECT  store_id, store_name, region, unique_customers
FROM    store_customers
ORDER BY unique_customers DESC;


-- ----------------------------------------------------------------------------
-- Question 9: Total revenue and transactions per gender.
-- Concept: CTE + JOIN on customer attribute.
-- ----------------------------------------------------------------------------
WITH gender_stats AS (
    SELECT  c.gender,
            SUM(f.total_amount) AS total_revenue,
            COUNT(*)            AS total_transactions
    FROM    fact_sales f
    JOIN    dim_customer c ON c.customer_key = f.customer_key
    GROUP BY c.gender
)
SELECT  gender,
        ROUND(total_revenue, 2) AS total_revenue,
        total_transactions
FROM    gender_stats
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- Question 10: Top 10 most-sold products by quantity.
-- Concept: CTE + JOIN + LIMIT.
-- ----------------------------------------------------------------------------
WITH product_units AS (
    SELECT  p.product_id, p.product_name, p.category,
            SUM(f.quantity_sold) AS total_units
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT  product_id, product_name, category, total_units
FROM    product_units
ORDER BY total_units DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- Question 11: Customers who joined in 2024.
-- Concept: CTE + date filter.
-- ----------------------------------------------------------------------------
WITH joined_2024 AS (
    SELECT  customer_id,
            CONCAT(first_name, ' ', last_name) AS customer_name,
            country, join_date
    FROM    dim_customer
    WHERE   YEAR(join_date) = 2024
)
SELECT  customer_id, customer_name, country, join_date
FROM    joined_2024
ORDER BY join_date;


-- ----------------------------------------------------------------------------
-- Question 12: Sales transactions per quarter.
-- Concept: CTE + JOIN to dim_date.
-- ----------------------------------------------------------------------------
WITH quarterly_tx AS (
    SELECT  d.year, d.quarter,
            COUNT(*) AS transaction_count
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.year, d.quarter
)
SELECT  year, quarter, transaction_count
FROM    quarterly_tx
ORDER BY year, quarter;


-- ----------------------------------------------------------------------------
-- Question 13: Average discount per category.
-- Concept: CTE + AVG + JOIN.
-- ----------------------------------------------------------------------------
WITH category_discount AS (
    SELECT  p.category,
            ROUND(AVG(f.discount), 2) AS avg_discount
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT  category, avg_discount
FROM    category_discount
ORDER BY avg_discount DESC;


-- ----------------------------------------------------------------------------
-- Question 14: Number of products per brand.
-- Concept: CTE + COUNT.
-- ----------------------------------------------------------------------------
WITH brand_products AS (
    SELECT  brand, COUNT(*) AS product_count
    FROM    dim_product
    GROUP BY brand
)
SELECT  brand, product_count
FROM    brand_products
ORDER BY product_count DESC;


-- ----------------------------------------------------------------------------
-- Question 15: Top 5 stores by transaction count.
-- Concept: CTE + COUNT + LIMIT.
-- ----------------------------------------------------------------------------
WITH store_tx AS (
    SELECT  s.store_name, s.region,
            COUNT(*) AS transaction_count
    FROM    fact_sales f
    JOIN    dim_store  s ON s.store_key = f.store_key
    GROUP BY s.store_name, s.region
)
SELECT  store_name, region, transaction_count
FROM    store_tx
ORDER BY transaction_count DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- Question 16: Total revenue per year.
-- Concept: CTE + JOIN + SUM grouped by year.
-- ----------------------------------------------------------------------------
WITH yearly_revenue AS (
    SELECT  d.year,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.year
)
SELECT  year, ROUND(revenue, 2) AS revenue
FROM    yearly_revenue
ORDER BY year;


-- ----------------------------------------------------------------------------
-- Question 17: Customers per state.
-- Concept: CTE + COUNT grouped by state.
-- ----------------------------------------------------------------------------
WITH state_count AS (
    SELECT  state, COUNT(*) AS customer_count
    FROM    dim_customer
    GROUP BY state
)
SELECT  state, customer_count
FROM    state_count
ORDER BY customer_count DESC;


-- ----------------------------------------------------------------------------
-- Question 18: Products launched in 2023.
-- Concept: CTE + date filter on dim_product.
-- ----------------------------------------------------------------------------
WITH launches_2023 AS (
    SELECT  product_id, product_name, category, brand, launch_date
    FROM    dim_product
    WHERE   YEAR(launch_date) = 2023
)
SELECT  product_id, product_name, category, brand, launch_date
FROM    launches_2023
ORDER BY launch_date;


-- ----------------------------------------------------------------------------
-- Question 19: Average daily revenue.
-- Concept: Chained CTE — aggregate to daily, then average.
-- ----------------------------------------------------------------------------
WITH daily_revenue AS (
    SELECT  d.date,
            SUM(f.total_amount) AS daily_total
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.date
)
SELECT  ROUND(AVG(daily_total), 2) AS avg_daily_revenue,
        COUNT(*)                   AS active_sales_days
FROM    daily_revenue;


-- ----------------------------------------------------------------------------
-- Question 20: Top 5 countries by customer count.
-- Concept: CTE + COUNT + LIMIT.
-- ----------------------------------------------------------------------------
WITH country_customers AS (
    SELECT  country, COUNT(*) AS customer_count
    FROM    dim_customer
    GROUP BY country
)
SELECT  country, customer_count
FROM    country_customers
ORDER BY customer_count DESC
LIMIT 5;



-- ============================================================================
-- SECTION B: INTERMEDIATE (Questions 21-40)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 21: Month-over-Month revenue growth %.
-- Concept: Multiple CTEs + LAG + safe division.
-- ----------------------------------------------------------------------------
WITH monthly_sales AS (
    SELECT  d.year, d.month,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.year, d.month
),
with_lag AS (
    SELECT  year, month, revenue,
            LAG(revenue) OVER (ORDER BY year, month) AS prev_revenue
    FROM    monthly_sales
)
SELECT  year, month,
        ROUND(revenue, 2)            AS revenue,
        ROUND(prev_revenue, 2)       AS prev_month_revenue,
        ROUND((revenue - prev_revenue) * 100.0
              / NULLIF(prev_revenue, 0), 2) AS mom_growth_pct
FROM    with_lag
ORDER BY year, month;


-- ----------------------------------------------------------------------------
-- Question 22: Top 3 products per category by revenue.
-- Concept: Multiple CTE + DENSE_RANK.
-- ----------------------------------------------------------------------------
WITH product_sales AS (
    SELECT  p.category, p.product_id, p.product_name,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    GROUP BY p.category, p.product_id, p.product_name
),
ranked AS (
    SELECT  ps.*,
            DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM    product_sales ps
)
SELECT  category, product_id, product_name,
        ROUND(revenue, 2) AS revenue, rnk
FROM    ranked
WHERE   rnk <= 3
ORDER BY category, rnk;


-- ----------------------------------------------------------------------------
-- Question 23: Running revenue total per region by date.
-- Concept: CTE + cumulative SUM window frame.
-- ----------------------------------------------------------------------------
WITH region_daily AS (
    SELECT  s.region, d.date,
            SUM(f.total_amount) AS daily_revenue
    FROM    fact_sales f
    JOIN    dim_store s ON s.store_key = f.store_key
    JOIN    dim_date  d ON d.date_key  = f.date_key
    GROUP BY s.region, d.date
)
SELECT  region, date,
        ROUND(daily_revenue, 2) AS daily_revenue,
        ROUND(SUM(daily_revenue) OVER (
                  PARTITION BY region ORDER BY date
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total
FROM    region_daily
ORDER BY region, date;


-- ----------------------------------------------------------------------------
-- Question 24: LTV quartile segmentation with NTILE(4).
-- Concept: NTILE bucketing.
-- ----------------------------------------------------------------------------
WITH customer_spend AS (
    SELECT  customer_key, SUM(total_amount) AS lifetime_value
    FROM    fact_sales
    GROUP BY customer_key
),
quartiles AS (
    SELECT  customer_key, lifetime_value,
            NTILE(4) OVER (ORDER BY lifetime_value DESC) AS quartile
    FROM    customer_spend
)
SELECT  CASE quartile
            WHEN 1 THEN 'Platinum'
            WHEN 2 THEN 'Gold'
            WHEN 3 THEN 'Silver'
            WHEN 4 THEN 'Bronze'
        END                              AS segment,
        COUNT(*)                         AS customer_count,
        ROUND(AVG(lifetime_value), 2)    AS avg_ltv,
        ROUND(SUM(lifetime_value), 2)    AS segment_revenue
FROM    quartiles
GROUP BY quartile
ORDER BY quartile;


-- ----------------------------------------------------------------------------
-- Question 25: Weekend vs weekday sales comparison.
-- Concept: Conditional aggregation + per-day grain.
-- ----------------------------------------------------------------------------
WITH day_type_sales AS (
    SELECT  CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
            d.date,
            SUM(f.total_amount) AS daily_revenue,
            COUNT(*)            AS transactions
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.is_weekend, d.date
)
SELECT  day_type,
        COUNT(DISTINCT date)         AS num_days,
        ROUND(SUM(daily_revenue), 2) AS total_revenue,
        ROUND(AVG(daily_revenue), 2) AS avg_daily_revenue,
        SUM(transactions)            AS total_transactions
FROM    day_type_sales
GROUP BY day_type
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- Question 26: 7-day rolling average revenue.
-- Concept: Sliding window AVG.
-- ----------------------------------------------------------------------------
WITH daily_sales AS (
    SELECT  d.date, SUM(f.total_amount) AS daily_revenue
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.date
)
SELECT  date,
        ROUND(daily_revenue, 2) AS daily_revenue,
        ROUND(AVG(daily_revenue) OVER (
                  ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7day_avg
FROM    daily_sales
ORDER BY date;


-- ----------------------------------------------------------------------------
-- Question 27: Product first-30-days launch revenue.
-- Concept: Per-row dynamic date range + multi-CTE join.
-- ----------------------------------------------------------------------------
WITH launch_window AS (
    SELECT  product_key, product_id, product_name, launch_date,
            DATE_ADD(launch_date, INTERVAL 30 DAY) AS window_end
    FROM    dim_product
),
launch_sales AS (
    SELECT  lw.product_id, lw.product_name, lw.launch_date,
            SUM(f.total_amount)  AS revenue_first_30d,
            SUM(f.quantity_sold) AS units_first_30d,
            COUNT(*)             AS txn_first_30d
    FROM    launch_window lw
    JOIN    fact_sales f ON f.product_key = lw.product_key
    JOIN    dim_date   d ON d.date_key    = f.date_key
    WHERE   d.date BETWEEN lw.launch_date AND lw.window_end
    GROUP BY lw.product_id, lw.product_name, lw.launch_date
)
SELECT  product_id, product_name, launch_date,
        ROUND(revenue_first_30d, 2) AS revenue_first_30d,
        units_first_30d, txn_first_30d
FROM    launch_sales
ORDER BY revenue_first_30d DESC
LIMIT 20;


-- ----------------------------------------------------------------------------
-- Question 28: Customer first purchase analysis + anomaly flag.
-- Concept: CTE + DATEDIFF + data quality flag.
-- ----------------------------------------------------------------------------
WITH first_purchase AS (
    SELECT  f.customer_key,
            MIN(d.date) AS first_purchase_date
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY f.customer_key
)
SELECT  c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.join_date,
        fp.first_purchase_date,
        DATEDIFF(fp.first_purchase_date, c.join_date) AS days_to_first_purchase,
        CASE WHEN fp.first_purchase_date < c.join_date THEN 'Pre-join anomaly'
             ELSE 'OK' END AS data_quality_flag
FROM    dim_customer  c
JOIN    first_purchase fp ON fp.customer_key = c.customer_key
ORDER BY days_to_first_purchase;


-- ----------------------------------------------------------------------------
-- Question 29: Discount band revenue breakdown.
-- Concept: CASE bucketing inside CTE.
-- ----------------------------------------------------------------------------
WITH banded AS (
    SELECT  CASE
                WHEN discount =  0  THEN '0_no_discount'
                WHEN discount <= 10 THEN '1_0-10'
                WHEN discount <= 25 THEN '2_10-25'
                WHEN discount <= 40 THEN '3_25-40'
                ELSE                     '4_40+'
            END AS discount_band,
            total_amount, quantity_sold
    FROM    fact_sales
)
SELECT  discount_band,
        COUNT(*)                       AS num_transactions,
        ROUND(SUM(total_amount), 2)    AS total_revenue,
        ROUND(AVG(total_amount), 2)    AS avg_revenue,
        SUM(quantity_sold)             AS total_units
FROM    banded
GROUP BY discount_band
ORDER BY discount_band;


-- ----------------------------------------------------------------------------
-- Question 30: Store performance with region + global rank.
-- Concept: Two RANK windows.
-- ----------------------------------------------------------------------------
WITH store_perf AS (
    SELECT  s.store_id, s.store_name, s.region,
            SUM(f.total_amount)             AS revenue,
            COUNT(DISTINCT f.customer_key)  AS unique_customers,
            COUNT(*)                        AS transactions
    FROM    fact_sales f
    JOIN    dim_store s ON s.store_key = f.store_key
    GROUP BY s.store_id, s.store_name, s.region
)
SELECT  store_id, store_name, region,
        ROUND(revenue, 2) AS revenue,
        unique_customers, transactions,
        RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS region_rank,
        RANK() OVER (ORDER BY revenue DESC)                     AS global_rank
FROM    store_perf
ORDER BY revenue DESC;


-- ----------------------------------------------------------------------------
-- Question 31: YoY quarterly revenue growth.
-- Concept: LAG with offset 4.
-- ----------------------------------------------------------------------------
WITH quarterly_sales AS (
    SELECT  d.year, d.quarter,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.year, d.quarter
),
with_yoy AS (
    SELECT  year, quarter, revenue,
            LAG(revenue, 4) OVER (ORDER BY year, quarter) AS prev_year_revenue
    FROM    quarterly_sales
)
SELECT  year, quarter,
        ROUND(revenue, 2)            AS revenue,
        ROUND(prev_year_revenue, 2)  AS prev_year_revenue,
        ROUND((revenue - prev_year_revenue) * 100.0
              / NULLIF(prev_year_revenue, 0), 2) AS yoy_growth_pct
FROM    with_yoy
ORDER BY year, quarter;


-- ----------------------------------------------------------------------------
-- Question 32: Top product per store per quarter.
-- Concept: ROW_NUMBER over composite partition.
-- ----------------------------------------------------------------------------
WITH spq AS (
    SELECT  s.store_id, s.store_name, d.year, d.quarter,
            p.product_id, p.product_name,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_store   s ON s.store_key   = f.store_key
    JOIN    dim_product p ON p.product_key = f.product_key
    JOIN    dim_date    d ON d.date_key    = f.date_key
    GROUP BY s.store_id, s.store_name, d.year, d.quarter, p.product_id, p.product_name
),
ranked AS (
    SELECT  spq.*,
            ROW_NUMBER() OVER (
                PARTITION BY store_id, year, quarter
                ORDER BY revenue DESC
            ) AS rn
    FROM    spq
)
SELECT  store_id, store_name, year, quarter,
        product_id, product_name,
        ROUND(revenue, 2) AS revenue
FROM    ranked
WHERE   rn = 1
ORDER BY year, quarter, store_id;


-- ----------------------------------------------------------------------------
-- Question 33: LTV with country rank + global percentile.
-- Concept: RANK + PERCENT_RANK + AOV.
-- ----------------------------------------------------------------------------
WITH customer_ltv AS (
    SELECT  c.customer_key, c.customer_id, c.country, c.join_date,
            SUM(f.total_amount)  AS ltv,
            COUNT(*)             AS order_count,
            MIN(d.date)          AS first_order,
            MAX(d.date)          AS last_order
    FROM    dim_customer c
    JOIN    fact_sales   f ON f.customer_key = c.customer_key
    JOIN    dim_date     d ON d.date_key     = f.date_key
    GROUP BY c.customer_key, c.customer_id, c.country, c.join_date
)
SELECT  customer_id, country,
        ROUND(ltv, 2)                                                 AS ltv,
        order_count,
        ROUND(ltv / NULLIF(order_count, 0), 2)                        AS avg_order_value,
        DATEDIFF(last_order, first_order)                             AS active_days,
        RANK()         OVER (PARTITION BY country ORDER BY ltv DESC)  AS country_rank,
        ROUND(PERCENT_RANK() OVER (ORDER BY ltv) * 100, 2)            AS global_percentile
FROM    customer_ltv
ORDER BY ltv DESC;


-- ----------------------------------------------------------------------------
-- Question 34: Avg days between consecutive purchases per customer.
-- Concept: LAG + DATEDIFF + filter for repeat buyers.
-- ----------------------------------------------------------------------------
WITH customer_orders AS (
    SELECT  f.customer_key, d.date,
            LAG(d.date) OVER (PARTITION BY f.customer_key ORDER BY d.date) AS prev_date
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
),
gaps AS (
    SELECT  customer_key,
            DATEDIFF(date, prev_date) AS days_between
    FROM    customer_orders
    WHERE   prev_date IS NOT NULL
)
SELECT  c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(g.days_between)                  AS gap_count,
        ROUND(AVG(g.days_between), 2)          AS avg_days_between_purchases
FROM    gaps g
JOIN    dim_customer c ON c.customer_key = g.customer_key
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_days_between_purchases;


-- ----------------------------------------------------------------------------
-- Question 35: Best-selling month per product.
-- Concept: ROW_NUMBER partitioned by product.
-- ----------------------------------------------------------------------------
WITH product_month_sales AS (
    SELECT  p.product_id, p.product_name,
            DATE_FORMAT(d.date, '%Y-%m') AS year_month,
            SUM(f.total_amount)          AS revenue
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    JOIN    dim_date    d ON d.date_key    = f.date_key
    GROUP BY p.product_id, p.product_name, DATE_FORMAT(d.date, '%Y-%m')
),
ranked AS (
    SELECT  pms.*,
            ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY revenue DESC) AS rn
    FROM    product_month_sales pms
)
SELECT  product_id, product_name, year_month AS best_month,
        ROUND(revenue, 2) AS best_month_revenue
FROM    ranked
WHERE   rn = 1
ORDER BY best_month_revenue DESC
LIMIT 50;


-- ----------------------------------------------------------------------------
-- Question 36: Frequency segments (Low / Medium / High).
-- Concept: CASE-based segmentation on aggregated count.
-- ----------------------------------------------------------------------------
WITH customer_freq AS (
    SELECT  customer_key,
            COUNT(*)            AS order_count,
            SUM(total_amount)   AS lifetime_value
    FROM    fact_sales
    GROUP BY customer_key
),
segmented AS (
    SELECT  customer_key, order_count, lifetime_value,
            CASE
                WHEN order_count BETWEEN 1 AND 2 THEN 'Low (1-2)'
                WHEN order_count BETWEEN 3 AND 5 THEN 'Medium (3-5)'
                ELSE                                  'High (6+)'
            END AS frequency_segment
    FROM    customer_freq
)
SELECT  frequency_segment,
        COUNT(*)                       AS customer_count,
        ROUND(AVG(lifetime_value), 2)  AS avg_revenue,
        ROUND(SUM(lifetime_value), 2)  AS total_revenue
FROM    segmented
GROUP BY frequency_segment
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- Question 37: Brand contribution within category.
-- Concept: Windowed SUM partitioned by category.
-- ----------------------------------------------------------------------------
WITH brand_in_cat AS (
    SELECT  p.category, p.brand,
            SUM(f.total_amount) AS brand_revenue
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    GROUP BY p.category, p.brand
)
SELECT  category, brand,
        ROUND(brand_revenue, 2)                                                  AS brand_revenue,
        ROUND(SUM(brand_revenue) OVER (PARTITION BY category), 2)                AS category_revenue,
        ROUND(brand_revenue * 100.0
              / SUM(brand_revenue) OVER (PARTITION BY category), 2)              AS pct_of_category
FROM    brand_in_cat
ORDER BY category, brand_revenue DESC;


-- ----------------------------------------------------------------------------
-- Question 38: Top 5 customers per country by LTV.
-- Concept: ROW_NUMBER partitioned by country.
-- ----------------------------------------------------------------------------
WITH customer_ltv AS (
    SELECT  c.country, c.customer_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            SUM(f.total_amount) AS lifetime_value
    FROM    fact_sales  f
    JOIN    dim_customer c ON c.customer_key = f.customer_key
    GROUP BY c.country, c.customer_id, c.first_name, c.last_name
),
ranked AS (
    SELECT  cl.*,
            ROW_NUMBER() OVER (PARTITION BY country ORDER BY lifetime_value DESC) AS rn
    FROM    customer_ltv cl
)
SELECT  country, customer_id, customer_name,
        ROUND(lifetime_value, 2) AS lifetime_value, rn AS country_rank
FROM    ranked
WHERE   rn <= 5
ORDER BY country, country_rank;


-- ----------------------------------------------------------------------------
-- Question 39: Quarter-over-Quarter revenue growth.
-- Concept: LAG ordered by (year, quarter).
-- ----------------------------------------------------------------------------
WITH quarterly AS (
    SELECT  d.year, d.quarter,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_date  d ON d.date_key = f.date_key
    GROUP BY d.year, d.quarter
),
with_prev AS (
    SELECT  year, quarter, revenue,
            LAG(revenue) OVER (ORDER BY year, quarter) AS prev_qtr_revenue
    FROM    quarterly
)
SELECT  year, quarter,
        ROUND(revenue, 2)           AS revenue,
        ROUND(prev_qtr_revenue, 2)  AS prev_quarter_revenue,
        ROUND((revenue - prev_qtr_revenue) * 100.0
              / NULLIF(prev_qtr_revenue, 0), 2) AS qoq_growth_pct
FROM    with_prev
ORDER BY year, quarter;


-- ----------------------------------------------------------------------------
-- Question 40: Monthly category share of revenue.
-- Concept: Windowed SUM partitioned by month.
-- ----------------------------------------------------------------------------
WITH cat_month AS (
    SELECT  DATE_FORMAT(d.date, '%Y-%m') AS year_month,
            p.category,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    JOIN    dim_date    d ON d.date_key    = f.date_key
    GROUP BY DATE_FORMAT(d.date, '%Y-%m'), p.category
)
SELECT  year_month, category,
        ROUND(revenue, 2) AS revenue,
        ROUND(SUM(revenue) OVER (PARTITION BY year_month), 2)                          AS month_total,
        ROUND(revenue * 100.0 / SUM(revenue) OVER (PARTITION BY year_month), 2)        AS pct_of_month
FROM    cat_month
ORDER BY year_month, pct_of_month DESC;



-- ============================================================================
-- SECTION C: ADVANCED (Questions 41-50)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Question 41: Customer cohort retention by join-month.
-- Concept: Multi-CTE + PERIOD_DIFF month offset.
-- ----------------------------------------------------------------------------
WITH customer_cohort AS (
    SELECT  customer_key,
            DATE_FORMAT(join_date, '%Y-%m') AS cohort_month
    FROM    dim_customer
),
purchase_months AS (
    SELECT  f.customer_key,
            DATE_FORMAT(d.date, '%Y-%m') AS purchase_month
    FROM    fact_sales f
    JOIN    dim_date   d ON d.date_key = f.date_key
    GROUP BY f.customer_key, DATE_FORMAT(d.date, '%Y-%m')
),
cohort_activity AS (
    SELECT  cc.cohort_month,
            pm.purchase_month,
            PERIOD_DIFF(
                REPLACE(pm.purchase_month,'-',''),
                REPLACE(cc.cohort_month,'-','')
            ) AS month_offset,
            COUNT(DISTINCT cc.customer_key) AS active_customers
    FROM    customer_cohort cc
    JOIN    purchase_months pm ON pm.customer_key = cc.customer_key
    GROUP BY cc.cohort_month, pm.purchase_month
)
SELECT  cohort_month, month_offset, active_customers
FROM    cohort_activity
WHERE   month_offset >= 0
ORDER BY cohort_month, month_offset;


-- ----------------------------------------------------------------------------
-- Question 42: Duplicate fact_sales detection.
-- Concept: Window function COUNT + ROW_NUMBER.
-- ----------------------------------------------------------------------------
WITH dup_flagged AS (
    SELECT  f.sales_id, f.customer_key, f.product_key, f.store_key,
            d.date, f.quantity_sold, f.total_amount,
            COUNT(*) OVER (
                PARTITION BY f.customer_key, f.product_key, f.store_key, d.date
            ) AS dup_count,
            ROW_NUMBER() OVER (
                PARTITION BY f.customer_key, f.product_key, f.store_key, d.date
                ORDER BY f.sales_id
            ) AS dup_seq
    FROM    fact_sales f
    JOIN    dim_date   d ON d.date_key = f.date_key
)
SELECT  *
FROM    dup_flagged
WHERE   dup_count > 1
ORDER BY customer_key, product_key, store_key, date, dup_seq;


-- ----------------------------------------------------------------------------
-- Question 43: Customers with consecutive month purchases.
-- Concept: LAG + PERIOD_DIFF + streak counting.
-- ----------------------------------------------------------------------------
WITH customer_months AS (
    SELECT DISTINCT
            f.customer_key,
            STR_TO_DATE(CONCAT(DATE_FORMAT(d.date,'%Y-%m'),'-01'),'%Y-%m-%d') AS purchase_month
    FROM    fact_sales f
    JOIN    dim_date   d ON d.date_key = f.date_key
),
with_prev AS (
    SELECT  customer_key, purchase_month,
            LAG(purchase_month) OVER (PARTITION BY customer_key ORDER BY purchase_month) AS prev_month
    FROM    customer_months
),
consecutive AS (
    SELECT  customer_key,
            SUM(CASE WHEN PERIOD_DIFF(DATE_FORMAT(purchase_month,'%Y%m'),
                                     DATE_FORMAT(prev_month,'%Y%m')) = 1
                     THEN 1 ELSE 0 END) AS consecutive_month_pairs
    FROM    with_prev
    GROUP BY customer_key
)
SELECT  c.customer_id,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        cs.consecutive_month_pairs
FROM    consecutive cs
JOIN    dim_customer c ON c.customer_key = cs.customer_key
WHERE   cs.consecutive_month_pairs >= 1
ORDER BY consecutive_month_pairs DESC;


-- ----------------------------------------------------------------------------
-- Question 44: Dates with zero sales (gap analysis).
-- Concept: Anti-join calendar to observed sales dates.
-- ----------------------------------------------------------------------------
WITH sales_dates AS (
    SELECT DISTINCT d.date
    FROM   fact_sales f
    JOIN   dim_date   d ON d.date_key = f.date_key
),
max_sales_date AS (
    SELECT MAX(date) AS upper_bound FROM sales_dates
)
SELECT  d.date AS missing_sales_date
FROM    dim_date d
LEFT JOIN sales_dates s ON s.date = d.date
CROSS JOIN max_sales_date msd
WHERE   s.date IS NULL
  AND   d.date <= msd.upper_bound
ORDER BY d.date;


-- ----------------------------------------------------------------------------
-- Question 45: RFM analysis with segmentation.
-- Concept: NTILE(5) on each of R, F, M dimensions.
-- ----------------------------------------------------------------------------
WITH ref_date AS (
    SELECT MAX(d.date) AS latest
    FROM   fact_sales f
    JOIN   dim_date   d ON d.date_key = f.date_key
),
rfm_base AS (
    SELECT  f.customer_key,
            DATEDIFF((SELECT latest FROM ref_date), MAX(d.date)) AS recency_days,
            COUNT(*)                                              AS frequency,
            SUM(f.total_amount)                                   AS monetary
    FROM    fact_sales f
    JOIN    dim_date   d ON d.date_key = f.date_key
    GROUP BY f.customer_key
),
rfm_scored AS (
    SELECT  rb.*,
            NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
            NTILE(5) OVER (ORDER BY frequency)         AS f_score,
            NTILE(5) OVER (ORDER BY monetary)          AS m_score
    FROM    rfm_base rb
)
SELECT  customer_key, recency_days, frequency,
        ROUND(monetary, 2)            AS monetary,
        r_score, f_score, m_score,
        (r_score + f_score + m_score) AS rfm_total,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal'
            WHEN r_score <= 2 AND f_score <= 2                  THEN 'At Risk'
            ELSE 'Regular'
        END AS segment
FROM    rfm_scored
ORDER BY rfm_total DESC;


-- ----------------------------------------------------------------------------
-- Question 46: Pareto (80/20) analysis on products.
-- Concept: Cumulative SUM ordered by revenue DESC.
-- ----------------------------------------------------------------------------
WITH product_revenue AS (
    SELECT  p.product_id, p.product_name,
            SUM(f.total_amount) AS revenue
    FROM    fact_sales f
    JOIN    dim_product p ON p.product_key = f.product_key
    GROUP BY p.product_id, p.product_name
),
pareto AS (
    SELECT  product_id, product_name, revenue,
            SUM(revenue) OVER (ORDER BY revenue DESC
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue,
            SUM(revenue) OVER ()                                                 AS grand_total
    FROM    product_revenue
)
SELECT  product_id, product_name,
        ROUND(revenue, 2)                                AS revenue,
        ROUND(cum_revenue * 100.0 / grand_total, 2)      AS cum_pct,
        CASE WHEN cum_revenue * 100.0 / grand_total <= 80 THEN 'Top 80%'
             ELSE 'Long Tail' END                        AS pareto_segment
FROM    pareto
ORDER BY revenue DESC;


-- ----------------------------------------------------------------------------
-- Question 47: Churned customers (no purchase in last 90 days).
-- Concept: Anchor date + last purchase per customer.
-- ----------------------------------------------------------------------------
WITH latest_in_data AS (
    SELECT MAX(d.date) AS latest_date
    FROM   fact_sales f
    JOIN   dim_date   d ON d.date_key = f.date_key
),
last_purchase AS (
    SELECT  f.customer_key,
            MAX(d.date) AS last_purchase_date
    FROM    fact_sales f
    JOIN    dim_date   d ON d.date_key = f.date_key
    GROUP BY f.customer_key
)
SELECT  c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        lp.last_purchase_date,
        DATEDIFF(ld.latest_date, lp.last_purchase_date) AS days_since_last_purchase
FROM    last_purchase  lp
JOIN    dim_customer   c  ON c.customer_key = lp.customer_key
CROSS JOIN latest_in_data ld
WHERE   DATEDIFF(ld.latest_date, lp.last_purchase_date) > 90
ORDER BY days_since_last_purchase DESC;


-- ----------------------------------------------------------------------------
-- Question 48: Recursive CTE for date dimension completeness check.
-- Concept: RECURSIVE CTE generates calendar; anti-join finds missing dates.
-- NOTE: If recursion depth exceeded, run:
--       SET SESSION cte_max_recursion_depth = 10000;
-- ----------------------------------------------------------------------------
WITH RECURSIVE bounds AS (
    SELECT MIN(date) AS min_d, MAX(date) AS max_d FROM dim_date
),
calendar AS (
    SELECT (SELECT min_d FROM bounds) AS gen_date
    UNION ALL
    SELECT DATE_ADD(gen_date, INTERVAL 1 DAY)
    FROM   calendar
    WHERE  gen_date < (SELECT max_d FROM bounds)
)
SELECT  c.gen_date AS missing_date
FROM    calendar c
LEFT JOIN dim_date d ON d.date = c.gen_date
WHERE   d.date IS NULL
ORDER BY c.gen_date;


-- ----------------------------------------------------------------------------
-- Question 49: Data quality audit pipeline.
-- Concept: Multiple CTEs unioned into a uniform issue log.
-- ----------------------------------------------------------------------------
WITH orphan_customer AS (
    SELECT 'orphan_customer' AS issue, f.sales_id
    FROM   fact_sales f
    LEFT JOIN dim_customer c ON c.customer_key = f.customer_key
    WHERE  c.customer_key IS NULL
),
orphan_product AS (
    SELECT 'orphan_product', f.sales_id
    FROM   fact_sales f
    LEFT JOIN dim_product p ON p.product_key = f.product_key
    WHERE  p.product_key IS NULL
),
orphan_store AS (
    SELECT 'orphan_store', f.sales_id
    FROM   fact_sales f
    LEFT JOIN dim_store s ON s.store_key = f.store_key
    WHERE  s.store_key IS NULL
),
orphan_date AS (
    SELECT 'orphan_date', f.sales_id
    FROM   fact_sales f
    LEFT JOIN dim_date d ON d.date_key = f.date_key
    WHERE  d.date_key IS NULL
),
negative_total AS (
    SELECT 'negative_total', sales_id FROM fact_sales WHERE total_amount < 0
),
zero_quantity AS (
    SELECT 'zero_or_negative_quantity', sales_id FROM fact_sales WHERE quantity_sold <= 0
),
discount_exceeds_price AS (
    SELECT 'discount_exceeds_unit_price', sales_id
    FROM   fact_sales WHERE discount > unit_price
),
all_issues AS (
    SELECT * FROM orphan_customer
    UNION ALL SELECT * FROM orphan_product
    UNION ALL SELECT * FROM orphan_store
    UNION ALL SELECT * FROM orphan_date
    UNION ALL SELECT * FROM negative_total
    UNION ALL SELECT * FROM zero_quantity
    UNION ALL SELECT * FROM discount_exceeds_price
)
SELECT  issue, COUNT(*) AS issue_count
FROM    all_issues
GROUP BY issue
ORDER BY issue_count DESC;


-- ----------------------------------------------------------------------------
-- Question 50: Z-score anomaly detection on sales per product.
-- Concept: Per-product mean+stddev, z-score filter.
-- ----------------------------------------------------------------------------
WITH product_stats AS (
    SELECT  product_key,
            AVG(total_amount)    AS mean_amt,
            STDDEV(total_amount) AS std_amt,
            COUNT(*)             AS n
    FROM    fact_sales
    GROUP BY product_key
    HAVING  COUNT(*) >= 5
),
scored AS (
    SELECT  f.sales_id, f.product_key, p.product_name,
            f.total_amount, ps.mean_amt, ps.std_amt,
            (f.total_amount - ps.mean_amt) / NULLIF(ps.std_amt, 0) AS z_score
    FROM    fact_sales    f
    JOIN    product_stats ps ON ps.product_key = f.product_key
    JOIN    dim_product   p  ON p.product_key  = f.product_key
)
SELECT  sales_id, product_key, product_name,
        ROUND(total_amount, 2) AS total_amount,
        ROUND(mean_amt, 2)     AS product_mean,
        ROUND(std_amt, 2)      AS product_std,
        ROUND(z_score, 2)      AS z_score
FROM    scored
WHERE   ABS(z_score) > 3
ORDER BY ABS(z_score) DESC;

-- ============================================================================
-- END OF FILE — 50 CTE practice questions with solutions
-- ============================================================================
