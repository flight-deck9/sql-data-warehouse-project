/*
======
Create database and Schemas
======

Purpose: 
  This script creates a new database named 'DataWarehouse' after checking if it already exists.
  It will drop it and recreate if exists. This also sets up three schemas within the database 'bronze', 'silver', 'gold'.

Warning: 
  use caution with prior database named "DataWarehouse'.
*/
  
USE master;
GO

  -- Drop and recreate any 'DataWarehouse' that was made prior.
IF EXISTS (Select 1 from sys.databases where name = 'DataWarehouse')
  Begin
    alter database DataWarehouse set SINGLE_USER with rollback immediate;
    drop database DataWarehouse;
end;
go

  
-- Create the 'DataWarehouse' database
  
create database DataWarehouse;

use DataWarehouse;

create schema bronze;
create schema silver;
create schema gold;

