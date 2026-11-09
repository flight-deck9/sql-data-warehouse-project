/* 
=================================================================================
Stored Procedure, Loads Silver Layer (Bronze --> Silver)
=================================================================================
Purpose:
    This stored procedure performs the ETL process to populate the Silver schema
    from the bronze schema.

        Actions Performed;
            - Truncates Silver Tables
            - Inserts transformed and cleansed data from Bronze into Silver Tables.
  
  
  Parameters:
        None.
                This stored procedure does not accept any parameters or return any 
                values


    Usuage Example: 

            EXEC silver.load_silver;
  
=================================================================================
*/

--exec silver.load_silver;

create or alter procedure silver.load_silver as

Begin

    Declare @start_time datetime, @end_time datetime;
    Declare @batch_start_time datetime, @batch_end_time datetime;
    begin try
        print '====================================================';
        print 'Loading SILVER Layer';
        print '====================================================';

        print '----------------------------------------------------';
        print 'Loading CRM Tables';
        print '----------------------------------------------------';

        set @batch_start_time = getdate();

        --This is the crm customer info
        set @start_time = getdate();
    print '>> Truncating Table: silver.crm_cust_info';
    truncate table silver.crm_cust_info;
    print '>> Inserting Data Into: silver.crm_cust_info';

    Insert into silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
    )
    
    SELECT
    cst_id,
    cst_key,
    trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as cst_lastname,
    CASE when UPPER(trim(cst_marital_status)) = 'S' then 'Single'
        when Upper(trim(cst_marital_status)) = 'M' then 'Married'
        else 'n/a'
    end cst_marital_status,
    CASE when UPPER(trim(cst_gndr)) = 'F' then 'Female'
        when Upper(trim(cst_gndr)) = 'M' then 'Male'
        else 'n/a'
    end cst_gndr,
    cst_create_date
    
    from(
        select
        *
        from
            (select  
            *,
            row_number() over (partition by cst_id order by cst_create_date desc) as pick_last
            from bronze.crm_cust_info) t1 
            where pick_last = 1

        ) t2;

         set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';

    -- ----------- next table

    set @start_time = getdate();

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
    replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
    substring(prd_key, 7, len(prd_key)) as prd_key,
    prd_nm,
    isnull(prd_cost, 0) as prd_cost,
    case when upper(trim(prd_line)) = 'M' then 'Mountain'
        when upper(trim(prd_line)) = 'R' then 'Road'
        when upper(trim(prd_line)) = 'S' then 'Other sales'
        when upper(trim(prd_line)) = 'T' then 'Touring'
        else 'n/a' 
    end as prd_line, 
    cast (prd_start_dt as date) as prd_start_dt,
    cast( LEAD(prd_start_dt) over ( partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt

    from bronze.crm_prd_info;

    set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';

    -- ----------- next table

    set @start_time = getdate();

    print '>> Truncating Table: silver.crm_sales_details';
    truncate table silver.crm_sales_details;
    print '>> Inserting Data Into: silver.crm_sales_details';


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
    
    Case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
        else cast(cast(sls_order_dt as varchar) as date)
    end as sls_order_dt,

    Case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
        else cast(cast(sls_ship_dt as varchar) as date)
    end as sls_ship_dt,

    Case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
        else cast(cast(sls_due_dt as varchar) as date)
    end as sls_due_dt,

    case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
            then sls_quantity * ABS(sls_price)
        else sls_sales
    end as sls_sales,

    sls_quantity,

    case when sls_price is null or sls_price <= 0
            then sls_sales / nullif(sls_quantity, 0) 
            else sls_price
    end as sls_price

    from bronze.crm_sales_details;

    set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';

    -- ----------- next table

    set @start_time = getdate();

    print '>> Truncating Table: silver.erp_cust_az12';
    truncate table silver.erp_cust_az12;
    print '>> Inserting Data Into: silver.erp_cust_az12';


    INSERT INTO silver.erp_cust_az12 (

        cid,
        bdate,
        gen
    )

    select 
    
    case when cid like 'NAS%' then substring(cid, 4, len(cid))
        else cid
    end as cid,

    case when bdate > getdate() then null
        else bdate
    end as bdate,

    case when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
        when upper(trim(gen)) in ('M', 'MALE') then 'Male'
        else 'n/a'
    end as gen

    from bronze.erp_cust_az12;

    set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';

    -- ----------- next table

    set @start_time = getdate();

    print '>> Truncating Table: silver.erp_loc_a101';
    truncate table silver.erp_loc_a101;
    print '>> Inserting Data Into: silver.erp_loc_a101';

    insert into silver.erp_loc_a101 (
    
        cid,
        cntry
    )

    select 

    replace(cid, '-', '') as cid,

    case when trim(cntry)  = 'DE' then 'Germany'
        when trim(cntry) in ('US', 'USA') then 'United States'
        when trim(cntry) = '' or cntry is null then 'n/a'
        else trim(cntry)
    end as cntry

    from bronze.erp_loc_a101;

    set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';

    -- ----------- next table

    set @start_time = getdate();

    print '>> Truncating Table: silver.erp_px_cat_g1v2';
    truncate table silver.erp_px_cat_g1v2;
    print '>> Inserting Data Into: silver.erp_px_cat_g1v2';

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

     set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';


        set @batch_end_time = getdate();

        print '====================================================';
    print 'Loading the silver layer is completed';
    print '     - Total load duration: ' + Cast(Datediff(millisecond, @batch_start_time, @batch_end_time) as varchar) + ' ms';
    print '====================================================';


    end try
    begin catch
    print '====================================================';
    print 'There was an error during loading of silver layer';
    print '';
    print 'Error Message' + Error_Message();
    print '';
    print 'Error Message' + CAST (Error_Number() as nvarchar);
    print '====================================================';
    end catch

    -- ----------- end of tables
end;
