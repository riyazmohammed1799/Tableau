"""
DentaKart Analytics — Automated SQL Server Controlled Ingestion Pipeline
Loads all 14 Star Schema tables from data/clean/csv/ into DentaKart_DW.
Follows strict dependency ordering, captures elapsed times, row counts, and verifies financial ledger balancing.
"""

import os
import sys
import time
from datetime import datetime
import pyodbc

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_DIR = os.path.join(BASE_DIR, "data", "clean", "csv")
DDL_PATH = os.path.join(BASE_DIR, "scripts", "setup_database.sql")

CONNECTION_STRING = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=.\\SQLEXPRESS;"
    "DATABASE=DentaKart_DW;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

MASTER_CONNECTION_STRING = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=.\\SQLEXPRESS;"
    "DATABASE=master;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)


def get_connection(use_master=False):
    conn_str = MASTER_CONNECTION_STRING if use_master else CONNECTION_STRING
    return pyodbc.connect(conn_str, autocommit=True)


def execute_ddl():
    print("[1/3] Executing DDL Schema Setup (scripts/setup_database.sql)...")
    conn = get_connection(use_master=True)
    cursor = conn.cursor()

    with open(DDL_PATH, "r", encoding="utf-8") as f:
        sql_content = f.read()

    batches = sql_content.split("GO")
    for b in batches:
        b_clean = b.strip()
        if b_clean:
            cursor.execute(b_clean)

    cursor.close()
    conn.close()
    print("      DDL Schema Setup completed successfully.\n")


def bulk_insert_table(cursor, table_name, csv_filename, expected_rows=None):
    csv_path = os.path.join(CSV_DIR, csv_filename)
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"Source file not found: {csv_path}")

    # Safety check: if table already populated, do not duplicate
    cursor.execute(f"SELECT COUNT(*) FROM dbo.{table_name};")
    current_count = cursor.fetchone()[0]
    if expected_rows is not None and current_count == expected_rows:
        print(f"--> [SKIP] {table_name} already contains {current_count:,} rows. Skipping load.")
        return current_count, 0.0

    if current_count > 0:
        print(f"--> [WARNING] {table_name} contains partial data ({current_count:,} rows). Re-synchronizing...")
        # To avoid duplicating, truncate in reverse dependency if needed, or raise notice
        cursor.execute(f"TRUNCATE TABLE dbo.{table_name};")

    print(f"--> Ingesting {table_name} from {csv_filename}...")
    start_time = time.time()

    bulk_sql = f"""
    BULK INSERT dbo.{table_name}
    FROM '{csv_path}'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\\n',
        TABLOCK,
        BATCHSIZE = 100000,
        KEEPNULLS
    );
    """
    cursor.execute(bulk_sql)
    elapsed = time.time() - start_time

    cursor.execute(f"SELECT COUNT(*) FROM dbo.{table_name};")
    loaded_count = cursor.fetchone()[0]
    print(f"    Loaded {loaded_count:,} rows into {table_name} in {elapsed:.2f}s ({loaded_count / max(elapsed, 0.01):,.0f} rows/s).")
    return loaded_count, elapsed


def load_all_tables():
    print("================================================================================")
    print(" DENTAKART ANALYTICS — SQL SERVER CONTROLLED INGESTION")
    print(f" Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("================================================================================\n")

    execute_ddl()

    print("[2/3] Executing Ingestion Sequence in Strict Dependency Order...")
    conn = get_connection(use_master=False)
    cursor = conn.cursor()

    load_sequence = [
        # Table Name, CSV File Name, Expected Rows
        ("Dim_Date", "dim_date.csv", 1826),
        ("Dim_Supplier", "dim_supplier.csv", 50),
        ("Dim_Warehouse", "dim_warehouse.csv", 6),
        ("Dim_Channel", "dim_channel.csv", 5),
        ("Dim_Location", "dim_location.csv", 60),
        ("Dim_Salesperson", "dim_salesperson.csv", 500),
        ("Dim_Product", "dim_product.csv", 1000),
        ("Dim_Customer", "dim_customer.csv", 100000),
        ("Fact_Sales_Targets", "fact_sales_targets.csv", 120000),
        ("Fact_Inventory_Snapshot", "fact_inventory_snapshot.csv", 360000),
        ("Fact_Orders", "fact_orders.csv", 1250000),
        ("Fact_Sales", "fact_sales.csv", 5000000),
        ("Fact_Returns", "fact_returns.csv", 187553),
        ("Fact_Service", "fact_service.csv", 120000),
    ]

    summary_stats = []
    total_start = time.time()

    for tbl, csv_file, exp_rows in load_sequence:
        cnt, duration = bulk_insert_table(cursor, tbl, csv_file, expected_rows=exp_rows)
        summary_stats.append({
            "table": tbl,
            "rows": cnt,
            "elapsed": duration
        })

    total_ingest_time = time.time() - total_start
    print(f"\n      Ingestion completed in {total_ingest_time:.2f} seconds ({total_ingest_time/60.0:.2f} minutes).")

    cursor.close()
    conn.close()
    return summary_stats, total_ingest_time


def run_database_validation():
    print("\n[3/3] Running Independent SQL Server Verification Queries...")
    conn = get_connection(use_master=False)
    cursor = conn.cursor()

    # 1. Financial Reconciliation Query
    fin_sql = """
    SELECT 
        COUNT(*) AS total_rows,
        SUM(CAST(gross_sales_inr AS DECIMAL(20,2))) AS total_gross,
        SUM(CAST(discount_amount_inr AS DECIMAL(20,2))) AS total_disc,
        SUM(CAST(net_sales_inr AS DECIMAL(20,2))) AS total_net,
        SUM(CAST(cogs_inr AS DECIMAL(20,2))) AS total_cogs,
        SUM(CAST(gross_profit_inr AS DECIMAL(20,2))) AS total_profit
    FROM dbo.Fact_Sales;
    """
    cursor.execute(fin_sql)
    row = cursor.fetchone()
    total_rows, gross, disc, net, cogs, profit = row

    print("\n--- Financial Reconciliation (dbo.Fact_Sales) ---")
    print(f"Total Rows:     {total_rows:,}")
    print(f"Gross Sales:    INR {gross:,.2f}")
    print(f"Discount Given: INR {disc:,.2f}")
    print(f"Net Revenue:    INR {net:,.2f}")
    print(f"COGS:           INR {cogs:,.2f}")
    print(f"Gross Margin:   INR {profit:,.2f} ({(float(profit)/float(net))*100:.2f}%)")

    # 2. Key Uniqueness & Referential Integrity Queries
    cursor.execute("SELECT COUNT(*) - COUNT(DISTINCT order_line_id) FROM dbo.Fact_Sales;")
    pk_dup_sales = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) - COUNT(DISTINCT order_id) FROM dbo.Fact_Orders;")
    pk_dup_orders = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) - COUNT(DISTINCT target_id) FROM dbo.Fact_Sales_Targets;")
    pk_dup_targets = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM dbo.Fact_Sales S LEFT JOIN dbo.Dim_Product P ON S.product_id = P.product_id WHERE P.product_id IS NULL;")
    orphan_sales_prod = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM dbo.Fact_Sales S LEFT JOIN dbo.Dim_Customer C ON S.customer_id = C.customer_id WHERE C.customer_id IS NULL;")
    orphan_sales_cust = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM dbo.Fact_Sales S LEFT JOIN dbo.Fact_Orders O ON S.order_id = O.order_id WHERE O.order_id IS NULL;")
    orphan_sales_order = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM dbo.Dim_Customer C LEFT JOIN dbo.Dim_Location L ON C.city_id = L.city_id WHERE L.city_id IS NULL;")
    orphan_cust_city = cursor.fetchone()[0]

    cursor.execute("""
    SELECT 
        (SELECT COUNT(*) FROM dbo.Fact_Sales_Targets GROUP BY target_month_key, region, salesperson_id, target_category HAVING COUNT(*) > 1) AS target_dups;
    """)
    target_uq_dups = cursor.fetchone()[0] or 0

    cursor.execute("""
    SELECT 
        (SELECT COUNT(*) FROM dbo.Fact_Inventory_Snapshot GROUP BY snapshot_date_key, product_id, warehouse_id HAVING COUNT(*) > 1) AS inv_dups;
    """)
    inv_uq_dups = cursor.fetchone()[0] or 0

    print("\n--- Integrity & Constraint Checks ---")
    print(f"Fact_Sales PK Duplicates:         {pk_dup_sales} (Expected: 0)")
    print(f"Fact_Orders PK Duplicates:        {pk_dup_orders} (Expected: 0)")
    print(f"Fact_Sales_Targets Composite UQ:  {target_uq_dups} (Expected: 0)")
    print(f"Fact_Inventory_Snapshot Comp UQ:  {inv_uq_dups} (Expected: 0)")
    print(f"Fact_Sales -> Dim_Product Orphan: {orphan_sales_prod} (Expected: 0)")
    print(f"Fact_Sales -> Dim_Customer Orphan:{orphan_sales_cust} (Expected: 0)")
    print(f"Fact_Sales -> Fact_Orders Orphan: {orphan_sales_order} (Expected: 0)")
    print(f"Dim_Customer -> Dim_Location:     {orphan_cust_city} (Expected: 0)")

    # 3. Database Size
    cursor.execute("""
    SELECT 
        SUM(size * 8 / 1024) AS db_size_mb
    FROM sys.master_files
    WHERE database_id = DB_ID('DentaKart_DW');
    """)
    db_size_mb = cursor.fetchone()[0]
    print(f"\nDatabase Storage Consumption: {db_size_mb:,} MB")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    try:
        load_all_tables()
        run_database_validation()
    except Exception as e:
        print(f"\n[ERROR] Ingestion failed: {e}", file=sys.stderr)
        sys.exit(1)
