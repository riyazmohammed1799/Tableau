# Data Quality Rules & Audit Matrix — DentaKart Analytics

## 1. Clean Production Dataset Validation Rules (Zero-Tolerance)

Every pipeline run against the production data layer (`Fact_Sales`, `Fact_Orders`, dimensions) must strictly satisfy the following assertions:

| Rule ID | Entity | Field / Check | Assertion / Condition | Severity | Business Impact |
|---|---|---|---|---|---|
| **DQR-001** | `Fact_Sales` | `order_line_id` | `COUNT(order_line_id) == COUNT(DISTINCT order_line_id)` | CRITICAL | Duplicate line items distort revenue and tax |
| **DQR-002** | `Fact_Sales` | `quantity` | `quantity > 0` | CRITICAL | Negative quantities corrupt inventory and volume |
| **DQR-003** | `Fact_Sales` | `unit_price_inr` | `unit_price_inr > 0` | CRITICAL | Free or negative price creates invalid revenue |
| **DQR-004** | `Fact_Sales` | `discount_pct` | `0.0000 <= discount_pct <= 0.4000` | HIGH | Discounts >40% require CCO executive approval |
| **DQR-005** | `Fact_Sales` | Revenue Math | `ABS(net_sales_inr - (gross_sales_inr - discount_amount_inr)) < 0.01` | CRITICAL | Financial reconciliation ledger balance |
| **DQR-006** | `Fact_Sales` | Margin Math | `ABS(gross_profit_inr - (net_sales_inr - cogs_inr)) < 0.01` | CRITICAL | Accurate gross margin accounting |
| **DQR-007** | `Fact_Sales` | Foreign Keys | `customer_id IN (Dim_Customer.customer_id)` | CRITICAL | Orphan sales lines unmapped to customer segments |
| **DQR-008** | `Fact_Sales` | Foreign Keys | `product_id IN (Dim_Product.product_id)` | CRITICAL | Orphan sales lines unmapped to catalog |
| **DQR-009** | `Fact_Sales` | Foreign Keys | `order_date_key IN (Dim_Date.date_key)` | CRITICAL | Calendar mismatch / unmapped fiscal period |
| **DQR-010** | `Fact_Returns`| Return Quantity| `returned_quantity <= Fact_Sales.quantity` | HIGH | Returned quantity cannot exceed purchased units |
| **DQR-011** | `Fact_Returns`| Return Date | `Fact_Returns.return_date >= Fact_Orders.order_date` | HIGH | Cannot return prior to purchase date |
| **DQR-012** | `Fact_Orders` | Shipping Date | `shipping_date >= order_date OR shipping_date IS NULL` | MEDIUM | Delivery timeline logic |

---

## 2. Controlled Flawed Dataset (`raw_dirty/`) Test Cases

In Phase 5, you will be tasked with writing profiling and cleansing queries against the `raw_dirty/` dataset. 
The injected anomalies will test your ability to discover and fix:
1. **Orphan Keys**: Sales lines referencing customer IDs not present in `Dim_Customer`.
2. **Text Inconsistencies**: Category names with trailing whitespaces, mixed casing (`'Dental Consumables'`, `'dental consumables'`, `'DENTAL CONSUMABLES'`).
3. **Price/Discount Anomalies**: Line discounts recorded as `15` instead of `0.15` (causing 1500% discounts), or negative prices.
4. **Duplicate Header & Lines**: Accidental double-firing of webhook orders resulting in identical `order_number` and lines.
5. **Impossible Dates**: Order dates recorded in year `2099` or leap year dates on non-leap years.
