-- ==============================================================================
-- DentaKart Analytics — Track B: Databricks Lakehouse (Bronze Layer)
-- Script: databricks_bronze_validation.sql
-- Purpose: Phase D Comprehensive Validation & Parity Audit (All 14 Tables)
-- Target Catalog: dentalkart_dw.bronze
-- ==============================================================================

-- 1. Unified 14-Table Row Count Parity Reconciliation
WITH expected_metrics AS (
    SELECT 'dim_channel' AS dataset, 5 AS expected_rows UNION ALL
    SELECT 'dim_customer', 100000 UNION ALL
    SELECT 'dim_date', 1826 UNION ALL
    SELECT 'dim_location', 60 UNION ALL
    SELECT 'dim_product', 1000 UNION ALL
    SELECT 'dim_salesperson', 500 UNION ALL
    SELECT 'dim_supplier', 50 UNION ALL
    SELECT 'dim_warehouse', 6 UNION ALL
    SELECT 'fact_orders', 1250000 UNION ALL
    SELECT 'fact_sales', 5000000 UNION ALL
    SELECT 'fact_returns', 187553 UNION ALL
    SELECT 'fact_sales_targets', 120000 UNION ALL
    SELECT 'fact_inventory_snapshot', 360000 UNION ALL
    SELECT 'fact_service', 120000
),
actual_counts AS (
    SELECT 'dim_channel' AS dataset, count(*) AS actual_rows FROM dentalkart_dw.bronze.dim_channel UNION ALL
    SELECT 'dim_customer', count(*) FROM dentalkart_dw.bronze.dim_customer UNION ALL
    SELECT 'dim_date', count(*) FROM dentalkart_dw.bronze.dim_date UNION ALL
    SELECT 'dim_location', count(*) FROM dentalkart_dw.bronze.dim_location UNION ALL
    SELECT 'dim_product', count(*) FROM dentalkart_dw.bronze.dim_product UNION ALL
    SELECT 'dim_salesperson', count(*) FROM dentalkart_dw.bronze.dim_salesperson UNION ALL
    SELECT 'dim_supplier', count(*) FROM dentalkart_dw.bronze.dim_supplier UNION ALL
    SELECT 'dim_warehouse', count(*) FROM dentalkart_dw.bronze.dim_warehouse UNION ALL
    SELECT 'fact_orders', count(*) FROM dentalkart_dw.bronze.fact_orders UNION ALL
    SELECT 'fact_sales', count(*) FROM dentalkart_dw.bronze.fact_sales UNION ALL
    SELECT 'fact_returns', count(*) FROM dentalkart_dw.bronze.fact_returns UNION ALL
    SELECT 'fact_sales_targets', count(*) FROM dentalkart_dw.bronze.fact_sales_targets UNION ALL
    SELECT 'fact_inventory_snapshot', count(*) FROM dentalkart_dw.bronze.fact_inventory_snapshot UNION ALL
    SELECT 'fact_service', count(*) FROM dentalkart_dw.bronze.fact_service
)
SELECT 
    e.dataset,
    e.expected_rows,
    a.actual_rows,
    (a.actual_rows - e.expected_rows) AS variance,
    CASE 
        WHEN a.actual_rows = e.expected_rows THEN 'PASS (Exact Parity)'
        ELSE 'FAIL (Mismatch Detected)'
    END AS status
FROM expected_metrics e
JOIN actual_counts a ON e.dataset = a.dataset
ORDER BY e.expected_rows ASC, e.dataset ASC;


-- 2. Basic Integrity & Key Non-Nullability Audit
SELECT 'dim_customer' AS table_tested, count(*) - count(customer_id) AS null_pk_count FROM dentalkart_dw.bronze.dim_customer
UNION ALL
SELECT 'dim_product', count(*) - count(product_id) FROM dentalkart_dw.bronze.dim_product
UNION ALL
SELECT 'dim_date', count(*) - count(date_key) FROM dentalkart_dw.bronze.dim_date
UNION ALL
SELECT 'fact_orders', count(*) - count(order_id) FROM dentalkart_dw.bronze.fact_orders
UNION ALL
SELECT 'fact_sales', count(*) - count(order_line_id) FROM dentalkart_dw.bronze.fact_sales;


-- 3. Core Financial Sanity Check in Fact_Sales
SELECT 
    count(*) AS total_sales_records,
    round(sum(gross_sales_inr), 2) AS total_gross_sales,
    round(sum(discount_amount_inr), 2) AS total_discount,
    round(sum(net_sales_inr), 2) AS total_net_revenue,
    round(sum(gross_profit_inr), 2) AS total_gross_profit,
    round(sum(gross_sales_inr - discount_amount_inr - net_sales_inr), 2) AS net_revenue_calc_variance
FROM dentalkart_dw.bronze.fact_sales;
