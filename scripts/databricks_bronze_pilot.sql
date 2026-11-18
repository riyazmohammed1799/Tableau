-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Bronze Layer)
-- Script: databricks_bronze_pilot.sql
-- Purpose: Phase B Pilot Ingestion (dim_channel)
-- Target Table:  dentalkart_dw.bronze.dim_channel
-- Source File:   /Volumes/dentalkart_dw/bronze/raw_files/dim_channel.parquet
-- Expected Rows: 5
-- ==============================================================================

-- 1. Create Pilot Table (Idempotent, Delta format)
CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.dim_channel
USING DELTA
COMMENT 'Bronze raw ingestion of dim_channel from Unity Catalog Volume'
AS 
SELECT * 
FROM parquet.`/Volumes/dentalkart_dw/bronze/raw_files/dim_channel.parquet`;

-- 2. Validate Table Schema and Metadata
DESCRIBE TABLE EXTENDED dentalkart_dw.bronze.dim_channel;

-- 3. Validate Row Count Parity (Expected = 5)
SELECT 
    'dim_channel' AS dataset_name,
    COUNT(*) AS actual_row_count,
    5 AS expected_row_count,
    CASE WHEN COUNT(*) = 5 THEN 'PASS' ELSE 'FAIL' END AS parity_status
FROM dentalkart_dw.bronze.dim_channel;

-- 4. Inspect Sample Records (All 5 channels)
SELECT 
    channel_id,
    channel_name
FROM dentalkart_dw.bronze.dim_channel
ORDER BY channel_id ASC;

-- 5. Inspect Delta Transaction History (Audit Trail)
DESCRIBE HISTORY dentalkart_dw.bronze.dim_channel;
