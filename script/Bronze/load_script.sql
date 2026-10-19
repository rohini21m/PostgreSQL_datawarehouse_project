CREATE OR REPLACE PROCEDURE bronze.load_tables()
LANGUAGE plpgsql
AS $$
DECLARE
    load_start_time timestamp;
    load_end_time timestamp;
    batch_start_time timestamp;
    batch_end_time timestamp;
BEGIN
    batch_start_time := clock_timestamp();

    ----------------------------------------------------
    -- 1. CRM Customer Info
    ----------------------------------------------------
    RAISE NOTICE '-------- loading CRM TABLES -------';
    load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ drop table if exist crm_customer_info ------';
    DROP TABLE IF EXISTS bronze.crm_customer_info;
    
    RAISE NOTICE '------ create table crm_customer_info ------';
    CREATE TABLE bronze.crm_customer_info (
        cst_id varchar(50),
        cst_key varchar(50),
        cst_firstname varchar(50),
        cst_lastname varchar(50),
        cst_marital_status varchar(50),
        cst_gndr varchar(50),
        cst_create_date date
    );

    RAISE NOTICE '------ INSERT DATA INTO CRM_CUSTOMER_INFO -----';
    EXECUTE 'COPY bronze.crm_customer_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_crm/crm_customer_info.csv'' 
             WITH (FORMAT csv, HEADER true)';
             
    RAISE NOTICE '------ SUCCESS: LOADED DATA INTO CRM_CUSTOMER_INFO ------';
    load_end_time := clock_timestamp();
    RAISE NOTICE '-- Total crm_customer_info Load Duration: % seconds --', EXTRACT(EPOCH FROM (load_end_time - load_start_time))::INT;

    ----------------------------------------------------
    -- 2. CRM Sales Details
    ----------------------------------------------------
    load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ drop table if exist crm_sales_details ----';
    DROP TABLE IF EXISTS bronze.crm_sales_details;
    
    RAISE NOTICE '------ create table crm_sales_details ------';
    CREATE TABLE bronze.crm_sales_details (
        sls_ord_num varchar(50),
        sls_prd_key varchar(50),
        sls_cust_id varchar(50),
        sls_order_dt varchar(50),
        sls_ship_dt varchar(50),
        sls_due_dt varchar(50),
        sls_sales varchar(50),
        sls_quantity varchar(50),
        sls_price varchar(50)
    );

    RAISE NOTICE '------ INSERT DATA INTO CRM_SALES_DETAILS-----';
    EXECUTE 'COPY bronze.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_crm/crm_sales_details.csv'' 
             WITH (FORMAT csv, HEADER true)';
             
    RAISE NOTICE '------ SUCCESS: LOADED DATA INTO CRM_SALES_DETAILS ------';
    load_end_time := clock_timestamp();
    RAISE NOTICE '-- Total crm_sales_details Load Duration: % seconds --', EXTRACT(EPOCH FROM (load_end_time - load_start_time))::INT;

    ----------------------------------------------------
    -- 3. CRM Product Info
    ----------------------------------------------------
    load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ drop table if exist crm_product_info ----';
    DROP TABLE IF EXISTS bronze.crm_product_info;
    
    RAISE NOTICE '------ create table crm_product_info ------';
    CREATE TABLE bronze.crm_product_info (
        prd_id varchar(50),
        prd_key varchar(50),
        prd_nm varchar(50),
        prd_cost varchar(50),
        prd_line varchar(50),
        prd_start_dt varchar(50),
        prd_end_dt varchar(50)
    );

    RAISE NOTICE '------ INSERT DATA into crm_product_info ----';
    EXECUTE 'COPY bronze.crm_product_info(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_crm/crm_product_info.csv'' 
             WITH (FORMAT csv, HEADER true)';
                
    RAISE NOTICE '------ SUCCESS: LOADED DATA INTO CRM_PRODUCT_INFO ------';
    load_end_time := clock_timestamp();
    RAISE NOTICE '-- Total crm_product_info Load Duration: % seconds --', EXTRACT(EPOCH FROM (load_end_time - load_start_time))::INT;
    RAISE NOTICE '------ ALL CRM TABLES HAVE BEEN LOADED ------';

    ----------------------------------------------------
    -- 4. ERP Customer AZ12
    ----------------------------------------------------
    RAISE NOTICE '-------- loading ERP TABLES -------';
    load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ drop table if exist erp_cust_az12 ----';
    DROP TABLE IF EXISTS bronze.erp_cust_az12;
    
    RAISE NOTICE '------ create table erp_cust_az12 ------';
    CREATE TABLE bronze.erp_cust_az12 (
        cid varchar(50),
        bdate date,
        gen varchar(50)
    );

    RAISE NOTICE '------ INSERT DATA into erp_cust_az12 ----';
    EXECUTE 'COPY bronze.erp_cust_az12(cid, bdate, gen) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_erp/erp_cust_az12.csv'' 
             WITH (FORMAT csv, HEADER true)';
                
    RAISE NOTICE '------ SUCCESS: LOADED DATA INTO ERP_CUST_AZ12 ------';
    load_end_time := clock_timestamp();
    RAISE NOTICE '-- Total erp_cust_az12 Load Duration: % seconds --', EXTRACT(EPOCH FROM (load_end_time - load_start_time))::INT;

    ----------------------------------------------------
    -- 5. ERP Location A101
    ----------------------------------------------------
    load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ drop table if exist erp_loc_a101 ----';
    DROP TABLE IF EXISTS bronze.erp_loc_a101;
    
    RAISE NOTICE '------ create table erp_loc_a101 ------';
    CREATE TABLE bronze.erp_loc_a101 (
        cid varchar(50),
        cntry varchar(50)
    );

    RAISE NOTICE '------ INSERT DATA into erp_loc_a101 ----';
    EXECUTE 'COPY bronze.erp_loc_a101(cid, cntry) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_erp/erp_loc_a101.csv'' 
             WITH (FORMAT csv, HEADER true)';
                
    RAISE NOTICE '------ SUCCESS: LOADED DATA INTO ERP_LOC_A101 ------';
    load_end_time := clock_timestamp();
    RAISE NOTICE '-- Total erp_loc_a101 Load Duration: % seconds --', EXTRACT(EPOCH FROM (load_end_time - load_start_time))::INT;

    ----------------------------------------------------
    -- 6. ERP Product Category G1V2
    ----------------------------------------------------
    load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ drop table if exist erp_px_cat_g1v2 ----';
    DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
    
    RAISE NOTICE '------ create table erp_px_cat_g1v2 ------';
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        id varchar(50),
        cat varchar(50),
        subcat varchar(50),
        maintenance varchar(50)
    );

    RAISE NOTICE '------ insert data into erp_px_cat_g1v2 ----';
    EXECUTE 'COPY bronze.erp_px_cat_g1v2(id, cat, subcat, maintenance) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_erp/erp_px_cat_g1v2.csv'' 
             WITH (FORMAT csv, HEADER true)';
             
    RAISE NOTICE '------ SUCCESS: LOADED DATA INTO ERP_PX_CAT_G1V2 ------';
    load_end_time := clock_timestamp();
    RAISE NOTICE '-- Total erp_px_cat_g1v2 Load Duration: % seconds --', EXTRACT(EPOCH FROM (load_end_time - load_start_time))::INT;
    RAISE NOTICE '------ SUCCESS: LOADED ALL ERP Tables ------';

    batch_end_time := clock_timestamp();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Total Batch Load Duration: % seconds', EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::INT;
    RAISE NOTICE '================================================';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'ERROR DURING BRONZE LAYER LOAD';
    RAISE NOTICE 'Error Message: %', SQLERRM;
    RAISE NOTICE 'Error State: %', SQLSTATE;
    RAISE NOTICE '------------------------------------------------';
    RAISE;
END;
$$;
