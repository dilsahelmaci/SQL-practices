WITH ranked_transactions AS (
  SELECT 
    user_id, 
    spend,
    transaction_date,
    -- to rank the users' transactions based on date
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) AS txn_rank
  FROM transactions
)

SELECT
  user_id,
  spend, 
  transaction_date
FROM ranked_transactions
-- to select only 3rd transaction of each user
WHERE txn_rank = 3;