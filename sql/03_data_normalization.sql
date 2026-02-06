USE LoanDefaultAnalysis;
GO

-- STEP 1: DROP EXISTING TABLES (if any)
IF OBJECT_ID('fact_loans', 'U') IS NOT NULL DROP TABLE fact_loans;
IF OBJECT_ID('dim_customers', 'U') IS NOT NULL DROP TABLE dim_customers;
IF OBJECT_ID('dim_loan', 'U') IS NOT NULL DROP TABLE dim_loan;
IF OBJECT_ID('dim_employment', 'U') IS NOT NULL DROP TABLE dim_employment;
IF OBJECT_ID('dim_education', 'U') IS NOT NULL DROP TABLE dim_education;


--DIM_EMPLOYMENT
CREATE TABLE dim_employment (
    employment_id INT IDENTITY(1,1) PRIMARY KEY,
    employment_type VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO dim_employment (employment_type)
SELECT DISTINCT EmploymentType
FROM loan_default_raw
WHERE EmploymentType IS NOT NULL
ORDER BY EmploymentType;

--DIM_EDUCATION
CREATE TABLE dim_education (
    education_id INT IDENTITY(1,1) PRIMARY KEY,
    education_level VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO dim_education (education_level)
SELECT DISTINCT Education
FROM loan_default_raw
WHERE Education IS NOT NULL
ORDER BY Education;

--DIM_CUSTOMERS
CREATE TABLE dim_customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    loan_id NVARCHAR(50) UNIQUE NOT NULL, 
    age INT,
    marital_status VARCHAR(20),
    has_dependents VARCHAR(10),
    has_mortgage VARCHAR(10),
    income INT,
    credit_score INT,
    num_credit_lines INT,
    dti_ratio FLOAT,
    months_employed INT,
    employment_id INT NOT NULL,
    education_id INT NOT NULL,
    
    FOREIGN KEY (employment_id) REFERENCES dim_employment(employment_id),
    FOREIGN KEY (education_id) REFERENCES dim_education(education_id)
);

INSERT INTO dim_customers (
    loan_id, age, marital_status, has_dependents, has_mortgage,
    income, credit_score, num_credit_lines, dti_ratio, months_employed,
    employment_id, education_id
)
SELECT
    r.LoanID,
    r.Age,
    r.MaritalStatus,
    r.HasDependents,
    r.HasMortgage,
    r.Income,
    r.CreditScore,
    r.NumCreditLines,
    r.DTIRatio,
    r.MonthsEmployed,
    e.employment_id,
    ed.education_id
FROM loan_default_raw r
INNER JOIN dim_employment e ON r.EmploymentType = e.employment_type
INNER JOIN dim_education ed ON r.Education = ed.education_level;

--DIM_LOAN
CREATE TABLE dim_loan (
    loan_key INT IDENTITY(1,1) PRIMARY KEY,
    loan_purpose VARCHAR(50) NOT NULL,
    loan_term INT NOT NULL,
    has_cosigner VARCHAR(10) NOT NULL,
    CONSTRAINT uq_loan UNIQUE (loan_purpose, loan_term, has_cosigner)
);

INSERT INTO dim_loan (loan_purpose, loan_term, has_cosigner)
SELECT DISTINCT
    LoanPurpose,
    LoanTerm,
    HasCoSigner
FROM loan_default_raw
WHERE LoanPurpose IS NOT NULL
ORDER BY LoanPurpose, LoanTerm;

--FACT_LOANS
CREATE TABLE fact_loans (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    loan_key INT NOT NULL,
    loan_amount INT NOT NULL,
    interest_rate FLOAT NOT NULL,
    default_flag BIT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (loan_key) REFERENCES dim_loan(loan_key)
);

INSERT INTO fact_loans (
    customer_id, loan_key, loan_amount, interest_rate, default_flag
)
SELECT
    c.customer_id,
    l.loan_key,
    r.LoanAmount,
    r.InterestRate,
    r.[Default]
FROM loan_default_raw r
INNER JOIN dim_customers c ON r.LoanID = c.loan_id
INNER JOIN dim_loan l 
    ON r.LoanPurpose = l.loan_purpose
   AND r.LoanTerm = l.loan_term
   AND r.HasCoSigner = l.has_cosigner;


-- STEP 3: CREATE INDEXES
CREATE INDEX idx_fact_customer ON fact_loans(customer_id);
CREATE INDEX idx_fact_loan ON fact_loans(loan_key);
CREATE INDEX idx_fact_default ON fact_loans(default_flag);
CREATE INDEX idx_customer_creditscore ON dim_customers(credit_score);
CREATE INDEX idx_customer_income ON dim_customers(income);

-- STEP 4: VALIDATION (Simple check only)
-- Row counts
SELECT 
    'loan_default_raw' as TableName, COUNT(*) as RowCount1 FROM loan_default_raw
UNION ALL
SELECT 'fact_loans', COUNT(*) FROM fact_loans;

-- Default distribution
SELECT 
    default_flag,
    COUNT(*) as Count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as DECIMAL(5,2)) as Pct
FROM fact_loans
GROUP BY default_flag;

