-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Bronze Layer)
-- Script: databricks_bronze_master_ingestion.sql
-- Target Catalog: dentalkart_dw
-- Target Schema:  dentalkart_dw.bronze
-- Source Volume:  /Volumes/dentalkart_dw/bronze/raw_files/
-- Expected Grand Total: 7,141,000 rows across 14 tables
-- ==============================================================================
-- INSTRUCTIONS FOR DATABRICKS SQL EDITOR:
-- STEP 1: Run the PREFLIGHT query first.
--         - If 0 rows are returned: The schema is clean. Proceed to STEP 2.
--         - If any table already exists: Check its current row count.
--           Do NOT blindly rely on IF NOT EXISTS to refresh existing data.
-- STEP 2: Run the INGESTION DDL statements to load the 14 Parquet files.
-- STEP 3: Run the RECONCILIATION query to verify row count parity across
--         all 14 tables and certify the 7,141,000 grand total.
-- ==============================================================================

USE CATALOG dentalkart_dw;
USE SCHEMA bronze;

-- ==============================================================================
-- STEP 1: PREFLIGHT TABLE EXISTENCE AUDIT
-- Run this query first to identify any pre-existing tables in the bronze schema.
-- ==============================================================================

SELECT 
    table_name, 
    table_type, 
    created, 
    last_altered
FROM dentalkart_dw.information_schema.tables
WHERE table_schema = 'bronze'
  AND table_name IN (
    'dim_channel', 'dim_warehouse', 'dim_supplier', 'dim_location',
    'dim_salesperson', 'dim_product', 'dim_date', 'dim_customer',
    'fact_sales_targets', 'fact_service', 'fact_returns',
    'fact_inventory_snapshot', 'fact_orders', 'fact_sales'
  )
ORDER BY table_name;


-- ==============================================================================
-- STEP 2: SAFE BRONZE INGESTION DDL (All 14 Datasets)
-- Creates managed Delta tables directly from Volume Parquet files.
-- Safe to re-run: IF NOT EXISTS prevents dropping, truncating, or overwriting.
-- ==============================================================================

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


-- ==============================================================================
-- STEP 3: UNIFIED 14-TABLE ROW COUNT RECONCILIATION & GRAND TOTAL AUDIT
-- Validates individual row counts and grand total in a single result grid.
-- ==============================================================================

WITH expected_metrics AS (
    SELECT '01. dim_channel' AS dataset, 5 AS expected_rows UNION ALL
    SELECT '02. dim_warehouse', 6 UNION ALL
    SELECT '03. dim_supplier', 50 UNION ALL
    SELECT '04. dim_location', 60 UNION ALL
    SELECT '05. dim_salesperson', 500 UNION ALL
    SELECT '06. dim_product', 1000 UNION ALL
    SELECT '07. dim_date', 1826 UNION ALL
    SELECT '08. dim_customer', 100000 UNION ALL
    SELECT '09. fact_sales_targets', 120000 UNION ALL
    SELECT '10. fact_service', 120000 UNION ALL
    SELECT '11. fact_returns', 187553 UNION ALL
    SELECT '12. fact_inventory_snapshot', 360000 UNION ALL
    SELECT '13. fact_orders', 1250000 UNION ALL
    SELECT '14. fact_sales', 5000000
),
actual_metrics AS (
    SELECT '01. dim_channel' AS dataset, count(*) AS actual_rows FROM dentalkart_dw.bronze.dim_channel UNION ALL
    SELECT '02. dim_warehouse', count(*) FROM dentalkart_dw.bronze.dim_warehouse UNION ALL
    SELECT '03. dim_supplier', count(*) FROM dentalkart_dw.bronze.dim_supplier UNION ALL
    SELECT '04. dim_location', count(*) FROM dentalkart_dw.bronze.dim_location UNION ALL
    SELECT '05. dim_salesperson', count(*) FROM dentalkart_dw.bronze.dim_salesperson UNION ALL
    SELECT '06. dim_product', count(*) FROM dentalkart_dw.bronze.dim_product UNION ALL
    SELECT '07. dim_date', count(*) FROM dentalkart_dw.bronze.dim_date UNION ALL
    SELECT '08. dim_customer', count(*) FROM dentalkart_dw.bronze.dim_customer UNION ALL
    SELECT '09. fact_sales_targets', count(*) FROM dentalkart_dw.bronze.fact_sales_targets UNION ALL
    SELECT '10. fact_service', count(*) FROM dentalkart_dw.bronze.fact_service UNION ALL
    SELECT '11. fact_returns', count(*) FROM dentalkart_dw.bronze.fact_returns UNION ALL
    SELECT '12. fact_inventory_snapshot', count(*) FROM dentalkart_dw.bronze.fact_inventory_snapshot UNION ALL
    SELECT '13. fact_orders', count(*) FROM dentalkart_dw.bronze.fact_orders UNION ALL
    SELECT '14. fact_sales', count(*) FROM dentalkart_dw.bronze.fact_sales
),
detail_audit AS (
    SELECT 
        e.dataset,
        e.expected_rows,
        a.actual_rows,
        (a.actual_rows - e.expected_rows) AS variance,
        CASE 
            WHEN a.actual_rows = e.expected_rows THEN 'PASS (Exact Parity)' 
            ELSE 'FAIL (Mismatch Detected)' 
        END AS audit_status
    FROM expected_metrics e
    JOIN actual_metrics a ON e.dataset = a.dataset
)
SELECT dataset, expected_rows, actual_rows, variance, audit_status 
FROM detail_audit
UNION ALL
SELECT 
    '=== GRAND TOTAL (ALL 14 TABLES) ===' AS dataset,
    sum(expected_rows) AS expected_rows,
    sum(actual_rows) AS actual_rows,
    sum(variance) AS variance,
    CASE 
        WHEN sum(variance) = 0 AND count(*) = 14 THEN 'PASSED (100% LEDGER PARITY)' 
        ELSE 'FAILED (Discrepancy Detected)' 
    END AS audit_status
FROM detail_audit;
