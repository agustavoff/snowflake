-- Prepare sample data
CREATE DATABASE TIME_TRAVEL_1;
 
CREATE TABLE ITEM AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.ITEM
LIMIT 10000;

SELECT * FROM ITEM LIMIT 100;
select count(1) FROM ITEM;


--3. Get current timestamp
SELECT CURRENT_TIMESTAMP;
-- 2021-03-03 17:27:53.015 -0800


-- 4. update ITEM table "accidentally"
UPDATE ITEM SET I_CURRENT_PRICE = 0;


-- 5. Check data 
SELECT DISTINCT I_CURRENT_PRICE FROM ITEM;


-- 6. Timetravel!
SELECT DISTINCT I_CURRENT_PRICE
FROM ITEM AT
(TIMESTAMP => '2021-03-03 17:27:53.015 -0800'::timestamp_tz);


-- 7. Possible to copy the previous data to a new table, or even to item table again.
SELECT *
FROM ITEM AT 
(TIMESTAMP => '2021-03-03 17:27:53.015 -0800'::timestamp_tz);


SELECT count(DISTINCT I_CURRENT_PRICE)
FROM ITEM AT
(TIMESTAMP => '2021-03-03 17:27:53.015 -0800'::timestamp_tz);


