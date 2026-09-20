
-- USE sample_procedure;

-- Transaction

-- a transaction is a group of one or more SQL statements that are treated as one unit of work.

/*

| ACID                | Meaning                                                 |
| ------------------- | ------------------------------------------------------- |
| A — Atomicity   | All operations happen or none happen                    |
| C — Consistency | Data remains valid                                      |
| I — Isolation   | Transactions don't improperly interfere with each other |
| D — Durability  | Committed changes survive failures                      |

*/

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    name VARCHAR(50),
    balance INT
);


INSERT INTO accounts VALUES
(101, 'Anu', 5000),
(102, 'Ravi', 3000),
(103, 'Priya', 7000);

/*

What is a transaction?

Imagine Anu wants to transfer ₹1,000 to Ravi.

Two things need to happen:

Anu:  ₹5000 → ₹4000
Ravi: ₹3000 → ₹4000

These two UPDATEs should be treated as one operation.

That's where a transaction comes in.

START TRANSACTION;

Now MySQL starts tracking the changes you make.

-------------------------
START TRANSACTION
       ↓
UPDATE Anu
       ↓
UPDATE Ravi
       ↓
     COMMIT
       ↓
Changes permanently saved

*/

START TRANSACTION;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 101;

SELECT * FROM accounts;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 102;


SELECT * FROM accounts;

COMMIT;    -- Save all the changes made in this transaction permanently.


-- rolling back
UPDATE accounts
SET balance = 5000
WHERE account_id = 101;

UPDATE accounts
SET balance = 3000
WHERE account_id = 102;


START TRANSACTION;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 101;

-- something goes wrong, instead of updating , we decide to cancel the transaction.

ROLLBACK; -- Undoes uncommitted changes.



/*

START TRANSACTION
       ↓
    Make changes
       ↓
   ┌───┴────┐
   ↓        ↓
COMMIT   ROLLBACK
   ↓        ↓
 SAVE      UNDO


A transaction can contain one SQL statement or many SQL statements.

-- transaction lock

A lock in MySQL is a mechanism used to control concurrent access to data.

Think of it like putting a temporary "Do not modify this row" sign while one transaction is working on it.

Example: last laptop

Suppose:

products
-------------------------
product_id = 101
stock = 1

Two customers try to buy the last laptop at the same time.

Transaction A:

START TRANSACTION;

SELECT stock
FROM products
WHERE product_id = 101
FOR UPDATE;

FOR UPDATE tells MySQL:

"I am going to work with this row. Lock it for me."

Conceptually:

Product 101
stock = 1
   ↓
🔒 ROW LOCKED
   ↓
Transaction A can work

Now Transaction B tries to modify the same row:

UPDATE products
SET stock = stock - 1
WHERE product_id = 101;

It may have to wait because Transaction A currently holds the relevant lock.

Transaction A              Transaction B

🔒 Product 101
      │
      │                    UPDATE Product 101
      │                          ↓
      │                       WAIT ⏳
      │
   COMMIT
      │
      ↓
🔓 Lock released
                           ↓
                       B can continue
Why do we need locks?

Without concurrency control, you can get problems like:

Stock = 1

A reads → 1
B reads → 1

A buys → stock 0
B buys → stock 0

Both customers thought the item was available.

Locks help coordinate these concurrent operations.

Important distinction:
A lock is not the transaction itself.

Transaction
    ↓
contains SQL operations
    ↓
may acquire locks
    ↓
COMMIT / ROLLBACK
    ↓
locks are released according to the locking rules

And remember:

SELECT ... FOR UPDATE

is a common way to explicitly request a lock on rows that you're going to update.

Interview definition:

A lock is a database mechanism that controls concurrent access to data so that multiple transactions don't make conflicting changes to the same data simultaneously.

*/


START TRANSACTION;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 101;


UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 999;

ROLLBACK;

-- transaction vs update
/*
An UPDATE is simply a SQL operation:

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 101;

A transaction is a group of operations treated as one unit:

START TRANSACTION;

UPDATE ...;
UPDATE ...;
INSERT ...;
DELETE ...;

COMMIT;

So a transaction can contain one SQL statement or many SQL statements.

A transaction should be treated as one complete unit: either all required changes are committed, or the changes are rolled back.

*/

-- transaction lock


START TRANSACTION;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 101;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 102;

COMMIT;




-- sample lock
START TRANSACTION;

SELECT *
FROM accounts
WHERE account_id = 101
FOR UPDATE;


COMMIT;



/*

Read the current value
Make a decision based on that value
Then update it

*/

START TRANSACTION;

SELECT balance
INTO @balance
FROM accounts
WHERE account_id = 101
FOR UPDATE;

-- Check whether enough money exists

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 101;

COMMIT;





