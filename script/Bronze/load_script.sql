-- we are using copy command in postgresql (BULK INSERT in SQL server) 
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

 --use same script and change table name for other tables as well.
