# DentaKart Analytics — All-in-One Master Project & Execution Summary

**Document Version**: 3.0.0 (Definitive Master Edition)  
**Project Name**: DentaKart Analytics — Enterprise Sales & Operations Platform  
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

## 5. End-to-End Conversation & Technical Execution History

### Milestone 1: Phase 1 — Business Requirements & Metric Framework 🟢
* Defined the 5M-row transaction scale (configurable to 10M+).
* Structured Star Schema across 8 dimensions and 6 fact tables.
* Established Indian commercial dynamics: GST tax brackets (12% consumables, 18% capital equipment), commercial payment methods, freight charges, and equipment warranty tracking.

### Milestone 2: Phase 2 — Pre-Ingestion Audit & Check V-06 Remediation 🟢
* **Defect**: Automated check V-06 failed when `Dim_Location` truncated at 60 cities using a blind slice `cities_data[:60]`, capturing only 4 regions and omitting Central India entirely.
* **Remediation**: Implemented programmatic regional quota assertion gates inside `scripts/generate_data.py`:
  - North: 14 cities
  - South: 16 cities
  - West: 15 cities
  - East: 9 cities
  - Central: 6 cities (Bhopal, Indore, Gwalior, Jabalpur, Ujjain, Raipur)
* **Validation**: Re-generated full dataset with deterministic seed `42`. Ran `scripts/validate_data.py` across 50 assertion points; **all 50/50 checks PASSED** with 100% referential integrity. Certified in `VALIDATION_REPORT.md`.

### Milestone 3: Phase 3 Track A — SQL Server EDW Setup & Bulk Ingestion 🟢
* **Instance Verification**: Verified Microsoft SQL Server 2025 Express (`.\SQLEXPRESS`) via `sqlcmd -E -C`.
* **Destructive Operation Avoidance**: Preserved pre-existing databases (e.g., `DentalKart`) by strictly targeting `DentaKart_DW` with non-destructive, idempotent DDL.
* **NTFS ACL Resolution**: SQL Server `BULK INSERT` executes in the server engine process context under `NT Service\MSSQL$SQLEXPRESS`. Windows user profile directories blocked access (`xp_fileexist` returned 0). Resolved by granting directory read ACLs via `icacls "data\clean\csv" /grant "NT Service\MSSQL$SQLEXPRESS:(OI)(CI)(R)"`.
* **High-Speed Bulk Ingestion**: Loaded all 14 clean CSVs in **105.42 seconds** (~66,800 rows/second, 0 rejected rows).
* **Ledger Validation**: Executed `scripts/validate_sql_server.sql`; passed 26 independent verification queries with zero variance.

### Milestone 4: Phase 14 Track B — Databricks Lakehouse Bronze Ingestion 🟢
* **Unity Catalog Volume Discovery**: Resolved `UC_VOLUME_NOT_FOUND` on `rawfiles` by locating the exact volume path via `system.information_schema.volumes`: `/Volumes/dentalkart_dw/bronze/raw_files/`.
* **Step 1 Preflight Audit**: Executed query checking `dentalkart_dw.information_schema.tables` in `bronze`; returned **0 rows**, confirming zero conflicting tables.
* **Step 2 Clean Ingestion DDL**: Executed `scripts/databricks_bronze_ingestion_step2_clean.sql` with 14 `CREATE TABLE IF NOT EXISTS ... USING DELTA AS SELECT ...` statements.
* **DDL Semantics Learning**: Learned that DDL statements in Databricks SQL Editor return "No records returned" upon successful creation (they alter catalog metadata without returning a query grid).
* **Step 3 Unified CTE Reconciliation**: Executed `scripts/databricks_bronze_step3_reconciliation.sql`; confirmed **exact row-count parity across all 14 tables (7,141,000 actual rows / 0 variance)**.

### Milestone 5: Phase 14 Track B — Silver Baseline Working Copies 🟢
* **Bronze Immutability**: Kept Bronze as the immutable raw audit layer.
* **Silver Baseline Copy**: Executed `scripts/databricks_silver_copy_step2_clean.sql`, creating 14 Delta tables in `dentalkart_dw.silver` to stage tables for subsequent data cleaning, schema transformation, and modeling.

---

## 6. Comprehensive Scripts & Documentation Directory Inventory

All project automation, DDL, and verification scripts reside in [`scripts/`](file:///c:/Users/riyaz/Tableau/scripts/):

| Script / File Path | Category | Purpose & Description |
|---|---|---|
| `scripts/generate_data.py` | Data Engineering | Vectorized chunked generator streaming 5M records to clean CSV and Parquet. |
| `scripts/validate_data.py` | Quality Assurance | 50-assertion pre-load verification suite testing referential integrity and arithmetic. |
| `scripts/setup_database.sql` | SQL Server DDL | Idempotent DDL establishing `DentaKart_DW` schema, PKs, FKs, and UQ constraints. |
| `scripts/load_sql_server.py` | Ingestion Pipeline | High-speed bulk ingestion pipeline loading clean CSVs into SQL Server. |
| `scripts/validate_sql_server.sql` | SQL Server Audit | 26 independent SQL validation queries performing ledger reconciliation. |
| `scripts/databricks_bronze_preflight.sql` | Databricks SQL | Step 1 preflight queries inspecting namespace and verifying 0 conflicting tables. |
| `scripts/databricks_bronze_ingestion_step2_clean.sql` | Databricks DDL | Step 2 clean ingestion DDL creating all 14 Bronze Delta tables from Volume Parquet files. |
| `scripts/databricks_bronze_step3_reconciliation.sql` | Databricks Audit | Step 3 unified CTE query validating per-table counts and the 7,141,000-row grand total. |
| `scripts/databricks_silver_master_copy.sql` | Databricks DDL | Master script managing 3-step baseline copy from Bronze to Silver. |
| `scripts/databricks_silver_copy_step2_clean.sql` | Databricks DDL | Clean DDL copying 14 tables into `dentalkart_dw.silver`. |
| `scripts/databricks_silver_step3_reconciliation.sql` | Databricks Audit | Reconciliation query verifying 100% row-count parity across the 14 Silver tables. |
| `README.md` | Documentation | Master project navigation, architectural context, and topology. |
| `PROGRESS.md` | Project Management | Live phase-by-phase completion tracker and task checklist. |
| `DATA_DICTIONARY.md` | Data Governance | Comprehensive 14-table schema definitions, data types, and grains. |
| `DATA_MODEL.md` | Data Modeling | Star schema ER diagram and anti-fan-out matrix. |
| `SQL_EXERCISES.md` | Skills Development | 25 hands-on SQL problems across 5 difficulty tiers. |
| `TABLEAU_EXERCISES.md` | BI Development | Hands-on LOD expressions, Table Calcs, and parameter specifications. |
| `DATA_QUALITY_RULES.md` | Data Quality | 12 zero-tolerance assertions and dirty practice dataset specification. |
| `VALIDATION_REPORT.md` | Audit Certification | 50-check pre-ingestion audit certification report. |
| `DATABRICKS_BRONZE_INGESTION_REPORT.md` | Lakehouse Report | Databricks Unity Catalog Bronze ingestion report and parity certification. |
| `MISTAKES_AND_LEARNINGS.md` | Technical Journal | Engineering journal tracking root causes, solutions, and interview talking points. |
| `INTERVIEW_QUESTION_BANK.md` | Interview Prep | 25 senior interview scenarios with 5-point evaluation rubrics. |

---

## 7. Key Engineering Lessons & Interview Talking Points

*(Captured from living journal [`MISTAKES_AND_LEARNINGS.md`](file:///c:/Users/riyaz/Tableau/MISTAKES_AND_LEARNINGS.md))*

1. **Automated Assertion Gates vs. Blind Data Generation**:
   - *Scenario*: Out of 50 checks, check V-06 caught an array slice truncation bug that would have silently dropped Central India from Tableau geographic maps.
   - *Interview Talking Point*: *"Senior analytics engineers enforce defensive programmatic validation within the data pipeline so schemas and referential integrity are mathematically verified before reaching the data warehouse."*
2. **Database Engine Service Account Security Context**:
   - *Scenario*: `xp_fileexist` returned 0 for CSV files during SQL Server ingestion.
   - *Interview Talking Point*: *"A 5-YOE BI data engineer understands that server-side bulk loaders execute under the DBMS service account security context (`NT Service\MSSQL$SQLEXPRESS`), requiring explicit file-system ACL validation before pipeline deployment."*
3. **Unity Catalog Namespace & Volume Governance**:
   - *Scenario*: `UC_VOLUME_NOT_FOUND` error on Databricks volume path.
   - *Interview Talking Point*: *"In Databricks Unity Catalog, Volumes require strict 3-level naming (`<catalog>.<schema>.<volume>`) and case-exact pathing. Preflight discovery using `information_schema` prevents deployment halts."*
4. **DDL Semantics & Automated Reconciliation**:
   - *Scenario*: Databricks SQL Editor displayed "No records returned" upon executing CTAS statements.
   - *Interview Talking Point*: *"A Senior Data Engineer understands SQL engine semantics: DDL operations modify catalog metadata without returning result sets. Automated reconciliation queries with unioned rollups provide instant mathematical proof of data integrity."*

---

## 8. Complete Test Suite Inventory & Quality Assurance Matrix

The DentaKart Analytics platform maintains a rigorous, multi-tiered testing framework encompassing **174 total tests and evaluation milestones**, divided into automated system integrity gates and candidate-led technical milestones.

### Part A: Automated System Integrity Tests (91 Tests — 100% Passed 🟢)

| Category / Test Suite | File / Script | Checks Passed | Scope & Description |
|---|---|:---:|---|
| **Pre-Ingestion Data Quality & Referential Integrity Suite** | [`scripts/validate_data.py`](file:///c:/Users/riyaz/Tableau/scripts/validate_data.py) | **50 / 50** | **1. Schema & Null Checks (1–14)**: Primary keys unique and non-null across all 14 tables.<br>**2. Referential Integrity (15–24)**: Strict foreign key relationships linking sales to customers, products, orders, salespersons, locations, and dates.<br>**3. Financial Arithmetic (25–34)**: $Gross - Discount = Net$, $Net - COGS = Gross Profit$, tax rates.<br>**4. Domain Constraints (35–44)**: Discount rate thresholds, status values, dates 2021–2025.<br>**5. Geographic Distribution (45–50)**: Check V-06 remediation verifying balanced coverage across all 60 cities and 5 regions. |
| **SQL Server EDW Ingestion & Ledger Validation Suite** | [`scripts/validate_sql_server.sql`](file:///c:/Users/riyaz/Tableau/scripts/validate_sql_server.sql) | **26 / 26** | **1. Table Row Counts (1–14)**: Verification of exactly 7,141,000 rows across 14 tables in `DentaKart_DW`.<br>**2. Financial Ledger Balance (15–18)**: Zero-variance proof for Net Revenue (₹1.01T), Gross Profit (₹205B), and Margin (20.22%).<br>**3. Referential Integrity (19–22)**: Zero orphan foreign keys across orders, sales, clinics, and locations.<br>**4. Storage & Performance (23–26)**: Baseline capture (1.1 GB DB size, 706 MB Fact_Sales). |
| **Databricks Unity Catalog Lakehouse Reconciliation Suite** | [`scripts/databricks_bronze_step3_reconciliation.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_bronze_step3_reconciliation.sql)<br>[`scripts/databricks_silver_step3_reconciliation.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_silver_step3_reconciliation.sql) | **15 / 15** | **1. Per-Table Delta Parity (1–14)**: Row-by-row verification of all 14 Delta tables against source Parquet.<br>**2. Unified Rollup (15)**: Step 3 unioned CTE asserting exactly 7,141,000 actual vs 7,141,000 expected rows with **0 variance** across Bronze and Silver. |
| **Total Automated Tests Certified** | — | **91 / 91 (100% Passed 🟢)** | Zero ledger variance, zero orphan records, 100% referential integrity across all engines. |

---

### Part B: Hands-on Practice, UAT & Evaluation Milestones Ahead (83 Milestones ⚪)

| Category / Milestone Suite | File / Reference | Count | Scope & Focus Areas |
|---|---|:---:|---|
| **SQL Engineering Mastery (5 Difficulty Tiers)** | [`SQL_EXERCISES.md`](file:///c:/Users/riyaz/Tableau/SQL_EXERCISES.md) | **25 Tasks** | **Tier 1 (Tasks 1–5)**: Aggregate reporting, margin formulas, delivery lag, discount anomaly detection.<br>**Tier 2 (Tasks 6–10)**: Window functions (`DENSE_RANK`, `LAG`), rolling 90-day moving averages, RFM segmentation.<br>**Tier 3 (Tasks 11–15)**: 60-day cohort retention, quota attainment, webhook deduplication, market basket affinity.<br>**Tier 4 (Tasks 16–20)**: Warranty claim rates, inventory DOH, MTTR, quota streak analysis.<br>**Tier 5 (Tasks 21–25)**: Columnstore vs rowstore, SARGability, type conversion bottlenecks, Cartesian fan-out prevention. |
| **Tableau Core Technical & Modeling Exercises** | [`TABLEAU_EXERCISES.md`](file:///c:/Users/riyaz/Tableau/TABLEAU_EXERCISES.md) | **12 Tasks** | **Tasks T-01 to T-02**: Logical Layer Relationships vs Physical Joins; Hyper Extract vs Live connection.<br>**Tasks T-03 to T-05**: Level of Detail (LOD) expressions (`FIXED` cohort, `EXCLUDE` benchmark, `INCLUDE` basket size).<br>**Tasks T-06 to T-09**: Tableau Order of Operations, Context Filters, Running Sums, MoM/YoY `LOOKUP`, Pareto 80/20.<br>**Tasks T-10 to T-12**: Parameter dynamic metric selectors, Top N with "Others" Sets, Asymmetric drill-down set actions. |
| **Production Enterprise Dashboards** | Phases 8–9 Architecture | **8 Dashboards** | 1. Executive Sales & Margin Overview<br>2. Regional Sales & Territory Performance<br>3. Customer Intelligence & Cohort Retention<br>4. Product Portfolio & Return Rate Analysis<br>5. Inventory Health & Supply Chain Operations<br>6. Capital Equipment & Service Contract Lifecycle<br>7. Financial Audit & Discount Leakage Control<br>8. Operations Control Tower & SLA Fulfillment |
| **User Acceptance Testing (UAT) Sign-Off Matrix** | [`UAT_TEST_CASES.md`](file:///c:/Users/riyaz/Tableau/UAT_TEST_CASES.md) | **14 Cases** | **UAT-001 to UAT-006**: Financial & Operational Ledger Sign-off (Net sales BAN, margin conservation, order distinctness, target anti-fan-out, returns).<br>**UAT-007 to UAT-010**: Interactivity verification (Date horizons, map drill-downs, Top N parameters, margin sliders).<br>**UAT-011 to UAT-014**: Dynamic Row-Level Security verification (North Director, West Director, NSD, Field Rep). |
| **5-YOE Senior Technical Interview Simulation** | [`INTERVIEW_QUESTION_BANK.md`](file:///c:/Users/riyaz/Tableau/INTERVIEW_QUESTION_BANK.md) | **24 Scenarios** | **Domain 1 (5)**: Multi-fact modeling, grain discrepancies, fan-out mitigation.<br>**Domain 2 (4)**: SQL Server engine internals, Columnstore indexes, memory grants, SARGability.<br>**Domain 3 (4)**: Tableau Logical Layer, Order of Operations, FIXED/INCLUDE/EXCLUDE LODs.<br>**Domain 4 (3)**: Table calculations addressing vs partitioning, late filtering.<br>**Domain 5 (4)**: Performance tuning, Hyper extracts vs Live, mark volume reduction.<br>**Domain 6 (4)**: Dynamic RLS, Lakehouse vs EDW architecture, production incident triage. |
| **Total Practice & Assessment Milestones Ahead** | — | **83 Milestones** | Structured hands-on implementation and 5-point evaluation rubrics. |

---

### Grand Total Platform Verification Matrix
$$\mathbf{91\text{ Automated Tests Passed}} + \mathbf{83\text{ Practice/UAT Milestones Ahead}} = \mathbf{174\text{ Total Verification Steps}}$$

---

## 9. Granular Two-Track Plan of Action (Step-by-Step Roadmap Ahead)

### 🎯 Track 1: Project 1 — SQL Server EDW & Enterprise Tableau BI (Immediate Next Session)

```
[ DentaKart_DW (SQL Server) ]
             │
             ├── Stage 1: Tier 1 SQL Mastery (Tasks 1–5 in sql_solutions/)
             ├── Stage 2: Tiers 2–5 Advanced SQL (Tasks 6–25)
             ├── Stage 3: Star Schema Clustered Columnstore Indexes & Marts (Phases 6–7)
             ├── Stage 4: Tableau Core Modeling, LODs & Calculations (Phase 8, Tasks T-01 to T-12)
             ├── Stage 5: 8 Production Enterprise Dashboards (Phase 9)
             ├── Stage 6: Performance Optimization, Hyper Extracts & Dynamic RLS (Phases 10–11)
             └── Stage 7: UAT 14-Point Sign-Off & 5-YOE Mock Interview Drills (Phases 12–13)
```

1. **Stage 1 — Tier 1 SQL Engineering Exercises** (`sql_solutions/`):
   - **Task 1: Annual Category Revenue & Margin Realization** ([`sql_solutions/task_01.sql`](file:///c:/Users/riyaz/Tableau/sql_solutions/task_01.sql)):
     - Calculate volume, gross sales, discounts, net sales, gross profit, and margin % by Year and Category (excluding cancelled orders).
     - Guard against naive averages of percentages; compute true weighted margin: `(SUM(gross_profit_inr) / SUM(net_sales_inr)) * 100`.
   - **Task 2: Tier-wise City Penetration & Discount Distribution** ([`sql_solutions/task_02.sql`](file:///c:/Users/riyaz/Tableau/sql_solutions/task_02.sql)):
     - City tiers (`Tier 1`, `Tier 2`, `Tier 3`) volume vs discount correlation. Active buying clinics count in 2025 using conditional aggregation.
   - **Task 3: Omnichannel Sales Performance & Delivery Lag** ([`sql_solutions/task_03.sql`](file:///c:/Users/riyaz/Tableau/sql_solutions/task_03.sql)):
     - Channel order volume, net revenue, fulfillment turnaround (`DATEDIFF`), and cancellation rate % with `NULL` shipping date handling.
   - **Task 4: High-Discount Anomaly Audit (Tier Leakage Detection)** ([`sql_solutions/task_04.sql`](file:///c:/Users/riyaz/Tableau/sql_solutions/task_04.sql)):
     - Identify sales transactions exceeding customer tier allowances (Platinum >25%, Gold >15%, Standard >8%, Value >5%) and compute revenue leakage.
   - **Task 5: Warehouse Fulfillment & Product Returns Breakdown** ([`sql_solutions/task_05.sql`](file:///c:/Users/riyaz/Tableau/sql_solutions/task_05.sql)):
     - Return rate % and net refunds by Warehouse and Category (`HAVING SUM(returned_quantity) > 1000`).
2. **Stage 2 — Advanced SQL Engineering (Tiers 2 to 5)**:
   - Window functions (`DENSE_RANK`, `LAG`, rolling 90-day moving averages, RFM customer segmentation).
   - Cohort retention analytics (60-day repurchase rate, market basket co-purchase affinity).
   - Query tuning (SARGability, execution plans, clustered columnstore indexing benchmarks).
3. **Stage 3 — Dimensional Data Modeling & Reporting Marts (Phases 6–7)**:
   - Defend star schema grains and author clustered columnstore indexed analytical views in `DentaKart_DW`.
4. **Stage 4 — Tableau Core Calculations & LOD Modeling (Phase 8)**:
   - Establish Logical Layer Relationships ("noodles") to prevent fan-out across multiple grains.
   - Author LOD expressions (`FIXED`, `INCLUDE`, `EXCLUDE`) and dynamic parameter controls (`TABLEAU_EXERCISES.md`).
5. **Stage 5 — Enterprise BI Dashboards (Phase 9)**:
   - Build 8 production executive and operational dashboards with consistent design system and interactivity.
6. **Stage 6 — Performance Optimization & Dynamic RLS (Phases 10–11)**:
   - Benchmark Hyper extract vs Live query performance using Tableau Performance Recorder.
   - Author and validate dynamic Row-Level Security (RLS) via User Entitlement tables and `USERNAME()`.
7. **Stage 7 — UAT Ledger Sign-off & Mock Technical Interview (Phases 12–13)**:
   - Execute the 14 UAT test cases (`UAT_TEST_CASES.md`) for zero-variance ledger sign-off.
   - Conduct 1-by-1 evaluation across 24 senior interview scenarios (`INTERVIEW_QUESTION_BANK.md`) with 5-point rubrics.

---

### 🚀 Track 2: Project 2 — Databricks Lakehouse Medallion Pipeline

```
[ Volumes raw_files/ ] ──> [ Bronze Delta (14 tables) ] ──> [ Silver Cleaned/Typed ] ──> [ Gold Marts ] ──> [ Tableau BI ]
```

1. **Stage 1 — Silver Layer Engineering (Data Cleaning & Typed Casting)**:
   - Schema enforcement: Typed casting (`STRING` dates → `DATE`/`TIMESTAMP`, `DOUBLE` revenue/cost → `DECIMAL(14,2)`).
   - Ingestion metadata (`_silver_ingested_at`), null handling, and surrogate key validation across all 14 Silver tables.
2. **Stage 2 — Semantic Dimensional Data Model & Grain Checks**:
   - Star schema dimension and fact modeling in Delta Lake.
   - Conformed dimensions validation and multi-grain anti-fan-out checks (Orders vs Quotas vs Returns vs Inventory).
3. **Stage 3 — Gold Layer Analytical Marts**:
   - Build high-performance analytical marts optimized via Delta Lake Liquid Clustering and Z-Ordering (`OPTIMIZE ... ZORDER BY (clinic_id, order_date)`).
4. **Stage 4 — Tableau BI Connectivity & Benchmarking**:
   - Direct connection from Databricks Serverless SQL Warehouse to Tableau.
   - Live query latency benchmarking comparing Databricks Lakehouse against SQL Server EDW.

---

*Certified and logged in `PROGRESS.md`, `VALIDATION_REPORT.md`, `DATABRICKS_BRONZE_INGESTION_REPORT.md`, `MISTAKES_AND_LEARNINGS.md`, and tracked in GitHub repository `riyazmohammed1799/Tableau`.*
