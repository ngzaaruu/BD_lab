-- 3.1 Setup: Create Test Database

CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);
DROP TABLE IF EXISTS products CASCADE ;
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Insert test data
 INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);
 INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);

-- 3.2 Task 1: Basic Transaction with COMMIT

BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
COMMIT;

-- 3.3 Task 2: Using ROLLBACK

BEGIN;
UPDATE accounts SET balance = balance - 500.00
    WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

--3.4 Task 3: Working with SAVEPOINTs

BEGIN;

UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';

SAVEPOINT my_savepoint;

UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';

-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;

UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';

COMMIT;

--  3.5 Task 4: Isolation Level Demonstration
-- TERMINAL 1

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED; -- видит только зафиксированные данные, но каждый раз самые недавние
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';

COMMIT;

--TERMINAL 2

BEGIN;

DELETE FROM products WHERE shop = 'Joe''s Shop';

INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);

COMMIT;

-- READ COMMITTED is weaker:
-- Each SELECT may see changes made by other transactions.
-- This can cause non-repeatable reads or phantom reads.

-- SERIALIZABLE is stronger:
-- Other transactions cannot change the data we read.
-- It behaves as if transactions run one after another.
-- Terminal 2 may get errors or be blocked until this transaction finishes.


-- 3.6 Task 5: Phantom Read Demonstration

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
-- ждём, пока Terminal 2 сделает изменения

SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';

COMMIT;

BEGIN;

INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Sprite', 4.00);

COMMIT;

-- 3.7 Task 6: Dirty Read Demonstration

BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT * FROM products WHERE shop = 'Joe''s Shop'; -- 1-й SELECT
-- ждём Terminal 2

SELECT * FROM products WHERE shop = 'Joe''s Shop'; -- 2-й SELECT
-- ждём ROLLBACK Terminal 2

SELECT * FROM products WHERE shop = 'Joe''s Shop'; -- 3-й SELECT

COMMIT;

BEGIN;

UPDATE products SET price = 99.99
    WHERE product = 'Fanta'; -- ждём (не коммитим)

ROLLBACK; -- отменяем изменения

--4.1

BEGIN;
DO $$
DECLARE
    bob_balance NUMERIC;
BEGIN
    SELECT balance INTO bob_balance
    FROM accounts
    WHERE name = 'Bob';

    IF bob_balance >= 200 THEN

        UPDATE accounts
        SET balance = balance - 200
        WHERE name = 'Bob';

        UPDATE accounts
        SET balance = balance + 200
        WHERE name = 'Wally';

        COMMIT;
    ELSE
        RAISE NOTICE 'Insufficient funds for Bob. Transaction rolled back.';
        ROLLBACK;
    END IF;
END;
$$;

--4.2

BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('Mike''s Shop', 'Pepsi', 2.50);

SAVEPOINT sp1;

UPDATE products
SET price = 3.00
WHERE product = 'Pepsi';

SAVEPOINT sp2;

DELETE FROM products
WHERE product = 'Pepsi';

ROLLBACK TO sp1;

COMMIT;

--4.3
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE accounts SET balance = balance - 100
WHERE name = 'Alice';

-- Terminal 2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE accounts SET balance = balance - 150
WHERE name = 'Alice';

--4.4

BEGIN;

-- Sally использует REPEATABLE READ
SELECT MAX(price) FROM Sells WHERE shop = 'Sally''s Shop';
SELECT MIN(price) FROM Sells WHERE shop = 'Sally''s Shop';

COMMIT;
