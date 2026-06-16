CREATE DATABASE schedulers;
use schedulers;

/*
SQL Scheduling :

Running SQL statements automatically at a specific time or interval without manual execution.

Examples:

Generate daily reports at midnight
Archive old records every week
Delete logs older than 90 days
Update inventory every hour
Refresh summary tables every night

In MySQL, this is done using the Event Scheduler.

*/




-- Check if Event Scheduler is Enabled
SHOW VARIABLES LIKE 'event_scheduler';

-- If it's OFF, enable Event Scheduler
SET GLOBAL event_scheduler = ON;

-- View Existing Scheduled Events
SHOW EVENTS;
-- or 

SELECT *
FROM information_schema.EVENTS;

/*

-- General Syntax
CREATE EVENT event_name
ON SCHEDULE schedule_definition
DO
sql_statement;




| Part                | Meaning                    |
| ------------------- | -------------------------- |
| CREATE EVENT        | Creates a scheduler        |
| event_name          | Name of the event          |
| ON SCHEDULE         | Defines when it should run |
| schedule_definition | Time/interval details      |
| DO                  | Work to perform            |
| sql_statement       | SQL query to execute       |


*/


-- Example
CREATE EVENT log_event
ON SCHEDULE EVERY 1 MINUTE
DO
INSERT INTO logs(message)
VALUES('Running');


-- Schedule Definition Syntaxes

-- There are only 2 major scheduling patterns.


-- 1. Run Once

/* 

CREATE EVENT event_name
ON SCHEDULE AT datetime
DO
sql_statement;


| Keyword  | Meaning          |
| -------- | ---------------- |
| AT       | Execute one time |
| datetime | Exact date/time  |

*/

-- Example
CREATE EVENT welcome_event
ON SCHEDULE AT '2026-06-01 09:00:00'
DO
INSERT INTO logs(message)
VALUES('Started');


-- Using Current Time
CREATE EVENT test_event
ON SCHEDULE AT NOW() + INTERVAL 5 MINUTE
DO
INSERT INTO logs(message)
VALUES('Executed');


-- General Syntax: INTERVAL value unit

/*


INTERVAL 5 MINUTE

INTERVAL 2 HOUR

INTERVAL 7 DAY

INTERVAL 1 MONTH

Supported units:
SECOND
MINUTE
HOUR
DAY
WEEK
MONTH
YEAR

*/


-- 2. Recurring Events

-- Syntax:

/*

CREATE EVENT event_name
ON SCHEDULE EVERY interval
DO
sql_statement;

*/

-- Example:

CREATE EVENT hourly_report
ON SCHEDULE EVERY 1 HOUR
DO
CALL generate_report(); -- every 1 hour generate report

-- Example:

CREATE EVENT salary_check
ON SCHEDULE EVERY 1 DAY
DO
INSERT INTO audit_log(action)
VALUES('Salary Verification');  -- Every day Insert audit record


-- EVERY Clause Grammar
-- General Syntax: EVERY value unit

/*

EVERY 10 SECOND
EVERY 30 MINUTE
EVERY 2 HOUR
EVERY 7 DAY

*/

-- STARTS Clause
-- Sometimes you don't want it to start immediately.

-- Syntax:
/*

CREATE EVENT event_name
ON SCHEDULE
EVERY interval
STARTS datetime
DO
sql_statement;

*/

-- Example:
CREATE EVENT future_job
ON SCHEDULE
EVERY 1 DAY
STARTS '2026-06-05 09:00:00'
DO
INSERT INTO logs(message)
VALUES('Started');

-- Start on June 5: Then repeat every 

-- ENDS Clause : Stop automatically.

/*

CREATE EVENT event_name
ON SCHEDULE
EVERY interval
STARTS datetime
ENDS datetime
DO
sql_statement;

*/

-- Example:
CREATE EVENT promo_job
ON SCHEDULE
EVERY 1 DAY
STARTS NOW()
ENDS NOW() + INTERVAL 30 DAY
DO
UPDATE offers
SET active='Y';


-- Run daily
-- Stop after 30 days



-- Multi Statement Events

-- Multiple queries:
/*

DO
BEGIN

query1;

query2;

query3;

END;

*/



/*

-- example:

CREATE EVENT cleanup_event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN

INSERT INTO audit_log(action)
VALUES('Cleanup Started');

DELETE FROM temp_orders;

INSERT INTO audit_log(action)
VALUES('Cleanup Completed');

END;


*/

-- PRESERVE Clause

/*

What happens after a one-time event executes?

Default:
event deleted

*/

-- example
CREATE EVENT test_event
ON SCHEDULE AT NOW() + INTERVAL 1 HOUR
ON COMPLETION PRESERVE  -- Keep event after execution
DO
INSERT INTO logs(message)
VALUES('Done');


-- ALTER EVENT Syntax

-- Change an event.

/*
ALTER EVENT event_name
new_definition;
*/

-- Change interval:
ALTER EVENT sales_refresh
ON SCHEDULE EVERY 30 MINUTE;

-- Disable:
ALTER EVENT sales_refresh
DISABLE;

-- Enable:
ALTER EVENT sales_refresh
ENABLE;


-- DROP EVENT Syntax:
DROP EVENT event_name;

-- Example:
DROP EVENT future_job;
DROP EVENT log_event;
DROP EVENT welcome_event;


-- Show Events
SHOW EVENTS;


-- Mental Formula:

/*

CREATE EVENT <name>
ON SCHEDULE <when>
DO <what>

Name → When → What

That's the entire Event Scheduler syntax in one sentence.

*/





/*



| Feature                | MySQL Event Scheduler | Airflow |
| ---------------------- | --------------------- | ------- |
| Schedule SQL           | ✅                     | ✅      | 
| Job Dependencies       | ❌                     | ✅      |
| Retry Failed Jobs      | ❌                     | ✅      |
| Monitoring UI          | ❌                     | ✅      |
| Alerts                 | ❌                     | ✅      |
| Multi-System Workflows | ❌                     | ✅      |


MySQL Event Scheduler is suitable for simple database tasks, while Airflow or enterprise 
schedulers are preferred for complex ETL pipelines with dependencies, retries, monitoring, and alerting.


*/