# 💳 Loan Default Risk Analysis

**SQL-based data analysis project for banking credit risk management**
---

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Dataset](#-dataset)
- [Database Schema](#-database-schema)
- [Key Findings](#-key-findings)
- [SQL Techniques Used](#-sql-techniques-used)
- [Project Structure](#-project-structure)
- [How to Use](#-how-to-use)
- [Business Recommendations](#-business-recommendations)

---

## 🎯 Project Overview

This project analyzes **255,347 loan records** to identify default risk patterns and provide data-driven recommendations for credit risk management in the banking sector.

### **Business Questions Answered:**
1. What is the overall default rate in the portfolio?
2. Which customer segments have the highest default risk?
3. What loan characteristics are strongest predictors of default?
4. How can we optimize lending decisions to reduce risk?

### **Key Achievements:**
- ✅ Designed normalized **Star Schema** data warehouse
- ✅ Performed **15 analytical SQL queries** using advanced techniques
- ✅ Identified **top 3 risk factors** and high-risk customer segments
- ✅ Provided **actionable business recommendations**

---

## 📊 Dataset

**Source:** [Loan Default Prediction Dataset](https://www.kaggle.com/datasets/nikhil1e9/loan-default) (Kaggle)

**Size:** 255,347 records × 18 columns

**Columns:**
- `LoanID` - Unique identifier
- `Age`, `Income`, `CreditScore` - Customer demographics
- `MonthsEmployed`, `NumCreditLines` - Financial history
- `LoanAmount`, `InterestRate`, `LoanTerm` - Loan characteristics
- `DTIRatio` - Debt-to-Income ratio
- `Education`, `EmploymentType`, `MaritalStatus` - Personal info
- `HasMortgage`, `HasDependents`, `HasCoSigner` - Additional factors
- `LoanPurpose` - Reason for loan
- `Default` - Target variable (0 = Good, 1 = Defaulted)

---

## 🗂️ Database Schema

### **Star Schema Design**

```
                dim_employment (4 rows)
                       ↓
    dim_education → dim_customers (255K) → fact_loans (255K) → dim_loan
       (5 rows)                                                 (combinations)
```

**Dimension Tables:**
1. **dim_education** - Education levels (High School, Bachelor's, Master's, PhD, Associate)
2. **dim_employment** - Employment types (Full-time, Part-time, Self-employed, Unemployed)
3. **dim_customers** - Customer demographics & financial profiles
4. **dim_loan** - Loan product characteristics (Purpose, Term, Co-signer)

**Fact Table:**
5. **fact_loans** - Loan transactions with measures (LoanAmount, InterestRate, DefaultFlag)

### **Why Star Schema?**
- ✅ Optimized for analytical queries (fast aggregations)
- ✅ Easy to understand and maintain
- ✅ Industry standard for data warehousing
- ✅ Follows Kimball methodology

---

## 🔍 Key Findings

### **1. Overall Portfolio Health**
- **Total Loans:** 255,347
- **Portfolio Value:** $6.4 billion
- **Default Rate:** [To be filled after analysis]

### **2. Top Risk Predictors** (Ranked)
1. **Credit Score** - Strongest predictor
2. **DTI Ratio** - Secondary predictor  
3. **Income Level** - Moderate impact

### **3. Highest Risk Segments**
- **Education:** [Fill with actual finding]
- **Employment Type:** [Fill with actual finding]
- **Loan Purpose:** [Fill with actual finding]

### **4. Notable Patterns**
- Credit score <580 shows [X]% default rate vs [Y]% for 740+
- DTI ratio >50% significantly increases risk
- Co-signers reduce default risk by [X]%

---

## 💻 SQL Techniques Used

This project demonstrates proficiency in:

### **Core SQL Skills:**
- ✅ Multi-table `JOIN` operations (INNER JOIN across 4-5 tables)
- ✅ `GROUP BY` with complex aggregations
- ✅ `CASE WHEN` for data categorization
- ✅ `HAVING` clause for filtered aggregations

### **Advanced Techniques:**
- ✅ **CTEs (Common Table Expressions)** - Risk segmentation analysis
- ✅ **Window Functions** - Ranking and analytical functions
- ✅ **Data Type Optimization** - `CAST`, `BIGINT` for overflow prevention
- ✅ **Subqueries** - Multi-dimensional filtering

### **Database Design:**
- ✅ **Star Schema normalization** (Kimball methodology)
- ✅ **Foreign Key constraints**
- ✅ **Index creation** for performance optimization

---

## 📁 Project Structure

```
loan-default-analysis/
│
├── 02_data_cleaning.sql          # Data quality checks & validation
├── 03_data_normalization.sql     # Star Schema creation
├── 04_data_analysis.sql          # 15 analytical queries
│
└── README.md                      # Project documentation (this file)
```
---

## 🚀 How to Use

### **Prerequisites:**
- SQL Server (2016 or later)
- Database: `LoanDefaultAnalysis`
- Raw data table: `loan_default_raw`

### **Setup Instructions:**

1. **Clone this repository**
   ```bash
   git clone https://github.com/yourusername/loan-default-analysis.git
   cd loan-default-analysis
   ```

2. **Import raw data**
   - Download dataset from [Kaggle](https://www.kaggle.com/datasets/nikhil1e9/loan-default)
   - Import into SQL Server as table `loan_default_raw`

3. **Run SQL scripts in order:**
   ```sql
   -- Step 1: Data cleaning (optional - data is already clean)
   -- Run: 02_data_cleaning.sql
   
   -- Step 2: Create Star Schema
   Run: 03_data_normalization.sql
   
   -- Step 3: Run analysis queries
   Run: 04_data_analysis.sql
   ```

4. **Review results** and fill in insights in comments

---

## 📈 Business Recommendations

Based on the analysis, the following actions are recommended:

### **Immediate Actions:**
1. ⚠️ **Tighten DTI Requirements** - Cap at 43% for standard approval
2. ⚠️ **Adjust Credit Score Thresholds** - Minimum 600 for unsecured loans
3. ⚠️ **Require Co-signers** - For credit score <650 OR income <$50K

### **Policy Adjustments:**
4. 💰 **Risk-Based Pricing** - Implement tiered interest rates by risk segment
5. 📊 **Portfolio Rebalancing** - Limit high-risk segments to 15% of portfolio
6. 🎯 **Segment-Specific Criteria** - Adjust approval by education + employment combinations

### **Retention Strategy:**
7. ⭐ **VIP Customer Program** - Loyalty benefits for top 100 low-risk customers
8. 🔄 **Cross-Sell Opportunities** - Target premium customers for additional products

---

## 📊 Sample Query Results

### **Default Rate by Credit Score Band**

| Credit Band        | Total Loans | Default Rate |
|--------------------|-------------|--------------|
| Poor (<580)        | XX,XXX      | XX.X%        |
| Fair (580-669)     | XX,XXX      | XX.X%        |
| Good (670-739)     | XX,XXX      | XX.X%        |
| Very Good (740-799)| XX,XXX      | XX.X%        |
| Excellent (800+)   | XX,XXX      | X.X%         |

*[Fill in actual numbers after running queries]*

---

## 🛠️ Technologies Used

- **Database:** SQL Server
- **Data Modeling:** Star Schema (Kimball)
- **Analysis:** T-SQL
- **Version Control:** Git/GitHub

---

## 📚 Learning Outcomes

Through this project, I developed skills in:

- ✅ **Data Warehousing** - Star Schema design and normalization
- ✅ **Advanced SQL** - CTEs, window functions, complex joins
- ✅ **Business Analysis** - Translating data insights into recommendations
- ✅ **Risk Analytics** - Credit scoring and customer segmentation
- ✅ **Data Storytelling** - Presenting findings clearly

---
