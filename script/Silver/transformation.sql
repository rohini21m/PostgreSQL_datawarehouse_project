--data consistencey & data standards & duplicates 
CREATE OR REPLACE PROCEDURE silver.load_tables()
LANGUAGE plpgsql
AS $$
DECLARE
    silver_load_start_time timestamp;
    silver_load_end_time timestamp;
    silver_batch_start_time timestamp;
    silver_batch_end_time timestamp;
BEGIN
    silver_batch_start_time := clock_timestamp();

    ----------------------------------------------------
    -- 1. CRM Customer Info Transformation cleaning----- 
    ----------------------------------------------------
    RAISE NOTICE '-------- data cleaning, transforming CRM TABLES -------';
    silver_load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ insert into silver.crm_customer_info ------';
    INSERT INTO silver.crm_customer_info (
        cst_id, 
        cst_firstname, 
        cst_lastname, 
        cst_marital_status, 
        cst_gndr
    )
    SELECT 
        cst_id::INT,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE 
            WHEN INITCAP(cst_marital_status) = 'M' THEN 'Married'
            WHEN INITCAP(cst_marital_status) = 'S' THEN 'Single'
            ELSE 'Unknown' 
        END AS cst_marital_status,
        CASE 
            WHEN cst_gndr = 'M' THEN 'Male'
            WHEN cst_gndr = 'F' THEN 'Female'
            ELSE 'Unknown' 
        END AS cst_gndr
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS created_flag
        FROM bronze.crm_customer_info 
        WHERE cst_id IS NOT NULL
    ) t
    WHERE created_flag = 1;
    
    RAISE NOTICE '---successfully transformed & loaded data into silver.crm_customer_info-----';
    silver_load_end_time := clock_timestamp(); 
    RAISE NOTICE '---Total silver.crm_customer_info transformation % seconds --', 
        EXTRACT(EPOCH FROM (silver_load_end_time - silver_load_start_time))::INT; 

    ----------------------------------------------------
    -- 2. CRM Product Info Transformation cleaning------
    ----------------------------------------------------
    RAISE NOTICE '----Cleaning & transforming table : crm_product_info ----';
    silver_load_start_time := clock_timestamp();

    INSERT INTO silver.crm_product_info (
        prd_id, 
        cat_id, 
        prd_key, 
        prd_nm, 
        prd_cost, 
        prd_line, 
        prd_start_dt, 
        prd_end_dt
    )
    SELECT 
        prd_id::INT, 
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS category_id, 
        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key, 
        prd_nm, 
        COALESCE(NULLIF(prd_cost, '')::int, 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'R' THEN 'Road'
            WHEN 'M' THEN 'Mountain'
            WHEN 'T' THEN 'Touring'
            WHEN 'S' THEN 'Other Sales'
            ELSE 'N/A'
        END AS prd_line, 
        prd_start_dt::date, 
        (LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)::date - 1) AS prd_end_dt 
    FROM bronze.crm_product_info;   
    
    RAISE NOTICE '------- Fixed prd_end_date, nulls, data types, names standardised in crm_prd_info---';
    silver_load_end_time := clock_timestamp();

    ----------------------------------------------------
    -- 3. CRM Sales Details Transformation cleaning-----
    ----------------------------------------------------
    RAISE NOTICE '------- transform & clean bronze.crm_sales_details table------';
    silver_load_start_time := clock_timestamp();

    INSERT INTO silver.crm_sales_details (
        sls_ord_num, 
        sls_prd_key, 
        sls_cust_id, 
        sls_order_dt, 
        sls_ship_dt, 
        sls_due_dt, 
        sls_sales, 
        sls_quantity, 
        sls_price
    )
    SELECT 
        sls_ord_num::varchar,
        sls_prd_key::varchar, 
        sls_cust_id::INT,
        CASE 
            WHEN sls_order_dt = '0' OR NULLIF(sls_order_dt, '') IS NULL OR sls_order_dt ~ '^[0-9]+$' 
                THEN (sls_ship_dt::date - INTERVAL '1 day')::date
            WHEN sls_order_dt::date > sls_ship_dt::date OR sls_order_dt::date > sls_due_dt::date 
                THEN (sls_ship_dt::date - INTERVAL '1 day')::date
            ELSE sls_order_dt::date
        END AS sls_order_dt,
        sls_ship_dt::date, 
        sls_due_dt::date,
        CASE 
            WHEN sls_sales = '0' OR NULLIF(sls_sales, '') IS NULL OR (NULLIF(sls_sales, '')::numeric < 0) 
                 OR sls_sales::numeric != (NULLIF(sls_quantity, '')::numeric * NULLIF(sls_price, '')::numeric)
                THEN ABS(COALESCE(NULLIF(sls_quantity, '')::numeric, 0) * COALESCE(NULLIF(sls_price, '')::numeric, 0))::int
            ELSE ABS(NULLIF(sls_sales, '')::numeric)::int
        END AS sls_sales,
        ABS(COALESCE(NULLIF(sls_quantity, '')::numeric, 0))::int AS sls_quantity,
        ABS(COALESCE(NULLIF(sls_price, '')::numeric, 0))::int AS sls_price
    FROM bronze.crm_sales_details
    WHERE (
        (CASE WHEN NULLIF(sls_sales, '') IS NULL THEN 1 ELSE 0 END) +
        (CASE WHEN NULLIF(sls_quantity, '') IS NULL THEN 1 ELSE 0 END) +
        (CASE WHEN NULLIF(sls_price, '') IS NULL THEN 1 ELSE 0 END)
    ) < 2;

    RAISE NOTICE '---- Cleaned & transformed bronze.crm_sales_details-----';
    RAISE NOTICE '---- loaded into silver.crm_sales_details-----'; 
    silver_load_end_time := clock_timestamp();

    ----------------------------------------------------
    -- 4. ERP Customer AZ12 Transformation cleaning-----
    ----------------------------------------------------
    RAISE NOTICE '---Cleaning & transforming bronze.erp_cust_az12---';
    silver_load_start_time := clock_timestamp();

    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT 
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, 10) ELSE cid END AS cid, 
        CASE WHEN bdate > NOW()::DATE THEN NULL ELSE bdate END AS bdate, 
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
            ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;
    
    RAISE NOTICE '---completed Cleaning & transforming bronze.erp_cust_az12---'; 
    silver_load_end_time := clock_timestamp();

    ----------------------------------------------------
    -- 5. ERP Location A101 Transformation cleaning-----
    ----------------------------------------------------
    RAISE NOTICE '--- CLEAN & Transform bronze.erp_loc_a101---';  
    silver_load_start_time := clock_timestamp();

    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT  
        REPLACE(cid, '-', '') AS cid,
        CASE 
            WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
			WHEN TRIM(cntry)= 'DE' THEN 'Germany'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
            ELSE TRIM(cntry)
        END AS cntry
    FROM bronze.erp_loc_a101;    

    RAISE NOTICE '--- Transformation completed for bronze.erp_loc_a101---';  
    silver_load_end_time := clock_timestamp();

    ----------------------------------------------------
    -- 6. ERP Product Category G1V2 Transformation cleaning
    ----------------------------------------------------
    RAISE NOTICE '--- clean & load bronze.erp_px_cat_g1v2---';  
    silver_load_start_time := clock_timestamp();

    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT 
        TRIM(id),
        TRIM(cat),
        TRIM(subcat),
        TRIM(maintenance)
    FROM bronze.erp_px_cat_g1v2;

    RAISE NOTICE '--- Transformation completed for bronze.erp_px_cat_g1v2---';  
    silver_load_end_time := clock_timestamp();

    -- Final Batch Wrap-up
    silver_batch_end_time := clock_timestamp();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Total Silver Batch Load Duration: % seconds', EXTRACT(EPOCH FROM (silver_batch_end_time - silver_batch_start_time))::INT;
    RAISE NOTICE '================================================';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'ERROR DURING SILVER LAYER LOAD';
    RAISE NOTICE 'Error Message: %', SQLERRM;
    RAISE NOTICE 'Error State: %', SQLSTATE;
    RAISE NOTICE '------------------------------------------------';
END $$; 
