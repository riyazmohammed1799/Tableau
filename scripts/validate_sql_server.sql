-- ==============================================================================
-- DentaKart Analytics — Independent SQL Server EDW Validation Queries
-- Database: DentaKart_DW
-- Executes independent verification queries to mathematically validate
-- the loaded database against the generated source datasets.
-- ==============================================================================

USE DentaKart_DW;
GO

-- 1. Table Row Counts Across All 14 Star Schema Tables
PRINT '=== 1. Table Row Counts ===';
SELECT 'Dim_Date' AS Table_Name, COUNT(*) AS Row_Count, 1826 AS Expected_Rows, CASE WHEN COUNT(*) = 1826 THEN 'PASS' ELSE 'FAIL' END AS Status FROM dbo.Dim_Date
UNION ALL
SELECT 'Dim_Location', COUNT(*), 60, CASE WHEN COUNT(*) = 60 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Dim_Location
UNION ALL
SELECT 'Dim_Warehouse', COUNT(*), 6, CASE WHEN COUNT(*) = 6 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Dim_Warehouse
UNION ALL
SELECT 'Dim_Supplier', COUNT(*), 50, CASE WHEN COUNT(*) = 50 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Dim_Supplier
UNION ALL
SELECT 'Dim_Channel', COUNT(*), 5, CASE WHEN COUNT(*) = 5 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Dim_Channel
UNION ALL
SELECT 'Dim_Salesperson', COUNT(*), 500, CASE WHEN COUNT(*) = 500 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Dim_Salesperson
UNION ALL
SELECT 'Dim_Product', COUNT(*), 1000, CASE WHEN COUNT(*) = 1000 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Dim_Product
UNION ALL
SELECT 'Dim_Customer', COUNT(*), 100000, CASE WHEN COUNT(*) = 100000 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Dim_Customer
UNION ALL
SELECT 'Fact_Sales_Targets', COUNT(*), 120000, CASE WHEN COUNT(*) = 120000 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Fact_Sales_Targets
UNION ALL
SELECT 'Fact_Inventory_Snapshot', COUNT(*), 360000, CASE WHEN COUNT(*) = 360000 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Fact_Inventory_Snapshot
UNION ALL
SELECT 'Fact_Orders', COUNT(*), 1250000, CASE WHEN COUNT(*) = 1250000 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Fact_Orders
UNION ALL
SELECT 'Fact_Sales', COUNT(*), 5000000, CASE WHEN COUNT(*) = 5000000 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Fact_Sales
UNION ALL
SELECT 'Fact_Returns', COUNT(*), 187553, CASE WHEN COUNT(*) = 187553 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Fact_Returns
UNION ALL
SELECT 'Fact_Service', COUNT(*), 120000, CASE WHEN COUNT(*) = 120000 THEN 'PASS' ELSE 'FAIL' END FROM dbo.Fact_Service;
GO

-- 2. Primary Key Uniqueness Verification
PRINT '=== 2. Primary Key Uniqueness ===';
SELECT 
    'Fact_Sales PK (order_line_id)' AS PK_Check,
    COUNT(*) - COUNT(DISTINCT order_line_id) AS Duplicate_Count,
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_line_id) THEN 'PASS' ELSE 'FAIL' END AS Status
FROM dbo.Fact_Sales
UNION ALL
SELECT 
    'Fact_Orders PK (order_id)',
    COUNT(*) - COUNT(DISTINCT order_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_id) THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Fact_Orders
UNION ALL
SELECT 
    'Dim_Customer PK (customer_id)',
    COUNT(*) - COUNT(DISTINCT customer_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT customer_id) THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Dim_Customer
UNION ALL
SELECT 
    'Dim_Product PK (product_id)',
    COUNT(*) - COUNT(DISTINCT product_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT product_id) THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Dim_Product
UNION ALL
SELECT 
    'Dim_Location PK (city_id)',
    COUNT(*) - COUNT(DISTINCT city_id),
    CASE WHEN COUNT(*) = COUNT(DISTINCT city_id) THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Dim_Location;
GO

-- 3. Composite Key Uniqueness on Targets and Inventory
PRINT '=== 3. Composite Key Uniqueness ===';
SELECT 
    'Fact_Sales_Targets (month, region, rep, category)' AS Composite_Key_Check,
    COUNT(*) AS Duplicate_Groups,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Status
FROM (
    SELECT target_month_key, region, salesperson_id, target_category
    FROM dbo.Fact_Sales_Targets
    GROUP BY target_month_key, region, salesperson_id, target_category
    HAVING COUNT(*) > 1
) D
UNION ALL
SELECT 
    'Fact_Inventory_Snapshot (date, product, warehouse)',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT snapshot_date_key, product_id, warehouse_id
    FROM dbo.Fact_Inventory_Snapshot
    GROUP BY snapshot_date_key, product_id, warehouse_id
    HAVING COUNT(*) > 1
) D;
GO

-- 4. Foreign Key Referential Integrity (Orphan Detection)
PRINT '=== 4. Foreign Key Integrity ===';
SELECT 
    'Fact_Sales -> Dim_Product' AS FK_Relationship,
    COUNT(*) AS Orphan_Rows,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS Status
FROM dbo.Fact_Sales S
LEFT JOIN dbo.Dim_Product P ON S.product_id = P.product_id
WHERE P.product_id IS NULL
UNION ALL
SELECT 
    'Fact_Sales -> Dim_Customer',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Fact_Sales S
LEFT JOIN dbo.Dim_Customer C ON S.customer_id = C.customer_id
WHERE C.customer_id IS NULL
UNION ALL
SELECT 
    'Fact_Sales -> Fact_Orders',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Fact_Sales S
LEFT JOIN dbo.Fact_Orders O ON S.order_id = O.order_id
WHERE O.order_id IS NULL
UNION ALL
SELECT 
    'Dim_Customer -> Dim_Location',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Dim_Customer C
LEFT JOIN dbo.Dim_Location L ON C.city_id = L.city_id
WHERE L.city_id IS NULL
UNION ALL
SELECT 
    'Fact_Returns -> Fact_Sales',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Fact_Returns R
LEFT JOIN dbo.Fact_Sales S ON R.order_line_id = S.order_line_id
WHERE S.order_line_id IS NULL
UNION ALL
SELECT 
    'Fact_Service -> Dim_Product',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM dbo.Fact_Service SV
LEFT JOIN dbo.Dim_Product P ON SV.product_id = P.product_id
WHERE P.product_id IS NULL;
GO

-- 5. Financial Ledger Reconciliation
PRINT '=== 5. Financial Ledger Reconciliation ===';
SELECT 
    COUNT(*) AS Total_Sales_Rows,
    SUM(CAST(gross_sales_inr AS DECIMAL(20,2))) AS Total_Gross_Sales,
    SUM(CAST(discount_amount_inr AS DECIMAL(20,2))) AS Total_Discount,
    SUM(CAST(net_sales_inr AS DECIMAL(20,2))) AS Total_Net_Revenue,
    SUM(CAST(cogs_inr AS DECIMAL(20,2))) AS Total_COGS,
    SUM(CAST(gross_profit_inr AS DECIMAL(20,2))) AS Total_Gross_Profit,
    ROUND(SUM(CAST(gross_profit_inr AS DECIMAL(20,2))) / SUM(CAST(net_sales_inr AS DECIMAL(20,2))) * 100, 2) AS Gross_Margin_Pct
FROM dbo.Fact_Sales;
GO

-- 6. Dim_Location Regional Breakdown
PRINT '=== 6. Regional Distribution in Dim_Location ===';
SELECT 
    customer_geographic_region,
    COUNT(*) AS Actual_City_Count,
    CASE customer_geographic_region
        WHEN 'North' THEN 14
        WHEN 'South' THEN 16
        WHEN 'West' THEN 15
        WHEN 'East' THEN 9
        WHEN 'Central' THEN 6
    END AS Expected_Count,
    CASE WHEN COUNT(*) = CASE customer_geographic_region
        WHEN 'North' THEN 14
        WHEN 'South' THEN 16
        WHEN 'West' THEN 15
        WHEN 'East' THEN 9
        WHEN 'Central' THEN 6
    END THEN 'PASS' ELSE 'FAIL' END AS Status
FROM dbo.Dim_Location
GROUP BY customer_geographic_region
ORDER BY customer_geographic_region;
GO
