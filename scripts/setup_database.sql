-- ==============================================================================
-- DentaKart Analytics — Enterprise Data Warehouse Schema Setup (Track A: SQL Server)
-- Database: DentaKart_DW
-- Idempotent, non-destructive schema script.
-- Generates all 14 Star Schema tables ONLY if they do not exist.
-- Never drops or recreates existing databases or tables.
-- ==============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'DentaKart_DW')
BEGIN
    CREATE DATABASE DentaKart_DW;
    PRINT 'Database DentaKart_DW created successfully.';
END
ELSE
BEGIN
    PRINT 'Database DentaKart_DW already exists. Retaining existing database.';
END
GO

USE DentaKart_DW;
GO

-- ==============================================================================
-- 1. CONFORMED DIMENSIONS (Created only if non-existent)
-- ==============================================================================

IF OBJECT_ID('dbo.Dim_Date', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Date (
        date_key INT NOT NULL PRIMARY KEY,
        calendar_date DATE NOT NULL,
        year INT NOT NULL,
        quarter INT NOT NULL,
        month_number INT NOT NULL,
        month_name VARCHAR(10) NOT NULL,
        month_year VARCHAR(7) NOT NULL,
        week_of_year INT NOT NULL,
        day_of_month INT NOT NULL,
        day_of_week INT NOT NULL,
        day_name VARCHAR(10) NOT NULL,
        is_weekend BIT NOT NULL,
        fiscal_year VARCHAR(10) NOT NULL,
        fiscal_quarter VARCHAR(5) NOT NULL,
        is_holiday_in BIT NOT NULL
    );
    PRINT 'Created table: dbo.Dim_Date';
END;

IF OBJECT_ID('dbo.Dim_Supplier', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Supplier (
        supplier_id INT NOT NULL PRIMARY KEY,
        supplier_name VARCHAR(100) NOT NULL,
        country VARCHAR(50) NOT NULL
    );
    PRINT 'Created table: dbo.Dim_Supplier';
END;

IF OBJECT_ID('dbo.Dim_Warehouse', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Warehouse (
        warehouse_id INT NOT NULL PRIMARY KEY,
        warehouse_name VARCHAR(60) NOT NULL,
        state_name VARCHAR(50) NOT NULL
    );
    PRINT 'Created table: dbo.Dim_Warehouse';
END;

IF OBJECT_ID('dbo.Dim_Channel', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Channel (
        channel_id INT NOT NULL PRIMARY KEY,
        channel_name VARCHAR(50) NOT NULL
    );
    PRINT 'Created table: dbo.Dim_Channel';
END;

IF OBJECT_ID('dbo.Dim_Location', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Location (
        city_id INT NOT NULL PRIMARY KEY,
        city_name VARCHAR(50) NOT NULL,
        state_name VARCHAR(50) NOT NULL,
        customer_geographic_region VARCHAR(20) NOT NULL,
        city_tier VARCHAR(10) NOT NULL
    );
    PRINT 'Created table: dbo.Dim_Location';
END;

IF OBJECT_ID('dbo.Dim_Salesperson', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Salesperson (
        salesperson_id INT NOT NULL PRIMARY KEY,
        salesperson_name VARCHAR(80) NOT NULL,
        email VARCHAR(100) NOT NULL,
        sales_territory_region VARCHAR(20) NOT NULL,
        manager_id INT NULL,
        hire_date DATE NOT NULL,
        is_active BIT NOT NULL,
        CONSTRAINT FK_Salesperson_Manager FOREIGN KEY (manager_id) REFERENCES dbo.Dim_Salesperson(salesperson_id)
    );
    PRINT 'Created table: dbo.Dim_Salesperson';
END;

IF OBJECT_ID('dbo.Dim_Product', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Product (
        product_id INT NOT NULL PRIMARY KEY,
        product_sku VARCHAR(25) NOT NULL,
        product_name VARCHAR(150) NOT NULL,
        target_category VARCHAR(50) NOT NULL,
        sub_category VARCHAR(50) NOT NULL,
        brand VARCHAR(50) NOT NULL,
        supplier_id INT NOT NULL,
        unit_cost_inr DECIMAL(12,2) NOT NULL,
        list_price_inr DECIMAL(12,2) NOT NULL,
        is_capital_equipment BIT NOT NULL,
        gst_rate DECIMAL(4,2) NOT NULL,
        warranty_months INT NOT NULL,
        CONSTRAINT FK_Product_Supplier FOREIGN KEY (supplier_id) REFERENCES dbo.Dim_Supplier(supplier_id)
    );
    PRINT 'Created table: dbo.Dim_Product';
END;

IF OBJECT_ID('dbo.Dim_Customer', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_Customer (
        customer_id INT NOT NULL PRIMARY KEY,
        customer_name VARCHAR(120) NOT NULL,
        customer_type VARCHAR(50) NOT NULL,
        customer_tier VARCHAR(20) NOT NULL,
        city_id INT NOT NULL,
        pin_code VARCHAR(10) NOT NULL,
        onboarding_date DATE NOT NULL,
        credit_limit_inr DECIMAL(12,2) NOT NULL,
        is_active BIT NOT NULL,
        CONSTRAINT FK_Customer_Location FOREIGN KEY (city_id) REFERENCES dbo.Dim_Location(city_id)
    );
    PRINT 'Created table: dbo.Dim_Customer';
END;

-- ==============================================================================
-- 2. FACT TABLES (Created only if non-existent)
-- ==============================================================================

IF OBJECT_ID('dbo.Fact_Sales_Targets', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Sales_Targets (
        target_id INT NOT NULL PRIMARY KEY,
        target_month_key INT NOT NULL,
        region VARCHAR(20) NOT NULL,
        salesperson_id INT NOT NULL,
        target_category VARCHAR(50) NOT NULL,
        target_sales_inr DECIMAL(14,2) NOT NULL,
        target_gross_profit_inr DECIMAL(14,2) NOT NULL,
        CONSTRAINT UQ_Sales_Targets UNIQUE (target_month_key, region, salesperson_id, target_category),
        CONSTRAINT FK_Targets_Date FOREIGN KEY (target_month_key) REFERENCES dbo.Dim_Date(date_key),
        CONSTRAINT FK_Targets_Salesperson FOREIGN KEY (salesperson_id) REFERENCES dbo.Dim_Salesperson(salesperson_id)
    );
    PRINT 'Created table: dbo.Fact_Sales_Targets';
END;

IF OBJECT_ID('dbo.Fact_Inventory_Snapshot', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Inventory_Snapshot (
        snapshot_id BIGINT NOT NULL PRIMARY KEY,
        snapshot_date_key INT NOT NULL,
        product_id INT NOT NULL,
        warehouse_id INT NOT NULL,
        closing_stock_qty INT NOT NULL,
        reorder_point_qty INT NOT NULL,
        stock_value_inr DECIMAL(14,2) NOT NULL,
        is_below_reorder BIT NOT NULL,
        CONSTRAINT UQ_Inventory_Snapshot UNIQUE (snapshot_date_key, product_id, warehouse_id),
        CONSTRAINT FK_Inv_Date FOREIGN KEY (snapshot_date_key) REFERENCES dbo.Dim_Date(date_key),
        CONSTRAINT FK_Inv_Product FOREIGN KEY (product_id) REFERENCES dbo.Dim_Product(product_id),
        CONSTRAINT FK_Inv_Warehouse FOREIGN KEY (warehouse_id) REFERENCES dbo.Dim_Warehouse(warehouse_id)
    );
    PRINT 'Created table: dbo.Fact_Inventory_Snapshot';
END;

IF OBJECT_ID('dbo.Fact_Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Orders (
        order_id INT NOT NULL PRIMARY KEY,
        order_number VARCHAR(30) NOT NULL,
        order_date DATE NOT NULL,
        order_date_key INT NOT NULL,
        customer_id INT NOT NULL,
        channel_id INT NOT NULL,
        salesperson_id INT NOT NULL,
        warehouse_id INT NOT NULL,
        shipping_date DATE NULL,
        order_status VARCHAR(20) NOT NULL,
        payment_method VARCHAR(30) NOT NULL,
        total_order_lines INT NOT NULL,
        total_net_amount_inr DECIMAL(14,2) NOT NULL,
        total_tax_amount_inr DECIMAL(14,2) NOT NULL,
        shipping_cost_inr DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_Orders_Date FOREIGN KEY (order_date_key) REFERENCES dbo.Dim_Date(date_key),
        CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Dim_Customer(customer_id),
        CONSTRAINT FK_Orders_Channel FOREIGN KEY (channel_id) REFERENCES dbo.Dim_Channel(channel_id),
        CONSTRAINT FK_Orders_Salesperson FOREIGN KEY (salesperson_id) REFERENCES dbo.Dim_Salesperson(salesperson_id),
        CONSTRAINT FK_Orders_Warehouse FOREIGN KEY (warehouse_id) REFERENCES dbo.Dim_Warehouse(warehouse_id)
    );
    PRINT 'Created table: dbo.Fact_Orders';
END;

IF OBJECT_ID('dbo.Fact_Sales', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Sales (
        order_line_id BIGINT NOT NULL PRIMARY KEY,
        order_id INT NOT NULL,
        line_number INT NOT NULL,
        order_date_key INT NOT NULL,
        customer_id INT NOT NULL,
        product_id INT NOT NULL,
        salesperson_id INT NOT NULL,
        warehouse_id INT NOT NULL,
        channel_id INT NOT NULL,
        quantity INT NOT NULL,
        unit_cost_inr DECIMAL(12,2) NOT NULL,
        list_price_inr DECIMAL(12,2) NOT NULL,
        discount_pct DECIMAL(5,4) NOT NULL,
        discount_amount_inr DECIMAL(12,2) NOT NULL,
        gross_sales_inr DECIMAL(14,2) NOT NULL,
        net_sales_inr DECIMAL(14,2) NOT NULL,
        cogs_inr DECIMAL(14,2) NOT NULL,
        gross_profit_inr DECIMAL(14,2) NOT NULL,
        gross_margin_pct DECIMAL(6,4) NOT NULL,
        gst_tax_rate DECIMAL(4,2) NOT NULL,
        gst_tax_amount_inr DECIMAL(12,2) NOT NULL,
        is_returned BIT NOT NULL,
        CONSTRAINT FK_Sales_Orders FOREIGN KEY (order_id) REFERENCES dbo.Fact_Orders(order_id),
        CONSTRAINT FK_Sales_Date FOREIGN KEY (order_date_key) REFERENCES dbo.Dim_Date(date_key),
        CONSTRAINT FK_Sales_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Dim_Customer(customer_id),
        CONSTRAINT FK_Sales_Product FOREIGN KEY (product_id) REFERENCES dbo.Dim_Product(product_id),
        CONSTRAINT FK_Sales_Salesperson FOREIGN KEY (salesperson_id) REFERENCES dbo.Dim_Salesperson(salesperson_id),
        CONSTRAINT FK_Sales_Warehouse FOREIGN KEY (warehouse_id) REFERENCES dbo.Dim_Warehouse(warehouse_id),
        CONSTRAINT FK_Sales_Channel FOREIGN KEY (channel_id) REFERENCES dbo.Dim_Channel(channel_id)
    );
    PRINT 'Created table: dbo.Fact_Sales';
END;

IF OBJECT_ID('dbo.Fact_Returns', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Returns (
        return_id INT NOT NULL PRIMARY KEY,
        order_line_id BIGINT NOT NULL,
        order_id INT NOT NULL,
        return_date_key INT NOT NULL,
        product_id INT NOT NULL,
        returned_quantity INT NOT NULL,
        return_reason VARCHAR(50) NOT NULL,
        refund_amount_inr DECIMAL(12,2) NOT NULL,
        restocking_fee_inr DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_Returns_Sales FOREIGN KEY (order_line_id) REFERENCES dbo.Fact_Sales(order_line_id),
        CONSTRAINT FK_Returns_Orders FOREIGN KEY (order_id) REFERENCES dbo.Fact_Orders(order_id),
        CONSTRAINT FK_Returns_Date FOREIGN KEY (return_date_key) REFERENCES dbo.Dim_Date(date_key),
        CONSTRAINT FK_Returns_Product FOREIGN KEY (product_id) REFERENCES dbo.Dim_Product(product_id)
    );
    PRINT 'Created table: dbo.Fact_Returns';
END;

IF OBJECT_ID('dbo.Fact_Service', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Service (
        service_ticket_id INT NOT NULL PRIMARY KEY,
        service_ticket_no VARCHAR(25) NOT NULL,
        order_line_id BIGINT NULL,
        product_id INT NOT NULL,
        customer_id INT NOT NULL,
        service_type VARCHAR(40) NOT NULL,
        request_date_key INT NOT NULL,
        resolved_date_key INT NULL,
        resolution_status VARCHAR(20) NOT NULL,
        service_cost_inr DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_Service_Sales FOREIGN KEY (order_line_id) REFERENCES dbo.Fact_Sales(order_line_id),
        CONSTRAINT FK_Service_Product FOREIGN KEY (product_id) REFERENCES dbo.Dim_Product(product_id),
        CONSTRAINT FK_Service_Customer FOREIGN KEY (customer_id) REFERENCES dbo.Dim_Customer(customer_id),
        CONSTRAINT FK_Service_ReqDate FOREIGN KEY (request_date_key) REFERENCES dbo.Dim_Date(date_key),
        CONSTRAINT FK_Service_ResDate FOREIGN KEY (resolved_date_key) REFERENCES dbo.Dim_Date(date_key)
    );
    PRINT 'Created table: dbo.Fact_Service';
END;
GO

PRINT 'DentaKart_DW schema setup verified.';
