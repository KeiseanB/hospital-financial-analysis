-- ============================================
-- Medicare Hospital Cost Report Analysis 2023
-- Author: Keisean Burnett
-- GitHub: github.com/KeiseanB
-- LinkedIn: linkedin.com/in/keiseanburnett
-- Data Source: CMS data.cms.gov
-- Purpose: Analyze hospital financial performance
--          and revenue cycle metrics relevant to
--          Epic Clarity reporting and healthcare
--          data analytics
-- ============================================

USE medicare_cost_analysis;

-- QUERY 1: Hospitals Losing the Most Money
-- This query identifies the 15 hospitals with the lowest net income in 2023
-- Net income = Total Revenue minus Total Expenses
-- Negative net income means the hospital is operating at a loss
-- This is critical for revenue cycle analysis and financial risk assessment

SELECT 
    h.hospital_name,        -- Name of the hospital
    h.state_code,           -- State the hospital is located in
    h.city,                 -- City the hospital is located in
    c.net_income            -- Net income (negative = losing money)
FROM hospitals h
JOIN cost_reports c         -- JOIN connects two tables using a shared column
    ON h.provider_ccn = c.provider_ccn  -- provider_ccn is the unique hospital ID (like a SSN for hospitals)
WHERE c.net_income IS NOT NULL          -- Filter out hospitals with missing financial data
ORDER BY c.net_income ASC               -- Sort lowest to highest (most losses first)
LIMIT 15;                               -- Show only the top 15 results

USE medicare_cost_analysis;

-- QUERY 1 IMPROVED: Hospitals Losing the Most Money (Deduplicated)
-- Using DISTINCT to remove duplicate entries caused by multiple fiscal year records
-- Non-profit hospitals often show large "losses" because they reinvest surplus into operations
-- This is a key concept in healthcare revenue cycle analysis

SELECT DISTINCT
    h.hospital_name,        -- Name of the hospital
    h.state_code,           -- State the hospital is located in
    h.city,                 -- City the hospital is located in
    c.net_income            -- Net income (negative = losing money)
FROM hospitals h
JOIN cost_reports c         
    ON h.provider_ccn = c.provider_ccn  
WHERE c.net_income IS NOT NULL          
ORDER BY c.net_income ASC               
LIMIT 15;


-- QUERY 2: Average Net Income by State
-- This shows which states have the most financially stressed hospital systems
-- Negative average means most hospitals in that state are operating at a loss
-- Healthcare policymakers and Epic analysts use this to prioritize resources

SELECT 
    h.state_code,                           -- State
    COUNT(DISTINCT h.hospital_name) AS total_hospitals,  -- How many hospitals per state
    ROUND(AVG(c.net_income), 2) AS avg_net_income,       -- Average net income per state
    ROUND(SUM(c.net_income), 2) AS total_net_income      -- Total net income for the state
FROM hospitals h
JOIN cost_reports c 
    ON h.provider_ccn = c.provider_ccn
WHERE c.net_income IS NOT NULL
GROUP BY h.state_code                       -- Group results by state
ORDER BY avg_net_income ASC                 -- Worst performing states first
LIMIT 15;

-- QUERY 3: Florida Hospital Financial Performance
-- Deep dive into Florida hospitals specifically
-- Florida is a major Medicare market due to large elderly population
-- This analysis is directly relevant to South Florida healthcare employers
-- including Memorial Healthcare, Broward Health, HCA Florida, and Baptist Health

SELECT DISTINCT
    h.hospital_name,                        -- Hospital name
    h.city,                                 -- City in Florida
    h.rural_versus_urban,                   -- Is it rural or urban?
    c.net_income,                           -- Net income
    c.net_patient_revenue,                  -- Total revenue from patients
    c.total_costs,                          -- Total operating costs
    f.cost_to_charge_ratio                  -- How much it costs vs what they charge
FROM hospitals h
JOIN cost_reports c ON h.provider_ccn = c.provider_ccn
JOIN financial_metrics f ON h.provider_ccn = f.provider_ccn
WHERE h.state_code = 'FL'                   -- Filter for Florida only
    AND c.net_income IS NOT NULL
ORDER BY c.net_income ASC                   -- Worst performing first
LIMIT 20;


-- QUERY 4: Cost vs Charge Analysis -- The Healthcare Markup
-- This reveals how much hospitals CHARGE vs what it actually COSTS them
-- A cost_to_charge_ratio of 0.25 means it costs $0.25 to provide $1 of care
-- Epic Clarity analysts use this metric constantly for revenue cycle reporting
-- Lower ratio = hospital marks up prices more aggressively

SELECT DISTINCT
    h.hospital_name,
    h.state_code,
    h.city,
    f.cost_to_charge_ratio,                          -- The markup ratio
    ROUND(c.total_costs / 1000000, 2) AS total_costs_millions,     -- Costs in millions
    ROUND(c.combined_total_charges / 1000000, 2) AS total_charges_millions, -- Charges in millions
    ROUND((c.combined_total_charges - c.total_costs) / 1000000, 2) AS markup_millions -- Difference in millions
FROM hospitals h
JOIN cost_reports c ON h.provider_ccn = c.provider_ccn
JOIN financial_metrics f ON h.provider_ccn = f.provider_ccn
WHERE f.cost_to_charge_ratio IS NOT NULL
    AND f.cost_to_charge_ratio > 0
    AND h.state_code = 'FL'
ORDER BY f.cost_to_charge_ratio ASC                  -- Lowest ratio = highest markup first
LIMIT 15;


-- QUERY 5: Medicare Dependency Analysis
-- Which Florida hospitals rely most heavily on Medicare patients?
-- High Medicare dependency = high exposure to CMS reimbursement changes
-- Epic Clarity analysts build these reports for CFOs and revenue cycle leadership
-- This is one of the most requested reports in healthcare finance

SELECT DISTINCT
    h.hospital_name,
    h.city,
    h.state_code,
    c.total_discharges,                    -- Total patients discharged
    c.medicare_discharges,                 -- Medicare patients specifically
    ROUND(
        (c.medicare_discharges * 100.0) / 
        NULLIF(c.total_discharges, 0), 2
    ) AS medicare_dependency_pct,          -- % of patients on Medicare
    ROUND(c.net_patient_revenue / 1000000, 2) AS revenue_millions
FROM hospitals h
JOIN cost_reports c ON h.provider_ccn = c.provider_ccn
WHERE h.state_code = 'FL'
    AND c.total_discharges > 0
    AND c.medicare_discharges IS NOT NULL
ORDER BY medicare_dependency_pct DESC
LIMIT 15;


-- ============================================
-- QUERY 6: Master Export Query for Tableau
-- Combines all three tables into one dataset
-- for visualization in Tableau Public
-- This is the final analytical dataset
-- ============================================
USE medicare_cost_analysis;

SELECT DISTINCT
    h.hospital_name,
    h.city,
    h.state_code,
    h.rural_versus_urban,
    c.net_income,
    c.net_patient_revenue,
    c.total_costs,
    c.total_discharges,
    c.medicare_discharges,
    f.cost_to_charge_ratio,
    f.cost_of_charity_care,
    ROUND((c.medicare_discharges * 100.0) / NULLIF(c.total_discharges, 0), 2) AS medicare_dependency_pct,
    ROUND((c.combined_total_charges / NULLIF(c.total_costs, 0)), 2) AS charge_markup_ratio
FROM hospitals h
JOIN cost_reports c ON h.provider_ccn = c.provider_ccn
JOIN financial_metrics f ON h.provider_ccn = f.provider_ccn
WHERE c.net_income IS NOT NULL;

