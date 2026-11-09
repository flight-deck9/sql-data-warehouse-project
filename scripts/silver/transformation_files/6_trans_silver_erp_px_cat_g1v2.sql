-- ============================================================
-- CLEANING SCRIPT FOR SILVER LAYER: silver.erp_px_cat_g1v2 DATA TRANSFORMATION
-- Source: bronze.erp_px_cat_g1v2
-- Target: silver.silver.erp_px_cat_g1v2
-- Purpose: Deduplicate and standardize customer records

-- ============================================================


print '>> Truncating Table: silver.erp_px_cat_g1v2';
truncate table silver.erp_px_cat_g1v2;
print '>> Inserting Data Into: silver.erp_px_cat_g1v2';


--id matches the prd_key in the crm_prd_info table, 
--made a column in the sliver layer called cat_id for this reason

insert into silver.erp_px_cat_g1v2 (

    id,
    cat,
    subcat,
    maintenance

)


select 
id,
cat, 
subcat, 
maintenance
from bronze.erp_px_cat_g1v2;



--Quality check
/*
select 
* 
from bronze.erp_px_cat_g1v2
where cat != trim(cat) 
or
subcat != trim(subcat)
or 
maintenance != trim(maintenance)

----------

select distinct 
cat 
from bronze.erp_px_cat_g1v2

-- checked subcat and maintenance as well
*/

