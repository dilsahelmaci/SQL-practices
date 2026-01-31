-- Question 1
SELECT 
  COUNT(*) AS total_transaction
FROM fct_mobile_transactions
WHERE transaction_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND LOWER(login_method) = 'one touch';

-- Question 2
SELECT
  COUNT(DISTINCT user_id) AS Unique_Users
FROM fct_mobile_transactions
WHERE transaction_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND LOWER(login_method) = 'one touch'
  AND transaction_status = 'Success';

-- Question 3
SELECT
  SUM(
    CASE WHEN LOWER(login_method)= 'one touch' THEN 1 ELSE 0 END
  ) AS One_Touch_Transaction,   
  SUM(
    CASE WHEN LOWER(login_method)= 'standard' THEN 1 ELSE 0 END
  ) AS Standard_Transaction   
FROM fct_mobile_transactions
WHERE transaction_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND transaction_status = 'Success'; 