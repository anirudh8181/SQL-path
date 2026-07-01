
-- Event Failure Handling

-- An event 

CREATE EVENT load_sales_staging_event
ON SCHEDULE EVERY 5 MINUTE
DO
CALL load_sales_staging();

/*

Every 5 minutes MySQL executes:

CALL load_sales_staging();

Now :

What if something goes wrong inside load_sales_staging()?



Understanding the current Architecture

current pipeline looks like this:

                MySQL Event Scheduler
                        │
                        │ Every 5 Minutes
                        ▼
            CALL load_sales_staging()
                        │
                        ▼
            Stored Procedure Executes
                        │
                        ▼
               sales_staging table

Notice something important.

There are two completely different components.
------------------------------------------------------
--- Component 1:

Scheduler

Its only job is
"When should I execute?"


--- Component 2:

Stored Procedure

Its job is
"What should I execute?"

These are independent.
-------------------------------------------------
Scenario 1 — Everything Works

Imagine current time
10:00

Scheduler says
It's time.

Calls

CALL load_sales_staging();

Procedure starts

↓

Reads

orders

order_items

payments

↓

Loads

sales_staging

↓

Ends successfully.

Everything is good.

--------------------------------------------------

Scenario 2 — Something Goes Wrong

Now:

Someone accidentally deletes
payments table.

Current time
10:05

Scheduler again says

It's time.
Calls

CALL load_sales_staging();

Procedure starts

↓

Reads

SELECT *

FROM payments;

↓

Database replies

ERROR:
Table doesn't exist
Procedure crashes.


Question:
Did the scheduler fail?

Most  say:
Yes

Wrong.

The scheduler did exactly what it was supposed to do.

Scheduler
Executed procedure - did it's job

Procedure
Failed

Huge difference.

Without Failure Handling

Let's see the timeline.

10:00

Scheduler

↓

Procedure

↓

Success

--------------------

10:05

Scheduler

↓

Procedure

↓

SQL Error

↓

Procedure Stops



Now ask yourself:
How would the company know?

They wouldn't.

The procedure simply stopped.

What does MySQL do?
Nothing.



MySQL simply says:
SQL Error and terminates the procedure.

-- No email.

-- No retry.

-- No logging.

-- No notification.

That's why Failure Handling exists.



Failure handling means:

"When something goes wrong,

don't just crash.

Do something useful."
What useful things?

For example:

-- Log failure
-- Store error
-- Rollback transaction
-- Release lock
-- Exit cleanly

Those are all examples of failure handling.


-------------------------------------------------------------

How does MySQL implement Failure Handling?

Using:

DECLARE HANDLER


Think of Handler as 'Emergency Plan'


-- Without Handler:

Procedure Starts

↓

Statement 1

↓

Statement 2

↓

SQL Error

↓

Procedure Dies

Nothing else happens.



-- With Handler:

Procedure Starts

↓

Statement 1

↓

Statement 2

↓

SQL Error

↓

Handler Executes

↓

Logs failure

↓

Procedure Ends


Instead of dying immediately the procedure gets one last chance to perform cleanup.



What is an SQL Exception?


-- Table not found
-- Duplicate key
-- Constraint violation
-- Divide by zero
-- Invalid column
-- Syntax error

All these are SQL EXCEPTIONs


-- Types of Handlers

There are mainly two you'll encounter.

1. EXIT HANDLER



Statement A

↓

Statement B

↓

Error

↓

Handler

↓

Procedure Ends

Once error happens

procedure never continues.
Why?
Because ETL jobs usually depend on previous steps.

Example:
Load staging

↓

Load fact

↓

Generate summary

Suppose

Load staging - fails.

Should

Load fact - continue?

No.

Because fact table will be incomplete.
That's why ETL procedures usually use
EXIT HANDLER



2.CONTINUE HANDLER

Different.

Flow

Statement A

↓

Statement B

↓

Error

↓

Handler

↓

Statement C

Procedure keeps going.

Useful when

the error isn't critical.

Example:

Could not insert optional log.
Continue processing.

Less common in ETL.

*/

DELIMITER $$

CREATE PROCEDURE load_sales_staging()

BEGIN

-- ------------------------------------------------------------------
    -- 1. Variables
-- ------------------------------------------------------------------

    -- Stores number of rows inserted into staging
    DECLARE v_rows_loaded INT DEFAULT 0;

    -- Stores audit_log row id
    DECLARE v_log_id INT;

--  ------------------------------------------------------------------
    -- 2. Exception Handler
--  ------------------------------------------------------------------

    /*
       If ANY SQL Exception occurs inside this procedure,

       1. Update audit_log
       2. Mark job FAILED
       3. Exit procedure
    */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION

    BEGIN

        UPDATE audit_log

        SET

            status = 'FAILED',

            comments = 'SQL Exception occurred while loading sales_staging',

            records_processed = 0

        WHERE log_id = v_log_id;

    END;
    
-- ------------------------------------------------------------------
    -- 3. Insert STARTED record
-- ------------------------------------------------------------------

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
        'load_sales_staging',

        NOW(),

        0,

        'STARTED',

        'ETL Started'
    );

    -- ------------------------------------------------------------------
    -- 4. Save generated audit id
    -- ------------------------------------------------------------------

    SET v_log_id = LAST_INSERT_ID();

    -- ------------------------------------------------------------------
    -- 5. Actual ETL
    -- ------------------------------------------------------------------

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

        ROUND
        (
            oi.quantity
            *
            oi.unit_price
            *
            (1 - oi.discount_pct / 100),

            2
        ),

        NOW()

    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN payments p
        ON o.order_id = p.order_id
    WHERE p.payment_status='SUCCESS';

    -- ------------------------------------------------------------------
    -- 6. Store inserted row count
    -- ------------------------------------------------------------------

    SET v_rows_loaded = ROW_COUNT();

    -- ------------------------------------------------------------------
    -- 7. Update audit row as SUCCESS
    -- ------------------------------------------------------------------

    UPDATE audit_log

    SET

        status='SUCCESS',

        records_processed=v_rows_loaded,

        comments='Staging Loaded Successfully'

    WHERE log_id=v_log_id;

END$$

DELIMITER ;


/*

-- Step 1:

Scheduler executes

CALL load_sales_staging();



-- Step 2:

Variables created:

v_log_id = NULL
v_rows_loaded = 0

Memory looks like:

RAM

----------------

v_log_id

NULL

----------------

v_rows_loaded

0


-- Step 3:

Insert STARTED

INSERT INTO audit_log(...)

Audit table:

log_id	    status
101	        STARTED



-- Step 4:

SET v_log_id = LAST_INSERT_ID();

Now

v_log_id

↓

101

This is extremely important.

The procedure now knows

"Everything I do belongs to audit row 101."


-- Step 5:

ETL starts

INSERT INTO sales_staging

SELECT ...

Suppose

Orders

Order
1001
1002
1003

Only SUCCESS payments

Order
1001
1003

Rows inserted:
250

Nothing has been updated yet.

Audit table still

log_id	  status
101	      STARTED


-- Step 6:

Immediately

SET v_rows_loaded = ROW_COUNT();

Now:

v_rows_loaded

↓

250

Remember

ROW_COUNT()

means:

Rows affected by
PREVIOUS SQL Statement

NOT

Rows in table


Step 7:

Update audit row:

UPDATE audit_log

Changes

From:
status
STARTED

To:
status	  rows
SUCCESS	  250

for Same row.





*/


