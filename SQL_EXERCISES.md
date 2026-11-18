# SQL Mastery Exercises — DentaKart Analytics (5-Year Experience Track)

> **Instructions**: Write and execute your SQL queries against `DentaKart_DW` (SQL Server) or Databricks SQL.
> Save your written queries in `sql_solutions/`. 
> Do not ask for the answers immediately. Attempt each task, inspect the results, check the execution plan, and submit your SQL for senior code review!

---

## Tier 1: Core Aggregations, Filtering, and Multi-Table Joins (Tasks 1 – 5)

### Task 1: Annual Category Revenue & Margin Realization
* **Objective**: Calculate Total Quantity Sold, Total Gross Sales, Total Discount Amount, Total Net Sales, Total Gross Profit, and Gross Margin % by `Year` and `Product Category`.
* **Requirements**:
  - Filter out cancelled orders.
  - Sort by Year ascending, then Net Sales descending.
  - Currency values formatted to 2 decimal places.

### Task 2: Tier-wise City Penetration & Discount Distribution
* **Objective**: Evaluate whether higher discounts correlate with higher sales volume across Indian city tiers (`Tier 1`, `Tier 2`, `Tier 3`).
* **Requirements**:
  - Output: `city_tier`, `total_clinics_count`, `active_buying_clinics`, `total_net_sales`, `avg_discount_pct`, and `avg_order_value`.
  - Use conditional aggregation to count clinics with at least 1 purchase in 2025.

### Task 3: Omnichannel Sales Performance & Delivery Lag
* **Objective**: Compare the 5 sales channels (`Direct Field Sales`, `B2B eCommerce Portal`, `Inside Sales`, `Distributor Network`, `Institutional Tender`).
* **Requirements**:
  - Output channel name, order count, total net sales, average fulfillment days (`DATEDIFF` between `order_date` and `shipping_date`), and cancellation rate % (`Cancelled orders / Total orders * 100`).

### Task 4: High-Discount Anomaly Audit (Leakage Detection)
* **Objective**: Identify all sales transactions where the discount applied exceeded the customer's tier allowance:
  - Platinum: > 25%
  - Gold: > 15%
  - Silver: > 8%
  - Bronze: > 5%
* **Requirements**:
  - Return `order_id`, `customer_name`, `customer_tier`, `product_name`, `discount_pct`, `salesperson_name`, and excess discount amount in ₹.

### Task 5: Warehouse Fulfillment & Product Returns Breakdown
* **Objective**: Find the return rate percentage by Fulfillment Warehouse and Product Category.
* **Requirements**:
  - Join `Fact_Sales`, `Fact_Returns`, `Dim_Warehouse`, and `Dim_Product`.
  - Calculate `total_sold_qty`, `total_returned_qty`, `return_rate_pct`, and `net_refunded_amount`.
  - Filter for categories with more than 1,000 returned units.

---

## Tier 2: Window Functions & Analytical Ranking (Tasks 6 – 10)

### Task 6: Top 3 Sales Representatives per Region by Year
* **Objective**: Find the top 3 revenue-generating sales representatives in each geographic region for each calendar year.
* **Requirements**:
  - Use `DENSE_RANK()` partitioned by `region` and `calendar_year`.
  - Output: Year, Region, Rank, Salesperson Name, Net Revenue ₹, and Category with their highest sales.

### Task 7: Month-over-Month (MoM) Growth using LAG
* **Objective**: Compute the monthly Net Sales and the MoM sales growth percentage for the `Dental Equipment` category across 2024 and 2025.
* **Requirements**:
  - Use `LAG()` over monthly sales.
  - Formula: `((Current_Month - Previous_Month) / Previous_Month) * 100`.
  - Properly handle the first month NULL edge case.

### Task 8: Running Cumulative Sales & 90-Day Moving Average
* **Objective**: For the year 2025, calculate the daily Net Sales, the running year-to-date cumulative total, and a 7-day rolling moving average.
* **Requirements**:
  - Use `SUM() OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.
  - Use `AVG() OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)`.

### Task 9: First-Time Purchase vs Repeat Purchase Order Identification
* **Objective**: Label every order in `Fact_Orders` as either `'First Order'` or `'Repeat Order'` for that customer.
* **Requirements**:
  - Use `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date)`.
  - Compare performance between `ROW_NUMBER()` vs `MIN(order_date) OVER (PARTITION BY customer_id)`.

### Task 10: Customer Recency, Frequency, and Monetary (RFM) Segmentation
* **Objective**: Compute RFM raw scores for all customers as of December 31, 2025:
  - Recency: Days since last order date.
  - Frequency: Distinct count of orders placed.
  - Monetary: Total Net Sales ₹.
  - Use `NTILE(5)` to assign R, F, and M quintile scores (1 to 5).

---

## Tier 3: CTEs, Subqueries, and Complex Cohort Analysis (Tasks 11 – 15)

### Task 11: 60-Day Customer Repurchase Cohort Retention
* **Objective**: For all customers whose first purchase was in Q1 2023, what percentage made a repeat purchase within 60 days?
* **Requirements**:
  - Use CTEs to isolate the Q1 2023 cohort.
  - Join back to subsequent orders within 60 days of acquisition date.

### Task 12: Sales Target Attainment & Commission Tier Assignment
* **Objective**: Join `Fact_Sales` and `Fact_Sales_Targets` to compute monthly quota attainment % by salesperson and category.
* **Requirements**:
  - **Avoid duplicate counting!** Pre-aggregate sales in a CTE before joining to targets.
  - Assign commission payout tiers:
    - `< 80%`: 0% bonus
    - `80% - 99%`: 5% bonus
    - `100% - 120%`: 10% bonus
    - `> 120%`: 15% bonus

### Task 13: Deduplication of Webhook Transaction Logs
* **Objective**: Given a staging table with duplicated rows caused by network retries, write a query using CTE and `ROW_NUMBER()` to delete or isolate exact duplicates while preserving the earliest record.

### Task 14: Market Basket Affinity (Product Co-Purchase Analysis)
* **Objective**: Find the top 10 most frequently co-purchased product pairs in the same order.
* **Requirements**:
  - Self-join `Fact_Sales` on `order_id` where `product_id_A < product_id_B`.
  - Count distinct orders containing both items.

### Task 15: Churned Customer Identification (Lapsed Accounts)
* **Objective**: Identify all clinics that ordered consumables regularly (>= 3 orders in 2023) but placed zero orders in 2024–2025.
* **Requirements**:
  - Output customer name, city, 2023 total revenue, last order date, and assigned salesperson.

---

## Tier 4: Supply Chain, Returns, and Service Analytics (Tasks 16 – 20)

### Task 16: Capital Equipment Warranty Claim Rate
* **Objective**: For all capital equipment units sold in 2023, calculate the percentage that generated a `Warranty Repair` ticket in `Fact_Service` within 365 days of installation.

### Task 17: Inventory Days of Inventory on Hand (DOH) & Reorder Alerts
* **Objective**: Using `Fact_Inventory_Snapshot` for the latest month (Dec 2025), calculate the DOH for each SKU in each warehouse.
* **Requirements**:
  - Compute average daily sales over the preceding 90 days.
  - Flag products with `closing_stock_qty < reorder_point_qty`.

### Task 18: Restocking Fee Recovery vs Refund Loss
* **Objective**: Calculate Net Return Loss by Category: `SUM(refund_amount_inr) - SUM(restocking_fee_inr)`. Rank categories by return loss.

### Task 19: Average Service Resolution Time (MTTR) by Product Brand
* **Objective**: Compute Mean Time To Repair (in days) for equipment service tickets by equipment brand and service type.

### Task 20: Salesperson Quota Consistency (Streak Analysis)
* **Objective**: Find salespeople who met or exceeded their quota (Attainment >= 100%) for 6 consecutive months or more.
* **Requirements**:
  - Use `LAG()` or Island-and-Gaps window function logic.

---

## Tier 5: Query Optimization, Index Benchmarking & Execution Plans (Tasks 21 – 25)

### Task 21: Columnstore vs Rowstore Performance Benchmark
* **Objective**: Run an aggregate query across all 2 million rows of `Fact_Sales` on a table with a standard B-Tree Clustered Index vs a Clustered Columnstore Index. Record CPU time, logical reads, and elapsed time using `SET STATISTICS IO, TIME ON`.

### Task 22: SARGability & Predicate Optimization
* **Objective**: Refactor a non-SARGable query containing `WHERE YEAR(order_date) = 2024 AND MONTH(order_date) = 10` into a SARGable range query (`WHERE order_date >= ... AND order_date < ...`). Compare execution plan index seeks vs index scans.

### Task 23: Implicit Data Type Conversion Bottlenecks
* **Objective**: Demonstrate the performance penalty when joining or filtering on a `VARCHAR` column with an `NVARCHAR` parameter. Inspect the execution plan for `CONVERT_IMPLICIT`.

### Task 24: Fact-to-Fact Join Cartesian Fan-Out Demonstration
* **Objective**: Write two queries comparing:
  1. A naive direct join between `Fact_Sales` and `Fact_Sales_Targets`.
  2. A pre-aggregated CTE join.
  Show how the naive join produces grossly inflated numbers.

### Task 25: Partition Pruning & Lakehouse Z-Order Benchmark
* **Objective**: In Databricks / Spark SQL, measure the file scan reduction of querying a partitioned and Z-Ordered Delta table versus an unpartitioned table.
