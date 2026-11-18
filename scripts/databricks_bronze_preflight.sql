-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Bronze Layer)
-- Script: databricks_bronze_preflight.sql
-- Purpose: Phase A Preflight Inspection (Read-Only)
-- Target Catalog: dentalkart_dw
-- Target Schema:  dentalkart_dw.bronze
-- Source Volume:  /Volumes/dentalkart_dw/bronze/raw_files/
-- ==============================================================================

-- 1. Verify Active Catalog and Namespace Context
SELECT current_catalog() AS active_catalog, current_schema() AS active_schema;

-- 2. Verify Schema Existence (bronze, silver, gold, dbo)
SHOW SCHEMAS IN dentalkart_dw;

-- 3. Inspect Existing Tables in Target Schema (dentalkart_dw.bronze)
-- Must return 0 tables or report existing objects before any table creation
SHOW TABLES IN dentalkart_dw.bronze;

-- 4. Verify Unity Catalog Volume and File Accessibility
LIST '/Volumes/dentalkart_dw/bronze/raw_files/';

-- 5. Test Parquet Read & Schema Inference for All 14 Datasets (Read-Only 1-Row Probes)

-- 5.1 Dimensions
SELECT 'dim_channel' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_channel.parquet` LIMIT 1;

SELECT 'dim_customer' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_customer.parquet` LIMIT 1;

SELECT 'dim_date' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_date.parquet` LIMIT 1;

SELECT 'dim_location' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_location.parquet` LIMIT 1;

SELECT 'dim_product' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_product.parquet` LIMIT 1;

SELECT 'dim_salesperson' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_salesperson.parquet` LIMIT 1;

SELECT 'dim_supplier' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_supplier.parquet` LIMIT 1;

SELECT 'dim_warehouse' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_warehouse.parquet` LIMIT 1;

-- 5.2 Facts
SELECT 'fact_orders' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_orders.parquet` LIMIT 1;

SELECT 'fact_sales' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_sales.parquet` LIMIT 1;

SELECT 'fact_returns' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_returns.parquet` LIMIT 1;

SELECT 'fact_sales_targets' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_sales_targets.parquet` LIMIT 1;

SELECT 'fact_inventory_snapshot' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_inventory_snapshot.parquet` LIMIT 1;

SELECT 'fact_service' AS dataset, * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_service.parquet` LIMIT 1;
