-- assignment setup steps

CREATE DATABASE time_travel;
create or replace stage sample_data_stage url='s3://snowflake-essentials-timetravel-lab';

list @sample_data_stage; 
USE DATABASE time_travel;

CREATE TABLE customer
(
	Customer_ID String,
	Customer_Name String
);

COPY INTO customer
  FROM @sample_data_stage
  file_format = (type = csv field_delimiter = '|' skip_header = 1);


-- solution starts here

-- set time zone to UTC to avoid any confusions
ALTER SESSION SET TIMEZONE = 'UTC';
--2019-11-05 07:17:00.810 +0000

-- select the current time stamp so that we can use it in the time travel query
SELECT CURRENT_TIMESTAMP;
-- accidental update of the table
-- make sure to note the query id
UPDATE customer SET Customer_ID = NULL;

-- oops all Customer_ID are now NULL
SELECT * FROM customer;


-- time travel to a time just before the time the update was run
select * from CUSTOMER before(timestamp => '2019-11-05 07:17:00.810 +0000'::timestamp);

-- alternatively if you don't know the time stamp you can specify a set interval from the current time
-- in this case 5 minute ago
-- make sure you wait 5 minutes before running this or alternativey adjust the number in the query
select * from CUSTOMER before(offset => -300);

-- alternatively you can use the query id to get the data before the specific query was run
SELECT * FROM CUSTOMER before (statement => '019004d5-00e2-eaa0-0000-00001e29c1b1'); 


-- create another table in which we will insert the data before the update
CREATE TABLE customer_before_change
(
	Customer_ID String,
	Customer_Name String
);

-- insert the time travel data into the new table
INSERT INTO customer_before_change SELECT * FROM CUSTOMER before (statement => '019004d5-00e2-eaa0-0000-00001e29c1b1'); 

-- check data in new table
SELECT * FROM customer_before_change;

-- all looks good, so we will drop the original table and rename this one
DROP TABLE customer;
ALTER TABLE customer_before_change RENAME TO customer;

-- all back to normal
SELECT * FROM customer;