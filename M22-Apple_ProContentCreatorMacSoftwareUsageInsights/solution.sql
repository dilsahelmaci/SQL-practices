-- Question 1
SELECT
  COUNT(DISTINCT user_id) AS distinct_user_cnt
FROM fct_multimedia_usage
WHERE usage_date = DATE '2024-07-31';

-- Question 2
WITH hours_spend_per_user AS (
  SELECT
    user_id, 
    SUM(hours_spent) AS total_hrs_spent
  FROM fct_multimedia_usage
  WHERE usage_date >= DATE '2024-08-01'
      AND usage_date < DATE '2024-09-01'
  GROUP BY user_id
)
SELECT
  CEIL(SUM(total_hrs_spent)::numeric / NULLIF(COUNT(user_id), 0)) AS avg_hrs_spent
FROM hours_spend_per_user; 
  
-- Question 3
WITH actv_metrics_Sep2024 AS (
  SELECT
    usage_date,
    COUNT(DISTINCT user_id) AS distinct_user_cnt, 
    SUM(hours_spent) AS total_hrs_spent
  FROM fct_multimedia_usage
  WHERE usage_date >= DATE '2024-09-01'
    AND usage_date < DATE '2024-10-01'
  GROUP BY usage_date
  ORDER BY usage_date
), 
avg_actv_metrics AS (
  SELECT 
    ROUND(AVG(distinct_user_cnt), 2) AS avg_distinct_user_cnt, 
    ROUND(AVG(total_hrs_spent), 2) AS avg_total_hrs_spent
  FROM actv_metrics_Sep2024
)
SELECT 
  *
FROM actv_metrics_Sep2024
WHERE distinct_user_cnt > (SELECT avg_distinct_user_cnt FROM avg_actv_metrics)
  AND total_hrs_spent > (SELECT avg_total_hrs_spent FROM avg_actv_metrics); 