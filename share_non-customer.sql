In this assignment, you will be sharing a table with a non-Snowflake user. To share data with a non-Snowflake user, you must create a reader account first so that non-Snowflake users can sign into Snowflake.



Please note that on a trial Snowflake account there is apparently a limit of a single Reader account. Due to a potential bug, even if you drop a Reader account after you have created, the limit doesn't get rest, so you are not able to create a new Reader account. I suggest that once you create a Reader account, you don't drop it.



The following steps should be run on your main Snowflake account.

1. You will create a Reader account in this first step. A Reader account is like a sub-account of your main account. All the costs associated with a reader account are charged to the main account. A reader account is established by creating a Managed Account of Reader type. Replace the <admin_user> and the <password> as per your choice.

USE ROLE ACCOUNTADMIN;
 
CREATE MANAGED ACCOUNT MY_FIRST_RA TYPE=READER,
 
ADMIN_NAME = '<admin_user>',
 
ADMIN_PASSWORD='<password>';


2. The output from the above command is important as it will provide you with the URL on which the Reader Account can be accessed. Take note of that URL. You can also find out the URL by running the following SQL.

SHOW MANAGED ACCOUNTS;




The following steps are to be run on the reader account that you created in previous steps.



3. In a new browser window navigate to the URL from the previous step and login using the admin user & password that you specified in previous step. Do note that it may take some time to setup a Reader account. Until it is setup, a 403 error may be returned when accessing the URL. If you encounter that give it a few minutes.



4. You will now create a virtual warehouse in the new Reader account as a newly created Reader Account doesn’t have a virtual warehouse by default. Make sure you set the virtual warehouse to auto suspend to keep costs in check.

USE ROLE ACCOUNTADMIN;
 
CREATE WAREHOUSE RDR_WH WITH
 
WAREHOUSE_SIZE = 'SMALL' WAREHOUSE_TYPE = 'STANDARD'
 
AUTO_SUSPEND = 300 AUTO_RESUME = TRUE
 
INITIALLY_SUSPENDED = TRUE;


5. Now you will grant other roles in the Reader Account access to this virtual warehouse. If we don’t, then no one else will be able to use this virtual warehouse.

GRANT USAGE ON WAREHOUSE RDR_WH TO ROLE PUBLIC;
 
GRANT ALL ON WAREHOUSE RDR_WH TO ROLE SYSADMIN;


6. You can now create one or more named users in the Reader Account so that non-snowflake users that you want data shared with can login into the Reader Account.

CREATE USER jsmith PASSWORD = '<password>' MUST_CHANGE_PASSWORD = TRUE;


The steps further are similar to actions performed in the previous assignment where we shared data with another Snowflake user. However, A few differences exists. The differences being that when sharing we will be using the reader account number and we will be using a specific way to grant privileges towards the end.



Run the below steps in the Snowflake account, which you intend to use as the data provider.

7. Create a new database and create a new table in that database.

CREATE DATABASE SHR_NON_SF;
 
CREATE TABLE EMPLOYEE
 
(
 
EMP_ID STRING,
 
BIRTH_DATE DATE,
 
ADDRESS STRING,
 
COUNTRY_CD STRING
 
);


8. Next, populate the table with some dummy data to generate through the Generator table function. If you like, you can use another table that you have already loaded with data.

INSERT INTO EMPLOYEE
 
SELECT
 
UUID_STRING() AS EMP_ID
 
,DATEADD(DAY,UNIFORM(1, 5000, RANDOM()) * -1, '1980-01-01') AS BIRTH_DATE
 
,UUID_STRING() AS ADDRESS
 
,RANDSTR(2,RANDOM()) AS COUNTRY_CD
 
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


9. Create the share object to share the data. (Note you will need to use ACCOUNTADMIN role to create the share).

--run statements one by one in order
 
USE ROLE ACCOUNTADMIN;
 
CREATE SHARE share_emp;
 


10. You will need to provide permissions to the newly created share object to ensure that the data sharing works correctly. USAGE permission is required on both the database and schema in which the table to be shared is located.

--run statements one by one in order
 
GRANT USAGE ON DATABASE SHR_NON_SF TO SHARE share_emp;
 
GRANT USAGE ON SCHEMA SHR_NON_SF.public TO SHARE share_emp;


11. In addition to the USAGE permissions on the database & schema, you will also need to provide SELECT permissions on the EMPLOYEE table to the share object.

GRANT SELECT ON TABLE SHR_NON_SF.public.EMPLOYEE TO SHARE share_emp;


12. In the next steps, you will grant the share to the reader account. You must use the account number from the earlier steps where you created the Reader account.



13. To add the reader account to the share, run the following SQL and replace <reader_account_number> with the reader account number.

ALTER SHARE share_emp ADD ACCOUNT=<reader_account_number>;
At this stage, you have successfully shared a table with the Reader Account. The next steps are to be executed on the reader account it self.



Run these next steps on the Snowflake Reader account which will be consuming the shared data.

14. You must login as the ADMIN for the Reader account for these next steps. You will first list all the available shares and check that the new share indeed appears in the list.

USE ROLE ACCOUNTADMIN;
 
SHOW SHARES;
15. You will now check what objects are contained in the share. You will need to replace the <provider_account_number> below.

USE ROLE ACCOUNTADMIN;
 
DESC SHARE <provider_account_number>.share_emp;


16. You will now create a new database on the share. Once the database is created on the share, all the share objects will appear under the database.

CREATE DATABASE crm_data FROM SHARE <provider_account_number>.share_emp;


17. You will now validate that the database is successfully associated with the share by running the following and checking the output.

USE ROLE ACCOUNTADMIN;
 
DESC SHARE <provider_account_number>.share_emp;


18. You will now test that you can query the table successfully in the consumer account.

USE ROLE ACCOUNTADMIN;
 
SELECT * FROM crm_data.PUBLIC.EMPLOYEE;


19. To allow the jsmith user access to this table, you will need to grant privileges to the database to the PUBLIC role (or if jsmith holds other roles, you can grant to those roles)

USE ROLE ACCOUNTADMIN;
 
GRANT IMPORTED PRIVILEGES ON DATABASE crm_data TO ROLE PUBLIC;


You have successfully shared a table from a Snowflake provider account to a non-Snowflake user by creating a Reader Account.



Perguntas dessa tarefa
Login as the jsmith user in the Reader account and try to select all the data from the EMPLOYEE table. Are you successfully able to select the data? How many rows are returned?
