# DentaKart Analytics — Comprehensive Project & Conversation Summary

**Document Version**: 1.0.0  
**Project**: DentaKart Analytics (5-Year Experience Senior Tableau Developer & Analytics Engineer Track)  
**Date**: 2026-11-18  
**Repository Path**: `c:\Users\riyaz\Tableau`  
**Primary Architect**: Riyaz Mohammed  

---

## 1. Executive Overview & Architecture Strategy

DentaKart Analytics is an enterprise-scale Business Intelligence and Analytics Engineering project modeling an Indian B2B dental supplies and equipment marketplace. The architecture implements a **Sequential Dual-Platform Strategy**:

1. **Track A (Project 1) — Relational Enterprise Data Warehouse (EDW) to Tableau**:
   - Platform: Microsoft SQL Server 2025 Express (`.\SQLEXPRESS`), Database: `DentaKart_DW`.
   - Focus: Relational Star Schema, T-SQL mastery exercises (Tiers 1–5), query plan optimization, clustered columnstore indexing, and 8 production Tableau dashboards with advanced LOD expressions and Row-Level Security (RLS).
2. **Track B (Project 2) — Databricks Lakehouse Medallion Architecture**:
   - Platform: Databricks Unity Catalog, Catalog: `dentalkart_dw`.
   - Focus: Delta Lake Medallion Pipeline (Bronze → Silver → Gold), schema enforcement, typed casting, Z-Order optimization, and direct SQL Warehouse connectivity to Tableau.

### Scale & Canonical Data Footprint
* **Sales Volume Target**: **5,000,000 order line items** across **1,250,000 commercial order headers** (2021 – 2025).
* **Total Warehouse Rows**: **7,141,000 rows** across 14 conformed Star Schema tables.
* **Deterministic Generation**: Generated from Python (`scripts/generate_data.py`) using fixed seed `42` to output identical clean CSVs (for SQL Server `BULK INSERT`) and Snappy Parquet files (for Databricks Delta Lake).

---

## 2. Phase-by-Phase Progress & Completed Milestones

### Phase 1: Business Requirements & Metric Framework 🟢 (Completed)
* Outlined commercial B2B operations: 16 specialized dental equipment and consumable sub-categories, 5 sales channels, 6 fulfillment hubs, and 4 customer tiers (Platinum, Gold, Standard, Value).
* Built-in Indian commercial realities: Standard GST tax rates (12% for consumables, 18% for capital equipment), realistic freight shipping costs, Indian B2B payment methods (NEFT/RTGS, Credit, Razorpay/UPI), and warranty ticket rates on capital equipment.

### Phase 2: Canonical Data Generation & Audit Remediation 🟢 (Completed)
* **Check V-06 Root Cause & Remediation**:
  - *Defect*: Automated check V-06 failed when `Dim_Location` truncated at 60 cities and captured only 4 regions, missing Central India.
  - *Fix*: Re-engineered generator with programmatic regional quota guards enforcing exactly 60 cities across all 5 Indian regions: North (14), South (16), West (15), East (9), and Central (6: Bhopal, Indore, Gwalior, Jabalpur, Ujjain, Raipur).
* **Automated Audit Suite**: Executed `scripts/validate_data.py` across 50 assertion points. All **50/50 checks passed** with zero referential integrity violations and zero arithmetic variance. Certified in `VALIDATION_REPORT.md`.

### Phase 3: Track A — SQL Server EDW Ingestion & Baseline 🟢 (Completed)
* **Pre-Execution Safety**: Verified instance connectivity (`sqlcmd -E -C -S .\SQLEXPRESS`). Prevented destruction of pre-existing databases (preserving `DentalKart`).
* **NTFS Service Account Permissions**: Identified that SQL Server service account `NT Service\MSSQL$SQLEXPRESS` lacked read permissions for user profile paths (`xp_fileexist` returned 0). Resolved by explicitly granting directory read ACLs via `icacls`.
* **DDL & Ingestion**:
  - Authored idempotent DDL in `scripts/setup_database.sql` creating `DentaKart_DW` and 14 tables with Primary Keys, Foreign Keys, and Unique constraints.
  - Executed high-throughput bulk ingestion pipeline `scripts/load_sql_server.py`. Ingested 7,041,000 records in **105.42 seconds** (~66,800 rows/second, 0 rejected rows).
* **Independent Financial Ledger Verification** (`scripts/validate_sql_server.sql`):
  - **Fact_Sales Row Count**: 5,000,000
  - **Total Gross Sales**: ₹1,139,371,183,767.44
  - **Total Discount Amount**: ₹125,280,638,871.83
  - **Total Net Revenue**: ₹1,014,090,544,895.61 ($Gross - Discount$, **variance = ₹0.00**)
  - **Total COGS**: ₹809,062,519,005.13
  - **Total Gross Profit**: ₹205,028,025,890.48 ($Net - COGS$, **variance = ₹0.00**)
  - **Realized Gross Margin**: 20.22%
  - **Database Storage Footprint**: MDF: 968 MB, LDF: 136 MB, Total: 1,104 MB (~1.1 GB).

### Phase 14: Track B — Databricks Lakehouse Bronze Ingestion & Silver Baseline 🟢 (Completed)
* **Unity Catalog Volume Discovery**:
  - Resolved `UC_VOLUME_NOT_FOUND` by discovering exact 3-level naming path: `/Volumes/dentalkart_dw/bronze/raw_files/`.
* **Bronze Delta Ingestion**:
  - Verified 14 Parquet files in volume (307.07 MB, 7,141,000 rows).
  - Executed safe, non-destructive CTAS statements in `scripts/databricks_bronze_ingestion_step2_clean.sql`.
* **Reconciliation Certification (Step 3 Audit Query)**:
  - Executed `scripts/databricks_bronze_step3_reconciliation.sql` on Databricks cluster.
  - **Certified Result**: 14/14 tables matched 100% with **0 variance** across all 7,141,000 rows.
* **Silver Baseline Working Copy**:
  - Authored and executed `scripts/databricks_silver_copy_step2_clean.sql`, creating working copies in `dentalkart_dw.silver` to isolate Bronze raw immutability from downstream Silver transformations.

---

## 3. Comprehensive 14-Table Parity Reconciliation Matrix

The table below certifies complete mathematical alignment across the Canonical Generation Source, SQL Server EDW, and Databricks Lakehouse:

| # | Entity Name | Table Type | Exact Business Grain | Source Baseline (Parquet / CSV) | SQL Server EDW (`DentaKart_DW`) | Databricks Bronze (`dentalkart_dw.bronze`) | Databricks Silver (`dentalkart_dw.silver`) | Parity Status |
|---|---|---|---|---:|---:|---:|---:|:---:|
| 01 | `dim_channel` | Dimension | 1 row per sales channel | 5 | 5 | 5 | 5 | 🟢 100% Parity |
| 02 | `dim_warehouse` | Dimension | 1 row per fulfillment hub | 6 | 6 | 6 | 6 | 🟢 100% Parity |
| 03 | `dim_supplier` | Dimension | 1 row per OEM dental manufacturer | 50 | 50 | 50 | 50 | 🟢 100% Parity |
| 04 | `dim_location` | Dimension | 1 row per city hub (5 regions) | 60 | 60 | 60 | 60 | 🟢 100% Parity |
| 05 | `dim_salesperson` | Dimension | 1 row per commercial rep | 500 | 500 | 500 | 500 | 🟢 100% Parity |
| 06 | `dim_product` | Dimension | 1 row per catalog SKU | 1,000 | 1,000 | 1,000 | 1,000 | 1,000 | 🟢 100% Parity |
| 07 | `dim_date` | Dimension | 1 row per calendar day (2021–2025) | 1,826 | 1,826 | 1,826 | 1,826 | 🟢 100% Parity |
| 08 | `dim_customer` | Dimension | 1 row per dental clinic account | 100,000 | 100,000 | 100,000 | 100,000 | 🟢 100% Parity |
| 09 | `fact_sales_targets` | Fact | 1 row per Month x Rep x Category | 120,000 | 120,000 | 120,000 | 120,000 | 🟢 100% Parity |
| 10 | `fact_service` | Fact | 1 row per service / repair ticket | 120,000 | 120,000 | 120,000 | 120,000 | 🟢 100% Parity |
| 11 | `fact_returns` | Fact | 1 row per return line event | 187,553 | 187,553 | 187,553 | 187,553 | 🟢 100% Parity |
| 12 | `fact_inventory_snapshot` | Fact | 1 row per SKU x Hub x Month-End | 360,000 | 360,000 | 360,000 | 360,000 | 🟢 100% Parity |
| 13 | `fact_orders` | Fact | 1 row per commercial order header | 1,250,000 | 1,250,000 | 1,250,000 | 1,250,000 | 🟢 100% Parity |
| 14 | `fact_sales` | Fact | 1 row per unique order line item | 5,000,000 | 5,000,000 | 5,000,000 | 5,000,000 | 🟢 100% Parity |
| **—** | **GRAND TOTAL** | — | **Full Data Warehouse Scope** | **7,141,000** | **7,141,000** | **7,141,000** | **7,141,000** | 🟢 **ZERO VARIANCE** |

---

## 4. Operational Scripts & Artifacts Inventory

All project automation and DDL scripts reside in [`scripts/`](file:///c:/Users/riyaz/Tableau/scripts/):

| Script File | Category | Purpose |
|---|---|---|
| `generate_data.py` | Data Engineering | Deterministic batch generator streaming 5M records to clean CSV and Parquet. |
| `validate_data.py` | Quality Assurance | 50-assertion automated audit suite validating source datasets. |
| `setup_database.sql` | SQL Server DDL | Idempotent DDL establishing `DentaKart_DW` schema, PKs, FKs, and UQ constraints. |
| `load_sql_server.py` | Ingestion Pipeline | High-speed bulk ingestion pipeline loading clean CSVs into SQL Server. |
| `validate_sql_server.sql` | SQL Server Audit | 26 verification queries performing ledger reconciliation and constraints check. |
| `databricks_bronze_preflight.sql` | Databricks SQL | Step 1 preflight queries inspecting namespace and verifying 0 conflicting tables. |
| `databricks_bronze_ingestion_step2_clean.sql` | Databricks DDL | Step 2 clean ingestion DDL creating all 14 Bronze Delta tables from Volume Parquet files. |
| `databricks_bronze_step3_reconciliation.sql` | Databricks Audit | Step 3 unified CTE query validating per-table counts and the 7,141,000-row grand total. |
| `databricks_silver_master_copy.sql` | Databricks DDL | Master script managing 3-step baseline copy from Bronze to Silver. |
| `databricks_silver_copy_step2_clean.sql` | Databricks DDL | Clean DDL copying 14 tables into `dentalkart_dw.silver`. |
| `databricks_silver_step3_reconciliation.sql` | Databricks Audit | Reconciliation query verifying 100% row-count parity across the 14 Silver tables. |

---

## 5. Next Steps & Two-Track Project Plan

### Project 1: SQL Server EDW & Enterprise Tableau BI Track (Next Immediate Focus)
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
   - Level of Detail expressions (`FIXED`, `INCLUDE`, `EXCLUDE`).
   - 8 Production Executive Dashboards (Executive Scorecard, Category Drilldown, Territory Performance, Inventory DOH, Returns Hotspots, Customer RFM, etc.).
   - Dynamic Row-Level Security (RLS) via User Entitlement tables.

### Project 2: Databricks Lakehouse Medallion Track (Subsequent Dedicated Session)
1. **Silver Layer Engineering**:
   - Schema casting (`STRING` dates → `DATE`, `DOUBLE` revenue/cost → `DECIMAL(14,2)`).
   - Timestamp standardization, null handling, and lineage audit columns (`_ingest_timestamp`).
2. **Data & Semantic Modeling**:
   - Star schema dimension/fact modeling in Delta Lake.
   - Surrogate keys, conformed dimension validation, and anti-fan-out testing.
3. **Gold Layer Analytical Marts**:
   - High-performance aggregated marts optimized with **Delta Z-Ordering** and **Liquid Clustering**.
4. **BI Connectivity & Performance Benchmark**:
   - Connecting Databricks Serverless SQL Warehouse directly to Tableau.
   - Live query latency benchmarking comparing Databricks Lakehouse against SQL Server EDW.

---

*Certified and logged in `PROGRESS.md`, `DATABRICKS_BRONZE_INGESTION_REPORT.md`, and `MISTAKES_AND_LEARNINGS.md`.*
