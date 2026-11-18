# Databricks Lakehouse Bronze Ingestion Report — DentaKart Analytics (Track B)

**Document Version**: 1.1.0 (Production Verified)  
**Status**: 🟢 CERTIFIED & COMPLETE (100% Parity across all 14 Delta Tables)  
**Environment**: Databricks Unity Catalog  
**Catalog**: `dentalkart_dw`  
**Target Schema**: `dentalkart_dw.bronze`  
**Source Volume**: `/Volumes/dentalkart_dw/bronze/raw_files/`  
**Storage Format**: Snappy Parquet (Source) → Managed Delta Lake (Target)  
**Execution Standard**: Databricks SQL (Zero PySpark dependencies, pure SQL-first)  
**Auditor**: Senior Databricks Data Engineer & Tableau Developer Track  

---

## 1. Executive Summary & Verification Boundary

Track B establishes the medallion Lakehouse architecture to mirror and benchmark against the existing Microsoft SQL Server enterprise data warehouse (`DentaKart_DW`). 

* **Local Source Baseline**: All 14 canonical Parquet files in `C:\Users\riyaz\Tableau\data\clean\parquet\` are 100% verified (307.07 MB, 7,141,000 total rows).
* **Source Volume Accessibility**: The Unity Catalog Volume `/Volumes/dentalkart_dw/bronze/raw_files/` has been verified accessible via Databricks `LIST`.
* **SQL Server Isolation**: Local database `DentaKart_DW` on `.\SQLEXPRESS` has remained completely untouched and unmodified.
* **Cluster Reconciliation**: All 14 Bronze Delta tables have been executed, loaded, and independently reconciled in Databricks SQL. Exact row count parity is achieved across every dataset: **7,141,000 actual rows / 7,141,000 expected rows (0 variance, 100% ledger balance)**.

---

## 2. Source Dataset Verification (Local Parquet Baseline)

Each of the 14 source files was audited via PyArrow metadata inspection:

| # | Dataset / Source Parquet File | Entity Grain | Verified Row Count | Columns | Physical File Size | Parquet Types Inferred |
|---|---|---|---:|:---:|---:|---|
| 1 | `dim_channel.parquet` | 1 row per sales channel | 5 | 2 | 1.92 KB | `int64`, `large_string` |
| 2 | `dim_customer.parquet` | 1 row per clinic account | 100,000 | 9 | 1.10 MB | `int64`, `large_string`, `double` |
| 3 | `dim_date.parquet` | 1 row per calendar day | 1,826 | 15 | 30.08 KB | `int64`, `large_string` |
| 4 | `dim_location.parquet` | 1 row per city hub (5 regions) | 60 | 5 | 4.64 KB | `int64`, `large_string` |
| 5 | `dim_product.parquet` | 1 row per catalog SKU | 1,000 | 12 | 44.51 KB | `int64`, `large_string`, `double` |
| 6 | `dim_salesperson.parquet` | 1 row per commercial rep | 500 | 7 | 17.60 KB | `int64`, `large_string` |
| 7 | `dim_supplier.parquet` | 1 row per OEM manufacturer | 50 | 3 | 3.46 KB | `int64`, `large_string` |
| 8 | `dim_warehouse.parquet` | 1 row per fulfillment hub | 6 | 3 | 2.58 KB | `int64`, `large_string` |
| 9 | `fact_orders.parquet` | 1 row per commercial order header | 1,250,000 | 15 | 39.04 MB | `int64`, `large_string`, `double` |
| 10 | `fact_sales.parquet` | 1 row per order line item | 5,000,000 | 22 | 251.46 MB | `int64`, `large_string`, `double` |
| 11 | `fact_returns.parquet` | 1 row per returned line item | 187,553 | 9 | 5.14 MB | `int64`, `large_string`, `double` |
| 12 | `fact_sales_targets.parquet` | 1 row per Month x Rep x Category | 120,000 | 7 | 2.63 MB | `int64`, `large_string`, `double` |
| 13 | `fact_inventory_snapshot.parquet` | 1 row per SKU x Hub x Month | 360,000 | 8 | 4.40 MB | `int64`, `large_string`, `double` |
| 14 | `fact_service.parquet` | 1 row per service / repair ticket | 120,000 | 10 | 3.20 MB | `int64`, `large_string`, `double` |
| **—** | **Canonical Total** | **14 Datasets** | **7,141,000** | — | **307.07 MB** | **All Inferred Cleanly** |

---

## 3. Bronze Lakehouse Ingestion Architecture

### 3.1 Design Principles
1. **Raw Fidelity (Zero Loss Ingestion)**: In the Medallion architecture, Bronze stores raw data in its original fidelity. Type conversions (e.g. `STRING` to `DATE` or `DECIMAL(14,2)`), surrogate key generation, and business cleaning are strictly reserved for Silver.
2. **ACID Transactionality**: Ingestion creates managed Delta tables (`USING DELTA`), granting instant ACID guarantees, transaction logging, time-travel history (`DESCRIBE HISTORY`), and Parquet columnar storage.
3. **Non-Destructive Idempotency**: All ingestion DDL employs `CREATE TABLE IF NOT EXISTS ... USING DELTA AS SELECT * FROM parquet.'...'`. Existing tables are never dropped or silently overwritten.
4. **Risk-Tiered Execution**: Ingestion is phased into 3 distinct batches (or a single master script with decoupled stages):
   - *Pilot*: `dim_channel` (5 rows) — tests volume pathing and permissions.
   - *Batch 1*: Small Reference Dimensions (6 tables, 3,442 rows total).
   - *Batch 2*: Large Dimensions & Secondary Facts (5 tables, 887,553 rows total).
   - *Batch 3*: High-Volume Transactions (2 tables, 6,250,000 rows total).
### 3.2 Safe Execution Protocol (3 Decoupled Steps in Master Script)
1. **Step 1: Preflight Existence Audit**: Executed in Databricks SQL Editor; returned **0 rows**. Confirmed zero pre-existing conflicting tables in `dentalkart_dw.bronze`. Cleared for Step 2.
2. **Step 2: Safe Ingestion DDL**: Executes `CREATE TABLE IF NOT EXISTS dentalkart_dw.bronze.<table_name> USING DELTA AS SELECT ...`. Existing tables are preserved untouched.
3. **Step 3: Unified Reconciliation**: Single CTE query auditing all 14 tables and outputting per-table counts plus the grand total summary row.

---

## 4. Ingestion & Validation Execution Matrix

| Dataset | Source Volume Accessible | Target Table Name | Expected Row Count | Actual Databricks Rows | Variance | Schema Verified | Ingestion Status |
|---|:---:|---|---:|---:|---:|:---:|:---:|
| `dim_channel` | 🟢 YES | `dentalkart_dw.bronze.dim_channel` | 5 | 5 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `dim_warehouse` | 🟢 YES | `dentalkart_dw.bronze.dim_warehouse` | 6 | 6 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `dim_supplier` | 🟢 YES | `dentalkart_dw.bronze.dim_supplier` | 50 | 50 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `dim_location` | 🟢 YES | `dentalkart_dw.bronze.dim_location` | 60 | 60 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `dim_salesperson` | 🟢 YES | `dentalkart_dw.bronze.dim_salesperson` | 500 | 500 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `dim_product` | 🟢 YES | `dentalkart_dw.bronze.dim_product` | 1,000 | 1,000 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `dim_date` | 🟢 YES | `dentalkart_dw.bronze.dim_date` | 1,826 | 1,826 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `dim_customer` | 🟢 YES | `dentalkart_dw.bronze.dim_customer` | 100,000 | 100,000 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `fact_sales_targets` | 🟢 YES | `dentalkart_dw.bronze.fact_sales_targets` | 120,000 | 120,000 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `fact_service` | 🟢 YES | `dentalkart_dw.bronze.fact_service` | 120,000 | 120,000 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `fact_returns` | 🟢 YES | `dentalkart_dw.bronze.fact_returns` | 187,553 | 187,553 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `fact_inventory_snapshot` | 🟢 YES | `dentalkart_dw.bronze.fact_inventory_snapshot` | 360,000 | 360,000 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `fact_orders` | 🟢 YES | `dentalkart_dw.bronze.fact_orders` | 1,250,000 | 1,250,000 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| `fact_sales` | 🟢 YES | `dentalkart_dw.bronze.fact_sales` | 5,000,000 | 5,000,000 | 0 | 🟢 Delta Managed | 🟢 PASS (Exact Parity) |
| **TOTALS** | **14 / 14** | **14 Tables** | **7,141,000** | **7,141,000** | **0** | **100% Verified** | 🟢 **PASSED (100% LEDGER PARITY)** |

---

## 5. Artifacts and Version Control

The following operational SQL scripts have been authored in [`scripts/`](file:///c:/Users/riyaz/Tableau/scripts/):

1. [`scripts/databricks_bronze_master_ingestion.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_bronze_master_ingestion.sql): Complete single-run master script executing safe ingestion of all 14 tables followed by unified 14-table row count reconciliation and grand total certification.
2. [`scripts/databricks_bronze_ingestion_step2_clean.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_bronze_ingestion_step2_clean.sql): Clean, executable version of Step 2 containing all 14 Bronze ingestion statements without formatting artifacts.
3. [`scripts/databricks_bronze_preflight.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_bronze_preflight.sql): Read-only namespace context, volume listing, and 1-row sample schema inference probes across all 14 datasets.
4. [`scripts/databricks_bronze_pilot.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_bronze_pilot.sql): Single-table ingestion of `dim_channel` with schema reflection and transaction history audit.
5. [`scripts/databricks_bronze_ingestion.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_bronze_ingestion.sql): 3-tiered batch ingestion of the remaining 13 tables with intermediate union verification queries.
6. [`scripts/databricks_bronze_validation.sql`](file:///c:/Users/riyaz/Tableau/scripts/databricks_bronze_validation.sql): Full 14-table parity reconciliation, key nullability audit, and financial ledger validation.

---

## 6. Known Considerations & Technical Learnings

* **Volume Naming Precision**: Initial UI setup noted `rawfiles`, but exact Unity Catalog naming was confirmed as `raw_files` (`/Volumes/dentalkart_dw/bronze/raw_files/`). Strict path conformance prevents `UC_VOLUME_NOT_FOUND`.
* **String Types in Parquet**: Arrow writes string columns as `large_string`, which Databricks maps to `STRING`. In the upcoming Silver layer, strings representing dates (`YYYY-MM-DD`) and financial amounts will be formally cast to strong SQL types (`DATE`, `DECIMAL(14,2)`).
* **Zero Duplication**: Using `CREATE TABLE IF NOT EXISTS ... AS SELECT ...` ensures that re-running the script will never append duplicate records to an already loaded Bronze table.
