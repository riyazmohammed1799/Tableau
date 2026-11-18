# Enterprise Data Dictionary — DentaKart Analytics (5M Scale)

## 1. Overview of Entities & Final Row Count Reconciliation

| Entity Name | Entity Type | Exact Grain | Expected Row Count | Derivation Formula / Generation Rule |
|---|---|---|---|---|
| **Dim_Date** | Dimension | 1 row per Calendar Day | **1,826 rows** | Full 5-year calendar: 2021-01-01 to 2025-12-31 ($365 \times 4 + 366 \text{ [leap year 2024]} = 1,826$) |
| **Dim_Product** | Dimension | 1 row per Product SKU | **1,000 rows** | Master dental catalog across 16 equipment and consumable sub-categories |
| **Dim_Customer** | Dimension | 1 row per Customer Account | **100,000 rows** | Master dental accounts across clinics, hospitals, colleges, labs, distributors |
| **Dim_Location** | Dimension | 1 row per City / Postal Hub | **60 rows** | Master geographic hubs across 5 regions and 3 demographic tiers |
| **Dim_Salesperson** | Dimension | 1 row per Sales Representative | **500 rows** | Master commercial sales reps mapped to 5 sales territory regions |
| **Dim_Channel** | Dimension | 1 row per Sales Channel | **5 rows** | Direct Field, B2B Portal, Inside Sales, Distributor, Institutional Tender |
| **Dim_Warehouse** | Dimension | 1 row per Fulfillment Warehouse | **6 rows** | Bhiwandi, Gurgaon, Nelamangala, Kolkata, Hyderabad, Chennai |
| **Dim_Supplier** | Dimension | 1 row per OEM Manufacturer | **50 rows** | Domestic and multinational dental manufacturing partners |
| **Fact_Orders** | Fact | 1 row per Commercial Order Header | **~1,250,000 rows** | Event-driven: Generated at average ratio of 4.0 line items per order |
| **Fact_Sales** | Fact | 1 row per Order Line Item | **~5,000,000 rows** | Primary transaction line volume target ($\sim 1,250,000 \times 4.0 = 5,000,000$) |
| **Fact_Returns** | Fact | 1 row per Return Line Event | **~220,000 rows** | Event-driven: Sampled from delivered lines at realistic 4.4% return rate |
| **Fact_Sales_Targets** | Fact | 1 row per Month x Region x Rep x Category | **120,000 rows** | Cartesian quota grain: $60 \text{ months} \times 500 \text{ reps} \times 4 \text{ target categories} = 120,000$ |
| **Fact_Inventory_Snapshot**| Fact | 1 row per Product x Warehouse x Month-End | **360,000 rows** | Cartesian inventory grain: $1,000 \text{ products} \times 6 \text{ warehouses} \times 60 \text{ month-ends} = 360,000$ |
| **Fact_Service** | Fact | 1 row per Service / Warranty Ticket | **~120,000 rows** | Event-driven: ~12% ticket rate on capital equipment purchases |

---

## 2. Dimension Table Schemas

### 2.1 Dim_Date
* **Grain**: 1 row per calendar day (2021-01-01 to 2025-12-31)
* **Primary Key**: `date_key` (INT: `YYYYMMDD`)

| Column Name | Data Type | Nullable | Example / Values | Description |
|---|---|---|---|---|
| `date_key` | INT | NO | `20231015` | Surrogate integer date key (`YYYYMMDD`) |
| `calendar_date` | DATE | NO | `2023-10-15` | Full calendar date |
| `year` | INT | NO | `2023` | Calendar year (2021 – 2025) |
| `quarter` | INT | NO | `4` | Calendar quarter (1–4) |
| `month_number` | INT | NO | `10` | Month number (1–12) |
| `month_name` | VARCHAR(10) | NO | `'October'` | Full month name |
| `month_year` | VARCHAR(7) | NO | `'2023-10'` | Year-Month string |
| `week_of_year` | INT | NO | `42` | ISO week number |
| `day_of_month` | INT | NO | `15` | Day of the month (1–31) |
| `day_of_week` | INT | NO | `1` | Day of the week (1=Sunday) |
| `day_name` | VARCHAR(10) | NO | `'Sunday'` | Day name |
| `is_weekend` | BIT / BOOLEAN | NO | `1` | 1 if Saturday or Sunday, else 0 |
| `fiscal_year` | VARCHAR(10) | NO | `'FY2023-24'` | Indian Fiscal Year (April to March) |
| `fiscal_quarter` | VARCHAR(5) | NO | `'FQ3'` | Indian Fiscal Quarter |
| `is_holiday_in` | BIT / BOOLEAN | NO | `0` | Indian national/festive holiday flag |

---

### 2.2 Dim_Product
* **Grain**: 1 row per unique Product SKU
* **Primary Key**: `product_id` (INT)

| Column Name | Data Type | Nullable | Example / Values | Description |
|---|---|---|---|---|
| `product_id` | INT | NO | `1042` | Unique product identifier |
| `product_sku` | VARCHAR(25) | NO | `'DK-EQ-CHAIR-004'` | Catalog SKU code |
| `product_name` | VARCHAR(150)| NO | `'DentaCare Elite Hydraulic Dental Chair'` | Commercial product title |
| `target_category`| VARCHAR(50) | NO | `'Dental Capital Equipment'` | 4 Core Target Categories (Equipment, Consumables, Imaging, Sterilization) + `'General / Non-Targeted'` |
| `sub_category` | VARCHAR(50) | NO | `'Dental Chairs'` | 16 Specialized sub-categories: Chairs, Autoclaves, Compressors, Suction, Handpieces, Micromotors, Scalers, Curing Lights, Endomotors, Apex Locators, RVG Sensors, Cameras, Intraoral Scanners, X-Ray Units, Implant Motors, Lab Equipment, Consumables |
| `brand` | VARCHAR(50) | NO | `'DentaPro'`, `'ApexDent'`, `'Dentsply Sirona'`, `'Kavo'` | Brand name |
| `supplier_id` | INT | NO | `12` | Foreign key referencing Dim_Supplier |
| `unit_cost_inr` | DECIMAL(12,2)| NO | `145000.00` | Standard wholesale procurement cost in INR |
| `list_price_inr` | DECIMAL(12,2)| NO | `210000.00` | Standard retail catalog selling price in INR |
| `is_capital_equipment` | BIT / BOOLEAN | NO | `1` | 1 if durable capital machinery, 0 if consumable |
| `gst_rate` | DECIMAL(4,2) | NO | `0.18` | Standard GST rate (0.12 for consumables, 0.18 for equipment) |
| `warranty_months` | INT | NO | `24` | Manufacturer warranty period in months |

---

### 2.3 Dim_Customer
* **Grain**: 1 row per customer account
* **Primary Key**: `customer_id` (INT)

| Column Name | Data Type | Nullable | Example / Values | Description |
|---|---|---|---|---|
| `customer_id` | INT | NO | `58120` | Unique customer account ID |
| `customer_name` | VARCHAR(120)| NO | `'Dr. Sharma Multi-Specialty Dental Clinic'` | Account legal name |
| `customer_type` | VARCHAR(50) | NO | `'Dental Clinic'`, `'Hospital Chain'`, `'Dental College'`, `'Dental Laboratory'`, `'Distributor'` | Commercial Account Type |
| `customer_tier` | VARCHAR(20) | NO | `'Platinum'`, `'Gold'`, `'Standard'`, `'Value'` | Commercial Value Tier |
| `city_id` | INT | NO | `101` | Foreign key referencing Dim_Location (Defines Customer Geographic Region) |
| `pin_code` | VARCHAR(10) | NO | `'400001'` | Indian postal PIN code |
| `onboarding_date` | DATE | NO | `'2021-03-12'` | Initial registration / acquisition date |
| `credit_limit_inr`| DECIMAL(12,2)| NO | `500000.00` | Credit approval limit in INR |
| `is_active` | BIT / BOOLEAN | NO | `1` | Current active purchasing status |

---

### 2.4 Dim_Location (Customer Geographic Hierarchy)
* **Grain**: 1 row per city / postal hub
* **Primary Key**: `city_id` (INT)
* **Analytical Purpose**: Defines **Customer Geographic Region** (where the physical clinic/hospital is located).

| Column Name | Data Type | Nullable | Example / Values | Description |
|---|---|---|---|---|
| `city_id` | INT | NO | `101` | Unique city identifier |
| `city_name` | VARCHAR(50) | NO | `'Mumbai'`, `'Bengaluru'`, `'Jaipur'`, `'Kochi'` | City name |
| `state_name` | VARCHAR(50) | NO | `'Maharashtra'`, `'Karnataka'`, `'Rajasthan'` | Indian State / UT |
| `customer_geographic_region` | VARCHAR(20) | NO | `'West'`, `'South'`, `'North'`, `'East'`, `'Central'` | **Customer Physical/Geographic Region** |
| `city_tier` | VARCHAR(10) | NO | `'Tier 1'`, `'Tier 2'`, `'Tier 3'` | Urban demographic economic tier |

---

### 2.5 Dim_Salesperson (Commercial Sales Territory Hierarchy)
* **Grain**: 1 row per sales representative
* **Primary Key**: `salesperson_id` (INT)
* **Analytical Purpose**: Defines **Sales Territory Region** (the commercial territory assigned to the rep). This controls `Fact_Sales_Targets.region`!

| Column Name | Data Type | Nullable | Example / Values | Description |
|---|---|---|---|---|
| `salesperson_id` | INT | NO | `304` | Unique sales rep ID |
| `salesperson_name`| VARCHAR(80) | NO | `'Rajesh Varma'` | Full name |
| `email` | VARCHAR(100)| NO | `'rajesh.varma@dentakart.in'` | Corporate email address |
| `sales_territory_region`| VARCHAR(20) | NO | `'West'`, `'South'`, `'North'`, `'East'`, `'Central'` | **Salesperson Assigned Territory Region** |
| `manager_id` | INT | YES | `301` | Self-referencing reporting manager ID |
| `hire_date` | DATE | NO | `'2020-08-01'` | Date joined DentaKart |
| `is_active` | BIT / BOOLEAN | NO | `1` | Employment active status |

---

### 2.6 Dim_Channel
* **Grain**: 1 row per sales channel
* **Primary Key**: `channel_id` (INT)

| Column Name | Data Type | Nullable | Values |
|---|---|---|---|
| `channel_id` | INT | NO | `1, 2, 3, 4, 5` |
| `channel_name` | VARCHAR(50) | NO | `'Direct Field Sales'`, `'B2B eCommerce Portal'`, `'Inside Sales'`, `'Distributor Network'`, `'Institutional Tender'` |

---

### 2.7 Dim_Warehouse
* **Grain**: 1 row per fulfillment warehouse
* **Primary Key**: `warehouse_id` (INT)

| Column Name | Data Type | Nullable | Values |
|---|---|---|---|
| `warehouse_id` | INT | NO | `1 to 6` |
| `warehouse_name`| VARCHAR(60) | NO | `'Bhiwandi Hub (Mumbai)'`, `'Gurgaon Hub (Delhi)'`, `'Nelamangala Hub (Bengaluru)'`, `'Kolkata Hub'`, `'Hyderabad Hub'`, `'Chennai Hub'` |
| `state_name` | VARCHAR(50) | NO | Regional warehouse location |

---

### 2.8 Dim_Supplier
* **Grain**: 1 row per OEM dental manufacturer
* **Primary Key**: `supplier_id` (INT)

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `supplier_id` | INT | NO | Primary key |
| `supplier_name` | VARCHAR(100)| NO | Manufacturer name (e.g. `'Kavo India'`, `'Dentsply Sirona'`, `'Ivoclar Vivadent'`) |
| `country` | VARCHAR(50) | NO | Origin country (India, Germany, Japan, USA, Switzerland) |

---

## 3. Fact Table Schemas

### 3.1 Fact_Orders
* **Grain**: 1 row per commercial order header
* **Expected Volume**: **~1,250,000 rows**
* **Primary Key**: `order_id` (INT)

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `order_id` | INT | NO | Primary Key |
| `order_number` | VARCHAR(30) | NO | Unique business order reference (e.g. `'DK-ORD-2023-0091823'`) |
| `order_date` | DATE | NO | Placement date |
| `order_date_key` | INT | NO | FK to Dim_Date (`YYYYMMDD`) |
| `customer_id` | INT | NO | FK to Dim_Customer |
| `channel_id` | INT | NO | FK to Dim_Channel |
| `salesperson_id`| INT | NO | FK to Dim_Salesperson |
| `warehouse_id` | INT | NO | FK to Dim_Warehouse |
| `shipping_date` | DATE | YES | Dispatch date |
| `order_status` | VARCHAR(20) | NO | `'Delivered'`, `'Shipped'`, `'In Transit'`, `'Processing'`, `'Cancelled'` |
| `payment_method`| VARCHAR(30) | NO | `'NEFT/RTGS'`, `'Credit Card'`, `'Net Banking'`, `'UPI / Razorpay'`, `'Cheque / 30-Day Credit'` |
| `total_order_lines`| INT | NO | Number of line items in this order |
| `total_net_amount_inr` | DECIMAL(14,2)| NO | Header total sum of Net Sales in INR |
| `total_tax_amount_inr` | DECIMAL(14,2)| NO | Header total sum of GST Tax in INR |
| `shipping_cost_inr`| DECIMAL(10,2)| NO | Freight and delivery charge in INR |

---

### 3.2 Fact_Sales (Fact_Order_Lines)
* **Grain**: 1 row per unique order line item
* **Expected Volume**: **~5,000,000 rows** (Configurable to 10M+)
* **Primary Key**: `order_line_id` (BIGINT)

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `order_line_id` | BIGINT | NO | Unique surrogate line identifier |
| `order_id` | INT | NO | Foreign Key to Fact_Orders |
| `line_number` | INT | NO | Sequential line index within order (1, 2, 3...) |
| `order_date_key` | INT | NO | FK to Dim_Date (`YYYYMMDD`) |
| `customer_id` | INT | NO | FK to Dim_Customer |
| `product_id` | INT | NO | FK to Dim_Product |
| `salesperson_id`| INT | NO | FK to Dim_Salesperson (Controls Sales Territory Region!) |
| `warehouse_id` | INT | NO | FK to Dim_Warehouse |
| `channel_id` | INT | NO | FK to Dim_Channel |
| `quantity` | INT | NO | Number of units purchased (1 to 500) |
| `unit_cost_inr` | DECIMAL(12,2)| NO | Unit procurement cost in INR |
| `list_price_inr`| DECIMAL(12,2)| NO | Catalog retail price in INR |
| `discount_pct` | DECIMAL(5,4) | NO | Discount fraction applied (0.0000 to 0.3500) |
| `discount_amount_inr` | DECIMAL(12,2)| NO | `quantity * list_price_inr * discount_pct` |
| `gross_sales_inr`| DECIMAL(14,2)| NO | `quantity * list_price_inr` |
| `net_sales_inr` | DECIMAL(14,2)| NO | `gross_sales_inr - discount_amount_inr` |
| `cogs_inr` | DECIMAL(14,2)| NO | `quantity * unit_cost_inr` |
| `gross_profit_inr`| DECIMAL(14,2)| NO | `net_sales_inr - cogs_inr` |
| `gross_margin_pct`| DECIMAL(6,4)| NO | `(gross_profit_inr / net_sales_inr) * 100` |
| `gst_tax_rate` | DECIMAL(4,2) | NO | GST tax rate (0.12 or 0.18) |
| `gst_tax_amount_inr` | DECIMAL(12,2)| NO | `net_sales_inr * gst_tax_rate` |
| `is_returned` | BIT / BOOLEAN | NO | 1 if line was returned, else 0 |

---

### 3.3 Fact_Returns
* **Grain**: 1 row per returned order line item
* **Expected Volume**: ~220,000 rows
* **Primary Key**: `return_id` (INT)

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `return_id` | INT | NO | Primary Key |
| `order_line_id` | BIGINT | NO | Foreign Key to Fact_Sales |
| `order_id` | INT | NO | FK to Fact_Orders |
| `return_date_key`| INT | NO | FK to Dim_Date |
| `product_id` | INT | NO | FK to Dim_Product |
| `returned_quantity`| INT | NO | Returned quantity (<= sold quantity) |
| `return_reason` | VARCHAR(50) | NO | `'Defective/Malfunction'`, `'Damaged in Transit'`, `'Wrong Item Shipped'`, `'Order Cancelled Post-Dispatch'`, `'Customer Dissatisfaction'` |
| `refund_amount_inr`| DECIMAL(12,2)| NO | Total refund processed in INR |
| `restocking_fee_inr`| DECIMAL(10,2)| NO | Restocking fee charged in INR |

---

### 3.4 Fact_Sales_Targets
* **Exact Business Grain**: 1 row per **Month × Region × Salesperson × Product Category**
* **Expected Volume**: **Exactly 120,000 rows** ($60 \text{ months} \times 500 \text{ reps} \times 4 \text{ focus categories}$)
* **Primary Key**: `target_id` (INT IDENTITY)
* **Unique Composite Key Constraint**: `UQ_Sales_Targets` on `(target_month_key, region, salesperson_id, target_category)`
* **Foreign Keys**:
  - `target_month_key` REFERENCES `Dim_Date(date_key)` (1st day of month: `YYYYMM01`)
  - `salesperson_id` REFERENCES `Dim_Salesperson(salesperson_id)`
* **Conformed Dimension Columns**:
  - `region` (VARCHAR(20)): Conformed with `Dim_Salesperson.sales_territory_region`
  - `target_category` (VARCHAR(50)): The 4 core target categories defined below.

#### The 4 Core Target-Bearing Product Categories:
1. **`Dental Capital Equipment`**: Hydraulic & electric dental chairs, compressors, central suction systems. (Capex driver; high revenue value).
2. **`Dental Clinical Consumables`**: Composites, bonding adhesives, impression alginates, dental burs, disposable needles. (High volume recurring cash-flow driver).
3. **`Digital Imaging & Radiology`**: Intraoral RVG sensors, 3D intraoral scanners, portable X-rays, 2D/3D OPG/CBCT scanners. (High-margin digital dentistry driver).
4. **`Sterilization & Infection Control`**: Class B vacuum autoclaves, ultrasonic instrument cleaners, sealing machines. (Regulatory compliance driver).

*Business Rule*: The remaining products in `Dim_Product` (such as specialized handpieces, dental lab articulators, education models) are sold as non-quota spot inventory. Their actual sales are recorded in `Fact_Sales` but have no corresponding rows in `Fact_Sales_Targets`.

| Column Name | Data Type | Nullable | Key / Constraint | Description |
|---|---|---|---|---|
| `target_id` | INT | NO | PRIMARY KEY | Surrogate unique target identifier |
| `target_month_key`| INT | NO | FK to Dim_Date, Part of UQ | Integer date key for 1st of target month (`YYYYMM01`) |
| `region` | VARCHAR(20) | NO | Part of UQ | **Sales Territory Region** (`Dim_Salesperson.sales_territory_region`) |
| `salesperson_id`| INT | NO | FK to Dim_Salesperson, Part of UQ | Assigned sales representative ID |
| `target_category`| VARCHAR(50) | NO | Part of UQ | One of the 4 defined target categories |
| `target_sales_inr`| DECIMAL(14,2)| NO | Metric | Monthly net sales revenue target in INR |
| `target_gross_profit_inr`| DECIMAL(14,2)| NO | Metric | Monthly gross profit quota in INR |

---

### 3.5 Fact_Inventory_Snapshot
* **Exact Business Grain**: 1 row per **Product × Warehouse × Month-End**
* **Expected Volume**: **Exactly 360,000 rows** ($1,000 \text{ products} \times 6 \text{ warehouses} \times 60 \text{ month-ends}$)
* **Primary Key**: `snapshot_id` (BIGINT)
* **Unique Composite Constraint**: `UQ_Inventory_Snapshot` on `(snapshot_date_key, product_id, warehouse_id)`
* **Foreign Keys**:
  - `snapshot_date_key` REFERENCES `Dim_Date(date_key)` (Last calendar day of each month: 2021-01-31, 2021-02-28, etc.)
  - `product_id` REFERENCES `Dim_Product(product_id)`
  - `warehouse_id` REFERENCES `Dim_Warehouse(warehouse_id)`

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `snapshot_id` | BIGINT | NO | Primary Key |
| `snapshot_date_key`| INT | NO | FK to Dim_Date (Month-End date key: `YYYYMMDD`) |
| `product_id` | INT | NO | FK to Dim_Product |
| `warehouse_id` | INT | NO | FK to Dim_Warehouse |
| `closing_stock_qty`| INT | NO | Physical stock count at snapshot date |
| `reorder_point_qty`| INT | NO | Safety stock reorder threshold |
| `stock_value_inr` | DECIMAL(14,2)| NO | `closing_stock_qty * unit_cost_inr` |
| `is_below_reorder` | BIT / BOOLEAN | NO | 1 if closing stock <= reorder point |

---

### 3.6 Fact_Service
* **Grain**: 1 row per service / warranty ticket
* **Expected Volume**: **~120,000 rows**
* **Primary Key**: `service_ticket_id` (INT)

| Column Name | Data Type | Nullable | Description |
|---|---|---|---|
| `service_ticket_id`| INT | NO | Primary Key |
| `service_ticket_no`| VARCHAR(25) | NO | Ticket reference (e.g. `'SRV-2024-00192'`) |
| `order_line_id` | BIGINT | YES | Associated equipment purchase line |
| `product_id` | INT | NO | FK to Dim_Product |
| `customer_id` | INT | NO | FK to Dim_Customer |
| `service_type` | VARCHAR(40) | NO | `'New Installation'`, `'Warranty Repair'`, `'Routine Maintenance'`, `'Emergency Breakdown'` |
| `request_date_key`| INT | NO | Ticket logged date |
| `resolved_date_key`| INT | YES | Resolution date |
| `resolution_status`| VARCHAR(20)| NO | `'Resolved'`, `'In Progress'`, `'Pending Spare Parts'` |
| `service_cost_inr` | DECIMAL(10,2)| NO | Service labor & spare parts cost in INR |
