# Mistakes, Learnings, and Technical Journal

> **Purpose**: This living document tracks technical errors, conceptual misunderstandings, anti-patterns identified during code reviews, and mock interview feedback during your 5-YOE Tableau Developer training.
> **Rule**: Treat every mistake as an interview asset. Explaining *how* you debugged and fixed an issue is the #1 signal interviewers look for in a 5-year senior candidate.

---

## 1. SQL & Data Engineering Log

| Date | Phase / Exercise | Issue / Mistake Observed | Root Cause & Concept Gap | Correct Senior Solution | Interview Talking Point |
|---|---|---|---|---|---|
| 2026-10-07 | Phase 2 Pre-Ingestion Audit | Check V-06 Failed: `Dim_Location` contained only 4 geographic regions (North, South, West, East) instead of 5 (missing Central). | Array truncation bug in generator: `cities_data[:60]` sliced before reaching the 5 Central cities (indices 60–64). | Explicitly rebalance the 60-city master list across all 5 regions (15 North, 15 South, 15 West, 8 East, 7 Central = 60). | "Automated assertion gates (Check V-06) catch boundary truncation defects before data is loaded into the EDW or extracted into Tableau." |
| 2026-10-09 | Phase 2 Remediation & Re-validation | Check V-06 Resolution: Need exact 60 cities across 5 regions (North: 14, South: 16, West: 15, East: 9, Central: 6) including Bhopal, Indore, Gwalior, Jabalpur, Ujjain, and Raipur. | Blind slice `[:60]` removed; programmatic regional assertion gates added inside `generate_dim_location()`. Full dataset regenerated with seed 42. | Validated all 50 audit assertions passed (50/50) with zero defects in `VALIDATION_REPORT.md`. | "Senior analytics engineers enforce defensive programmatic validation within the ingestion pipeline so schemas and referential integrity are mathematically verified before reaching the data warehouse." |
| 2026-10-09 | Phase 3 Pre-Load Environmental Audit | Pre-load check caught that `xp_fileexist` returned 0 for clean CSVs: SQL Server service account (`NT Service\MSSQL$SQLEXPRESS`) could not read files in user directory. | `BULK INSERT` executes in the server engine process context, not the client process. Windows user profile directories block external service accounts by default. | Granted read permissions via `icacls "data\clean\csv" /grant "NT Service\MSSQL$SQLEXPRESS:(OI)(CI)(R)"` and verified file existence before running ingestion. | "A 5-YOE BI data engineer knows that server-side bulk loaders execute under the DBMS service account security context, requiring file-system ACL validation before pipeline deployment." |
| 2026-10-12 | Phase 14 / Track B Lakehouse Ingestion | Databricks SQL returned `UC_VOLUME_NOT_FOUND` for `dentalkart_dw.bronze.rawfiles`. | Naming discrepancy between UI creation (`raw_files` with underscore) and query path, plus Unity Catalog 3-level namespace requirement. | Used `system.information_schema.volumes` and Databricks `LIST` to confirm exact path `/Volumes/dentalkart_dw/bronze/raw_files/` before authoring ingestion DDL. | "In Databricks Unity Catalog, Volumes require strict 3-level naming (`<catalog>.<schema>.<volume>`) and case-exact pathing. Preflight discovery avoids deployment halts." |
| 2026-10-12 | Phase 14 / Track B Lakehouse Ingestion | Databricks SQL Editor displayed "No records returned" upon running Step 2 DDL. | `CREATE TABLE ... AS SELECT` is DDL, which alters catalog metadata and writes storage objects without returning data rows. | Recognized DDL completion; immediately ran pre-staged CTE reconciliation query (`SELECT count(*)`) to mathematically verify 100% row-count parity across all 14 tables. | "A Senior Data Engineer understands SQL engine semantics: DDL operations do not return result sets. Automated reconciliation queries with unioned rollups provide instant mathematical proof of data integrity." |

---

## 2. Tableau Modeling & Calculation Log

| Date | Phase / Exercise | Issue / Mistake Observed | Root Cause & Concept Gap | Correct Senior Solution | Interview Talking Point |
|---|---|---|---|---|---|
| — | — | *Awaiting candidate development* | — | — | — |

---

## 3. Mock Interview Performance Log

| Question # | Topic | Candidate Initial Answer Summary | Identified Gaps / Red Flags | Required Depth (5-YOE Standard) | Retest Status |
|---|---|---|---|---|---|
| — | — | *Awaiting mock interview sessions* | — | — | — |

---

## 4. Key Lessons & Senior Best Practice Takeaways
1. **Never Rely on Blind Data Generation**: Always build an automated pre-load test suite (`scripts/validate_data.py`) with strict assertion gates. Out of 50 checks, 49 passed, but check V-06 caught a critical truncation issue that would have corrupted downstream geographic slicing in Tableau.
