-- Question 1
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

-- Question 2
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
  
-- Question 3
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
