-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Silver Layer)
-- Script: databricks_silver_copy_step2_clean.sql
-- Target Catalog: dentalkart_dw
-- Target Schema:  dentalkart_dw.silver
-- Source Schema:  dentalkart_dw.bronze
-- Expected Grand Total: 7,141,000 rows across 14 tables
-- ==============================================================================

USE CATALOG dentalkart_dw;
USE SCHEMA silver;

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
