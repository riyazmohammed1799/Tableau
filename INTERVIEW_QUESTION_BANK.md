# Technical Interview Question Bank (5-Year Experience Level) — DentaKart Analytics

> **Format**: When we reach Phase 13 (or when you request a mock interview checkpoint), questions will be presented **one at a time**.
> Your answers will be graded on a 5-point scale:
> - **Score 1**: Basic textbook definition; lacks enterprise understanding.
> - **Score 2**: Understands syntax but misses real-world caveats, edge cases, or performance implications.
> - **Score 3**: Competent developer; provides a working solution but lacks architectural depth.
> - **Score 4**: Strong senior developer; mentions order of operations, execution plan impact, and indexing/compression.
> - **Score 5**: Principal/Lead level; explains trade-offs, Tableau cache internals, database execution plans, and communicates with executive clarity.

---

## Domain 1: Multi-Fact Modeling & Grain Discrepancies (Core Interview Scenarios)

1. **Q-MOD-01 (Fact-to-Fact Duplication)**: 
   *"During an executive sales review, a stakeholder reports that total sales revenue appears to have doubled after your latest data model update. You investigate and notice someone joined `Fact_Sales` to `Fact_Returns`. Why did the sales amount double after joining returns, and how do you resolve it at the architecture level?"*
2. **Q-MOD-02 (Quota Fan-Out & Target Inflation)**: 
   *"A sales director points out that a representative with a ₹10,00,000 monthly quota is showing a total target of ₹80,00,00,000 in your Tableau workbook. Why did the target duplicate, and what are the exact steps in SQL and in Tableau Logical Layer to ensure targets are never inflated?"*
3. **Q-MOD-03 (Multiple Fact Modeling Across Grains)**: 
   *"In our enterprise architecture, we have Order Lines (5M rows), Monthly Quotas (120k rows), Returns (220k rows), and Inventory Snapshots (72k rows). How do you model multiple fact tables with fundamentally different grains in Tableau without causing Cartesian explosions or double counting?"*
4. **Q-MOD-04 (Kimball Star Schema vs Inmon 3NF)**: 
   *"Why is a Kimball Star Schema with conformed dimensions preferred for BI tools like Tableau over a normalized 3NF schema or a single wide flattened table?"*
5. **Q-MOD-05 (Slowly Changing Dimensions)**: 
   *"If a dental sales representative moves from the West Region to the North Region halfway through the fiscal year, how do you handle this SCD scenario so historical sales remain credited to West, but new sales and quotas accrue to North?"*

---

## Domain 2: SQL & Database Engine Internals (SQL Server 2025 Express)

6. **Q-SQL-01 (Columnstore vs Rowstore Internals)**: 
   *"We are running SQL Server Express with a 1.4 GB memory limit on 5 million rows of sales data. How does a Clustered Columnstore Index (CCI) achieve 8x compression and eliminate buffer pool thrashing compared to a standard B-Tree Clustered Index?"*
7. **Q-SQL-02 (Window Functions Execution Mechanics)**: 
   *"What is the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`? How does SQL Server physically process these in terms of memory grants, sorting, and tempdb spills?"*
8. **Q-SQL-03 (SARGability & Index Seeks)**: 
   *"Why does `WHERE YEAR(order_date) = 2024` cause a full table scan, and how do you rewrite it as a SARGable predicate to leverage index seeks?"*
9. **Q-SQL-04 (Deduplication of Large Volumes)**: 
   *"Given a webhook orders staging table with 5 million rows containing intermittent duplicates from network retries, write the most efficient T-SQL query using CTE and `ROW_NUMBER()` to delete duplicates while retaining the earliest record."*

---

## Domain 3: Tableau Core Modeling & LOD Expressions

10. **Q-TAB-01 (Logical vs Physical Layer)**: 
    *"What is the architectural difference between Tableau's Logical Layer (Relationships / noodles) and Physical Layer (Joins)? How does Tableau's query engine generate queries under the hood when two tables are related?"*
11. **Q-TAB-02 (Order of Operations)**: 
    *"Recite the exact Tableau Order of Operations from top to bottom. Where do Context Filters, Dimension Filters, and Measure Filters sit relative to FIXED and INCLUDE/EXCLUDE LODs?"*
12. **Q-TAB-03 (FIXED vs SQL Solution)**: 
    *"Why did you use a FIXED LOD in Tableau instead of solving the calculation upstream in SQL? What are the architectural trade-offs between flexibility in Tableau and pre-computation in the database?"*
13. **Q-TAB-04 (INCLUDE vs EXCLUDE in Practice)**: 
    *"In what scenario does an INCLUDE LOD return a different result when the visual level of detail changes, while a FIXED LOD remains constant?"*

---

## Domain 4: Table Calculations & Advanced Interactivity

14. **Q-TC-01 (Addressing vs Partitioning)**: 
    *"Explain 'Addressing' (Compute Using) versus 'Partitioning' in Tableau Table Calculations. How do they determine how `RUNNING_SUM` and `LOOKUP` calculate across dimensions?"*
15. **Q-TC-02 (Late Filtering for YoY Growth)**: 
    *"When calculating Year-over-Year (YoY) Growth using `LOOKUP`, if the user filters the dashboard to show only 2025, the calculation breaks because 2024 is filtered out. How do you implement late filtering to preserve the previous year in the cache?"*
16. **Q-TC-03 (Dynamic Top N with Others)**: 
    *"How do you build a parameter-driven Top N customer ranking with an automatic '[Others]' rollup using Sets and Calculated Fields?"*

---

## Domain 5: Performance Tuning & Optimization (10 Scenarios)

17. **Q-OPT-01 (Live vs Extract Architectural Decision)**: 
    *"Why did you choose a Tableau Hyper Extract instead of a Live connection for your 5-million-row sales dashboard? Under what business circumstances would you be forced to revert to a Live connection?"*
18. **Q-OPT-02 (Troubleshooting Slow Dashboard Refresh)**: 
    *"How would you troubleshoot a dashboard that became critically slow after a scheduled data refresh? Walk me through your step-by-step diagnostic process using the Tableau Performance Recorder."*
19. **Q-OPT-03 (High-Cardinality Filter Toxic Overhead)**: 
    *"Why is a quick filter containing 100,000 clinic names toxic to dashboard render time, and how do you remediate it without sacrificing user experience?"*
20. **Q-OPT-04 (Mark Saturation)**: 
    *"A scatter plot renders 50,000 marks and locks up the browser. How do you redesign the visualization to convey the same business insight with fewer than 500 marks?"*

---

## Domain 6: Enterprise Security, Governance & Production Support

21. **Q-SEC-01 (Dynamic Row-Level Security)**: 
    *"How do you implement dynamic Row-Level Security (RLS) in Tableau using an Entitlement Table and `USERNAME()` without duplicating workbooks for different regional sales directors?"*
22. **Q-SEC-02 (RLS Join Performance Penalty)**: 
    *"What is the performance penalty of joining an entitlement table to a 5-million-row fact table, and how can security predicates be optimized?"*
23. **Q-ARC-01 (Lakehouse vs EDW Architectural Comparison)**: 
    *"When would you choose Databricks (Delta Lake Medallion Architecture) over a traditional Microsoft SQL Server EDW? Compare them across data volume, ACID transactions, maintenance overhead, and BI query latency."*
24. **Q-INC-01 (Production Incident Triage)**: 
    *"On Monday at 8:00 AM, the CFO reports that yesterday's Net Sales BAN shows ₹0 on the Executive Dashboard. How do you communicate, triage, and resolve this production incident?"*
