--1. Create a new database and create a new table in that database.

CREATE DATABASE SHR_TEST;
CREATE TABLE CUSTOMER
(
  CUST_ID STRING,
  BIRTH_DATE DATE,
  ADDRESS STRING,
  COUNTRY_CD STRING
);


-- 2. Next, populate the table with some dummy data that you will generate through the Generator table function. 
--If you like, you can use another table that you have already loaded with data.

INSERT INTO CUSTOMER
SELECT
UUID_STRING() AS CUST_ID
,DATEADD(DAY,UNIFORM(1, 5000, RANDOM()) * -1, '1980-01-01') AS BIRTH_DATE
,UUID_STRING() AS ADDRESS
,RANDSTR(2,RANDOM()) AS COUNTRY_CD
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


--3. Create the share object to share the data. (Note you will need to use ACCOUNTADMIN role to create the share).

--run statements one by one in order
USE ROLE ACCOUNTADMIN;
CREATE SHARE share_customer;


--4. You will need to provide permissions to the newly created share object to ensure that the data sharing works correctly. 
--USAGE permission is required on both the database and schema in which the table to be shared is located.

--run statements one by one in order
GRANT USAGE ON DATABASE SHR_TEST TO SHARE share_customer;
GRANT USAGE ON SCHEMA SHR_TEST.public TO SHARE share_customer;


--5. In addition to the USAGE permissions on the database & schema, you will also need to provide 
--SELECT permissions on the customer table to the share object.
GRANT SELECT ON TABLE SHR_TEST.public.customer TO SHARE share_customer;


--7. In the next steps, you will grant the share to the consumer account. To do so, you must first find out the account number of the consumer. 
--In real life scenario, the consumer will provide their account number themselves. To find the consumer's account number, 
--look at the first alphanumeric string in the snowflake instance URL for the consumer. That alphanumeric string is the account number.

--8. To add the consumer to a share, run the following SQL and replace <consumer_account_number> with the consumer account number.
ALTER SHARE share_customer ADD ACCOUNT=xx27251;


--------
--At this stage, you have successfully shared a table with a consumer. The next steps are to be executed as a consumer.
--Run these next steps on the Snowflake account which will be consuming the shared data.

--9. As a consumer, you will first list all the available shares and check that the new share indeed appears in the list.

USE ROLE ACCOUNTADMIN;
SHOW SHARES;


--10. You will now check what objects are contained in the share. You will need to replace the <producer_account_number> below.

USE ROLE ACCOUNTADMIN;
DESC SHARE <producer_account_number>.share_customer;
DESC SHARE SFC_SAMPLES.SAMPLE_DATA;


--11. You will now create a new database on the share. Once the database is created on the share, all the share objects will appear under the database.

CREATE DATABASE crm_data FROM SHARE <producer_account_number>.share_customer;


--12. You will now validate that the database is successfully associated with the share by running the following and checking the output.
USE ROLE ACCOUNTADMIN;
DESC SHARE <producer_account_number>.share_customer;


--13. You will now test that you can query the table successfully in the consumer account.
USE ROLE ACCOUNTADMIN;
SELECT * FROM crm_data.PUBLIC.customer; 


--You have successfully shared a table from a Snowflake provider account to another Snowflake account acting as a consumer.
--This is also referred to as "Direct Data Sharing".

