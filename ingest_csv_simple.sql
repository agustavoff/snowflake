select * from OUR_FIRST_TABLE;

# Load data from: https://s3.ap-southeast-2.amazonaws.com/snowflake-essentials/customer.csv
 
CREATE TABLE customer (
  ID STRING,
  Name STRING,
  Address STRING,
  City STRING,
  PostCode Number,
  State STRING,
  Company STRING,
  Contact STRING
  )
  
create or replace stage my_s3_stage url='s3://snowflake-essentials/';

copy into customer
  from s3://snowflake-essentials/customer.csv
  file_format = (type = csv field_delimiter = '|' skip_header = 1);

select count(1) from customer


 
