import pandas as pd
import mysql.connector

df = pd.read_csv('CostReport_2023_Final.csv')

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='Bestatsoccer519$',
    database='medicare_cost_analysis'
)

cursor = conn.cursor()

print("Importing cost reports...")

for index, row in df.iterrows():
    cursor.execute("""
        INSERT INTO cost_reports 
        (provider_ccn, fiscal_year_end_date, total_costs, inpatient_total_charges, 
        outpatient_total_charges, combined_total_charges, net_patient_revenue, 
        net_income, total_discharges, medicare_discharges)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        str(row['Provider CCN']),
        str(row['Fiscal Year End Date']),
        None if pd.isna(row['Total Costs']) else float(row['Total Costs']),
        None if pd.isna(row['Inpatient Total Charges']) else float(row['Inpatient Total Charges']),
        None if pd.isna(row['Outpatient Total Charges']) else float(row['Outpatient Total Charges']),
        None if pd.isna(row['Combined Outpatient + Inpatient Total Charges']) else float(row['Combined Outpatient + Inpatient Total Charges']),
        None if pd.isna(row['Net Patient Revenue']) else float(row['Net Patient Revenue']),
        None if pd.isna(row['Net Income']) else float(row['Net Income']),
        None if pd.isna(row['Total Discharges (V + XVIII + XIX + Unknown)']) else int(row['Total Discharges (V + XVIII + XIX + Unknown)']),
        None if pd.isna(row['Total Discharges Title XVIII']) else int(row['Total Discharges Title XVIII'])
    ))

conn.commit()
print(f"Cost reports imported: {len(df)} rows")

print("Importing financial metrics...")

for index, row in df.iterrows():
    cursor.execute("""
        INSERT INTO financial_metrics 
        (provider_ccn, cost_to_charge_ratio, medicaid_charges, 
        total_salaries, cost_of_charity_care, total_assets)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        str(row['Provider CCN']),
        None if pd.isna(row['Cost To Charge Ratio']) else float(row['Cost To Charge Ratio']),
        None if pd.isna(row['Medicaid Charges']) else float(row['Medicaid Charges']),
        None if pd.isna(row['Total Salaries (adjusted)']) else float(row['Total Salaries (adjusted)']),
        None if pd.isna(row['Cost of Charity Care']) else float(row['Cost of Charity Care']),
        None if pd.isna(row['Total Assets']) else float(row['Total Assets'])
    ))

conn.commit()
print(f"Financial metrics imported: {len(df)} rows")

cursor.close()
conn.close()
print("All done!")