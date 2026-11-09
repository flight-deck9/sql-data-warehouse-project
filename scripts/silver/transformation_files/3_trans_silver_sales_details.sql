-- ============================================================
-- CLEANING SCRIPT FOR SILVER LAYER: SALES DETAILS DATA TRANSFORMATION
-- Source: bronze.crm_sales_details table
-- Target: silver.crm_cust_info
-- Purpose: Clean and standardize sales details


-- ============================================================

print '>> Truncating Table: silver.crm_sales_details';
truncate table silver.crm_sales_details;
print 'Inserting Data Into: silver.crm_sales_details';


INSERT into silver.crm_sales_details (

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


select 
sls_ord_num,
sls_prd_key,
sls_cust_id,

-- had to cast int to varchar, then varchar to date
--sls_order_dt,
Case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
     else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,


--sls_ship_dt,
Case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
     else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt,

--sls_due_dt,
Case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
     else cast(cast(sls_due_dt as varchar) as date)
end as sls_due_dt,


-- so the sum of sales = quaity * price
--sls_sales,
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
        then sls_quantity * ABS(sls_price)
    else sls_sales
end as sls_sales,

sls_quantity,

--sls_price
case when sls_price is null or sls_price <= 0
        then sls_sales / nullif(sls_quantity, 0) 
        else sls_price
end as sls_price


from bronze.crm_sales_details;
