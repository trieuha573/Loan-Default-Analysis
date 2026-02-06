USE LoanDefaultAnalysis;
GO

-- BƯỚC 1.1: XEM TỔNG QUAN
-- Xem cấu trúc
SELECT TOP 10 * FROM loan_default_raw;

-- Đếm records
SELECT COUNT(*) as TotalRows FROM loan_default_raw;

-- Check duplicates
SELECT 
    COUNT(*) as Total,
    COUNT(DISTINCT LoanID) as UniqueLoans,
    COUNT(*) - COUNT(DISTINCT LoanID) as Duplicates
FROM loan_default_raw;

-- BƯỚC 1.2: CHECK NULL VALUES
SELECT 
    'LoanID' AS ColumnName,
    COUNT(*) - COUNT(LoanID) AS NullCount,
    CAST((COUNT(*) - COUNT(LoanID)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS NullPercent
FROM loan_default_raw

UNION ALL
SELECT 
    'Age',
    COUNT(*) - COUNT(Age),
    CAST((COUNT(*) - COUNT(Age)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'Income',
    COUNT(*) - COUNT(Income),
    CAST((COUNT(*) - COUNT(Income)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'LoanAmount',
    COUNT(*) - COUNT(LoanAmount),
    CAST((COUNT(*) - COUNT(LoanAmount)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'InterestRate',
    COUNT(*) - COUNT(InterestRate),
    CAST((COUNT(*) - COUNT(InterestRate)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'CreditScore',
    COUNT(*) - COUNT(CreditScore),
    CAST((COUNT(*) - COUNT(CreditScore)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'EmploymentType',
    COUNT(*) - COUNT(EmploymentType),
    CAST((COUNT(*) - COUNT(EmploymentType)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'Education',
    COUNT(*) - COUNT(Education),
    CAST((COUNT(*) - COUNT(Education)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'LoanPurpose',
    COUNT(*) - COUNT(LoanPurpose),
    CAST((COUNT(*) - COUNT(LoanPurpose)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'MaritalStatus',
    COUNT(*) - COUNT(MaritalStatus),
    CAST((COUNT(*) - COUNT(MaritalStatus)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'LoanTerm',
    COUNT(*) - COUNT(LoanTerm),
    CAST((COUNT(*) - COUNT(LoanTerm)) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw

UNION ALL
SELECT 
    'Default',
    COUNT(*) - COUNT([Default]),
    CAST((COUNT(*) - COUNT([Default])) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM loan_default_raw
ORDER BY NullPercent DESC;

-- BƯỚC 1.3: CHECK DATA TYPES
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'loan_default_raw'
ORDER BY ORDINAL_POSITION;

-- BƯỚC 1.4: CHECK OUTLIERS (Numerical)
SELECT 
    MIN(Age) as Min_Age, MAX(Age) as Max_Age,
    MIN(Income) as Min_Income, MAX(Income) as Max_Income,
    MIN(CreditScore) as Min_Credit, MAX(CreditScore) as Max_Credit,
    MIN(LoanAmount) as Min_Loan, MAX(LoanAmount) as Max_Loan
FROM loan_default_raw;

-- BƯỚC 1.5: CHECK CATEGORICAL VALUES
SELECT Education, COUNT(*) as Count
FROM loan_default_raw
GROUP BY Education;

SELECT EmploymentType, COUNT(*) as Count
FROM loan_default_raw
GROUP BY EmploymentType;

SELECT MaritalStatus, COUNT(*) as Count
FROM loan_default_raw
GROUP BY MaritalStatus;