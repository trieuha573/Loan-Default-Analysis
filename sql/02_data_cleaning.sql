--Check duplicates
SELECT LoanID, COUNT(*) AS cnt
FROM loan_default_raw
GROUP BY LoanID
HAVING COUNT(*) > 1;

--Handle invalid values (logic cleaning)
WITH clean_data AS (
    SELECT
        LoanID,

        CASE 
            WHEN Age < 18 OR Age > 70 THEN NULL 
            ELSE CAST(Age AS INT) 
        END AS Age,

        CASE 
            WHEN Income <= 0 THEN NULL 
            ELSE CAST(Income AS FLOAT) 
        END AS Income,

        CAST(LoanAmount AS FLOAT) AS LoanAmount,
        CAST(InterestRate AS FLOAT) AS InterestRate,
        CAST(CreditScore AS INT) AS CreditScore,

        EmploymentType,
        Education,
        LoanPurpose,
        MaritalStatus,
        CAST(LoanTerm AS INT) AS LoanTerm,
        CAST([Default] AS INT) AS Defaulted
    FROM loan_default_raw
)
SELECT *
FROM clean_data;
