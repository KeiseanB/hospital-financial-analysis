# Hospital Financial Analysis — CMS Hospital Provider Cost Report 2023

## Overview
Built a SQL database from scratch and Tableau dashboard analyzing the financial 
performance of 6,103 U.S. hospitals using the CMS Hospital Provider Cost Report. 
This project mirrors the type of revenue cycle and financial analysis performed 
by Epic Clarity analysts for hospital CFOs and finance teams.

## Key Findings
- Charleston Area Medical Center reported a $1.7B net loss in 2023
- South Florida State Hospital in Pembroke Pines reported a $40M net loss
- Florida hospitals charge up to 17x what care actually costs to provide
- PAM Health Jupiter relies on Medicare for 93% of its patients
- Washington state hospitals reported a combined $7.5B in net losses
- The highest performing hospital in the dataset reported $1.3B net income

## Tools & Technologies
- **MySQL** — database design and storage
- **SQL** — 6 analytical queries with documented methodology
- **Python (pandas)** — data cleaning and ETL pipeline
- **Tableau Public** — interactive dashboard
- **CMS Public Data** — data.cms.gov

## Project Structure
hospital-financial-analysis/
├── medicare_analysis_queries.sql   # 6 SQL queries with comments
├── import_data.py                  # Python ETL script
├── medicare_final_data.csv         # Cleaned dataset
└── README.md

## Interactive Dashboard
[[(https://public.tableau.com/app/profile/keisean.burnett/viz/MedicareHospitalCostReportAnalysis2023/Dashboard1#1)]

## Data Source
CMS Hospital Provider Cost Report 2023
[https://data.cms.gov/provider-data/dataset/g6vv-u9sr](https://data.cms.gov/provider-compliance/cost-reports/hospital-provider-cost-report)

## Author
Keisean Burnett
- LinkedIn: linkedin.com/in/keiseanburnett
- GitHub: github.com/KeiseanB
