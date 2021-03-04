-- Create objects
CREATE DATABASE PROD;
CREATE SCHEMA CRM;

USE SCHEMA CRM;
CREATE TABLE CUSTOMER AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER
LIMIT 1000;

USE SCHEMA PUBLIC;
CREATE TABLE DATE_DIM AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.DATE_DIM;


-- Drop table
USE SCHEMA CRM;
DROP TABLE CUSTOMER;

-- Undrop
USE SCHEMA CRM;
UNDROP TABLE CUSTOMER;


-- drop schema
DROP SCHEMA CRM;
SELECT * FROM PROD.CRM.CUSTOMER;

-- undrop schema
UNDROP SCHEMA CRM;
SELECT * FROM PROD.CRM.CUSTOMER;


-- drop database
DROP DATABASE PROD;
SELECT * FROM PROD.CRM.CUSTOMER;

-- undrop
UNDROP DATABASE PROD;
SELECT * FROM PROD.CRM.CUSTOMER;