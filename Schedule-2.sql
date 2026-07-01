

DELIMITER //

CREATE PROCEDURE load_sales_staging()
BEGIN

    INSERT INTO sales_staging
    (
        order_id,
        customer_id,
        product_id,
        quantity,
        unit_price,
        discount_pct,
        revenue,
        load_timestamp
    )
    SELECT
        o.order_id,
        o.customer_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.discount_pct,
        ROUND(
            oi.quantity *
            oi.unit_price *
            (1 - oi.discount_pct/100),
            2
        ) AS revenue,
        NOW()
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id;

END //

DELIMITER ;


-- 1.Event Metadata & Monitoring

CREATE EVENT load_sales_event
ON SCHEDULE EVERY 5 MINUTE
DO
CALL load_sales_staging();


-- Did the job run at 10:00 AM?

SHOW EVENTS;


-- More Detailed Information
SELECT
    EVENT_NAME,
    STATUS,
    LAST_EXECUTED,
    INTERVAL_VALUE,
    INTERVAL_FIELD
FROM information_schema.EVENTS;


-- example scenario

/*
Suppose:

CALL load_sales_staging();

should run every 5 minutes.

Current time:
10:30 AM

Check:

SELECT
    EVENT_NAME,
    LAST_EXECUTED
FROM information_schema.EVENTS;

Output:
LAST_EXECUTED:
10:25 AM

Looks good.

Output:
LAST_EXECUTED:
09:00 AM

Then Problem:
Scheduler stopped running.
We now know where to investigate.


Limitation:

Notice:
SHOW EVENTS;

only tells:
When it last ran

It does NOT tell:

Success?
Failure?
Rows processed?
Duration?
Error message?

That's why Data Engineers build logging tables.

*/

-- Create a simple event
CREATE EVENT monitor_demo
ON SCHEDULE EVERY 1 MINUTE
DO
INSERT INTO audit_log
(
    process_name,
    execution_time,
    records_processed,
    status,
    comments
)
VALUES
(
    'MONITOR_DEMO',
    NOW(),
    1,
    'SUCCESS',
    'Test Event'
);

-- Verify event exists
SHOW events;

-- How many rows were inserted?
SELECT *
FROM audit_log
WHERE process_name='MONITOR_DEMO'
ORDER BY execution_time DESC;

-- Check  metadata
SELECT
    EVENT_NAME,
    STATUS,
    LAST_EXECUTED
FROM information_schema.EVENTS
WHERE EVENT_NAME='monitor_demo';

ALTER EVENT monitor_demo
DISABLE;

DROP EVENT monitor_demo;



-- 2. Job Run History Table

SHOW events;

/*

SHOW events can't answer:

How many records were processed?
How long did the job take?
Did it succeed or fail?
What was the error?
What happened yesterday at 2 AM?

*/

SELECT *
FROM audit_log
ORDER BY execution_time DESC;


--  Show Latest Runs
SELECT *
FROM audit_log
ORDER BY execution_time DESC
LIMIT 10;


--  Count Success vs Failure
SELECT
    status,
    COUNT(*) AS runs
FROM audit_log
GROUP BY status;


--  Find Failed Jobs
SELECT *
FROM audit_log
WHERE status='FAILED';


-- 4. Find Today's Executions
SELECT *
FROM audit_log
WHERE DATE(execution_time)=CURDATE();

-- 5. Number of Records Processed Today
SELECT
    SUM(records_processed)
FROM audit_log
WHERE DATE(execution_time)=CURDATE();


-- Production Example

-- Imagine:

/*

load_sales_staging
Every 5 minutes

Expected runs per day:

24 × 60 / 5
=
288 runs

*/

-- Check:

SELECT COUNT(*)
FROM audit_log
WHERE process_name='MONITOR_DEMO'
AND DATE(execution_time)=CURDATE();








