# Project Progress Tracker — DentaKart Analytics

> **Policy:** Update this tracker only when a phase or task has actually been completed and validated by the candidate. Generating files or instructions does NOT count as completion.

---

## Overall Status Summary
* **Current Phase**: Phase 3 — Core & Advanced SQL Engineering Exercises (🟡 IN PROGRESS — Database Loaded & Verified)
* **Target Role**: Senior Tableau Developer (5-Year Experience)
* **Execution Roadmap**: Track A (SQL Server EDW → Tableau) first, followed by Track B (Databricks Lakehouse replication & benchmarking)
* **Dataset Scale Generated**: **5,000,000 Sales Transaction Lines** across **1,250,000 Orders** (7,141,000 total rows across 14 tables)
* **System Testing Integrity**: **91 / 91 Automated Tests Passed (100% 🟢)** (50 pre-load checks, 26 SQL Server checks, 15 Databricks reconciliation checks)
* **Evaluation Milestones Ahead**: **83 Milestones ⚪** (25 SQL tasks, 12 Tableau tasks, 8 dashboards, 14 UAT test cases, 24 interview scenarios)
* **Total Platform Verification Suite**: **174 Total Tests & Milestones**

---

## Phase Checklist

| Phase | Description | Status | Completion Date | Sign-off Notes |
|---|---|---|---|---|
| **Phase 1** | Business Requirements Document (BRD) | 🟢 COMPLETED | 2026-10-07 | Signed off with modifications: 5M scale, Indian GST/shipping/payment fields, specialized dental categories, and SQL Server-first execution. |
| **Phase 2** | Source Systems & Data Generation (5M Rows) | 🟢 COMPLETED | 2026-10-09 | 5M sales records, 1.25M orders, master dimensions, targets, snapshots generated. Dim_Location rebalanced across 5 regions (North: 14, South: 16, West: 15, East: 9, Central: 6). Automated audit suite passed 50/50 checks with zero defects. Certified production-ready. |
| **Phase 3** | Core & Advanced SQL Engineering Exercises | 🟡 IN PROGRESS | — | `DentaKart_DW` created on SQL Server 2025 Express. All 14 tables loaded (5M rows) in 105.4s. 26 independent SQL validation queries passed with 100% ledger balance. Baseline captured (1.1 GB). Ready for candidate SQL solutions. |
| **Phase 4** | EDA & Data Profiling | ⚪ PENDING | — | Profiling queries & reconciliation across 5M rows to be run by candidate. |
| **Phase 5** | Data Quality Auditing & Anomaly Resolution | ⚪ PENDING | — | Controlled `data/dirty/` dataset to be audited and cleaned by candidate. |
| **Phase 6** | Dimensional Data Modeling & Star Schema | ⚪ PENDING | — | Candidate will propose and defend schema, grains, and anti-fan-out strategy. |
| **Phase 7** | Transformation & Reporting Layer (SQL Server Track) | ⚪ PENDING | — | Candidate creates clustered columnstore indexed tables, views, and marts in `DentaKart_DW`. |
| **Phase 8** | Tableau Core Development (Calculations, LODs, Table Calcs) | ⚪ PENDING | — | Candidate implements FIXED/INCLUDE/EXCLUDE, Table Calcs, and Parameters. |
| **Phase 9** | Enterprise Dashboards (8 Production Dashboards) | ⚪ PENDING | — | Candidate builds 8 production dashboards with interactive action flows. |
| **Phase 10** | Performance Optimization & Query Tuning (10 Scenarios) | ⚪ PENDING | — | Hands-on performance benchmarking: Live vs Extract, slow joins, heavy LODs, mark volume. |
| **Phase 11** | Security, Row-Level Security (RLS) & Governance | ⚪ PENDING | — | Candidate implements dynamic RLS via User Entitlement tables. |
| **Phase 12** | UAT & Production Support Scenarios | ⚪ PENDING | — | Candidate runs ledger reconciliation tests and resolves production incident drills. |
| **Phase 13** | 5-YOE Technical Mock Interview Simulation | ⚪ PENDING | — | 1-by-1 rigorous interview evaluation across architecture, SQL, LODs, and tuning. |
| **Phase 14** | Track B: Databricks Lakehouse (Bronze & Silver Baseline) | 🟢 BRONZE & SILVER READY | 2026-10-12 | Bronze certified (7.14M rows, 0 variance). Silver baseline working tables created. Staged for Project 2 cleaning, data modeling, semantic model, marts, and BI connection. |

---

## Detailed Task Breakdown

### Phase 1: Business Requirements
- [x] Review business context, scope, and objectives of DentaKart Analytics
- [x] Incorporate 5M scale target (configurable to 10M+)
- [x] Incorporate GST tax rates, shipping costs, payment methods, and specialized dental equipment categories
- [x] Formal sign-off on requirements (Approved 2026-10-07)

### Phase 2: Source Systems & Data Generation
- [x] Update dimensional schema & data dictionary specifications for 5M rows
- [x] Document grains, composite keys, and foreign keys for all fact and dimension tables
- [x] Define data-generation dependency sequence
- [x] Author memory-efficient batch generator (`scripts/generate_data.py`)
- [x] Generate clean 5,000,000 sales lines, 1,250,000 orders, 120,000 targets, 360,000 inventory snapshots, 187,553 returns, 120,000 service tickets
- [x] Author automated audit suite (`scripts/validate_data.py`)
- [x] Run 50-point audit suite and generate [VALIDATION_REPORT.md](file:///c:/Users/riyaz/Tableau/VALIDATION_REPORT.md)
- [x] Review Check V-06 audit finding with candidate and remediate
- [x] Re-run automated audit suite: 50/50 checks PASSED (100% compliant)

### Phase 3: Core & Advanced SQL Engineering Exercises
- [x] Verify SQL Server 2025 Express instance, connectivity, and disk capacity
- [x] Author idempotent, non-destructive schema script ([scripts/setup_database.sql](file:///c:/Users/riyaz/Tableau/scripts/setup_database.sql))
- [x] Create `DentaKart_DW` and all 14 Star Schema tables with PKs, FKs, and UQ constraints
- [x] Execute controlled bulk ingestion pipeline ([scripts/load_sql_server.py](file:///c:/Users/riyaz/Tableau/scripts/load_sql_server.py)) across all 14 clean CSVs (5M rows loaded in 105.4s)
- [x] Author & execute independent SQL validation suite ([scripts/validate_sql_server.sql](file:///c:/Users/riyaz/Tableau/scripts/validate_sql_server.sql)): 26/26 checks PASSED
- [x] Capture performance and storage baselines (1.1 GB total DB size, 706 MB Fact_Sales)
- [ ] Candidate authors SQL solutions for Tier 1: Tasks 1 – 5 in `sql_solutions/`
  - [ ] Task 1: Annual Category Revenue & Margin Realization
  - [ ] Task 2: Tier-wise City Penetration & Discount Distribution
  - [ ] Task 3: Omnichannel Sales Performance & Delivery Lag
  - [ ] Task 4: High-Discount Anomaly Audit (Leakage Detection)
  - [ ] Task 5: Warehouse Fulfillment & Product Returns Breakdown
- [ ] Candidate authors SQL solutions for Tier 2: Tasks 6 – 10 in `sql_solutions/`
- [ ] Candidate authors SQL solutions for Tier 3: Tasks 11 – 15 in `sql_solutions/`
- [ ] Candidate authors SQL solutions for Tier 4: Tasks 16 – 20 in `sql_solutions/`
- [ ] Candidate authors SQL solutions for Tier 5: Tasks 21 – 25 in `sql_solutions/`

### Phase 14: Track B — Databricks Lakehouse Bronze Ingestion
- [x] Verify Parquet source datasets locally (14 files, 307.07 MB, 7,141,000 total rows)
- [x] Confirm Unity Catalog Volume accessibility (`/Volumes/dentalkart_dw/bronze/raw_files/`)
- [x] Author safe, idempotent Bronze ingestion DDL (`scripts/databricks_bronze_master_ingestion.sql`)
- [x] Author comprehensive 14-table parity validation script (`scripts/databricks_bronze_validation.sql`)
- [x] Document Lakehouse architecture and baseline metrics in [`DATABRICKS_BRONZE_INGESTION_REPORT.md`](file:///c:/Users/riyaz/Tableau/DATABRICKS_BRONZE_INGESTION_REPORT.md)
- [x] Preflight Step 1 executed in Databricks: 0 conflicting tables confirmed in `dentalkart_dw.bronze`
- [x] Execute Step 2 Bronze ingestion in Databricks SQL Editor: 14 Delta tables created
- [x] Step 3 Reconciliation Audit passed: 14/14 Delta tables verified with 100% ledger parity (7,141,000 actual rows, 0 variance)
- [x] Execute Step 2 Silver baseline copy in Databricks SQL Editor: 14 working tables created in `dentalkart_dw.silver`
- [ ] Next Databricks Session (Track B / Project 2): Silver data cleaning, type casting, semantic model, grain checks, Gold marts, and BI connection

---

## Log of Candidate Mistakes & Struggled Concepts
*(Tracked in [MISTAKES_AND_LEARNINGS.md](file:///c:/Users/riyaz/Tableau/MISTAKES_AND_LEARNINGS.md))*

* **2026-10-07**: Check V-06 caught an array slice truncation bug in `Dim_Location` (4 geographic regions instead of 5). Logged in technical journal.
* **2026-10-09**: Check V-06 remediated by defining 60 cities across 5 regions with internal assertion gates. 50/50 audit pass achieved.
* **2026-10-09**: Pre-load review identified NTFS ACL restriction on SQL Server service account `NT Service\MSSQL$SQLEXPRESS` for user folders; resolved via explicit directory grant before `BULK INSERT`.
* **2026-10-12**: Track B Databricks Unity Catalog Volume naming discrepancy resolved (`/Volumes/dentalkart_dw/bronze/raw_files/`). Bronze ingestion certified across 14 tables (7,141,000 rows, 100% parity). Silver baseline tables created.

---

## Interview Performance Log
*(Tracks questions asked, candidate answers, score out of 5, gaps identified, and re-test status.)*

* None conducted yet.

---

## Next Recommended Actions

### Project 1: SQL Server EDW & Enterprise Tableau BI Track (Next Immediate Session)
* Begin **Tier 1 SQL Exercises (Tasks 1 – 5)** against `DentaKart_DW` on `.\SQLEXPRESS`:
  - **Task 1**: Annual Category Revenue & Margin Realization ([`sql_solutions/task_01.sql`](file:///c:/Users/riyaz/Tableau/sql_solutions/task_01.sql))
  - **Task 2**: Tier-wise City Penetration & Discount Distribution
  - **Task 3**: Omnichannel Sales Performance & Delivery Lag
  - **Task 4**: High-Discount Anomaly Audit (Tier leakage detection)
  - **Task 5**: Warehouse Fulfillment & Product Returns Breakdown
* Transition to Tableau Core Modeling (Calculations, LOD expressions, Table Calcs, and the 8 production enterprise dashboards).

### Project 2: Databricks Lakehouse Medallion Track
* **Silver Engineering**: Data cleaning, typed schema casting (`STRING` → `DATE`, `DOUBLE` → `DECIMAL(14,2)`), surrogate key validation, and audit metadata.
* **Data & Semantic Modeling**: Star schema relationships, conformed dimension validation, and grain checks.
* **Gold Layer Marts**: Aggregated analytical marts and Lakehouse Z-Order optimization.
* **BI Connectivity**: Connecting Databricks SQL Warehouse to Tableau for direct Lakehouse dashboarding and performance benchmarking against SQL Server.
