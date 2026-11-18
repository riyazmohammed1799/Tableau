-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Bronze Layer)
-- Script: databricks_bronze_ingestion.sql
-- Purpose: Phase C Remaining Ingestion (13 Datasets in 3 Risk-Tiered Batches)
-- Target Catalog: dentalkart_dw
-- Target Schema:  dentalkart_dw.bronze
-- Source Volume:  /Volumes/dentalkart_dw/bronze/raw_files/
-- ==============================================================================

-- ==============================================================================
-- BATCH 1: Low-Volume Master Dimensions (6 Tables)
-- Verify completion of each batch before triggering the next.
-- ==============================================================================

-- 1. Dim_Warehouse (Expected: 6 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_warehouse
USING DELTA
COMMENT 'Bronze raw ingestion of dim_warehouse'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_warehouse.parquet`;

-- 2. Dim_Supplier (Expected: 50 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_supplier
USING DELTA
COMMENT 'Bronze raw ingestion of dim_supplier'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_supplier.parquet`;

-- 3. Dim_Location (Expected: 60 rows across 5 regions)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_location
USING DELTA
COMMENT 'Bronze raw ingestion of dim_location'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_location.parquet`;

-- 4. Dim_Salesperson (Expected: 500 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_salesperson
USING DELTA
COMMENT 'Bronze raw ingestion of dim_salesperson'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_salesperson.parquet`;

-- 5. Dim_Product (Expected: 1,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_product
USING DELTA
COMMENT 'Bronze raw ingestion of dim_product'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_product.parquet`;

-- 6. Dim_Date (Expected: 1,826 rows, 2021-2025)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_date
USING DELTA
COMMENT 'Bronze raw ingestion of dim_date'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_date.parquet`;

-- Batch 1 Verification Query:
SELECT 'dim_warehouse' AS tbl, count(*) AS cnt, 6 AS exp FROM dentalkart_dw.bronze.dim_warehouse
UNION ALL
SELECT 'dim_supplier', count(*), 50 FROM dentalkart_dw.bronze.dim_supplier
UNION ALL
SELECT 'dim_location', count(*), 60 FROM dentalkart_dw.bronze.dim_location
UNION ALL
SELECT 'dim_salesperson', count(*), 500 FROM dentalkart_dw.bronze.dim_salesperson
UNION ALL
SELECT 'dim_product', count(*), 1000 FROM dentalkart_dw.bronze.dim_product
UNION ALL
SELECT 'dim_date', count(*), 1826 FROM dentalkart_dw.bronze.dim_date;


-- ==============================================================================
-- BATCH 2: Mid-Volume Dimensions & Fact Tables (5 Tables)
-- ==============================================================================

-- 7. Dim_Customer (Expected: 100,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_customer
USING DELTA
COMMENT 'Bronze raw ingestion of dim_customer'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_customer.parquet`;

-- 8. Fact_Sales_Targets (Expected: 120,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_sales_targets
USING DELTA
COMMENT 'Bronze raw ingestion of fact_sales_targets'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_sales_targets.parquet`;

-- 9. Fact_Service (Expected: 120,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_service
USING DELTA
COMMENT 'Bronze raw ingestion of fact_service'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_service.parquet`;

-- 10. Fact_Returns (Expected: 187,553 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_returns
USING DELTA
COMMENT 'Bronze raw ingestion of fact_returns'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_returns.parquet`;

-- 11. Fact_Inventory_Snapshot (Expected: 360,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_inventory_snapshot
USING DELTA
COMMENT 'Bronze raw ingestion of fact_inventory_snapshot'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_inventory_snapshot.parquet`;

-- Batch 2 Verification Query:
SELECT 'dim_customer' AS tbl, count(*) AS cnt, 100000 AS exp FROM dentalkart_dw.bronze.dim_customer
UNION ALL
SELECT 'fact_sales_targets', count(*), 120000 FROM dentalkart_dw.bronze.fact_sales_targets
UNION ALL
SELECT 'fact_service', count(*), 120000 FROM dentalkart_dw.bronze.fact_service
UNION ALL
SELECT 'fact_returns', count(*), 187553 FROM dentalkart_dw.bronze.fact_returns
UNION ALL
SELECT 'fact_inventory_snapshot', count(*), 360000 FROM dentalkart_dw.bronze.fact_inventory_snapshot;


-- ==============================================================================
-- BATCH 3: High-Volume Transaction Fact Tables (2 Tables)
-- ==============================================================================

-- 12. Fact_Orders (Expected: 1,250,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_orders
USING DELTA
COMMENT 'Bronze raw ingestion of fact_orders'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_orders.parquet`;

-- 13. Fact_Sales (Expected: 5,000,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.fact_sales
USING DELTA
COMMENT 'Bronze raw ingestion of fact_sales'
AS SELECT * FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/fact_sales.parquet`;

-- Batch 3 Verification Query:
SELECT 'fact_orders' AS tbl, count(*) AS cnt, 1250000 AS exp FROM dentalkart_dw.bronze.fact_orders
UNION ALL
SELECT 'fact_sales', count(*), 5000000 FROM dentalkart_dw.bronze.fact_sales;
