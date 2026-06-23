

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


-- Event Metadata & Monitoring

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

Problem:
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
