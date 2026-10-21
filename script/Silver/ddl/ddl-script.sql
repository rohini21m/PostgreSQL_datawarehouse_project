-- creating tables in silver_scr layer : we are performing full load(truncate & load) 
create table silver.crm_customer_info(
cst_id int,
cst_key	varchar(25),
cst_firstname varchar(50),
cst_lastname varchar(50),
cst_marital_status	varchar(20),
cst_gndr varchar(25),
cst_create_date date, 
dwh_created_time TIMESTAMPTZ DEFAULT NOW() -- metadata column to track inremental changes in silver layer , thsi gives more information about 
    -- the table columns values,
) 
create table silver.crm_sales_details(
sls_ord_num	varchar(50),
sls_prd_key	varchar(50),
sls_cust_id	int,
sls_order_dt int,
sls_ship_dt	int,
sls_due_dt	int,
sls_sales int,	
sls_quantity int,	
sls_price int, 
dwh_created_time TIMESTAMPTZ DEFAULT NOW() -- metadata column to track inremental changes in silver layer , thsi gives more information about 
    -- the table columns values,

) 
create table silver.crm_product_info(
prd_id  INT,
prd_key  varchar(50),
prd_nm  varchar(50),
prd_cost  INT,
prd_line  varchar(50),
prd_start_dt date,
prd_end_dt date,
dwh_created_time TIMESTAMPTZ DEFAULT NOW() -- metadata column to track inremental changes in silver layer , thsi gives more information about 
    -- the table columns values,
)  

CREATE TABLE silver.erp_cust_az12 (
cid   varchar(50),
bdate  date,
gen   varchar(50) 
dwh_created_time TIMESTAMPTZ DEFAULT NOW() -- metadata column to track inremental changes in silver layer , thsi gives more information about 
    -- the table columns values,
);

CREATE TABLE silver.erp_loc_a101(
cid    varchar(50),
cntry   varchar(50),
dwh_created_time TIMESTAMPTZ DEFAULT NOW() -- metadata column to track inremental changes in silver layer , thsi gives more information about 
    -- the table columns values,
);
CREATE TABLE silver.erp_px_cat_g1v2 (
id              VARCHAR(50),
cat             VARCHAR(50),
subcat          VARCHAR(50),
maintenance     VARCHAR(50),
dwh_created_time TIMESTAMPTZ DEFAULT NOW() -- metadata column to track inremental changes in silver layer , thsi gives more information about 
    -- the table columns values,
);
