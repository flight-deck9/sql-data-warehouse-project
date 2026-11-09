-- ============================================================
-- CLEANING SCRIPT FOR SILVER LAYER: PRODUCT INFO DATA TRANSFORMATION
-- Source: bronze.crm_prd_info
-- Target: silver.crm_prd_info
-- Purpose: Deduplicate and standardize product records

-- fyi, I checked the prd_start_dt and the prd_end_dt and had many inconsistencies.
-- I tried to swap them but the prd_cost didn't make sense as it was increasing in value.
-- I ended up taking the table including start date and rebuilding the prd_end_dt from prior start date.
-- The logic I used is the end date of a record comes from the start date of new record,
-- and the start date used for that end date will be subtracted by 1 day to avoid overlap with new start date.
-- ============================================================

print '>> Truncating Table: silver.crm_prd_info';
truncate table silver.crm_prd_info;
print '>> Inserting Data Into: silver.crm_prd_info';

INSERT INTO silver.crm_prd_info (

    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)

select 

prd_id,


--fyi, when looking over the csvs, it took me some digging to figure out that first 5 char of prd_key 
--is linked as the pk of erp_px_cat_g1v2 and that char[3] needs to be converted for joining cat_id
--need to be able to join with erp_px_cat_g1v2
replace(substring(prd_key, 1, 5), '-', '_') as cat_id,

--need to extract second part of prd_key to be able to join with sales_details
substring(prd_key, 7, len(prd_key)) as prd_key,

prd_nm,

--fix null values and replace with zeros
isnull(prd_cost, 0) as prd_cost,

--prd_line, trimming and formatting single values to full string
case when upper(trim(prd_line)) = 'M' then 'Mountain'
     when upper(trim(prd_line)) = 'R' then 'Road'
     when upper(trim(prd_line)) = 'S' then 'Other sales'
     when upper(trim(prd_line)) = 'T' then 'Touring'
     else 'n/a' 
end as prd_line,

--Had lots of nulls in new end date logic so casted start datetime and last datetime as dates. 
cast (prd_start_dt as date) as prd_start_dt,

--prd_end_dt
--this takes the next start date and makes it the new end date of prior column, 
-- the minus 1 subtracts a day from that result
cast( LEAD(prd_start_dt) over ( partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt

from bronze.crm_prd_info;





--select distinct id from bronze.erp_px_cat_g1v2;

/*
select 

prd_id,
prd_key,
replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt

from bronze.crm_prd_info

-- trying to find any cat_id not in erp_px_cat_g1v2 table
where replace(substring(prd_key, 1, 5), '-', '_') as cat_id not in
select distinct id from bronze.erp_px_cat_g1v2;
*/
