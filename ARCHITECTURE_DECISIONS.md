# Architectural Decision Records (ADR) — DentaKart Analytics

## ADR-001: Sequential Dual-Track Platform Strategy (SQL Server EDW First, Databricks Lakehouse Second)
* **Date**: October 2026
* **Status**: Accepted
* **Context**: The candidate is preparing for senior (5-year) Tableau Developer and BI Engineer interviews. The candidate requested completing the full end-to-end SQL Server → Tableau workflow first, and subsequently replicating the data engineering workflow in Databricks to compare architectures directly without duplicate business logic.
* **Decision**: 
  - Produce a single canonical, deterministic dataset in Python streamed to both CSV (for SQL Server `BULK INSERT`) and Snappy Parquet (for Databricks Delta Lake).
  - Implement **Track A (SQL Server)** first: Load into relational database `DentaKart_DW`, apply Star Schema, Clustered Columnstore Indexes, and SQL Reporting Views, connecting to Tableau.
  - Implement **Track B (Databricks)** second: Use the canonical Parquet data as the Bronze layer, transform into Silver and Gold Delta tables, and compare query generation, compression, and refresh latency against SQL Server.
* **Consequences**: Guarantees a deep, non-fragmented mastery of T-SQL and relational EDW modeling before transitioning to Spark and Delta Lake paradigms.

---

## ADR-002: Fact Table Granularity and Anti-Fan-Out Separation
* **Date**: October 2026
* **Status**: Accepted
* **Context**: Direct joins between Orders, Sales Line Items (5M rows), Returns, Targets, and Inventory cause severe Cartesian fan-out and double-counting in Tableau aggregations.
* **Decision**: Maintain distinct, conformed fact tables at strictly documented grains:
  1. `Fact_Orders`: Order Header grain (`order_id`). Expected ~1,250,000 rows.
  2. `Fact_Sales`: Order Line grain (`order_line_id`). Expected ~5,000,000 rows.
  3. `Fact_Returns`: Return event line grain (`return_id`). Expected ~220,000 rows.
  4. `Fact_Sales_Targets`: `Month x Region x Salesperson x Product Category` (`target_id` PK, UQ on `target_month_key, region, salesperson_id, category`). Expected 120,000 rows.
  5. `Fact_Inventory_Snapshot`: Periodic stock grain (`Product x Warehouse x Month End`). Expected ~72,000 rows.
  6. `Fact_Service`: Ticket grain (`service_ticket_id`). Expected ~120,000 rows.
* **Consequences**: Multi-fact models in Tableau are constructed using **Logical Layer Relationships (Noodles)** rather than physical joins, ensuring Tableau aggregates each table at its native grain without multiplying rows.

---

## ADR-003: Vectorized Streaming Batch Generation for 5M+ Rows
* **Date**: October 2026
* **Status**: Accepted
* **Context**: Generating ~5,000,000 sales lines with 1.25M orders in Python row loops causes high memory pressure and slow execution (>45 minutes).
* **Decision**: Implement a chunked generator using NumPy vectorized array generation and streaming directly to disk in batches of 250,000 rows with deterministic seed `SEED = 42`. The script is parameter-driven (`--rows 5000000`, `--rows 10000000`) to support future 10M+ scalability.
* **Consequences**: Generates 5M+ rows in under 75 seconds with peak memory consumption under 350MB RAM. Guarantees reproducible datasets across reruns.

---

## ADR-004: Local Database Engine — Microsoft SQL Server 2025 Express Architecture & Indexing Strategy
* **Date**: October 2026
* **Status**: Accepted
* **Context**: System inspection detected `Microsoft SQL Server 2025 Express Edition (v17.0.1000.7 / SQLEXPRESS)` installed locally on the developer machine. SQL Server Express has distinct resource boundaries:
  - Max Database Size: **10 GB per database** (MDF file).
  - Buffer Cache Limit: **1,410 MB (~1.4 GB)**.
  - Max Compute: Lesser of 1 socket or 4 CPU cores.
  - SQL Server Agent is disabled.
* **Decision**: 
  - **Storage Sizing for 5M Rows**:
    - In raw uncompressed rowstore, 5,000,000 rows across `Fact_Sales` and related tables will consume ~1.2 GB to 1.5 GB. This safely uses only ~15% of the 10 GB Express limit.
    - Under a **Clustered Columnstore Index (CCI)**, compression reaches ~6x to 8x, shrinking `Fact_Sales` down to **~180 MB – 220 MB**, which easily fits entirely inside the 1.4 GB buffer cache, delivering blazing sub-second query performance!
  - **Memory & Ingestion Safety**:
    - Ingest data via `BULK INSERT` into a heap staging table with `TABLOCK` and `BATCHSIZE = 100000`.
    - Build the Clustered Columnstore Index post-load with `MAXDOP = 2` to prevent memory grant starvation within the 1.4 GB limit.
    - Provide a dual indexing exercise for the candidate: compare query execution plans and logical reads between a traditional **B-Tree Clustered Index** and a **Clustered Columnstore Index**.
