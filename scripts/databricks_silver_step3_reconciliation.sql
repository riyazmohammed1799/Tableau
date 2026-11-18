-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Silver Layer)
-- Script: databricks_silver_step3_reconciliation.sql
-- Target Catalog / Schema: dentalkart_dw.silver
-- Expected Grand Total: 7,141,000 rows across 14 tables
-- ==============================================================================

USE CATALOG dentalkart_dw;
USE SCHEMA silver;

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
