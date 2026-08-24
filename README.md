# Urbanclick Global Ecommerce Analysis
## Overview
This project is a production-style end-to-end data analysis that simulates a real enterprise Ecommerce business.

The Project Covers:
- Business Understanding & Schema Design
- Synthetic Dataset Generation
- Data Cleaning & Validation
- Exploratory Data Analysis (EDA)
- Business Analysis
- Star Schema Design
- Power BI Dashboard
- Tableau Dashboard
- Executive Business Report

## Project Phases
- Phase 1: Business Understanding & Schema Design ✅
- Phase 2: Synthetic Data Pipeline (Python) ✅
- Phase 3: Data Warehouse & MySQL Implementation ✅
- Phase 4: Power BI Enterprise Analytics 🔄
- Phase 5: Tableau Exploratory Analytics & Storytelling 🔄
- Phase 6: Enterprise Packaging & Git Commit Optimization ⏳

## Repository Structure
```text
data_pipeline/
docs/
power_bi/
reports/
sql/
tableau/
venv/
```

## Technology Stack
- MySQL
- Power BI
- Tableau
- Python (Data Generation)
- Git
- GitHub

## Documentation
- Business Requirement Document (BRD)
- ER_Diagram
- Metrics Catalog


## Issues during project
1. **Connectivity between Power BI -> MySQL**\
    Compativility issue between native MySQL connector and the installed Connector/NET provider.

    **Solution:** Power BI was connected to MySQL using the MySQL ODBC 8.4 Unicode Driver. The database connection was validated through DSN testing before use.