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
    RAISE NOTICE '-------- data cleaning, transfomring CRM TABLES -------';
   silver)load_start_time := clock_timestamp();
    
    RAISE NOTICE '------ insert into silver.crm_customer_info ------';
    INSERT into silver.crm_customer_info (cst_id,cst_firstname,cst_lastname,cst_marital_status,
    cst_gndr)
    SELECT cst_id,trim(cst_firstname),trim(cst_lastname),-- 
    case when INITCAP(cst_marital_status)= 'M' then 'Married'
         when INITCAP(cst_marital_status)='S' then 'Single'
         else 'Unknown' 
    end as cst_marital_status,
    CASE WHEN cst_gndr='M' THEN 'Male'
    when cst_gndr='F' then 'female'
    ELSE 'Unknown' -- Safely handles NULLs or empty strings
    END AS cst_gndr,
    cst_created_date
    from 
    (
       select *, row_number()over(partition by cst_id order by cst_create_date desc) as created_flag
       from bronze.crm_customer_info 
     WHERE cst_id IS NOT NULL
    )t
    where created_flag=1 
    RAISE NOTICE '---successfully transformed & loaded data into silver.crm_customer_info-----'
	load_end_time := clock_timestamp(); 
	RAISE NOTICE '---=Total silver.crm_customer_info trandformation % seconds --', 
	EXTRACT(EPOCH FROM (load_end_time - load_start_time))::INT; 

    INSERT INTO silver.crm_product_info(prd_id, cat_id,prd_key,prd_nm,prd_cost,prd_line,
	prd_start_dt,prd_end_dt)
	-----Cleaning & Transforming silver.crm_product_info 
	RAISE NOTICE '----Cleaning & transforming table : crm_product_info ----'
	RAISE NOTICE 
	select prd_id, 
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') as category_id, --extracting category key 
	prd_key as old_prd_key, --extracting product key 
	SUBSTRING(prd_key,7,LENGTH(prd_key)) as prd_key, -- since each prd_key lenth is diff we used len()
	prd_nm, 
	COALESCE(prd_cost::int,0) as prd_cost,
	CASE UPPER(trim(prd_line))
	WHEN 'R' then 'Road'
	when 'M' then 'Mountain'
	when  'T' then 'Touring'
	when 'S' then 'Other Sales'
    ELSE 'N/A'
	end as prd_line, 
	prd_start_dt::date, 
	lead(prd_start_dt)over(partition by prd_key order by prd_start_dt)::date-1 as prd_end_dt 
	from bronze.crm_product_info   
	RAISE NOTICE '------- Fixed prd_end_date, nulls, data types, names standardised in crm_prd_info---'

    RAISE NOTICE '------- transform & clean bronze.crm_sales_details table------'
	insert into silver.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,
	sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
	-------- cleaning & transforming crm_sales_details 
	select sls_ord_num::varchar,
	sls_prd_key::varchar, 
	sls_cust_id,
    (CASE 
    -- If it's '0', blank, or a broken numeric string, default to ship date minus 1 day
    WHEN sls_order_dt = '0' OR NULLIF(sls_order_dt, '') IS NULL 
         OR sls_order_dt ~ '^[0-9]+$' THEN (sls_ship_dt::date - INTERVAL '1 day')::date
         
    -- If it's a real YYYY-MM-DD string, compare it safely
    WHEN sls_order_dt::date > sls_ship_dt::date or sls_order_dt>sls_due_dt ::date 
	THEN (sls_ship_dt::date - INTERVAL '1 day')::date
    ELSE sls_order_dt::date
    END) AS sls_order_dt,
	sls_ship_dt::date, --since ship, & due date doesnot has any issues like order date we ae not applying 
	--same condition, or use sls_ship_dt>sls_due_dt then sls_due_date-2
	sls_due_dt::date,
--Rules :1)if sales are null, 0, -ve then sls_quantity*sls_price 
--2)if sls_price is ve->+ve, 
--3)if any 2 columns are out of sls_sales, sls_quantity, sls_price are null or all 3 are null then drop those records
    
    -- Rule 1 & 2: Calculate sales if missing/negative, ensure positive values, and drop decimals
        (CASE 
        WHEN sls_sales = '0' 
             OR NULLIF(sls_sales, '') IS NULL 
             OR (NULLIF(sls_sales, '')::numeric < 0) 
             THEN ABS(COALESCE(NULLIF(sls_quantity, '')::numeric, 0) * COALESCE(NULLIF(sls_price, '')::numeric, 0))::int
        ELSE ABS(NULLIF(sls_sales, '')::numeric)::int
     END) AS sls_sales,

    -- Standardize quantity to a clean positive integer
    ABS(COALESCE(NULLIF(sls_quantity, '')::numeric, 0))::int AS sls_quantity,

    -- Rule 2: Ensure price is positive (-ve -> +ve)
    ABS(COALESCE(NULLIF(sls_price, '')::numeric, 0))::int AS sls_price

    FROM bronze.crm_sales_details

-- Rule 3: Drop records where any 2 columns or all 3 columns are null/blank
    WHERE (
     (CASE WHEN NULLIF(sls_sales, '') IS NULL THEN 1 ELSE 0 END) +
     (CASE WHEN NULLIF(sls_quantity, '') IS NULL THEN 1 ELSE 0 END) +
     (CASE WHEN NULLIF(sls_price, '') IS NULL THEN 1 ELSE 0 END)
    ) < 2;
    RAISE NOTICE '---- Cleaned & transformed bronze.crm_sales_details-----'
	RAISE NOTICE '---- loaded into silver.crm_sales_details-----'
