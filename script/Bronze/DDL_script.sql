-- creating tables in bronze_scr layer : we are performing full load(truncate & load) 

drop table if exists bronze.crm_customer_info;
create table bronze.crm_customer_info(
cst_id int,
cst_key	varchar(25),
cst_firstname varchar(50),
cst_lastname varchar(50),
cst_marital_status	varchar(20),
cst_gndr varchar(25),
cst_create_date date
) 

copy bronze.crm_customer_info(cst_id, cst_key,cst_firstname,cst_lastname,cst_marital_status,
cst_gndr,cst_create_date) from 
'/Users/path/Downloads/datawarehouse_project/source_crm/crm_customer_info.csv' 
WITH (FORMAT csv, HEADER true);  

drop table IF exists bronze.crm_sales_details ;
create table bronze.crm_sales_details(
sls_ord_num	varchar(50),
sls_prd_key	varchar(50),
sls_cust_id	int,
sls_order_dt int,
sls_ship_dt	int,
sls_due_dt	int,
sls_sales int,	
sls_quantity int,	
sls_price int
) 

copy bronze.crm_sales_details(sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,	
sls_quantity,	
sls_price) from 
'/Users/path/Downloads/datawarehouse_project/source_crm/crm_sales_details.csv' 
WITH (FORMAT csv, HEADER true);  

-- ddl fpr product_info 
drop table if exists bronze.crm_product_info;
create table bronze.crm_product_info(
prd_id  INT,
prd_key  varchar(50),
prd_nm  varchar(50),
prd_cost  INT,
prd_line  varchar(50),
prd_start_dt date,
prd_end_dt date
)  
copy bronze.crm_product_info(prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt) 
from 
'/Users/path/Downloads/datawarehouse_project/source_crm/crm_product_info.csv' 
WITH (FORMAT csv, HEADER true);   

drop table if exists bronze.erp_cust_az12 ;
CREATE TABLE bronze.erp_cust_az12 (
cid   varchar(50),
bdate  date,
gen   varchar(50)
);

copy bronze.erp_cust_az12(cid,bdate,gen) 
from 
'/Users/path/Downloads/datawarehouse_project/source_erp/erp_cust_az12.csv' 
WITH (FORMAT csv, HEADER true);    

drop table  if exists bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
cid    varchar(50),
cntry   varchar(50)
);

copy bronze.erp_loc_a101(cid,cntry) 
from 
'/Users/path/Downloads/datawarehouse_project/source_erp/erp_loc_a101.csv' 
WITH (FORMAT csv, HEADER true);     

select * from bronze.erp_loc_a101

drop table if exists bronze.erp_px_cat_g1v2 ;
CREATE TABLE bronze.erp_px_cat_g1v2 (
id varchar(50),
cat   varchar(50),
subcat varchar(50),
maintenance   varchar(50)
);

copy bronze.erp_px_cat_g1v2(id,cat,subcat,maintenance)
from 
'/Users/path/Downloads/datawarehouse_project/source_erp/erp_px_cat_g1v2.csv' 
WITH (FORMAT csv, HEADER true);   

-- using stored procedure id data is stored in database server side: 
CREATE OR REPLACE PROCEDURE bronze.load_erp_px_cat()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Drop the table if it already exists
    DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
    
    -- Create the table
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        id varchar(50),
        cat   varchar(50),
        subcat varchar(50),
        maintenance   varchar(50)
    );

    -- Copy data from the CSV file dynamically
    EXECUTE 'COPY bronze.erp_px_cat_g1v2(id, cat, subcat, maintenance) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_erp/erp_px_cat_g1v2.csv'' 
             WITH (FORMAT csv, HEADER true)';
END;
$$;



