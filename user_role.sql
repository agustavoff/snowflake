//USE ROLE <name>
//USE WAREHOUSE <name>
//USE [ DATABASE ] <name>
//USE [ SCHEMA ] [<db_name>.]<name>

--USE ROLE ACCOUNTADMIN;
USE ROLE SYSADMIN;
USE ROLE SECURITYADMIN;

select current_role(), current_warehouse(), current_database(), current_schema();

--------------
-- SHOW
-- SHOW <object_type_plural> [ LIKE '<pattern>' ] [ IN <scope_object_type> [ <scope_object_name> ] ]

//Check users
-- SHOW USERS [ LIKE '<pattern>' ]
SHOW USERS;

SHOW ROLES;


//SHOW GRANTS ON <object_type> <object_name>
//SHOW GRANTS TO { ROLE <role_name> | USER <user_name> | SHARE <share_name> }
//SHOW GRANTS OF ROLE <role_name>
//SHOW GRANTS OF SHARE <share_name>
//SHOW FUTURE GRANTS IN SCHEMA { <schema_name> }
//SHOW FUTURE GRANTS IN DATABASE { <database_name> }

//show grants to user <user-name>;
SHOW GRANTS TO USER AGUSTAVOFF;
SHOW GRANTS TO USER DNEWTON;
SHOW GRANTS TO USER JSMITH;

SHOW GRANTS TO ROLE "Marketing Users";


//Create a new user with the name "John Smith" and a login name of "Jsmith"
//
CREATE USER Jsmith 
    PASSWORD = 'blabla' 
    LOGIN_NAME = 'JSMITH'
    DISPLAY_NAME = 'John Smith'
    DEFAULT_ROLE = null 
    MUST_CHANGE_PASSWORD = FALSE;

//Create a new user with the name "Dave Newton" and a login name of "Dnewton". Dave will be our new system admin, so they should have SYSADMIN as a the default role.
//
CREATE USER Dnewton 
    PASSWORD = 'blabla' 
    LOGIN_NAME = 'Dnewton'
    DISPLAY_NAME = 'Dave Newton'
    DEFAULT_ROLE = SYSADMIN 
    MUST_CHANGE_PASSWORD = FALSE;
GRANT ROLE SYSADMIN TO USER Dnewton;
   

//Login as Dave Newton and create a database called "Customer_Analytics".
//
USE ROLE SYSADMIN;
CREATE DATABASE Customer_Analytics;
USE ROLE SECURITYADMIN;

--GRANT OWNERSHIP ON SCHEMA MARKETING_DATABASE.PUBLIC TO ROLE MARKETING_DBA;
--GRANT OWNERSHIP ON DATABASE MARKETING_DATABASE TO ROLE MARKETING_DBA;


//(you will need to do this step logged in as  SECURITYADMIN role) 
//Create a new custom role called "Marketing Users" and grant the role to "John Smith".
//
CREATE ROLE "Marketing Users";
GRANT ROLE "Marketing Users" TO USER "JSMITH";


//Make "Marking Users" the default role for "John Smith". 
ALTER USER IF EXISTS JSMITH SET DEFAULT_ROLE = "Marketing Users" 

//Make sure that the "Marketing Users" role is granted to the SYSADMIN role i.e. complete the role hierarchy.
GRANT ROLE "Marketing Users" TO ROLE SYSADMIN;

//Grant the role "Marketing Users" ALL privileges on the "Customer_Analytics" database.
grant all privileges on DATABASE Customer_Analytics to role "Marketing Users";

//
//Test your setup by logging in as "John Smith" and validating that you can create a new table under the Customer_Analytics database.



