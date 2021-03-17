In this assignment, you will be sharing data from a view. The view will combine data from two different from different databases. Sharing a View is somewhat similar to sharing a table but requires some additional privileges and configuration.



1. You will create a new database and a table.

CREATE DATABASE PARTY;
CREATE TABLE SUPPLIER
(
SUPP_ID NUMBER,
SUPP_NAME STRING
);


2. You will now populate this table with some dummy data.

INSERT INTO SUPPLIER
SELECT
SEQ8() AS SUPP_ID,
RANDSTR(10,RANDOM()) AS SUPP_NAME
FROM TABLE(GENERATOR(ROWCOUNT => 1000));
3. You will now create another database and create a table to hold supplier address information.

CREATE DATABASE CONTACT;
CREATE TABLE SUPP_ADDRESS
(
SUPP_ID NUMBER,
SUPP_ADDRESS STRING
);


4. You will now populate the table with dummy address data.

INSERT INTO SUPP_ADDRESS
SELECT
SEQ8() AS SUPP_ID,
RANDSTR(50,RANDOM()) AS SUPP_ADDRESS
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


5. You will now create a new database, in which we will create a new view combining data from the SUPPLIER & the SUPP_ADDRESS table.

CREATE DATABASE VIEW_DB;


6. You will now create the view to combine the data. Note that if you are creating a view for sharing, it must be created as a secure view. A standard view can not be shared, and only secure views can be.

CREATE SECURE VIEW SUPP_INFO AS
SELECT S.SUPP_ID, S.SUPP_NAME, S2.SUPP_ADDRESS
FROM PARTY.PUBLIC.SUPPLIER S
INNER JOIN CONTACT.PUBLIC.SUPP_ADDRESS S2
ON S.SUPP_ID = S2.SUPP_ID;


7. You will now validate that the view works correctly and returns a thousand rows.

SELECT * FROM SUPP_INFO;


8. Now you will create the share object to share the data. (Note you will need to use ACCOUNTADMIN role to create the share).

--run statements one by one in order

USE ROLE ACCOUNTADMIN;
CREATE SHARE share_supp;


9. You will need to provide permissions to the newly created share object to ensure that the data sharing works correctly. USAGE permission is required on both the database and schema in which the view to be shared is located.

--run statements one by one in order
GRANT USAGE ON DATABASE VIEW_DB TO SHARE share_supp;
GRANT USAGE ON SCHEMA VIEW_DB.public TO SHARE share_supp;


10. Since you are sharing data from a view that uses two different databases, you must provide REFERENCE_USAGE privileges on the two databases.

GRANT REFERENCE_USAGE ON DATABASE PARTY TO SHARE share_supp;
GRANT REFERENCE_USAGE ON DATABASE CONTACT TO SHARE share_supp;


11. Finally, you will provide SELECT permissions on the SUPP_INFO view to the share object.

GRANT SELECT ON VIEW VIEW_DB.public.SUPP_INFO TO SHARE share_supp;


12. To add the consumer to the share_supp share, run the following SQL and replace <consumer_account_number> with the consumer's account number.

ALTER SHARE share_supp ADD ACCOUNT=<consumer_account_number>;


At this stage you have successfully shared a view with a consumer by creating a secure view and providing the required privileges on the view.



Now on the consumer account, You can follow steps to create a database using this share. Run these next steps on the Snowflake Consumer account, which will be consuming the shared data.



13. As a consumer, you will first list all the available shares and check that the new share indeed appears in the list.

USE ROLE ACCOUNTADMIN;
SHOW SHARES;


14. You will now check what objects are contained in the share. You will need to replace the <producer_account_number> below.

USE ROLE ACCOUNTADMIN;
DESC SHARE <producer_account_number>.share_supp;


15. You will now create a new database on the share. Once the database is created on the share, all the share objects will appear under the database.

CREATE DATABASE supp_data FROM SHARE <producer_account_number>.share_supp;


16. You will now validate that the database is successfully associated with the share by running the following and checking the output.

USE ROLE ACCOUNTADMIN;
DESC SHARE <producer_account_number>.share_supp;


17. You will now test that you can query the table successfully in the consumer account.

USE ROLE ACCOUNTADMIN;
SELECT * FROM supp_data.PUBLIC.supp_info;


Sharing data through a view is quite similar to how data is shared through a table. However, you must

create the view as a Secure View &

provide Reference Usage permission on the underlying databases.

Perguntas dessa tarefa
Login as the consumer and SELECT * from the SUPP_INFO view. How many rows are returned?
