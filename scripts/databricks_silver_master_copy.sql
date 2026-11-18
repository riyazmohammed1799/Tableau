-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Silver Layer)
-- Script: databricks_silver_master_copy.sql
-- Target Catalog: dentalkart_dw
-- Target Schema:  dentalkart_dw.silver
-- Source Schema:  dentalkart_dw.bronze
-- Expected Grand Total: 7,141,000 rows across 14 tables
-- ==============================================================================
-- INSTRUCTIONS FOR DATABRICKS SQL EDITOR:
-- STEP 1: Run Preflight query to ensure `silver` schema has 0 conflicting tables.
-- STEP 2: Run Copy DDL to populate `dentalkart_dw.silver` directly from `bronze`.
-- STEP 3: Run Reconciliation query to verify 100% parity across all 14 tables.
-- ==============================================================================

USE CATALOG dentalkart_dw;
USE SCHEMA silver;

-- ==============================================================================
-- STEP 1: PREFLIGHT TABLE EXISTENCE AUDIT (Silver Schema)
-- ==============================================================================

SELECT 
    table_name, 
    table_type, 
    created, 
    last_altered
FROM dentalkart_dw.information_schema.tables
WHERE table_schema = 'silver'
  AND table_name IN (
    'dim_channel', 'dim_warehouse', 'dim_supplier', 'dim_location',
    'dim_salesperson', 'dim_product', 'dim_date', 'dim_customer',
    'fact_sales_targets', 'fact_service', 'fact_returns',
    'fact_inventory_snapshot', 'fact_orders', 'fact_sales'
  )
ORDER BY table_name;


-- ==============================================================================
-- STEP 2: BRONZE TO SILVER BASELINE COPY DDL (All 14 Tables)
-- Creates managed Delta tables in `silver` as independent copies of `bronze`.
-- Preserves Bronze raw layer immutability while enabling Silver transformations.
-- ==============================================================================

-- 1. Dim_Channel (Expected: 5 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_channel
USING DELTA
COMMENT 'Silver working copy of dim_channel'
AS SELECT * FROM dentalkart_dw.bronze.dim_channel;

-- 2. Dim_Warehouse (Expected: 6 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_warehouse
USING DELTA
COMMENT 'Silver working copy of dim_warehouse'
AS SELECT * FROM dentalkart_dw.bronze.dim_warehouse;

-- 3. Dim_Supplier (Expected: 50 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_supplier
USING DELTA
COMMENT 'Silver working copy of dim_supplier'
AS SELECT * FROM dentalkart_dw.bronze.dim_supplier;

-- 4. Dim_Location (Expected: 60 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_location
USING DELTA
COMMENT 'Silver working copy of dim_location'
AS SELECT * FROM dentalkart_dw.bronze.dim_location;

-- 5. Dim_Salesperson (Expected: 500 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_salesperson
USING DELTA
COMMENT 'Silver working copy of dim_salesperson'
AS SELECT * FROM dentalkart_dw.bronze.dim_salesperson;

-- 6. Dim_Product (Expected: 1,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_product
USING DELTA
COMMENT 'Silver working copy of dim_product'
AS SELECT * FROM dentalkart_dw.bronze.dim_product;

-- 7. Dim_Date (Expected: 1,826 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_date
USING DELTA
COMMENT 'Silver working copy of dim_date'
AS SELECT * FROM dentalkart_dw.bronze.dim_date;

-- 8. Dim_Customer (Expected: 100,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.dim_customer
USING DELTA
COMMENT 'Silver working copy of dim_customer'
AS SELECT * FROM dentalkart_dw.bronze.dim_customer;

-- 9. Fact_Sales_Targets (Expected: 120,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.fact_sales_targets
USING DELTA
COMMENT 'Silver working copy of fact_sales_targets'
AS SELECT * FROM dentalkart_dw.bronze.fact_sales_targets;

-- 10. Fact_Service (Expected: 120,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.fact_service
USING DELTA
COMMENT 'Silver working copy of fact_service'
AS SELECT * FROM dentalkart_dw.bronze.fact_service;

-- 11. Fact_Returns (Expected: 187,553 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.fact_returns
USING DELTA
COMMENT 'Silver working copy of fact_returns'
AS SELECT * FROM dentalkart_dw.bronze.fact_returns;

-- 12. Fact_Inventory_Snapshot (Expected: 360,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.fact_inventory_snapshot
USING DELTA
COMMENT 'Silver working copy of fact_inventory_snapshot'
AS SELECT * FROM dentalkart_dw.bronze.fact_inventory_snapshot;

-- 13. Fact_Orders (Expected: 1,250,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.fact_orders
USING DELTA
COMMENT 'Silver working copy of fact_orders'
AS SELECT * FROM dentalkart_dw.bronze.fact_orders;

-- 14. Fact_Sales (Expected: 5,000,000 rows)
CREATE TABLE IF NOT EXISTS dentalkart_dw.silver.fact_sales
USING DELTA
COMMENT 'Silver working copy of fact_sales'
AS SELECT * FROM dentalkart_dw.bronze.fact_sales;


-- ==============================================================================
-- STEP 3: UNIFIED SILVER ROW COUNT RECONCILIATION & AUDIT
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
    SELECT '01. dim_channel' AS dataset, count(*) AS actual_rows FROM dentalkart_dw.silver.dim_channel UNION ALL
    SELECT '02. dim_warehouse', count(*) FROM dentalkart_dw.silver.dim_warehouse UNION ALL
    SELECT '03. dim_supplier', count(*) FROM dentalkart_dw.silver.dim_supplier UNION ALL
    SELECT '04. dim_location', count(*) FROM dentalkart_dw.silver.dim_location UNION ALL
    SELECT '05. dim_salesperson', count(*) FROM dentalkart_dw.silver.dim_salesperson UNION ALL
    SELECT '06. dim_product', count(*) FROM dentalkart_dw.silver.dim_product UNION ALL
    SELECT '07. dim_date', count(*) FROM dentalkart_dw.silver.dim_date UNION ALL
    SELECT '08. dim_customer', count(*) FROM dentalkart_dw.silver.dim_customer UNION ALL
    SELECT '09. fact_sales_targets', count(*) FROM dentalkart_dw.silver.fact_sales_targets UNION ALL
    SELECT '10. fact_service', count(*) FROM dentalkart_dw.silver.fact_service UNION ALL
    SELECT '11. fact_returns', count(*) FROM dentalkart_dw.silver.fact_returns UNION ALL
    SELECT '12. fact_inventory_snapshot', count(*) FROM dentalkart_dw.silver.fact_inventory_snapshot UNION ALL
    SELECT '13. fact_orders', count(*) FROM dentalkart_dw.silver.fact_orders UNION ALL
    SELECT '14. fact_sales', count(*) FROM dentalkart_dw.silver.fact_sales
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
    '=== GRAND TOTAL (ALL 14 SILVER TABLES) ===' AS dataset,
    sum(expected_rows) AS expected_rows,
    sum(actual_rows) AS actual_rows,
    sum(variance) AS variance,
    CASE 
        WHEN sum(variance) = 0 AND count(*) = 14 THEN 'PASSED (100% LEDGER PARITY)' 
        ELSE 'FAILED (Discrepancy Detected)' 
    END AS audit_status
FROM detail_audit;
