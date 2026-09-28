-- 1. Switch to the default maintenance database
\c postgres

  /*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
-- 2. Drop the data warehouse if already exists
DROP DATABASE IF EXISTS data_warehouse WITH (FORCE);
create database datawarehouse
create schema bronze;
create schema silver; 
create schema gold;  
