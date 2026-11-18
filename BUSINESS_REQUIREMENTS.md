# Business Requirements Document (BRD) — DentaKart Analytics

## 1. Document Control
* **Document Version**: 2.0.0 (Approved with Enterprise 5M Scale & Specialized Dental Domain Enhancements)
* **Project Name**: DentaKart Enterprise Sales & Operations Analytics
* **Business Unit**: Commercial Sales, Supply Chain, Finance & Clinical Services
* **Lead BI Architect**: Senior Tableau Developer Mentor
* **Candidate Role**: Lead Tableau Developer (5-Year Experience Track)

---

## 2. Business Background & Executive Summary
**DentaKart Analytics** is a premier distributor and multi-channel supplier of dental capital equipment, surgical instruments, consumable materials, imaging systems, and sterilization apparatus across India. 

Operating through an omnichannel ecosystem (Field Direct Sales, B2B Online Portal, Institutional Government/College Tenders, Sub-Distributor Network, and Inside Tele-sales), the company serves over **100,000 active dental accounts** across 50+ Indian metropolitan, Tier-1, Tier-2, and Tier-3 cities.

### Strategic Challenge & Business Context
Despite rapid topline revenue growth, executive leadership (VP of Sales, Chief Commercial Officer, CFO) faces critical business challenges:
1. **Margin Erosion & Discount Leakage**: Uncontrolled discounting by field sales reps on high-demand clinical equipment and bundled packages.
2. **Territory Discrepancies**: High concentration in Tier-1 metros (Mumbai, Delhi-NCR, Bengaluru) with under-penetrated dental healthcare markets in Tier-2/3 cities.
3. **Equipment Service & Warranty Friction**: Capital equipment (such as Intraoral Scanners, OPG X-Rays, Autoclaves, and Hydraulic Dental Chairs) requires post-sale installation, warranty tracking, and spare parts management. High breakdown frequencies directly depress repeat consumable reorders.
4. **GST & Commercial Ledger Balancing**: Compliance with Indian GST tax brackets (12% and 18%) across clinical devices and consumables, freight/shipping charges, and payment gateway methods.
5. **Quota Attainment Single Source of Truth**: Disputed monthly performance targets between field sales reps and management due to inconsistent reporting grains.

---

## 3. Project Objectives & Phased Execution Strategy
1. **Data Volume**: Build an enterprise data warehouse and lakehouse containing **5 complete years (2021–2025) of granular transaction history (~5,000,000 sales line items across ~1,250,000 order headers)**. The generation engine must be configurable to scale to 10M+ rows for performance benchmarking.
2. **Sequential Platform Implementation**:
   - **Phase A**: Complete the **Microsoft SQL Server EDW → Tableau Desktop/Cloud** workflow end-to-end first.
   - **Phase B**: Reproduce the data engineering and lakehouse transformation workflow in **Databricks (Delta Lake Medallion Architecture)** and benchmark both platforms.
3. **Tableau Enterprise Suite**: Deliver **8 Production Dashboards** serving executive, regional, merchandising, financial, supply chain, and clinical support leaders.
4. **Strict Isolation of Data Quality Scenarios**: Maintain two distinct environments:
   - **CLEAN**: 100% referential integrity and zero-defect financial reconciliation.
   - **DIRTY**: Controlled, isolated synthetic anomalies to practice real-world auditing, profiling, and remediation in Phase 5.
5. **Hands-on Performance & Interview Mastery**: Deliberately engineer 10 performance bottleneck scenarios to inspect query plans, LOD costs, and Tableau performance recordings without premature optimization.

---

## 4. Key Stakeholders & Target Personas

| Stakeholder Persona | Role in Organization | Core Business Focus | Primary Dashboard Target |
|---|---|---|---|
| **Chief Commercial Officer (CCO)** | Executive Leadership | Topline Net Sales, Gross Margin %, YoY growth, Pan-India market share | Dashboard 1: Executive Sales Overview |
| **National Sales Director (NSD)** | Sales Leadership | Regional performance, territory quota attainment, sales rep ranking | Dashboard 2: Regional Sales & Territory Performance |
| **Product Category Leads** | Merchandising & Procurement | SKU velocity, category margins, brand performance, supplier dependency | Dashboard 3: Product & Category Analysis |
| **Customer Retention Manager** | Marketing & CRM | Repeat purchasing, RFM segmentation, dormant account reactivation | Dashboard 4: Customer & Retention Analytics |
| **Chief Financial Officer (CFO)** | Finance & Pricing Strategy | Discount leakage, GST tax realization, shipping costs, payment terms | Dashboard 5: Profitability & Discount Analysis |
| **VP of Supply Chain** | Warehousing & Fulfillment | Stock-out risk, reorder levels, days of inventory on hand (DOH) | Dashboard 6: Inventory & Replenishment |
| **Head of Clinical Support** | After-Sales & Engineering | Equipment warranty claims, breakdown frequency, MTTR | Dashboard 7: Returns & Warranty Analysis |
| **Sales Operations Lead** | Planning & Incentive Comp | Quota achievement %, variance to budget, rep commission bands | Dashboard 8: Sales Target & Forecast Analysis |

---

## 5. Dental Product Catalog & Customer Classifications

### 5.1 Specialized Dental Product Catalog (~1,000 SKUs)
The catalog covers 16 core dental categories and equipment classes:
1. **Dental Chairs** (Hydraulic, Electromechanical, Pediatric, Continental delivery)
2. **Autoclaves** (Class B Vacuum Autoclaves, Class N, Benchtop Sterilizers)
3. **Compressors** (Oil-free dental air compressors, Acoustic noise-reduction units)
4. **Suction Systems** (Dry suction, Wet suction, Semi-dry central clinic suction)
5. **Handpieces** (High-speed air turbine handpieces, Low-speed contra-angle, Straight)
6. **Micromotors** (Brushless electric micromotors, Air micromotors)
7. **Ultrasonic Scalers** (Piezoelectric scalers, Magnetostrictive units, Cavitron tips)
8. **Curing Lights** (Broadband LED curing lights, Cordless high-intensity)
9. **Endomotors** (Cordless endodontic rotary motors with built-in apex locators)
10. **Apex Locators** (Multi-frequency digital electronic apex locators)
11. **RVG Sensors** (Digital intraoral radiovisiography sensors, Size 1 & Size 2)
12. **Intraoral Cameras** (HD wireless dental inspection cameras)
13. **Intraoral Scanners** (3D digital color optical impression scanners)
14. **X-Ray Units** (Wall-mounted DC dental X-ray, Portable handheld X-ray, 2D/3D OPG)
15. **Implant Motors** (Surgical physiodispensers with optic contra-angle handpieces)
16. **Dental Laboratory Equipment** (Porcelain furnaces, Model trimmers, Die cutters, CAD/CAM milling units)
17. **Clinical Consumables & Biomaterials** (Composite resins, Bonding agents, Alginates, Needles, Burs)

### 5.2 Customer Account Typology & Lifecycle Segments
* **Account Types**:
  - Solo Dental Clinics (Single practitioner practices)
  - Multi-Specialty Dental Hospitals & Corporate Chains (e.g., Clove Dental, Apollo White)
  - Dental Colleges & Teaching Universities (Institutional bulk procurement)
  - Dental Laboratories (Prosthodontic crown & bridge labs)
  - Regional Sub-Distributors (Wholesale buyers)
* **Lifecycle Classification**:
  - **New Accounts**: Onboarded within the current calendar year.
  - **Repeat Accounts**: Accounts placing >= 2 orders within a 12-month trailing window.
  - **Dormant / At-Risk Accounts**: Historical buyers with zero purchases in the past 180+ days.
* **Commercial Value Tiers**:
  - **Platinum**: Institutional hospital chains and dental colleges (Highest volume, 15%–25% negotiated discount).
  - **Gold**: Established multi-chair private clinics (Regular orders, 8%–15% discount).
  - **Standard / Silver**: Established solo practices (3%–8% discount).
  - **Value / Bronze**: New, single-chair rural/semi-urban practices (0%–5% list price).

---

## 6. Financial, Transactional & Indian GST Logic

Every sales line item in `Fact_Sales` contains complete unit economics and commercial parameters:
* **Quantity**: Number of units ordered (1 to 500 depending on consumable vs capital equipment).
* **List Price (INR)**: Standard catalog retail price.
* **Discount (%) & Discount Amount (INR)**: `Quantity * List_Price * Discount_Pct`.
* **Gross Sales (INR)**: `Quantity * List_Price`.
* **Net Sales (INR)**: `Gross Sales - Discount Amount`.
* **Cost of Goods Sold (COGS) (INR)**: `Quantity * Unit_Cost`.
* **Gross Profit (INR)**: `Net Sales - COGS`.
* **Gross Margin (%)**: `(Gross Profit / Net Sales) * 100`.
* **Indian GST Tax**:
  - Clinical Consumables & Diagnostic Instruments: **12% GST**.
  - Capital Machinery, Digital Imaging & Dental Furniture: **18% GST**.
  - `GST_Tax_Amount_INR = Net_Sales * GST_Rate`.
* **Shipping Cost (INR)**: Calculated based on order weight, freight distance, and delivery tier (Free for orders > ₹25,000, flat ₹250–₹1,500 for smaller/heavy freight).
* **Payment Method**: `'NEFT/RTGS'`, `'Credit Card'`, `'Corporate Net Banking'`, `'UPI / Razorpay'`, `'Cheque / 30-Day Credit'`.
* **Order Status**: `'Delivered'`, `'Shipped'`, `'In Transit'`, `'Processing'`, `'Cancelled'`.

---

## 7. Target Quota Architecture & Anti-Fan-Out Logic

* **Fact_Sales_Targets Grain**: Exactly **Month x Region x Salesperson x Product Category**.
* **Target Metrics**:
  - `Target_Sales_INR`: Monthly net revenue quota.
  - `Target_Gross_Profit_INR`: Monthly gross profit quota.
* **Analytical Calculations Required**:
  - **Actual Sales**: `SUM(Net_Sales_INR)` aggregated to the matching month, rep, category, and region.
  - **Target Sales**: `SUM(Target_Sales_INR)` at its native grain.
  - **Variance (INR)**: `Actual Sales - Target Sales`.
  - **Variance %**: `((Actual Sales - Target Sales) / Target Sales) * 100`.
  - **Achievement %**: `(Actual Sales / Target Sales) * 100`.
* **Tableau Anti-Fan-Out Rule**:
  Because `Fact_Sales` is at the **Order Line** grain (~5,000,000 rows) and `Fact_Sales_Targets` is at the **Rep x Category x Month** grain (~36,000 rows), direct physical joins multiply target rows by the number of transactions per rep.
  We will model this strictly via **Tableau Logical Relationships (Noodles)** and **Pre-Aggregated SQL Marts** to ensure zero duplication of targets.

---

## 8. Documented Performance Scenarios (Hands-on Troubleshooting)

To build genuine senior-level optimization competence, we have designed 10 real-world performance exercises:
1. **Live Connection vs Single-Table Hyper Extract Benchmark**: Slicing 5M rows on live SQL Server vs Hyper engine.
2. **High-Cardinality Quick Filters**: Measuring query lag when rendering 100,000 clinic names in a drop-down vs wildcard search / context filtering.
3. **Expensive LOD Expressions**: Comparing `{ FIXED [Customer ID] : SUM([Sales]) }` vs database-indexed customer aggregates.
4. **Mark Over-Saturation**: Browser DOM lag when rendering 50,000 individual scatter plot marks vs aggregated binned heatmaps.
5. **Complex Table Calculations**: Measuring execution overhead of nested `WINDOW_SUM` and `LOOKUP` across 5 million rows.
6. **Non-SARGable SQL Join**: Demonstrating execution plan scans caused by date conversions or functions in join predicates.
7. **Fact-to-Fact Join Cartesian Explosion**: Measuring memory and query duration of a naive join between `Fact_Sales` and `Fact_Sales_Targets`.
8. **Unnecessary Calculated Fields**: Performance impact of row-level string manipulations (`CONCAT`, `SPLIT`) in Tableau vs pre-computed SQL columns.
9. **Context Filter Misconfiguration**: Demonstrating query thrashing when dynamic filters are improperly moved to context.
10. **Extract Refresh Bottlenecks**: Full refresh vs Incremental extract refresh tuning on 5M rows.

---

## 9. Data Isolation: Clean vs Controlled Dirty Datasets

* **Clean Environment (`data/clean/`)**:
  - Strict foreign key integrity across all dimensions.
  - Zero orphan transactions.
  - Positive quantities and prices.
  - Validated dates within Jan 1, 2021 – Dec 31, 2025.
  - Clean CSVs and Parquet files for production SQL Server and Databricks ingestion.
* **Dirty Environment (`data/dirty/`)**:
  - Completely separate folder and database schema (`stg_dirty`).
  - Synthetically introduced errors: orphan customer IDs, trailing string whitespaces, invalid discounts (>100%), negative quantities, leap-year date errors, duplicate webhook lines.
  - Used exclusively in Phase 5 for data quality profiling and remediation scripts.
