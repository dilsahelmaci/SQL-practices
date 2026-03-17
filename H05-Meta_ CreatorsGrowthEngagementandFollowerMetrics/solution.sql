-- Question 1
WITH total_new_followers AS (
  SELECT
    creator_id,
    content_type,
    SUM(new_followers_count) AS total_followers_count
  FROM fct_creator_content
  WHERE published_date >= DATE '2024-05-01'
    AND published_date < DATE '2024-06-01'
  GROUP BY creator_id, content_type
),
followers_count_ranked AS (
  SELECT
    content_type, 
    creator_id, 
    total_followers_count,
    RANK() OVER(PARTITION BY content_type ORDER BY total_followers_count DESC) AS rnk
  FROM total_new_followers
)
SELECT
  content_type, 
  creator_id, 
  total_followers_count
FROM followers_count_ranked
WHERE rnk = 1; 

-- Question 2
WITH aggregated_metrics AS (
  SELECT
    content_type, 
    SUM(impressions_count) AS total_impressions_count,
    SUM(likes_count) AS total_likes_count, 
    SUM(comments_count) AS total_comments_count, 
    SUM(shares_count) AS total_shares_count
  FROM fct_creator_content
  WHERE published_date >= DATE '2024-04-08'
    AND published_date < DATE '2024-04-22'
  GROUP BY content_type
)
SELECT
  content_type, 
  'Impressions' AS metric_type, 
  total_impressions_count AS metric_value
FROM aggregated_metrics
UNION ALL 
SELECT
  content_type, 
  'Likes' AS metric_type, 
  total_likes_count AS metric_value
FROM aggregated_metrics
UNION ALL 
SELECT
  content_type, 
  'Comments' AS metric_type, 
  total_comments_count AS metric_value
FROM aggregated_metrics
UNION ALL 
SELECT
  content_type, 
  'Shares' AS metric_type, 
  total_shares_count AS metric_value
FROM aggregated_metrics;
  
-- Question 3
WITH creator_content_new_followers AS (
  SELECT
  creator_id, 
  content_type, 
  SUM(new_followers_count) AS total_new_followers
FROM fct_creator_content
WHERE published_date >= DATE '2024-04-01'
  AND published_date < DATE '2024-07-01'
GROUP BY creator_id, content_type
)
SELECT
  f.creator_id,
  c.creator_name,
  f.content_type, 
  --total_new_followers,
  --SUM(total_new_followers) OVER(PARTITION BY creator_id) AS total_followers_per_creator, 
  ROUND(100.0 * f.total_new_followers / SUM(f.total_new_followers) OVER(PARTITION BY f.creator_id), 2) AS pct_of_creator_new_followers
FROM creator_content_new_followers AS f
JOIN dim_creator AS c
  ON f.creator_id = c.creator_id; 
