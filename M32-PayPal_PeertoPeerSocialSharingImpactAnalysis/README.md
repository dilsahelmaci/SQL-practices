# **Peer-to-Peer Social Sharing Impact Analysis**

## **Problem Overview**
You are a Product Analyst on the Venmo social payments team investigating how social sharing behaviors influence user engagement and retention. Your team wants to understand the relationship between users' social interactions and their transaction patterns. The goal is to explore how social features might drive long-term platform usage.

*Tables:*

*fct_transactions(transaction_id, user_id, transaction_date, amount)*

*fct_social_shares(share_id, user_id, share_date)*

---
## **Question 1**
What is the floor value of the average number of transactions per user made between October 1st, 2024 and December 31st, 2024? This helps establish a baseline for user engagement on Venmo.

## **Solution**
```sql
WITH transactions_per_user AS (
  SELECT
    user_id, 
    COUNT(*) AS total_transaction_cnt
  FROM fct_transactions
  WHERE transaction_date >= DATE '2024-10-01'
    AND transaction_date <= DATE '2024-12-31'
  GROUP BY user_id
)
SELECT
  FLOOR(SUM(total_transaction_cnt) / NULLIF(COUNT(user_id), 0)) AS avg_transaction_cnt_per_user
FROM transactions_per_user;
```

---
## **Question 2**
How many distinct users executed at least one social share between October 1st, 2024 and December 31st, 2024? This helps assess the prevalence of social sharing among active users.

## **Solution**
```sql
SELECT
  COUNT(DISTINCT user_id) AS user_cnt_shared_q4
FROM fct_social_shares
WHERE share_date >= DATE '2024-10-01'
  AND share_date <= DATE '2024-12-31';
```

---
## **Question 3**
What is the average difference in days between a user's first and last transactions from October 1st, 2024 to December 31st, 2024, for users who made 2 transactions vs. 3+ transactions?

## **Solution**
## Approach 1
```sql
WITH user_transaction_stats AS (
  SELECT
    user_id,
    COUNT(*) AS transaction_count,
    MAX(transaction_date) - MIN(transaction_date) AS days_diff
  FROM fct_transactions
  WHERE transaction_date >= DATE '2024-10-01'
    AND transaction_date <  DATE '2025-01-01'
  GROUP BY user_id
  HAVING COUNT(*) >= 2
)
SELECT
  CASE
    WHEN transaction_count = 2 THEN '2 transactions'
    ELSE '3+ transactions'
  END AS transaction_group,
  ROUND(AVG(days_diff)::numeric, 2) AS avg_days_between_first_last_transaction
FROM user_transaction_stats
GROUP BY 1
ORDER BY 1;
```

## Approach 2
```sql
WITH user_transactions_q4 AS (
  SELECT
    user_id,
    MIN(transaction_date) AS first_transaction_date, 
    MAX(transaction_date) AS last_transaction_date,
    COUNT(transaction_id) AS transaction_cnt
  FROM fct_transactions
  WHERE transaction_date >= DATE '2024-10-01'
    AND transaction_date <= DATE '2024-12-31'
  GROUP BY user_id
),
user_transactions_day_diff AS (
  SELECT
    user_id, 
    transaction_cnt, 
    last_transaction_date - first_transaction_date AS days_diff
  FROM user_transactions_q4
  WHERE transaction_cnt >= 2
)
SELECT
  ROUND(AVG(CASE WHEN transaction_cnt = 2 THEN days_diff END), 2) AS avg_day_diff_2_transactions, 
  ROUND(AVG(CASE WHEN transaction_cnt >= 3 THEN days_diff END), 2) AS avg_day_diff_3_transactions
FROM user_transactions_day_diff; 
```