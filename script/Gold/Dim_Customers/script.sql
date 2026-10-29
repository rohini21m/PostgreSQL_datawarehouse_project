create view gold.Dim_Customers as 
--crm_customer_info is the master table & mostly left join is used 
select 
--we must create surrogate key for dimension table for better data modellning & column distinction
ROW_NUMBER()over(order by c1.cst_create_date) as customer_key,
c1.cst_id as customer_id, 
c1.cst_key as customer_no,
c1.cst_firstname as customer_firstname,
c1.cst_lastname as customer_lastname,
c1.cst_marital_status as customer_marital_status,
c1.cst_create_date as custoemr_created_date,
c2.bdate as customer_brithdate, 
case when c1.cst_gndr= 'Unknown' then c2.gen 
else c1.cst_gndr 
end as customer_gender
from silver.crm_customer_info c1
left join silver.erp_cust_az12 c2 
on c1.cst_key = c2.cid 
left join silver.erp_loc_a101 c3 
on c1.cst_key= c3.cid  
