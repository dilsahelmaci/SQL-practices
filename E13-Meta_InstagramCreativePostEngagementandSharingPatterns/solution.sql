-- Question 1
SELECT
  user_id, 
  SUM(share_count) AS total_shares
FROM agg_daily_creative_shares
WHERE share_date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY user_id
HAVING SUM(share_count) > 10; 

-- Question 2
WITH agg_shares AS (
  SELECT
    user_id, 
    SUM(share_count) AS total_shares
  FROM agg_daily_creative_shares
  WHERE (share_date BETWEEN '2024-05-01' AND '2024-05-31')
    AND share_count >= 1
  GROUP BY user_id
  )
SELECT 
  AVG(total_shares) AS avg_shares
FROM agg_shares; 

-- Question 3
WITH agg_shares AS (
  SELECT
    user_id,
    SUM(share_count) AS total_shares,
    COUNT(DISTINCT share_date) AS share_days
  FROM agg_daily_creative_shares
  WHERE share_date BETWEEN '2024-04-01' AND '2024-06-30'
    AND content_type IS NOT NULL
  GROUP BY user_id
),
scored AS (
  SELECT
    user_id,
    FLOOR(total_shares::numeric / NULLIF(share_days, 0)) AS avg_shares_daily
  FROM agg_shares
)
SELECT
  user_id,
  avg_shares_daily
FROM scored
WHERE avg_shares_daily >= 5;