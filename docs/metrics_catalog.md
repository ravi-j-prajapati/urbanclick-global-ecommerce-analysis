# Primary Metrics Catalog

**Project Title:** UrbanClick Enterprise Global E-Commerce Analytics Platform  
**Repository:** `urbanclick-global-ecommerce-analysis`  
**Document ID:** MC-UC-2026-V1  
**Version:** 1.0.0  
**Date:**  2026-07-31

## Key Enterprise Calculations
- **Gross Sales:** SUM(`quantity` x `unit_price`)
- **Net Sales:** Gross Sales - SUM(`discount_amount`)
- **Cost of Goods Sold (COGS):** SUM(`quantity` x `mst_products.unit_cost`)
- **Net Profit:** Net Sales - COGS - SUM(`shipping_cost_allocated`) - refunds
- **Return Rate (%):** ( Total Returned Line Items / Total Sold Line Items ) x 100
- **Fulfillment SLA Accuracy (%):** (Orders Shipped Within Promised Days / Total Orders ) x 100