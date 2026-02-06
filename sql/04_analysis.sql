/*
LOAN DEFAULT ANALYSIS - BUSINESS INSIGHTS
PURPOSE: Analyze loan default patterns and identify risk factors
DATASET: 255,347 loan records from loan_default_raw
KEY QUESTIONS:
1. What is the overall default rate?
2. Which customer segments have highest risk?
3. What loan characteristics predict default?
*/

USE LoanDefaultAnalysis;
GO

-- QUERY 1: PORTFOLIO OVERVIEW
-- Overall summary of loan portfolio
SELECT 
    COUNT_BIG(*) AS total_loans,
    SUM(CAST(loan_amount AS BIGINT)) AS total_portfolio_value,
    AVG(CAST(loan_amount AS FLOAT)) AS avg_loan_size,
    AVG(interest_rate) AS avg_interest_rate,
    SUM(CAST(default_flag AS BIGINT)) AS total_defaults,
    CAST(SUM(CAST(default_flag AS BIGINT)) * 100.0 / COUNT_BIG(*) AS DECIMAL(5,2)) AS default_rate_pct
FROM fact_loans;

-- QUERY 2: DEFAULT RATE BY EDUCATION
-- Which education level has highest default rate?
SELECT 
    ed.education_level,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(c.credit_score) AS avg_credit_score,
    AVG(CAST(c.income AS BIGINT)) AS avg_income
FROM fact_loans f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_education ed ON c.education_id = ed.education_id
GROUP BY ed.education_level
ORDER BY default_rate_pct DESC;

-- QUERY 3: DEFAULT RATE BY EMPLOYMENT TYPE
-- Which employment type is riskiest?
SELECT 
    e.employment_type,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(c.months_employed) AS avg_months_employed,
    AVG(CAST(f.loan_amount AS BIGINT)) AS avg_loan_amount
FROM fact_loans f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_employment e ON c.employment_id = e.employment_id
GROUP BY e.employment_type
ORDER BY default_rate_pct DESC;

-- QUERY 4: DEFAULT RATE BY CREDIT SCORE
-- How does credit score impact default?
SELECT 
    CASE 
        WHEN c.credit_score < 580 THEN '1. Poor (<580)'
        WHEN c.credit_score BETWEEN 580 AND 669 THEN '2. Fair (580-669)'
        WHEN c.credit_score BETWEEN 670 AND 739 THEN '3. Good (670-739)'
        WHEN c.credit_score BETWEEN 740 AND 799 THEN '4. Very Good (740-799)'
        ELSE '5. Excellent (800+)'
    END as credit_band,
    COUNT(f.fact_id) as total_loans,
    SUM(CAST(f.default_flag AS INT)) as defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT(f.fact_id) as DECIMAL(5,2)) as default_rate_pct,
    AVG(f.interest_rate) as avg_interest_rate
FROM fact_loans f
INNER JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY 
    CASE 
        WHEN c.credit_score < 580 THEN '1. Poor (<580)'
        WHEN c.credit_score BETWEEN 580 AND 669 THEN '2. Fair (580-669)'
        WHEN c.credit_score BETWEEN 670 AND 739 THEN '3. Good (670-739)'
        WHEN c.credit_score BETWEEN 740 AND 799 THEN '4. Very Good (740-799)'
        ELSE '5. Excellent (800+)'
    END
ORDER BY credit_band;

-- QUERY 5: DEFAULT RATE BY INCOME LEVEL
-- Does income affect default risk?
SELECT 
    CASE 
        WHEN c.income < 30000 THEN '1. Low (<30K)'
        WHEN c.income BETWEEN 30000 AND 59999 THEN '2. Lower-Mid (30-60K)'
        WHEN c.income BETWEEN 60000 AND 89999 THEN '3. Middle (60-90K)'
        WHEN c.income BETWEEN 90000 AND 119999 THEN '4. Upper-Mid (90-120K)'
        ELSE '5. High (120K+)'
    END as income_bracket,
    COUNT(f.fact_id) as total_loans,
    SUM(CAST(f.default_flag AS INT)) as defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT(f.fact_id) as DECIMAL(5,2)) as default_rate_pct,
    AVG(c.credit_score) as avg_credit_score
FROM fact_loans f
INNER JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY 
    CASE 
        WHEN c.income < 30000 THEN '1. Low (<30K)'
        WHEN c.income BETWEEN 30000 AND 59999 THEN '2. Lower-Mid (30-60K)'
        WHEN c.income BETWEEN 60000 AND 89999 THEN '3. Middle (60-90K)'
        WHEN c.income BETWEEN 90000 AND 119999 THEN '4. Upper-Mid (90-120K)'
        ELSE '5. High (120K+)'
    END
ORDER BY income_bracket;

-- QUERY 6: DEFAULT RATE BY DTI RATIO
-- Is Debt-to-Income ratio a strong predictor?
SELECT 
    CASE 
        WHEN c.dti_ratio < 0.2 THEN '1. Very Low (<20%)'
        WHEN c.dti_ratio < 0.35 THEN '2. Low (20-35%)'
        WHEN c.dti_ratio < 0.5 THEN '3. Moderate (36-49%)'
        ELSE '4. High (50%+)'
    END AS dti_category,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(CAST(c.income AS BIGINT)) AS avg_income
FROM fact_loans f
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY 
    CASE 
        WHEN c.dti_ratio < 0.2 THEN '1. Very Low (<20%)'
        WHEN c.dti_ratio < 0.35 THEN '2. Low (20-35%)'
        WHEN c.dti_ratio < 0.5 THEN '3. Moderate (36-49%)'
        ELSE '4. High (50%+)'
    END
ORDER BY dti_category;

-- QUERY 7: DEFAULT RATE BY LOAN PURPOSE
-- Which loan purpose has highest risk?
SELECT 
    l.loan_purpose,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(CAST(f.loan_amount AS BIGINT)) AS avg_loan_amount,
    AVG(f.interest_rate) AS avg_interest_rate
FROM fact_loans f
JOIN dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.loan_purpose
ORDER BY default_rate_pct DESC;

-- QUERY 8: DEFAULT RATE BY LOAN TERM
-- Do longer loan terms have higher default rates?
SELECT 
    l.loan_term,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(CAST(f.loan_amount AS BIGINT)) AS avg_loan_amount,
    AVG(f.interest_rate) AS avg_interest_rate
FROM fact_loans f
JOIN dim_loan l ON f.loan_key = l.loan_key
GROUP BY l.loan_term
ORDER BY l.loan_term;

-- QUERY 9: IMPACT OF CO-SIGNER
-- Does having a co-signer reduce default risk?
SELECT 
    l.has_cosigner,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(c.credit_score) AS avg_credit_score,
    AVG(CAST(f.loan_amount AS BIGINT)) AS avg_loan_amount
FROM fact_loans f
JOIN dim_loan l ON f.loan_key = l.loan_key
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY l.has_cosigner
ORDER BY default_rate_pct DESC;

-- QUERY 10: AGE GROUP ANALYSIS
-- Which age group has highest default rate?
SELECT 
    CASE 
        WHEN c.age < 25 THEN '1. Under 25'
        WHEN c.age < 35 THEN '2. 25-34'
        WHEN c.age < 45 THEN '3. 35-44'
        WHEN c.age < 55 THEN '4. 45-54'
        ELSE '5. 55+'
    END AS age_group,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(CAST(c.income AS BIGINT)) AS avg_income
FROM fact_loans f
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY 
    CASE 
        WHEN c.age < 25 THEN '1. Under 25'
        WHEN c.age < 35 THEN '2. 25-34'
        WHEN c.age < 45 THEN '3. 35-44'
        WHEN c.age < 55 THEN '4. 45-54'
        ELSE '5. 55+'
    END
ORDER BY age_group;

-- QUERY 11: MARITAL STATUS ANALYSIS
-- Does marital status affect default?
SELECT 
    c.marital_status,
    COUNT_BIG(f.fact_id) AS total_loans,
    SUM(CAST(f.default_flag AS INT)) AS defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT_BIG(f.fact_id)AS DECIMAL(5,2)) AS default_rate_pct,
    AVG(CAST(c.income AS BIGINT)) AS avg_income,
    AVG(c.credit_score) AS avg_credit_score
FROM fact_loans f
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY c.marital_status
ORDER BY default_rate_pct DESC;

-- QUERY 12: GOOD LOANS VS DEFAULTED LOANS COMPARISON
-- What's the profile difference between good and defaulted loans?
SELECT 
    CASE f.default_flag 
        WHEN 0 THEN 'Good Loans'
        WHEN 1 THEN 'Defaulted Loans'
    END AS loan_type,
    COUNT_BIG(*) AS count,
    AVG(c.age) AS avg_age,
    AVG(CAST(c.income AS BIGINT)) AS avg_income,
    AVG(c.credit_score) AS avg_credit_score,
    AVG(c.dti_ratio) AS avg_dti,
    AVG(c.months_employed) AS avg_months_employed,
    AVG(CAST(f.loan_amount AS BIGINT)) AS avg_loan_amount,
    AVG(f.interest_rate) AS avg_interest_rate
FROM fact_loans f
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY f.default_flag;

-- QUERY 13: TOP 10 RISKIEST COMBINATIONS (Multi-dimensional)
-- What combinations of Education + Employment + Loan Purpose are riskiest?
SELECT TOP 10
    ed.education_level,
    e.employment_type,
    l.loan_purpose,
    COUNT(f.fact_id) as total_loans,
    SUM(CAST(f.default_flag AS INT)) as defaults,
    CAST(SUM(CAST(f.default_flag AS INT)) * 100.0 / COUNT(f.fact_id) as DECIMAL(5,2)) as default_rate_pct
FROM fact_loans f
INNER JOIN dim_customers c ON f.customer_id = c.customer_id
INNER JOIN dim_education ed ON c.education_id = ed.education_id
INNER JOIN dim_employment e ON c.employment_id = e.employment_id
INNER JOIN dim_loan l ON f.loan_key = l.loan_key
GROUP BY ed.education_level, e.employment_type, l.loan_purpose
HAVING COUNT(f.fact_id) >= 100  -- Only segments with enough data
ORDER BY default_rate_pct DESC;

-- QUERY 14: CUSTOMER RISK SEGMENTATION (Using CTE)
-- Segment customers into risk tiers based on multiple factors
WITH customer_risk AS (
    SELECT 
        CASE 
            WHEN c.credit_score >= 740 AND c.dti_ratio < 0.35 THEN 'Low Risk'
            WHEN c.credit_score >= 670 AND c.dti_ratio < 0.45 THEN 'Medium Risk'
            WHEN c.credit_score >= 580 THEN 'High Risk'
            ELSE 'Very High Risk'
        END as risk_tier,
        f.default_flag,
        f.loan_amount
    FROM fact_loans f
    INNER JOIN dim_customers c ON f.customer_id = c.customer_id
)
SELECT 
    risk_tier,
    COUNT(*) as total_loans,
    SUM(CAST(default_flag AS INT)) as defaults,
    CAST(SUM(CAST(default_flag AS INT)) * 100.0 / COUNT(*) as DECIMAL(5,2)) as default_rate_pct,
    SUM(CAST(loan_amount AS BIGINT)) as total_exposure
FROM customer_risk
GROUP BY risk_tier
ORDER BY 
    CASE risk_tier
        WHEN 'Low Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'High Risk' THEN 3
        ELSE 4
    END;

-- QUERY 15: HIGH-VALUE LOW-RISK CUSTOMERS (For retention strategy)
-- Identify top customers for retention programs
SELECT TOP 100
    c.loan_id,
    c.age,
    c.income,
    c.credit_score,
    c.dti_ratio,
    ed.education_level,
    e.employment_type,
    f.loan_amount,
    f.interest_rate,
    f.default_flag
FROM fact_loans f
INNER JOIN dim_customers c ON f.customer_id = c.customer_id
INNER JOIN dim_education ed ON c.education_id = ed.education_id
INNER JOIN dim_employment e ON c.employment_id = e.employment_id
WHERE f.default_flag = 0  -- Only good loans
    AND c.credit_score >= 700
    AND c.income >= 60000
    AND c.dti_ratio < 0.4
ORDER BY c.credit_score DESC, c.income DESC;
