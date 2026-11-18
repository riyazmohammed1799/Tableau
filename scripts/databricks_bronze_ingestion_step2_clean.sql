-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Bronze Layer)
-- Script: databricks_bronze_ingestion_step2_clean.sql
-- Target Catalog: dentalkart_dw
-- Target Schema:  dentalkart_dw.bronze
-- Source Volume:  /Volumes/dentalkart_dw/bronze/raw_files/
-- Expected Grand Total: 7,141,000 rows across 14 tables
-- ==============================================================================

USE CATALOG dentalkart_dw;
USE SCHEMA bronze;

-- 1. Dim_Channel (Expected: 5 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_channel
USING DELTA
COMMENT 'Bronze raw ingestion of dim_channel'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_channel.parquet`;

-- 2. Dim_Warehouse (Expected: 6 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_warehouse
USING DELTA
COMMENT 'Bronze raw ingestion of dim_warehouse'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_warehouse.parquet`;

-- 3. Dim_Supplier (Expected: 50 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_supplier
USING DELTA
COMMENT 'Bronze raw ingestion of dim_supplier'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_supplier.parquet`;

-- 4. Dim_Location (Expected: 60 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_location
USING DELTA
COMMENT 'Bronze raw ingestion of dim_location'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_location.parquet`;

-- 5. Dim_Salesperson (Expected: 500 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_salesperson
USING DELTA
COMMENT 'Bronze raw ingestion of dim_salesperson'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_salesperson.parquet`;

-- 6. Dim_Product (Expected: 1,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_product
USING DELTA
COMMENT 'Bronze raw ingestion of dim_product'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_product.parquet`;

-- 7. Dim_Date (Expected: 1,826 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_date
USING DELTA
COMMENT 'Bronze raw ingestion of dim_date'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_date.parquet`;

-- 8. Dim_Customer (Expected: 100,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_customer
USING DELTA
COMMENT 'Bronze raw ingestion of dim_customer'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_customer.parquet`;

-- 9. Fact_Sales_Targets (Expected: 120,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_sales_targets
USING DELTA
COMMENT 'Bronze raw ingestion of fact_sales_targets'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_sales_targets.parquet`;

-- 10. Fact_Service (Expected: 120,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_service
USING DELTA
COMMENT 'Bronze raw ingestion of fact_service'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_service.parquet`;

-- 11. Fact_Returns (Expected: 187,553 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_returns
USING DELTA
COMMENT 'Bronze raw ingestion of fact_returns'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_returns.parquet`;

-- 12. Fact_Inventory_Snapshot (Expected: 360,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_inventory_snapshot
USING DELTA
COMMENT 'Bronze raw ingestion of fact_inventory_snapshot'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_inventory_snapshot.parquet`;

-- 13. Fact_Orders (Expected: 1,250,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_orders
USING DELTA
COMMENT 'Bronze raw ingestion of fact_orders'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_orders.parquet`;

-- 14. Fact_Sales (Expected: 5,000,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_sales
USING DELTA
COMMENT 'Bronze raw ingestion of fact_sales'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_sales.parquet`;
