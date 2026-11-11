-- ============================================================
-- CLEANING SCRIPT FOR SILVER LAYER: silver.erp_loc_a101 DATA TRANSFORMATION
-- Source: bronze.erp_loc_a101
-- Target: silver.silver.erp_loc_a101
-- Purpose: Deduplicate and standardize customer records

-- ============================================================


print '>> Truncating Table: silver.erp_loc_a101';
truncate table silver.erp_loc_a101;
print '>> Inserting Data Into: silver.erp_loc_a101';


insert into silver.erp_loc_a101 (

    cid,
    cntry

)


select 

--need to remove cid "-" to match the same cst_key within the crm_cust_info table
replace(cid, '-', '') as cid,


-- need to fix some countries 
--cntry
case when trim(cntry)  = 'DE' then 'Germany'
     when trim(cntry) in ('US', 'USA') then 'United States'
     when trim(cntry) = '' or cntry is null then 'n/a'
     else trim(cntry)
end as cntry


from bronze.erp_loc_a101;

--select cst_key from silver.crm_cust_info;
