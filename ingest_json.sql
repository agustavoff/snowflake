Use OUR_FIRST_DATABASE;

drop table ExampleCustomers;

CREATE TABLE Example_Customers (
  json_data_raw VARIANT
);

select * from Example_Customers;

CREATE OR REPLACE STAGE json_example_stage url='s3://snowflake-essentials-json-lab';

list @json_example_stage;

COPY INTO Example_Customers
    FROM @json_example_stage/sample_data.json
    file_format = (type = json);

SELECT * FROM Example_Customers;

SELECT
    json_data_raw:customers
  FROM Example_Customers;


CREATE OR REPLACE TABLE customer_ctas AS
SELECT
    json_data_raw:table_name::String as tablee,
    VALUE:Customer_Name::String as Cust_Name,
    VALUE:Customer_City::String as Cust_City
  FROM 
    Example_Customers
    , lateral flatten( input => json_data_raw:customers)
  ;
  
  
select * from customer_ctas;

select count(1) from customer_ctas; --39

select cust_city, count(1) from customer_ctas
group by cust_city
order by 2;

