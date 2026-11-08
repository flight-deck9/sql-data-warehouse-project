/* 
=================================================================================
Procedure for the Bronze Layer
=================================================================================
Purpose:
  This stored procedure loads data into the bronze schema from external CSV files.
      It performs the following actions:
      - Truncates the bronze tables before loading the data.
      - Uses the Bulk insert command to load data from csv files to bronze tables.

Parameters:
  No parameters are accected in this script and no values are returned.

Usage Example:
    EXEC bronze.load_bronze;

Additional:
I'm operating on a mac and my sqlserver is running inside a seperate linux container via docker. 
I just copied my local file path into docker using console 
(docker cp "local_path" "sql-dwh-project:/var/opt/mssql/(filename).csv") 
and used a container destination for upload.

- I have assigned, "declared", four variables for time durations that are used in the log output for performance readings.
- I truncated to help refresh the table when loading so I wont get duplicates when testing and calling exec.
- Put try and catch in place that will provide an error message and error number functions in the console log. 
=================================================================================
*/




create or alter procedure bronze.load_bronze AS

begin 
    Declare @start_time datetime, @end_time datetime;
    Declare @batch_start_time datetime, @batch_end_time datetime;
    begin try
        print '====================================================';
        print 'Loading Bronze Layer';
        print '====================================================';

        print '----------------------------------------------------';
        print 'Loading CRM Tables';
        print '----------------------------------------------------';

        set @batch_start_time = getdate();

        --This is the crm customer info
        set @start_time = getdate();
        print '>> Truncating Table: bronze.crm_cust_info';
        truncate table bronze.crm_cust_info;

        print '>> Inserting Data Into: bronze.crm_cust_info';
        BULK insert bronze.crm_cust_info
        from '/var/opt/mssql/cust_info.csv'

        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock                
        );

             set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';

        -- double check quality of upload 
        --select * from bronze.crm_cust_info;
        --select count(*) from bronze.crm_cust_info;

        print '';
        -------------
        

        -- This is the CRM prd info
        set @start_time = getdate();
        print '>> Truncating Table: bronze.crm_prd_info';
        truncate table bronze.crm_prd_info;

        print '>> Inserting Data Into: bronze.crm_prd_info';
        BULK insert bronze.crm_prd_info
        from '/var/opt/mssql/prd_info.csv'

        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock                
        );

            set @end_time = getdate();
            print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
            print '   ----------------------';
        -- double check quality of upload 
        --select * from bronze.crm_prd_info;
        --select count(*) from bronze.crm_prd_info;

        print '';
        ---------------

        -- This is the Sales Details
        set @start_time = getdate();
        print '>> Truncating Table: bronze.crm_sales_details';
        truncate table bronze.crm_sales_details;

        print '>> Inserting Data Into: bronze.crm_sales_details';
        BULK insert bronze.crm_sales_details
        from '/var/opt/mssql/sales_details.csv'

        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock                
        );

            set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';
        -- double check quality of upload 
        --select * from bronze.crm_sales_details;
        --select count(*) from bronze.crm_sales_details;

        print '';
        -----------------

        print '----------------------------------------------------';
        print 'Loading ERP Tables';
        print '----------------------------------------------------';


        -- this is for the cust_az12
        set @start_time = getdate();
        print '>> Truncating Table: bronze.erp_cust_az12';
        truncate table bronze.erp_cust_az12;

        print '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK insert bronze.erp_cust_az12
        from '/var/opt/mssql/cust_az12.csv'

        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock                
        );

            set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';
        -- double check quality of upload 
        --select * from bronze.erp_cust_az12;;
        --select count(*) from bronze.erp_cust_az12;

        print '';
        --------------------

        -- this is for the loc_A101
        set @start_time = getdate();
        print '>> Truncating Table: bronze.erp_loc_a101';
        truncate table bronze.erp_loc_a101;

        print '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK insert bronze.erp_loc_a101
        from '/var/opt/mssql/loc_a101.csv'

        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock                
        );

                set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as nvarchar) + ' ms';
             print '   ----------------------';
        -- double check quality of upload 
        --select * from bronze.erp_loc_a101;;
        --select count(*) from bronze.erp_loc_a101;

        print '';
        --------------------

        -- this is for the px_cat_g1v2
        set @start_time = getdate();
        print '>> Truncating Table: bronze.erp_px_cat_g1v2';
        truncate table bronze.erp_px_cat_g1v2;

        print '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK insert bronze.erp_px_cat_g1v2
        from '/var/opt/mssql/px_cat_g1v2.csv'

        with (
            firstrow = 2,
            fieldterminator = ',',
            tablock                
        );

            set @end_time = getdate();
             print '>> Load Duration: ' + Cast(DATEDIFF(millisecond, @start_time, @end_time) as varchar(20)) + ' ms';
             print '   ----------------------';
        -- double check quality of upload 
        --select * from bronze.erp_px_cat_g1v2;;
        --select count(*) from bronze.erp_px_cat_g1v2;


    set @batch_end_time = getdate();

    print '====================================================';
    print 'Loading the bronze layer is completed';
    print '     - Total load duration: ' + Cast(Datediff(millisecond, @batch_start_time, @batch_end_time) as varchar) + ' ms';
    print '====================================================';


    end try
    begin catch
    print '====================================================';
    print 'There was an error during loading of bronze layer';
    print '';
    print 'Error Message' + Error_Message();
    print '';
    print 'Error Message' + CAST (Error_Number() as nvarchar);
    print '====================================================';
    end catch
end;
