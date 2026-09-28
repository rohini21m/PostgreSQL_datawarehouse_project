-- creating tables in bronze_scr layer : we are performing full load(truncate & load) 

drop table IF exists bronze.crm_customer_info ; 
create table bronze.crm_customer_info(
 cst_id              INT,
 cst_key          VARCHAR(50),
 cst_firstname    VARCHAR(50),
 cst_lastname        VARCHAR(50),
 cst_marital_status  VARCHAR(50),
 cst_gndr            VARCHAR(50),
 cst_create_date     DATE
);  

drop table IF exists bronze.crm_sales_details; 
create table bronze.crm_sales_details(
  sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);  
drop table IF exists bronze.crm_product_info; 
create table bronze.crm_product_info (
   prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
 ) 
 
creating erp source tables in bronze :
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
);

DROP TABLE IF exists bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
);
