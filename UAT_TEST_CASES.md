# User Acceptance Testing (UAT) & Production Sign-Off Matrix — DentaKart Analytics

## 1. Reconciliation Test Suite (Financial & Operational Ledger Sign-off)

| Test ID | Test Name | Validation Logic / SQL Assertion | Expected Result | Pass/Fail Criteria |
|---|---|---|---|---|
| **UAT-001** | Total Sales Reconciliation | Compare Tableau BAN (Big Angry Number) for Net Sales against `SUM(net_sales_inr)` from raw table | Exact match to ₹0.01 | Discrepancy > ₹0.00 is a FAIL |
| **UAT-002** | Line Item Margin Conservation | `SUM(gross_sales_inr) - SUM(discount_amount_inr) == SUM(net_sales_inr)` | 100% balanced | Strict arithmetic equality |
| **UAT-003** | Gross Margin Integrity | `SUM(net_sales_inr) - SUM(cogs_inr) == SUM(gross_profit_inr)` | 100% balanced | Strict arithmetic equality |
| **UAT-004** | Order Count Distinctness | Compare `COUNTD(order_id)` in Tableau against `SELECT COUNT(DISTINCT order_id) FROM Fact_Orders` | Exact match | Mismatch indicates join duplication |
| **UAT-005** | Target Quota Anti-Fan-Out | Verify total monthly targets in Tableau match `SELECT SUM(target_sales_inr) FROM Fact_Sales_Targets` | Exact match | Inflated sum indicates relationship fan-out |
| **UAT-006** | Return Rate Reconciliation | Verify returned quantity matches sum of `Fact_Returns` quantity | Exact match | Zero discrepancy |

---

## 2. Dashboard Filter & Interactivity Verification

| Test ID | Dashboard | Component Tested | Action Performed | Expected Behavior |
|---|---|---|---|---|
| **UAT-007** | Exec Overview | Date Horizon Filter | Toggle between FY2024 and FY2025 | All KPI cards and sparklines update instantaneously (<1.5s) |
| **UAT-008** | Regional View | Map Drill-down | Click on State 'Maharashtra' | City table filters to Mumbai, Pune, Nagpur; KPI cards update |
| **UAT-009** | Product View | Top N Parameter | Change parameter from 10 to 25 | Chart dynamically expands to show top 25 SKUs with dynamic rank labels |
| **UAT-010** | Pricing View | Margin Threshold Slider | Set minimum margin filter to 20% | Scatters plot highlights products operating below minimum margin |

---

## 3. Row-Level Security (RLS) Verification

| Test ID | Persona Simulated | Expected Visible Territory | Forbidden Territories (Must Return Zero Rows) |
|---|---|---|---|
| **UAT-011** | Regional Director - North | Delhi-NCR, Punjab, Haryana, UP, Rajasthan | Maharashtra, Karnataka, Tamil Nadu, West Bengal |
| **UAT-012** | Regional Director - West | Maharashtra, Gujarat, Goa, MP | North, South, and East regions |
| **UAT-013** | National Sales Director (NSD) | All 5 Regions nationwide | None (Unrestricted access) |
| **UAT-014** | Field Sales Rep | Assigned Accounts / Salesperson ID only | Other Sales Representatives' pipelines |
