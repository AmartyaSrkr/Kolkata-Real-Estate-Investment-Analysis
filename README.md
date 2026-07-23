# Kolkata-Real-Estate-Investment-Analysis
End-to-end PostgreSQL analysis of 3,000+ real estate listings in Kolkata to identify undervalued investment opportunities.

## Tech Stack & SQL Toolkit
* **Database:** PostgreSQL 18
* **IDE:** pgAdmin 4
* **SQL Capabilities Applied:**
  * **DDL / DML:** `CREATE TABLE`, `ALTER TABLE`, `COPY`, `UPDATE`
  * **Data Cleansing & Regex:** `REPLACE()`, `CAST()`, `SUBSTRING()`, `CASE WHEN`
  * **Aggregations & Pivoting:** `GROUP BY`, `HAVING`, `COUNT(*) FILTER (...)`
  * **Advanced Analytics:** Chained **CTEs**, **Subqueries**, `JOIN`
  * **Window Functions:** `RANK() OVER()`, `NTILE()`, `PERCENT_RANK() OVER()`

---

## Data Cleaning & Feature Engineering
Raw housing values were stored as messy text strings (e.g., `"1850 sqft"`, `"₹2.38 Cr"`). The data pipeline executed the following transformations:
1. **Price Standardization:** Parsed string denominations (`"Lac"`, `"Cr"`) and converted them into exact INR numeric values.
2. **Area Extraction:** Stripped units (`"sqft"`) and cast string values into clean `NUMERIC` columns.
3. **Regex Extraction:** Extracted distinct `property_type` (e.g., *3 BHK Apartment*) and `location` parameters directly from property title strings.

---

## Key Business Insights
* **Market Composition:** 2 BHK and 3 BHK apartments make up over 60% of all available inventory in Kolkata.
* **Commercial Premium:** Commercial properties (Shops, Offices) command the highest average price per square foot (~₹9,541/sqft) despite having smaller footprints.
* **Investment Opportunities:** Using `PERCENT_RANK()`, isolated top-tier neighborhoods (*Kankurgachi*, *Rajarhat*, *Ballygunge*) and identified spacious properties listing below neighborhood market averages.

---

## File Structure
* `kolkata_real_estate_analysis.sql` — Complete SQL script containing table creation, data cleaning, and analytical queries.
