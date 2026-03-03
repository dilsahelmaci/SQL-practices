-- Question 1
SELECT
  merchant_category,
  SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 ELSE 0 END) AS success_cnt, 
  SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_cnt
FROM fct_transactions
WHERE transaction_date >= DATE '2024-01-01'
  AND transaction_date < DATE '2024-02-01'
GROUP BY merchant_category
ORDER BY merchant_category; 

-- Question 2
WITH transaction_success_rate AS (
  SELECT
    merchant_category, 
    ROUND(
      100.0 * COALESCE(SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 END), 0) 
      / NULLIF(COUNT(*), 0)
    , 2) AS success_rate
  FROM fct_transactions
  WHERE transaction_date >= DATE '2024-01-01'
    AND transaction_date < DATE '2024-04-01'
  GROUP BY merchant_category
)
SELECT 
  *
FROM transaction_success_rate
WHERE success_rate < 90.0
ORDER BY success_rate; 

-- Question 3
WITH transaction_cnts_per_categories AS(
  SELECT 
    merchant_category, 
    COALESCE(SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 END), 0) AS success_cnt, 
    COALESCE(SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 END), 0) AS failed_cnt
  FROM fct_transactions
  WHERE transaction_date >= DATE '2024-01-01'
    AND transaction_date <= DATE '2024-03-31'
  GROUP BY merchant_category
)

SELECT
  merchant_category, 
  'SUCCESS: ' || success_cnt || ', ' || 'FAILED: ' || failed_cnt AS transaction_data, 
  DENSE_RANK() OVER(ORDER BY success_cnt+failed_cnt DESC) AS rnk
FROM transaction_cnts_per_categories; 
