# Tableau Hands-on Exercises — DentaKart Analytics (5-Year Experience Track)

> **Purpose**: This exercise suite covers senior-level Tableau concepts required to design high-performance, enterprise-grade dashboards across 2,000,000+ rows.

---

## Module 1: Data Modeling & Connection Strategy

### Task T-01: Logical Layer vs Physical Layer (Relationships vs Joins)
* **Goal**: Build the primary Tableau Data Source using Tableau's **Logical Layer (Relationships)**.
* **Exercise**:
  - Drag `Dim_Salesperson` into the canvas.
  - Relate `Fact_Sales` (grain: line item) and `Fact_Sales_Targets` (grain: rep x month).
  - Verify that pulling `SUM(Target_Sales)` and `SUM(Net_Sales)` onto a worksheet produces mathematically correct results without multiplying target rows.
  - Compare this against an older physical `INNER JOIN` or `LEFT JOIN` and observe the fan-out.

### Task T-02: Hyper Extract vs Live Connection Optimization
* **Goal**: Benchmark the performance difference on 2M rows between:
  1. Live SQL query against SQL Server / Databricks.
  2. Aggregated extract vs Single Table Extract vs Multiple Tables Extract.
  3. Analyze why **Single Table Extract** is typically fastest for Tableau Hyper engine compression.

---

## Module 2: Calculated Fields & LOD Expressions (FIXED, INCLUDE, EXCLUDE)

### Task T-03: Customer Acquisition Cohort Analysis (FIXED LOD)
* **Goal**: Calculate the First Purchase Date for each clinic:
  `{ FIXED [Customer ID] : MIN([Order Date]) }`
* **Exercise**:
  - Group customers by Acquisition Year-Quarter.
  - Track customer revenue retention curves across subsequent quarters.

### Task T-04: Category Benchmark Variance (EXCLUDE LOD)
* **Goal**: On a view displaying Sales by Sub-Category, compute the Category Average Benchmark:
  `{ EXCLUDE [Sub Category] : AVG([Net Sales]) }`
* **Exercise**:
  - Calculate the variance of each sub-category against its parent category average.

### Task T-05: Order-Level Aggregation for Basket Size (INCLUDE LOD)
* **Goal**: Compute the Average Order Value across clinics:
  `AVG({ INCLUDE [Order ID] : SUM([Net Sales]) })`
* **Exercise**:
  - Explain in an interview why `SUM([Net Sales]) / COUNTD([Order ID])` differs from `AVG({ INCLUDE [Order ID] : SUM([Net Sales]) })` when slicing across customer tiers.

### Task T-06: Order of Operations & Context Filters
* **Goal**: Build a Top 10 Customers by Sales chart with a Category filter.
* **Exercise**:
  - Demonstrate what happens when the Category filter is a standard Dimension Filter (computed AFTER the FIXED Top 10 filter).
  - Promote Category to **Context Filter** (grey pill) and explain how this forces the Top 10 to recalculate within the filtered category.

---

## Module 3: Advanced Table Calculations & Partitioning

### Task T-07: Running Cumulative Sales & Pacing
* **Goal**: Compute YTD Cumulative Net Sales using `RUNNING_SUM(SUM([Net Sales]))`.
* **Exercise**:
  - Set addressing and partitioning to restart every Fiscal Year.

### Task T-08: MoM and YoY Variance with LOOKUP
* **Goal**: Calculate YoY Percentage Growth using:
  `(ZN(SUM([Net Sales])) - LOOKUP(ZN(SUM([Net Sales])), -12)) / ABS(LOOKUP(ZN(SUM([Net Sales])), -12))`
* **Exercise**:
  - Properly hide (not filter out) the first 12 months using a `LOOKUP(MIN(Date), 0)` table calc filter so historical data is retained in the cache.

### Task T-09: Pareto 80/20 Distribution Curve
* **Goal**: Build a dual-axis Pareto chart showing:
  - Bars: Individual product sales descending.
  - Line: Cumulative % of total sales (`RUNNING_SUM(SUM([Net Sales])) / TOTAL(SUM([Net Sales]))`).
  - Add reference lines at 80% revenue and 20% SKU count.

---

## Module 4: Dynamic Interactivity (Parameters & Actions)

### Task T-10: Dynamic Metric Selector Parameter
* **Goal**: Allow users to swap the primary chart measure between Net Sales, Gross Profit, Order Count, and Return Rate % via a single dropdown parameter.

### Task T-11: Dynamic Top N with "Others" Grouping using Sets
* **Goal**: Build a parameter-driven Top N (e.g. Top 5, 10, 20) with an automatic `[Others]` bucket for long-tail clinics using Sets and Calculated Fields.

### Task T-12: Asymmetric Drill-Down using Set Actions
* **Goal**: In a category hierarchy, allow the user to click on "Dental Equipment" to expand only that category into sub-categories without expanding other categories.
