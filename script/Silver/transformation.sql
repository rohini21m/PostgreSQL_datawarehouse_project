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
