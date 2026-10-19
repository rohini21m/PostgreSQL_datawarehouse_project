-- we are using copy command in postgresql (BULK INSERT in SQL server) . 
--It first checks if table exists then drop it,if not created already,
--then it creates a table and then inserts using COPY command. SQLSERVER uses BULK INSERT
-- using stored procedure id data is stored in database server side: 
-- This stored procedure does not accept any parameters or return any values.
CREATE OR REPLACE PROCEDURE bronze.load_erp_tables()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE '------------------------';
    RAISE NOTICE ' LOADING BRONZE LAYER TABLES';
    RAISE NOTICE '------------------------';
    RAISE NOTICE ''; 
    
    ----------------------------------------------------
    -- 1. Load ERP Table: erp_px_cat_g1v2
    ----------------------------------------------------
    RAISE NOTICE 'LOADING ERP TABLE: erp_px_cat_g1v2';
    
    DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
    
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        id varchar(50),
        cat varchar(50),
        subcat varchar(50),
        maintenance varchar(50)
    );
    
    RAISE NOTICE '------------ Insert data into erp_px_cat_g1v2 -------';
    EXECUTE 'COPY bronze.erp_px_cat_g1v2(id, cat, subcat, maintenance) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_erp/erp_px_cat_g1v2.csv'' 
             WITH (FORMAT csv, HEADER true)';
             
    RAISE NOTICE 'SUCCESS: erp_px_cat_g1v2 table loaded successfully.';  

    ----------------------------------------------------
    -- 2. Load ERP Table: erp_loc_a101
    ----------------------------------------------------
    RAISE NOTICE 'LOADING ERP TABLE: erp_loc_a101';
    
    DROP TABLE IF EXISTS bronze.erp_loc_a101;

    CREATE TABLE bronze.erp_loc_a101 (
        cid varchar(50),
        cntry varchar(50)
    );
    
    RAISE NOTICE '------------ Insert data into erp_loc_a101 ------';
    EXECUTE 'COPY bronze.erp_loc_a101(cid, cntry) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_erp/erp_loc_a101.csv'' 
             WITH (FORMAT csv, HEADER true)';
             
    RAISE NOTICE 'SUCCESS: erp_loc_a101 table loaded successfully.';  

    ----------------------------------------------------
    -- 3. Load ERP Table: erp_cust_az12
    ----------------------------------------------------
    RAISE NOTICE 'LOADING ERP TABLE: erp_cust_az12';
    
    DROP TABLE IF EXISTS bronze.erp_cust_az12;

    CREATE TABLE bronze.erp_cust_az12 (
        cid varchar(50),
        bdate date,
        gen varchar(50)
    );
    
    RAISE NOTICE '------------ Insert data into erp_cust_az12 -------';
    EXECUTE 'COPY bronze.erp_cust_az12(cid, bdate, gen) 
             FROM ''/Users/path/Downloads/datawarehouse_project/source_erp/erp_cust_az12.csv'' 
             WITH (FORMAT csv, HEADER true)';
             
    RAISE NOTICE 'SUCCESS: erp_cust_az12 table loaded successfully.';  

END;
$$;

 --use same script and change table name for other tables as well.
