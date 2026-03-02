-- Question 1
WITH first_reco AS (
    -- Get the earliest recommendation date per user and content
  SELECT
    user_id,
    content_id,
    MIN(recommended_date) AS first_recommended_date
  FROM fct_recommendations
  GROUP BY user_id, content_id
),
watch_after_reco AS (
  SELECT
    wh.watch_id,
    wh.user_id,
    wh.content_id,
    wh.watch_time_minutes,
    wh.watch_date
  FROM fct_watch_history AS wh
  JOIN first_reco AS fr
    ON wh.user_id = fr.user_id
   AND wh.content_id = fr.content_id
   AND wh.watch_date >= fr.first_recommended_date
)
SELECT
  SUM(watch_time_minutes) AS total_watch_time_mins
FROM watch_after_reco;

-- Question 2
WITH watched_q1 AS (
  SELECT
    user_id, 
    content_id, 
    watch_time_minutes
  FROM fct_watch_history
  WHERE watch_date >= DATE '2024-01-01'
    AND watch_date < DATE '2024-04-01'
), 
reco_pairs AS (
  SELECT
    DISTINCT user_id, content_id,
    MIN(recommended_date) AS first_recommended_date
  FROM fct_recommendations
  GROUP BY user_id, content_id
)
SELECT
  dc.genre, 
  CASE WHEN first_recommended_date IS NOT NULL THEN 'Recommended'
    ELSE 'Not Recommended'
  END AS bucket, 
  SUM(watch_time_minutes) AS total_watch_time
FROM watched_q1 AS wq
LEFT JOIN dim_content AS dc 
  ON wq.content_id = dc.content_id
LEFT JOIN reco_pairs AS rp 
  ON wq.user_id = rp.user_id 
    AND wq.content_id = rp.content_id
GROUP BY dc.genre, bucket 
ORDER BY dc.genre, bucket DESC;

-- Question 3
WITH watched_q1 AS (
  SELECT user_id, content_id, watch_time_minutes
  FROM fct_watch_history
  WHERE watch_date >= DATE '2024-01-01'
    AND watch_date <  DATE '2024-04-01'
),
reco_pairs AS (
  SELECT DISTINCT user_id, content_id
  FROM fct_recommendations
)
SELECT
  CASE
    WHEN watch_time_minutes < 60 THEN 'Short'
    WHEN watch_time_minutes BETWEEN 60 AND 120 THEN 'Medium'
    ELSE 'Long'
  END AS bucket,
  COUNT(*) AS total_sessions
FROM watched_q1 AS wq
JOIN reco_pairs AS rp
  ON wq.user_id = rp.user_id
 AND wq.content_id = rp.content_id
GROUP BY bucket
ORDER BY bucket DESC;