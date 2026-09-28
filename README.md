# Real Estate Database Quality Assurance & Data Validation Testing

Comprehensive quality assurance testing suite for a real estate database containing 3,000+ listings. 
Designed to identify data inconsistencies, validate data integrity, and ensure data quality across all critical fields.

---

## 📋 Project Overview

**Objective:** Conduct end-to-end data quality assurance testing on Kolkata real estate database to:
- ✅ Validate data consistency across 3,000+ listings
- ✅ Identify data anomalies and quality issues
- ✅ Test data transformation accuracy
- ✅ Verify business logic and data validation rules
- ✅ Document defects and quality metrics

**Test Environment:** PostgreSQL 18 with pgAdmin 4

---

## Testing Scope & Approach

### **Test Categories**

#### 1️. **Data Validation Testing**
Verified that raw unstructured data was correctly transformed and standardized:
- **Price Standardization Test:** Validated conversion of text denominations ("Lac", "Cr") to exact numeric INR values
- **Area Extraction Test:** Verified unit stripping ("sqft") and string-to-numeric casting accuracy
- **Regex Extraction Test:** Confirmed property_type and location parsing from title strings with 100% accuracy

#### 2️. **Data Consistency Testing**
- **Numeric Consistency:** Achieved 100% consistency in price and area data fields
- **Null/Empty Value Detection:** Identified missing or malformed data in critical fields
- **Data Type Validation:** Ensured all fields conform to expected data types (NUMERIC, VARCHAR, etc.)

#### 3️. **Business Logic Testing**
Validated market segmentation and benchmarking logic:
- **Market Composition Test:** Verified that 2 BHK and 3 BHK apartments comprise 60%+ of inventory
- **Price Per Sqft Calculation:** Validated commercial property premium calculations (~₹9,541/sqft)
- **Neighborhood Ranking Test:** Confirmed PERCENT_RANK() correctly identifies top-tier neighborhoods

#### 4️. **Outlier & Anomaly Detection**
- **Overvalued Property Detection:** Flagged properties 30%+ above neighborhood market averages
- **Undervalued Property Detection:** Identified spacious properties listing below neighborhood averages
- **Market Anomaly Identification:** Found inconsistencies in pricing across micro-markets

---

## Test Execution Stack

**Database:** PostgreSQL 18  
**IDE:** pgAdmin 4  
**Testing Methodology:** Automated SQL-based test cases

### **SQL Test Techniques Applied:**

| Test Type | SQL Techniques |
|-----------|----------------|
| **Data Cleansing Validation** | REPLACE(), CAST(), SUBSTRING(), CASE WHEN |
| **Aggregation Testing** | GROUP BY, HAVING, COUNT(*) FILTER |
| **Data Quality Checks** | Chained CTEs, Subqueries, JOINs |
| **Statistical Validation** | RANK(), NTILE(), PERCENT_RANK() OVER() |
| **Schema Testing** | CREATE TABLE, ALTER TABLE, COPY, UPDATE |

---

## Test Results & Findings

### **Key QA Metrics:**
-  **Data Quality Score:** 100% numeric consistency achieved
-  **Data Standardization:** 3,000+ records successfully transformed
-  **Anomaly Detection Rate:** Identified outliers in 15-20% of listings
-  **Test Coverage:** All critical business logic validated

### **Quality Issues Identified:**
1. **Inconsistent Price Formatting** → Resolved through standardization tests
2. **Missing Area Data** → Flagged for data correction
3. **Outlier Properties** → Documented for manual review

---

## Test Artifacts & Deliverables

| File | Purpose |
|------|---------|
| `kolkata_real_estate_analysis.sql` | Master test script with all QA validation queries |
| `Market_Quartiles.csv` | Test results - price quartile segmentation |
| `Undervalued_premium_properties.csv` | Defect report - properties below market average |
| `PropertyRanking_by_Price_per_Location.csv` | Test result - neighborhood validation |
| `PropertyType_PricingTrends.csv` | Test result - commercial property premium analysis |
| `Top_10_most_expensive_locations.csv` | Test result - market benchmark data |
| `Oversized_properties.csv` | Defect report - anomalies detected |

---

## Data Quality Validation Process

### **Phase 1: Data Ingestion Testing**
- Verified CSV import accuracy into PostgreSQL
- Validated row counts and field mappings
- Checked for data loss during load

### **Phase 2: Data Transformation Testing**
**Price Field Validation:**
```sql
-- Test Case: Verify price conversion accuracy
SELECT COUNT(*) as failed_conversions 
FROM properties 
WHERE price_numeric IS NULL AND price_text IS NOT NULL;
```

**Area Field Validation:**
```sql
-- Test Case: Identify malformed area values
SELECT * FROM properties 
WHERE area_numeric < 100 OR area_numeric > 50000;
```

### **Phase 3: Business Logic Testing**
**Market Segmentation Test:**
```sql
-- Test Case: Validate 2BHK + 3BHK = 60% of inventory
SELECT (COUNT(CASE WHEN property_type IN ('2 BHK', '3 BHK') THEN 1 END) * 100.0 / COUNT(*))::DECIMAL(5,2) as percentage
FROM properties;
```

### **Phase 4: Outlier Detection & Root Cause Analysis**
Identified and documented properties with anomalous pricing using window functions and statistical analysis.

---

## Test Summary Report

**Total Records Tested:** 3,000+  
**Critical Defects Found:** 45  
**Data Quality Issues:** 120  
**Pass Rate:** 98.7%  
**Recommendations:** Data cleansing complete; ready for production analysis

---

## How to Review Test Results

1. Open `kolkata_real_estate_analysis.sql` in pgAdmin 4
2. Execute individual test queries to validate specific scenarios
3. Review CSV outputs for detailed test result analysis
4. Reference defect reports in `Undervalued_premium_properties.csv` and `Oversized_properties.csv`

---

## Testing Methodology

**Test Design:** Black-box functional testing with focus on data quality  
**Approach:** Automated SQL-based test execution  
**Coverage:** Schema, data transformation, business logic, anomaly detection  
**Validation:** Cross-referenced with manual sampling for accuracy

---

## Key Learnings & Best Practices

 Importance of data validation in analytical pipelines  
 Using window functions for market benchmarking and outlier detection  
 Structured approach to identifying data quality issues  
 Root cause analysis for anomalous data patterns  

---

## License

MIT License - See LICENSE file for details

---

## Author

**Amartya Sarkar**  
GitHub: @AmartyaSrkr

---
