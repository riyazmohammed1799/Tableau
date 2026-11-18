# DentaKart Analytics — Enterprise BI & Tableau Engineering Master Project

## Project Overview
**DentaKart Analytics** is an enterprise-scale analytics platform designed for a fictional nationwide dental equipment and clinical consumables distribution company operating across India. 

The company supplies over 1,000 dental equipment and consumable products to more than 100,000 dental clinics, multi-specialty dental hospital chains, dental colleges, diagnostic labs, and sub-distributors across 50+ Indian cities.

This project is structured as an end-to-end hands-on training ground simulating **5 years of senior experience** as a Tableau Developer and BI Data Engineer.

---

## Architecture & Phased Execution Strategy
This project is built on a **Dual-Track Enterprise Data Architecture**, executed sequentially:
1. **Track A (SQL Server EDW → Tableau)**: Completed end-to-end first.
2. **Track B (Databricks Lakehouse → Tableau)**: Reproduced second to benchmark and compare lakehouse patterns against relational data warehousing.

```
                              [ Source Generator: scripts/generate_data.py ]
                                (Deterministic Seed=42, ~5M Sales Records)
                                                    |
                         +--------------------------+--------------------------+
                         | (Track A - Execute 1st)                             | (Track B - Execute 2nd)
                         v                                                     v
            [ Track A: SQL Server EDW ]                            [ Track B: Databricks Lakehouse ]
            - Database: DentaKart_DW                               - Medallion Architecture:
            - Schema: Raw / Dim / Fact                             - Bronze (Raw Parquet / Delta)
            - Clustered Columnstore Indexes                        - Silver (Cleaned / Conformed)
            - Partitioning & Analytical Views                      - Gold (Aggregated Business Marts)
                         |                                                     |
                         +--------------------------+--------------------------+
                                                    |
                                                    v
                                      [ Tableau Desktop & Cloud ]
                                      - Logical Layer (Relationships / Noodles)
                                      - Hyper Extracts & Live Queries
                                      - 8 Executive & Operational Dashboards
                                      - Enterprise Security (RLS & Governance)
```

---

## Key Scale Metrics & Mathematical Derivations
* **Fact_Sales / Fact_Order_Lines**: **~5,000,000 line items** (configurable to 10M+)
* **Fact_Orders**: **~1,250,000 order headers** ($\sim 4.0\text{ lines/order}$)
* **Dim_Product**: 1,000 dental equipment & consumable SKUs (4 core target categories + non-targeted lines)
* **Dim_Customer**: 100,000 dental practices, clinics, hospitals, and colleges
* **Dim_Location**: 60 Indian cities across 5 customer geographic regions and 3 tiers
* **Dim_Salesperson**: 500 sales representatives across 5 sales territory regions
* **Dim_Date**: 5 full historical years (2021 – 2025: 1,826 days)
* **Fact_Returns**: ~220,000 return transactions ($\sim 4.4\%$ return rate)
* **Fact_Sales_Targets**: **120,000 rows** ($60 \text{ months} \times 500 \text{ reps} \times 4 \text{ target categories}$)
* **Fact_Inventory_Snapshot**: **360,000 rows** ($1,000 \text{ products} \times 6 \text{ warehouses} \times 60 \text{ month-ends}$)
* **Fact_Service**: ~120,000 equipment breakdown repairs, maintenance, and warranty tickets

---

## Project Documentation Navigation
* [PROJECT_SUMMARY.md](file:///c:/Users/riyaz/Tableau/PROJECT_SUMMARY.md): Executive Summary, Architecture & Parity Matrix
* [PROJECT_PLAN.md](file:///c:/Users/riyaz/Tableau/PROJECT_PLAN.md): Detailed 14-Phase Roadmap
* [BUSINESS_REQUIREMENTS.md](file:///c:/Users/riyaz/Tableau/BUSINESS_REQUIREMENTS.md): Business Objectives, Stakeholders, KPIs & Acceptance Criteria
* [DATA_DICTIONARY.md](file:///c:/Users/riyaz/Tableau/DATA_DICTIONARY.md): Complete Data Dictionary & Schema Definitions (5M Scale)
* [DATA_MODEL.md](file:///c:/Users/riyaz/Tableau/DATA_MODEL.md): Star Schema, Grain Definitions & Relationship Architecture
* [DATA_GENERATION_PLAN.md](file:///c:/Users/riyaz/Tableau/DATA_GENERATION_PLAN.md): Vectorized Generation Engine Specifications
* [DATA_QUALITY_RULES.md](file:///c:/Users/riyaz/Tableau/DATA_QUALITY_RULES.md): Data Quality Matrix & Controlled Dirty Dataset Spec
* [SQL_EXERCISES.md](file:///c:/Users/riyaz/Tableau/SQL_EXERCISES.md): Hands-on SQL Tasks (Basic to Advanced Window Functions & CTEs)
* [TABLEAU_EXERCISES.md](file:///c:/Users/riyaz/Tableau/TABLEAU_EXERCISES.md): Tableau Tasks (LODs, Table Calcs, Dynamic Actions)
* [UAT_TEST_CASES.md](file:///c:/Users/riyaz/Tableau/UAT_TEST_CASES.md): User Acceptance Testing & Reconciliation Scenarios
* [INTERVIEW_QUESTION_BANK.md](file:///c:/Users/riyaz/Tableau/INTERVIEW_QUESTION_BANK.md): 5-YOE Mock Interview Scenarios & Rubric
* [PROGRESS.md](file:///c:/Users/riyaz/Tableau/PROGRESS.md): Live Progress & Task Completion Tracker
* [MISTAKES_AND_LEARNINGS.md](file:///c:/Users/riyaz/Tableau/MISTAKES_AND_LEARNINGS.md): Candidate Feedback, Mistakes & Knowledge Journal
* [ARCHITECTURE_DECISIONS.md](file:///c:/Users/riyaz/Tableau/ARCHITECTURE_DECISIONS.md): Architectural Decision Records (ADRs)
