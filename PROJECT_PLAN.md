# Project Plan — DentaKart Analytics (Tableau Senior Developer Master Track)

## 1. Project Mission & Methodology
This plan establishes a production-grade analytics engineering lifecycle for a fictional dental distribution enterprise in India. Rather than presenting passive tutorials, every phase is set up with clear business objectives, architectural deliverables, rigorous validation criteria, and technical interview checkpoints tailored for a **5-Year Experience Tableau Developer**.

**Sequential Track Strategy**: We will complete Track A (**Microsoft SQL Server EDW → Tableau Desktop/Cloud**) end-to-end first. Once complete, we will replicate the data pipeline in Track B (**Databricks Lakehouse Medallion Architecture**) and conduct direct architectural comparisons.

---

## 2. Phased Roadmap & Milestones

### Phase 1 — Business Requirements & Metric Architecture
* **Status**: 🟢 **COMPLETED** (Approved with modifications: 5M scale, Indian GST/shipping/payment fields, specialized dental catalog, SQL Server-first execution).

### Phase 2 — Source Data Generation (5,000,000+ Transactions)
* **Status**: 🟡 **IN PROGRESS**
* **Deliverables**: [DATA_DICTIONARY.md](file:///c:/Users/riyaz/Tableau/DATA_DICTIONARY.md), [DATA_MODEL.md](file:///c:/Users/riyaz/Tableau/DATA_MODEL.md), [DATA_GENERATION_PLAN.md](file:///c:/Users/riyaz/Tableau/DATA_GENERATION_PLAN.md), Python generator script (`scripts/generate_data.py`).
* **Milestone**: Candidate reviews final Phase 2 table grains, keys, dependency sequence, and loading strategy. Upon approval, deterministic generation produces ~5M clean sales rows, ~1.25M orders, master dimensions, 120k targets, 360k inventory snapshots, and the isolated `data/dirty/` dataset.

### Phase 3 — Hands-on SQL Mastery (Track A: SQL Server)
* **Deliverables**: [SQL_EXERCISES.md](file:///c:/Users/riyaz/Tableau/SQL_EXERCISES.md), Candidate query solutions folder (`sql_solutions/`).
* **Milestone**: Candidate independently writes and tunes 25 production-grade SQL queries spanning aggregations, multi-table joins, CTEs, window functions, cohort retention, and actual-vs-budget pacing.

### Phase 4 — Exploratory Data Analysis & Data Profiling
* **Deliverables**: Profiling queries, reconciliation scripts, validation metrics across 5M rows.
* **Milestone**: Complete audit of row counts, key uniqueness, null ratios, cardinality, and numerical distributions.

### Phase 5 — Data Quality Auditing & Anomaly Resolution
* **Deliverables**: [DATA_QUALITY_RULES.md](file:///c:/Users/riyaz/Tableau/DATA_QUALITY_RULES.md), DQ auditing queries against `data/dirty/`.
* **Milestone**: Investigation and programmatic remediation of synthetic anomalies (orphaned foreign keys, negative quantities, discount leaks, duplicate lines).

### Phase 6 — Dimensional Data Modeling & Semantic Layer Design
* **Deliverables**: Star schema DDL for SQL Server `DentaKart_DW`.
* **Milestone**: Candidate designs dimensional relationships, handles conformed dimensions, surrogate keys, and proves anti-fan-out logic.

### Phase 7 — Transformation & Reporting Layer (SQL Server Track)
* **Deliverables**: `DentaKart_DW` schema, Clustered Columnstore Indexes, reporting views, and indexed marts.
* **Milestone**: Production-ready curated layers feeding Tableau with sub-second aggregate response.

### Phase 8 — Tableau Core Calculation & LOD Engineering
* **Deliverables**: [TABLEAU_EXERCISES.md](file:///c:/Users/riyaz/Tableau/TABLEAU_EXERCISES.md), Tableau workbook components.
* **Milestone**: Hands-on authoring of FIXED/INCLUDE/EXCLUDE LODs, Table Calculations (RUNNING_SUM, WINDOW_AVG, RANK), and dynamic parameters.

### Phase 9 — Enterprise Dashboard Suite (8 Dashboards)
* **Deliverables**: 8 production-standard Tableau dashboards:
  1. Executive Sales Overview
  2. Regional Sales & Territory Performance
  3. Product & Category Profitability
  4. Customer RFM & Retention Analytics
  5. Pricing, Discount & Margin Leakage
  6. Inventory, Reorder & Replenishment
  7. Returns, Warranties & Quality Assurance
  8. Sales Target Attainment & Quota Forecasting
* **Milestone**: Complete dashboard interactivity, container layout architecture, visual hierarchy, and UI polish.

### Phase 10 — Performance Optimization & Query Tuning (10 Scenarios)
* **Deliverables**: Tableau Performance Recorder workbooks, SQL execution plans, index benchmarking reports across the 10 defined scenarios.
* **Milestone**: Optimization of heavy calculations, context filter placement, extract tuning, and mark reduction.

### Phase 11 — Enterprise Security, Governance & Deployment
* **Deliverables**: Row-Level Security (RLS) entitlement tables, User Filters, simulated Tableau Cloud project permissions.
* **Milestone**: Validation of multi-tenant and territory-based security without workbook duplication.

### Phase 12 — UAT & Production Support Scenarios
* **Deliverables**: [UAT_TEST_CASES.md](file:///c:/Users/riyaz/Tableau/UAT_TEST_CASES.md), test execution logs.
* **Milestone**: Reconciliation against financial ledgers, edge-case testing, and mock production incident triage.

### Phase 13 — 5-YOE Technical Mock Interview Simulation
* **Deliverables**: [INTERVIEW_QUESTION_BANK.md](file:///c:/Users/riyaz/Tableau/INTERVIEW_QUESTION_BANK.md), candidate performance reviews in [PROGRESS.md](file:///c:/Users/riyaz/Tableau/PROGRESS.md).
* **Milestone**: Comprehensive 1-on-1 mock interviews covering SQL, modeling, Tableau internals, and architectural trade-offs.

### Phase 14 — Track B: Databricks Lakehouse Replication & Comparison
* **Deliverables**: Delta Lake Bronze/Silver/Gold layers, PySpark/SQL transformations, Z-Order benchmarking, and a comparative architecture report (EDW vs Lakehouse).
* **Milestone**: Full replication and comparative analysis of performance, maintenance, and BI connectivity.
