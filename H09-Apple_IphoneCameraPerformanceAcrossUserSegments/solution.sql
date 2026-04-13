-- Question 1
WITH avg_scores AS (
  SELECT
    user_group_id, 
    AVG(photo_quality_score) AS avg_daily_score
  FROM fct_capture_quality
  WHERE capture_date >= DATE '2024-07-01'
    AND capture_date < DATE '2024-08-01'
  GROUP BY user_group_id
)
SELECT
  s.user_group_id, 
  u.user_group_name, 
  s.avg_daily_score
FROM avg_scores AS s
JOIN dim_user_group AS u
  ON s.user_group_id = u.user_group_id
ORDER BY s.user_group_id; 

-- Question 2
WITH daily_avg AS (
  SELECT
      user_group_id,
      capture_date,
      AVG(photo_quality_score) AS avg_daily_score
  FROM fct_capture_quality
  WHERE capture_date >= DATE '2024-08-01'
      AND capture_date <= DATE '2024-08-07'
  GROUP BY user_group_id, capture_date
),
rolling_avg AS (
  SELECT
    user_group_id,
    capture_date,
    ROUND(AVG(avg_daily_score) OVER (
              PARTITION BY user_group_id
              ORDER BY capture_date
              -- calendar-based; safer since date gaps exist
              RANGE BETWEEN INTERVAL '2 days' PRECEDING AND CURRENT ROW
              -- exact 3-row window; would be safe since daily_avg had no date gaps
              --ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    )::numeric, 2) AS rolling_3day_avg
  FROM daily_avg
)
SELECT
  u.user_group_name,
  r.capture_date,
  r.rolling_3day_avg
FROM rolling_avg AS r
JOIN dim_user_group AS u
  ON r.user_group_id = u.user_group_id
ORDER BY u.user_group_name, r.capture_date;

-- Question 3
WITH daily_avg AS (
  SELECT
    user_group_id, 
    capture_date,
    ROUND(AVG(video_quality_score)::numeric, 1) AS avg_daily_score
  FROM fct_capture_quality
  WHERE capture_date >= DATE '2024-07-01'
    AND capture_date < DATE '2024-10-01'
  GROUP BY user_group_id, capture_date
), 
score_comparison AS (  
  SELECT
    user_group_id, 
    capture_date,
    avg_daily_score, 
    LEAD(avg_daily_score) OVER(PARTITION BY user_group_id ORDER BY capture_date) AS subsequent_daily_score
  FROM daily_avg
)
SELECT
  c.user_group_id, 
  c.capture_date,
  u.user_group_name,
  c.avg_daily_score, 
  c.subsequent_daily_score, 
  CASE 
    WHEN c.avg_daily_score > c.subsequent_daily_score THEN 'Positive'
    WHEN c.avg_daily_score < c.subsequent_daily_score THEN 'Negative'
    WHEN c.avg_daily_score = c.subsequent_daily_score THEN 'Same'
    ELSE 'No subsequent data'
  END AS difference
FROM score_comparison AS c
JOIN dim_user_group AS u 
  ON c.user_group_id = u.user_group_id
ORDER BY c.user_group_id, c.capture_date; 