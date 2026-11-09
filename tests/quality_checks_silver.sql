/*
============================================================
Quality Checks
============================================================
Script Purpose: 
  This is a script that I made while creating several quality checks
  for data consistency, accuracy, and standization across the silver schemas.
  It includes checks for: 
    - Null or duplicate pks.
    - Unwanted spaces in string fields.
    - Data standarization and consistency.
    - Invalid date range fixs and orders.
    - Checking consistency between related fields. 

Usage Notes:
    - Run these checks after loading data into the silver layer. 
    - I left most of my comments I made during the process for keeping track.

============================================================
*/

--Validation checks for columns across tables

--check for duplicate or null values from pk
select prd_id, count(*)
from bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null;


--check for unwanted spaces
-- want no result
select prd_nm
from bronze.crm_prd_info
where prd_nm != trim(prd_nm);


--checking for nulls or negative numbers
--want no results
select prd_cost
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null



--data standardization and consistency
select distinct prd_line
from bronze.crm_prd_info;


-- select for invalid date orders
select 
*
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt;

--check for invalid dates
select 
sls_order_dt
from bronze.crm_sales_details
where sls_order_dt < 0;

--further invalid date checks
SELECT
nullif(sls_ship_dt, 0) sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt <= 0
OR len(sls_ship_dt) != 8
or sls_ship_dt > 20500101
or sls_ship_dt < 19000101;

--Check for invalid date orders
select 
* 
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;


-- Checking consistency between sales, quantity, and price
-- sales = quantity * price
-- cannot have returned null, 0, or negative
select distinct
sls_sales as old_sls_sales,
sls_quantity, 
sls_price as old_sls_price,

case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
        then sls_quantity * ABS(sls_price)
    else sls_sales
end as sls_sales,

case when sls_price is null or sls_price <= 0
        then sls_sales / nullif(sls_quantity, 0) 
        else sls_price
end as sls_price

from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales, sls_quantity, sls_price;


--date start/end date inconsistanies with products
select 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,

--this takes the next start date and makes it the new end date of prior column, 
-- the minus 1 subtracts a day from that result
LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_dt_test

from bronze.crm_prd_info
where prd_key in ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')


--check material status and gender 
select distinct  cst_gndr
from bronze.crm_cust_info


-- identify if dates are out of range
select DISTINCT
bdate
from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > getdate();


-- foreign key integrity check (dimensions)
select * 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where c.customer_key is null

