# DentaKart Analytics — Master Project & Conversation History Summary

**Document Version**: 2.0.0 (Master Merged Edition)  
**Project**: DentaKart Analytics — Enterprise Sales & Operations Platform  
**Target Role**: Senior Tableau Developer & Analytics Engineer (5-Year Experience Track)  
**Author / Lead Developer**: Riyaz Mohammed  
**GitHub Repository**: [https://github.com/riyazmohammed1799/Tableau](https://github.com/riyazmohammed1799/Tableau)  
**Last Updated**: November 18, 2026  
**Local Project Path**: `c:\Users\riyaz\Tableau`  

---

## 1. Executive Summary & Business Context

**DentaKart Analytics** is an enterprise-scale analytics engineering and Business Intelligence platform built for a nationwide dental equipment, clinical instruments, and consumables distributor operating across India.

Operating through an omnichannel commercial sales ecosystem (Direct Field Sales, B2B Online Portal, Institutional Dental College Tenders, Distributor Sub-networks, and Tele-Inside Sales), DentaKart supplies over **1,000 specialized dental SKUs** to more than **100,000 active dental accounts** (solo dental practices, multi-chair clinics, corporate hospital chains, diagnostic labs, and dental universities) across 60 Indian cities.

### Strategic Business Challenges Addressed
1. **Margin Erosion & Discount Leakage**: Uncontrolled discounting across high-demand consumables and bundled capital equipment packages exceeding commercial tier allowances.
2. **Territory vs. Geographic Discrepancies**: High metro concentration in Mumbai, Bengaluru, and Delhi-NCR vs. untapped growth in Tier-2/3 dental healthcare hubs, complicated by commercial sales territory alignment differing from clinic physical locations.
3. **Equipment Warranty & Post-Sale Service Friction**: Tracking installation turnaround, routine preventive maintenance, and warranty breakdown claims on capital equipment (hydraulic chairs, OPG/CBCT scanners, autoclaves).
4. **GST Tax Compliance & Ledger Balancing**: Indian GST tax brackets (12% for consumables, 18% for machinery), freight/shipping calculations, and diverse payment gateway methods.
5. **Quota Attainment Single Source of Truth**: Resolving disputed sales targets between field representatives and leadership through strict dimensional grain separation and pre-aggregated CTE modeling to prevent Cartesian join inflation.

---

## 2. Enterprise Dual-Track Architecture

The platform implements a sequential dual-platform data engineering and visualization architecture:

```
                           [ Generation Engine: scripts/generate_data.py ]
                             (Deterministic Seed=42 | 5,000,000 Sales Lines)
                                                   |
                     +-----------------------------+-----------------------------+
                     | (Track A: Completed First)                                | (Track B: Medallion Staged)
                     v                                                           v
        [ Track A: Microsoft SQL Server EDW ]                       [ Track B: Databricks Lakehouse ]
        - Engine: SQL Server 2025 Express (`.\SQLEXPRESS`)          - Platform: Databricks Unity Catalog
        - Database: `DentaKart_DW` (14 Star Schema Tables)          - Catalog: `dentalkart_dw`
        - Volume: 7,141,000 rows loaded in 105.4s                   - Bronze: 14 Delta tables (Parquet volume)
        - Columnstore Clustered Indexing Benchmark                  - Silver: 14 working tables staged
        - 26/26 SQL Validations Passed (₹0.00 Variance)             - Parity: 100% (7,141,000 rows, 0 variance)
                     |                                                           |
                     +-----------------------------+-----------------------------+
                                                   |
                                                   v
                                     [ Tableau Desktop / Cloud BI Suite ]
                                     - Logical Layer Relationships ("Noodles" anti-fan-out)
                                     - Hyper Extract vs. Live Query Optimization
                                     - Advanced Calculations & LOD Expressions (FIXED, INCLUDE, EXCLUDE)
                                     - Dynamic Row-Level Security (RLS) via Entitlement Tables
                                     - 8 Production Dashboards (Exec, Category, Territory, Inventory, etc.)
```

---

## 3. Scale & 14-Table Canonical Parity Matrix

The dataset was generated deterministically (`SEED = 42`) and loaded across both platforms with **100% mathematical row-count and ledger parity**:

| # | Entity Name | Type | Exact Business Grain | Source (Parquet/CSV) | SQL Server EDW (`DentaKart_DW`) | Databricks Bronze (`bronze`) | Databricks Silver (`silver`) | Parity Status |
|---|---|---|---|---:|---:|---:|---:|:---:|
| 01 | `dim_channel` | Dimension | 1 row per sales channel | 5 | 5 | 5 | 5 | 🟢 100% Parity |
| 02 | `dim_warehouse` | Dimension | 1 row per fulfillment warehouse | 6 | 6 | 6 | 6 | 🟢 100% Parity |
| 03 | `dim_supplier` | Dimension | 1 row per OEM dental manufacturer | 50 | 50 | 50 | 50 | 🟢 100% Parity |
| 04 | `dim_location` | Dimension | 1 row per city / geographic hub (5 regions) | 60 | 60 | 60 | 60 | 🟢 100% Parity |
| 05 | `dim_salesperson` | Dimension | 1 row per commercial rep (5 territories) | 500 | 500 | 500 | 500 | 🟢 100% Parity |
| 06 | `dim_product` | Dimension | 1 row per product SKU (16 categories) | 1,000 | 1,000 | 1,000 | 1,000 | 🟢 100% Parity |
| 07 | `dim_date` | Dimension | 1 row per calendar day (2021–2025) | 1,826 | 1,826 | 1,826 | 1,826 | 🟢 100% Parity |
| 08 | `dim_customer` | Dimension | 1 row per dental practice account | 100,000 | 100,000 | 100,000 | 100,000 | 🟢 100% Parity |
| 09 | `fact_sales_targets` | Fact | 1 row per Month × Territory × Rep × Category | 120,000 | 120,000 | 120,000 | 120,000 | 🟢 100% Parity |
| 10 | `fact_service` | Fact | 1 row per service / warranty ticket | 120,000 | 120,000 | 120,000 | 120,000 | 🟢 100% Parity |
| 11 | `fact_returns` | Fact | 1 row per return line event (~4.4% return rate)| 187,553 | 187,553 | 187,553 | 187,553 | 🟢 100% Parity |
| 12 | `fact_inventory_snapshot`| Fact | 1 row per SKU × Warehouse × Month-End | 360,000 | 360,000 | 360,000 | 360,000 | 🟢 100% Parity |
| 13 | `fact_orders` | Fact | 1 row per commercial order header | 1,250,000 | 1,250,000 | 1,250,000 | 1,250,000 | 🟢 100% Parity |
| 14 | `fact_sales` | Fact | 1 row per order line item (Core Fact) | **5,000,000** | **5,000,000** | **5,000,000** | **5,000,000** | 🟢 100% Parity |
| **—** | **GRAND TOTAL** | — | **Full Data Warehouse Footprint** | **7,141,000** | **7,141,000** | **7,141,000** | **7,141,000** | 🟢 **ZERO VARIANCE** |

---

## 4. Financial Ledger Reconciliation (Strict Zero-Variance)

Independent SQL validation against all 5,000,000 rows of `Fact_Sales` confirmed exact arithmetic ledger balance:

$$\text{Net Sales} = \text{Gross Sales} - \text{Discount Amount} \quad (\Delta = ₹0.00)$$
$$\text{Gross Profit} = \text{Net Sales} - \text{COGS} \quad (\Delta = ₹0.00)$$

* **Total Gross Sales**: ₹1,139,371,183,767.44 (~₹1.14 Trillion)
* **Total Discount Amount**: ₹125,280,638,871.83 (~₹125.28 Billion)
* **Total Net Revenue**: ₹1,014,090,544,895.61 (~₹1.01 Trillion)
* **Total Cost of Goods Sold (COGS)**: ₹809,062,519,005.13 (~₹809.06 Billion)
* **Total Realized Gross Profit**: ₹205,028,025,890.48 (~₹205.03 Billion)
* **Overall Realized Gross Margin**: **20.22%**
* **Database Physical Footprint (SQL Server Express)**: MDF: 968 MB, LDF: 136 MB, Total: 1,104 MB (~1.1 GB).

---

## 5. Chronological Technical Milestones & Engineering Solutions

### Milestone 1: Phase 2 Pre-Ingestion Audit & Check V-06 Remediation
* **Defect**: Automated check V-06 caught an array slice truncation bug in `scripts/generate_data.py`. Taking `cities_data[:60]` sliced before reaching the 5 Central cities, resulting in 4 regions instead of 5.
* **Remediation**: Replaced slice logic with defensive programmatic regional quota assertions:
  - North: 14 cities
  - South: 16 cities
  - West: 15 cities
  - East: 9 cities
  - Central: 6 cities (Bhopal, Indore, Gwalior, Jabalpur, Ujjain, Raipur)
* **Validation**: Re-executed `scripts/validate_data.py`; **50/50 checks PASSED** (100% compliant).

### Milestone 2: Phase 3 Track A — SQL Server EDW Deployment
* **Instance Verification**: Verified Microsoft SQL Server 2025 Express (`.\SQLEXPRESS`) via `sqlcmd -E -C`.
* **Destructive Operation Avoidance**: Preserved pre-existing databases (e.g., `DentalKart`) by strictly targeting `DentaKart_DW` with non-destructive, idempotent DDL.
* **NTFS ACL Resolution**: SQL Server `BULK INSERT` executes in the server engine process context under `NT Service\MSSQL$SQLEXPRESS`. Granted directory read permissions via `icacls "data\clean\csv" /grant "NT Service\MSSQL$SQLEXPRESS:(OI)(CI)(R)"`.
* **High-Speed Bulk Ingestion**: Loaded all 14 clean CSVs in **105.42 seconds** (~66,800 rows/second, 0 errors).
* **Ledger Validation**: Executed `scripts/validate_sql_server.sql`; passed 26 independent verification queries with zero variance.

### Milestone 3: Phase 14 Track B — Databricks Lakehouse Bronze Ingestion
* **Unity Catalog Volume Pathing**: Resolved `UC_VOLUME_NOT_FOUND` on `rawfiles` by locating the exact volume path via `system.information_schema.volumes`: `/Volumes/dentalkart_dw/bronze/raw_files/`.
* **Step 1 Preflight Audit**: Executed query checking `dentalkart_dw.information_schema.tables` in `bronze`; returned **0 rows**, confirming zero conflicting tables.
* **Step 2 Clean DDL**: Executed `scripts/databricks_bronze_ingestion_step2_clean.sql` with 14 `CREATE TABLE IF NOT EXISTS ... USING DELTA AS SELECT ...` statements.
* **Step 3 Unified CTE Reconciliation**: Executed `scripts/databricks_bronze_step3_reconciliation.sql`; confirmed **exact row-count parity across all 14 tables (7,141,000 actual rows / 0 variance)**.

### Milestone 4: Phase 14 Track B — Silver Baseline Working Copies
* **Bronze Immutability**: Kept Bronze as the immutable raw audit layer.
* **Silver Baseline Copy**: Executed `scripts/databricks_silver_copy_step2_clean.sql`, creating 14 Delta tables in `dentalkart_dw.silver` to stage tables for subsequent data cleaning and schema transformation.

---

## 6. Project Directory & Scripts Inventory

All project automation, DDL, and verification scripts reside in [`scripts/`](file:///c:/Users/riyaz/Tableau/scripts/):

| Script File | Category | Purpose |
|---|---|---|
| `generate_data.py` | Data Engineering | Vectorized chunked generator streaming 5M records to clean CSV and Parquet. |
| `validate_data.py` | Quality Assurance | 50-assertion pre-load verification suite. |
| `setup_database.sql` | SQL Server DDL | Idempotent DDL creating `DentaKart_DW` schema, PKs, FKs, and UQ constraints. |
| `load_sql_server.py` | Ingestion Pipeline | High-speed bulk ingestion pipeline loading CSVs into SQL Server. |
| `validate_sql_server.sql` | SQL Server Audit | 26 SQL validation queries verifying ledger integrity. |
| `databricks_bronze_preflight.sql` | Databricks SQL | Step 1 preflight queries inspecting namespace and verifying 0 conflicting tables. |
| `databricks_bronze_ingestion_step2_clean.sql` | Databricks DDL | Step 2 clean ingestion DDL creating all 14 Bronze Delta tables from Volume Parquet files. |
| `databricks_bronze_step3_reconciliation.sql` | Databricks Audit | Step 3 unified CTE query validating per-table counts and the 7,141,000-row grand total. |
| `databricks_silver_master_copy.sql` | Databricks DDL | Master script managing 3-step baseline copy from Bronze to Silver. |
| `databricks_silver_copy_step2_clean.sql` | Databricks DDL | Clean DDL copying 14 tables into `dentalkart_dw.silver`. |
| `databricks_silver_step3_reconciliation.sql` | Databricks Audit | Reconciliation query verifying 100% row-count parity across the 14 Silver tables. |

---

## 7. Two-Track Project Roadmap Ahead

### 🎯 Track 1: SQL Server EDW & Enterprise Tableau BI (Immediate Next Session)
1. **Tier 1 SQL Engineering Exercises** (`sql_solutions/`):
   - **Task 1**: Annual Category Revenue & Margin Realization (`task_01.sql`)
   - **Task 2**: Tier-wise City Penetration & Discount Distribution (`task_02.sql`)
   - **Task 3**: Omnichannel Sales Performance & Delivery Lag (`task_03.sql`)
   - **Task 4**: High-Discount Anomaly Audit (Tier allowance leakage detection) (`task_04.sql`)
   - **Task 5**: Warehouse Fulfillment & Product Returns Breakdown (`task_05.sql`)
2. **Subsequent SQL Tiers (Tiers 2 to 5)**:
   - Window functions (`DENSE_RANK`, `LAG`, rolling moving averages).
   - Cohort analysis (60-day repurchase retention, market basket affinity).
   - Query tuning (SARGability, execution plans, clustered columnstore indexing benchmarks).
3. **Tableau Enterprise BI Suite (Phases 8–11)**:
   - Logical Layer modeling avoiding fan-out across multiple grains.
   - Authoring calculated fields, Level of Detail expressions (`FIXED`, `INCLUDE`, `EXCLUDE`).
   - Building the 8 production executive and operational dashboards.
   - Dynamic Row-Level Security (RLS) via User Entitlement tables.

### 🚀 Track 2: Databricks Lakehouse Medallion Pipeline (Project 2 Track)
1. **Silver Layer Engineering**:
   - Schema casting (`STRING` dates → `DATE`, `DOUBLE` revenue/cost → `DECIMAL(14,2)`).
   - Ingestion timestamps (`_silver_ingested_at`), null handling, and surrogate key validation.
2. **Data Modeling & Semantic Architecture**:
   - Star schema dimension/fact modeling in Delta Lake.
   - Conformed dimensions validation and anti-fan-out grain checks.
3. **Gold Layer Analytical Marts**:
   - High-performance analytical marts optimized via Delta Lake Liquid Clustering and Z-Ordering.
4. **BI Connectivity & Performance Benchmark**:
   - Direct connection from Databricks Serverless SQL Warehouse to Tableau.
   - Live query latency benchmarking comparing Databricks Lakehouse against SQL Server EDW.

---

*Certified and logged in `PROGRESS.md`, `DATABRICKS_BRONZE_INGESTION_REPORT.md`, `MISTAKES_AND_LEARNINGS.md`, and `MASTER_PROJECT_SUMMARY.md`.*
