# DentaKart Analytics — Master Project & Executive Summary

**Project Name**: DentaKart Analytics — Enterprise Sales & Operations Platform  
**Target Role**: Senior Tableau Developer & Analytics Engineer (5-Year Experience Track)  
**Author / Lead Developer**: Riyaz Mohammed  
**GitHub Repository**: [https://github.com/riyazmohammed1799/Tableau](https://github.com/riyazmohammed1799/Tableau)  
**Last Updated**: November 18, 2026  
**Local Project Path**: `c:\Users\riyaz\Tableau`  

---

## 1. Executive Summary & Business Context

**DentaKart Analytics** is an enterprise-scale analytics engineering and Business Intelligence platform built for a fictional nationwide dental equipment, clinical instruments, and consumables distributor operating across India. 

Operating through an omnichannel sales ecosystem (Direct Field Sales, B2B Online Portal, Institutional Dental College Tenders, Distributor Sub-networks, and Tele-Inside Sales), DentaKart supplies over **1,000 specialized dental SKUs** to more than **100,000 active dental accounts** (solo practices, multi-chair clinics, corporate hospital chains, diagnostic labs, and dental universities) across 60 Indian cities.

### Strategic Business Challenges Addressed
1. **Margin Erosion & Discount Leakage**: Uncontrolled discounting across high-demand consumables and bundled capital equipment packages.
2. **Territory vs. Geographic Discrepancies**: High metro concentration in Mumbai, Bengaluru, and Delhi-NCR vs. untapped growth in Tier-2/3 dental healthcare hubs.
3. **Equipment Warranty & Post-Sale Service Friction**: Tracking installation lead times, routine preventive maintenance, and warranty breakdown claims on capital equipment (chairs, OPG/CBCT scanners, autoclaves).
4. **GST Tax Compliance & Ledger Balancing**: Indian GST tax brackets (12% for consumables, 18% for machinery), freight/shipping calculations, and diverse payment gateway methods.
5. **Quota Attainment Single Source of Truth**: Resolving disputed sales targets between field representatives and leadership through strict dimensional grain separation.

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

## 5. Completed Phases & Milestones

| Phase | Milestone Name | Status | Certified Outputs |
|---|---|:---:|---|
| **Phase 1** | Business Requirements Document (BRD) | 🟢 Complete | Approved metric formulas, stakeholders, 8 dashboard wireframe plans. |
| **Phase 2** | Source Systems & Data Generation (5M Rows) | 🟢 Complete | Python generator streamed 5M sales lines, 1.25M orders, master dimensions. Check V-06 rebalanced across 5 regions. 50/50 checks PASSED in `VALIDATION_REPORT.md`. |
| **Phase 3 (Setup)** | SQL Server EDW Schema & Bulk Ingestion | 🟢 Complete | `DentaKart_DW` created; all 14 tables ingested in 105.4s. 26 independent SQL validation queries passed with 100% ledger balance. |
| **Phase 14 (Track B)** | Databricks Lakehouse Bronze Ingestion & Silver Baseline | 🟢 Complete | Bronze Delta tables created from Unity Catalog volume; Silver working baseline established with 100% row-count parity (7,141,000 rows, 0 variance). |

---

## 6. Project Directory & Scripts Inventory

* **Root Documentation**:
  * [`README.md`](file:///c:/Users/riyaz/Tableau/README.md) — Master project navigation and topology.
  * [`PROGRESS.md`](file:///c:/Users/riyaz/Tableau/PROGRESS.md) — Real-time phase-by-phase completion tracker.
  * [`BUSINESS_REQUIREMENTS.md`](file:///c:/Users/riyaz/Tableau/BUSINESS_REQUIREMENTS.md) — Complete Phase 1 BRD and KPI formulas.
  * [`DATA_DICTIONARY.md`](file:///c:/Users/riyaz/Tableau/DATA_DICTIONARY.md) — 14-table schema definitions, data types, and grains.
  * [`DATA_MODEL.md`](file:///c:/Users/riyaz/Tableau/DATA_MODEL.md) — Star schema ER diagram and anti-fan-out matrix.
  * [`SQL_EXERCISES.md`](file:///c:/Users/riyaz/Tableau/SQL_EXERCISES.md) — 25 hands-on SQL problems across 5 difficulty tiers.
  * [`TABLEAU_EXERCISES.md`](file:///c:/Users/riyaz/Tableau/TABLEAU_EXERCISES.md) — Hands-on LOD, Table Calc, and parameter specifications.
  * [`DATA_QUALITY_RULES.md`](file:///c:/Users/riyaz/Tableau/DATA_QUALITY_RULES.md) — 12 zero-tolerance assertions and dirty dataset spec.
  * [`VALIDATION_REPORT.md`](file:///c:/Users/riyaz/Tableau/VALIDATION_REPORT.md) — 50-check pre-ingestion audit certification.
  * [`DATABRICKS_BRONZE_INGESTION_REPORT.md`](file:///c:/Users/riyaz/Tableau/DATABRICKS_BRONZE_INGESTION_REPORT.md) — Lakehouse Unity Catalog audit report.
  * [`MISTAKES_AND_LEARNINGS.md`](file:///c:/Users/riyaz/Tableau/MISTAKES_AND_LEARNINGS.md) — Living engineering journal and interview talking points.
  * [`INTERVIEW_QUESTION_BANK.md`](file:///c:/Users/riyaz/Tableau/INTERVIEW_QUESTION_BANK.md) — 25 senior interview scenarios with 5-point grading rubric.

* **Engineering Scripts** (`scripts/`):
  * `generate_data.py` — Vectorized chunked generator streaming 5M records to CSV and Parquet.
  * `validate_data.py` — 50-assertion pre-load verification suite.
  * `setup_database.sql` — Idempotent DDL creating `DentaKart_DW` schema, PKs, FKs, and UQ constraints.
  * `load_sql_server.py` — High-speed bulk ingestion pipeline loading CSVs into SQL Server.
  * `validate_sql_server.sql` — 26 SQL validation queries verifying ledger integrity.
  * `databricks_bronze_master_ingestion.sql` — Unity Catalog Bronze Delta table creation script.
  * `databricks_bronze_step3_reconciliation.sql` — Lakehouse row-count and parity audit query.
  * `databricks_silver_master_copy.sql` — Silver baseline working copy pipeline.

---

## 7. Immediate Next Steps & Execution Roadmap

### Track A: SQL Server EDW & Tableau Development (Current Priority)
1. **Tier 1 SQL Engineering Exercises** (`sql_solutions/`):
   * **Task 1**: Annual Category Revenue & Margin Realization (`task_01.sql`)
   * **Task 2**: Tier-wise City Penetration & Discount Distribution (`task_02.sql`)
   * **Task 3**: Omnichannel Sales Performance & Delivery Lag (`task_03.sql`)
   * **Task 4**: High-Discount Anomaly Audit (Tier allowance leakage detection) (`task_04.sql`)
   * **Task 5**: Warehouse Fulfillment & Product Returns Breakdown (`task_05.sql`)
2. **Subsequent SQL Tiers (Tiers 2 to 5)**:
   * Window functions (`DENSE_RANK`, `LAG`, rolling moving averages).
   * Cohort analysis (60-day repurchase retention, market basket affinity).
   * Query tuning (SARGability, execution plans, clustered columnstore indexing benchmarks).
3. **Tableau Enterprise BI Suite (Phases 8–11)**:
   * Logical Layer modeling avoiding fan-out across multiple grains.
   * Authoring calculated fields, Level of Detail expressions (`FIXED`, `INCLUDE`, `EXCLUDE`).
   * Building the 8 production executive and operational dashboards.
   * Dynamic Row-Level Security (RLS) via User Entitlement tables.

### Track B: Databricks Lakehouse Medallion Pipeline (Project 2 Track)
1. **Silver Layer Engineering**: Schema enforcement, timestamp standardization, typed casting (`STRING` → `DATE`/`DECIMAL`).
2. **Gold Layer Analytical Marts**: High-performance marts optimized via Delta Lake Liquid Clustering and Z-Ordering.
3. **Tableau Lakehouse Integration**: Direct connection to Databricks Serverless SQL Warehouse and live performance benchmarking against SQL Server EDW.
