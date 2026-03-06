# **Capital Lending Performance for Small Business Revenue**

## **Problem Overview**
As a Business Analyst on the Stripe Capital team, you are tasked with evaluating the effectiveness of lending products for small businesses. Your goal is to understand how different levels of revenue variability impact loan repayment success rates. By analyzing these insights, your team aims to optimize lending strategies to better support small businesses with varying financial stability.

*Tables:*

*fct_loans(loan_id, business_id, loan_amount, loan_issued_date, loan_repaid)*

*dim_businesses(business_id, monthly_revenue, revenue_variability, business_size)*

---
## **Question 1**
What is the average monthly revenue for small businesses that received a loan versus those that did not receive a loan during January 2024? Use the ''business_size'' field to filter for small businesses.

## **Solution**
```sql
WITH loans_January AS (
  SELECT
    business_id, 
    loan_amount
  FROM fct_loans
  WHERE loan_issued_date >= DATE '2024-01-01'
    AND loan_issued_date < DATE '2024-02-01'
), 
small_businesses_loan_stats AS (
  SELECT 
    b.business_id, 
    b.monthly_revenue, 
    CASE WHEN l.loan_amount IS NOT NULL THEN 1 ELSE 0 END AS loan_taken
  FROM dim_businesses AS b 
  LEFT JOIN loans_January AS l 
    ON b.business_id = l.business_id
  WHERE b.business_size = 'small'
)
SELECT 
  ROUND(AVG(CASE WHEN loan_taken = 1 THEN monthly_revenue END), 2) AS revenue_for_businesses_w_loan, 
  ROUND(AVG(CASE WHEN loan_taken = 0 THEN monthly_revenue END), 2) AS revenue_for_businesses_wout_loan
FROM small_businesses_loan_stats; 
```

---
## **Question 2**
For loans issued to small businesses in January 2024, what percentage were successfully repaid? Categorize these loans based on the borrowing business’s revenue variability (low, medium, or high) using these values:

- Low: <0.1
- Medium: 0.1 - 0.3 inclusive
- High: >0.3

## **Solution**
```sql
WITH loans_January AS (
  SELECT
    business_id, 
    loan_repaid 
  FROM fct_loans
  WHERE loan_issued_date >= DATE '2024-01-01'
    AND loan_issued_date < DATE '2024-02-01'
), 
small_businesses_categories AS (
  SELECT
    business_id, 
    (CASE WHEN revenue_variability < 0.1 THEN 'Low'
         WHEN revenue_variability BETWEEN 0.1 AND 0.3 THEN 'Medium'
    ELSE 'High' END) AS revenue_categories
  FROM dim_businesses
  WHERE business_size = 'small'
)
SELECT
  bc.revenue_categories, 
  ROUND(
    100.0 * SUM(CASE WHEN l.loan_repaid = 'true' THEN 1 ELSE 0 END)
      / NULLIF(COUNT(*), 0), 2)
  AS repaid_loans_pct 
FROM small_businesses_categories AS bc 
JOIN loans_January AS l 
  ON bc.business_id = l.business_id
GROUP BY bc.revenue_categories
ORDER BY repaid_loans_pct DESC; 
```

---
## **Question 3**
For small businesses during January 2024, what is the loan repayment success rate for each revenue variability category? Order the results from the highest to the lowest success rate to assess the correlation between revenue variability and repayment reliability.

## **Solution**
```sql
WITH loans_January AS (
  SELECT
    business_id, 
    loan_repaid
  FROM fct_loans
  WHERE loan_issued_date >= DATE '2024-01-01'
    AND loan_issued_date < DATE '2024-02-01'
),
small_businesses_categories AS (
  SELECT
    business_id, 
    CASE WHEN revenue_variability < 0.1 THEN 'Low'
        WHEN revenue_variability BETWEEN 0.1 AND 0.3 THEN 'Medium'
        ELSE 'High'
    END AS revenue_category
  FROM dim_businesses
  WHERE business_size = 'small'
)
SELECT
  bc.revenue_category, 
  ROUND( 100.0 * SUM(CASE WHEN l.loan_repaid = 'true' THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0), 2) AS success_rate 
FROM small_businesses_categories AS bc 
JOIN loans_January AS l 
  ON bc.business_id = l.business_id
GROUP BY revenue_category
ORDER BY success_rate DESC; 
```