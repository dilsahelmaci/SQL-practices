-- Question 1
WITH usage_q3_2024 AS (
  SELECT
    device_id, 
    SUM(usage_duration_minutes) AS total_usage_duration_min
  FROM fct_device_usage
  WHERE usage_date >= DATE '2024-07-01'
    AND usage_date <= DATE '2024-09-30'
  GROUP BY device_id
), 
  device_cat_usage AS (
SELECT
    dd.device_id, 
    u.total_usage_duration_min,
    SPLIT_PART(dd.device_name, ' ', 1) AS primary_category
  FROM dim_device AS dd 
  LEFT JOIN usage_q3_2024 AS u
    ON dd.device_id = u.device_id
)
SELECT
  primary_category, 
  COALESCE(SUM(total_usage_duration_min), 0) AS total_usage_duration_min
FROM device_cat_usage
GROUP BY primary_category;

-- Question 2
 WITH usage_q3_2024 AS (
  SELECT
    device_id, 
    SUM(usage_duration_minutes) AS total_usage_duration_min
  FROM fct_device_usage
  WHERE usage_date >= DATE '2024-07-01'
    AND usage_date <= DATE '2024-09-30'
  GROUP BY device_id
)
SELECT
  device_id, 
  CASE WHEN total_usage_duration_min < 300 THEN 'Low'
    ELSE 'High'
  END AS usage_category, 
  total_usage_duration_min
FROM usage_q3_2024; 
  
-- Question 3
-- Approach 1 
WITH usage_q3_2024 AS (
  SELECT
    service_id, 
    SUM(usage_duration_minutes) AS total_usage_duration_min
  FROM fct_device_usage
  WHERE usage_date >= DATE '2024-07-01'
    AND usage_date <= DATE '2024-09-30'
  GROUP BY service_id
), 
usage_per_service AS (
  SELECT
    s.service_id, 
    s.service_name,
    u.total_usage_duration_min, 
    SUM(total_usage_duration_min) OVER() AS total_usage_all
  FROM dim_service AS s 
  LEFT JOIN usage_q3_2024 AS u 
    ON s.service_id = u.service_id
)
SELECT
  service_name, 
  ROUND(100.0 * total_usage_duration_min / NULLIF(total_usage_all, 0), 2) AS pct_usage_duration
FROM usage_per_service 
WHERE service_name IN ('Prime Video' , 'Amazon Music'); 

-- Approach 2
WITH usage_q3_2024 AS (
  SELECT
    du.service_id,
    SUM(du.usage_duration_minutes) AS total_usage_minutes
  FROM fct_device_usage du
  WHERE du.usage_date >= DATE '2024-07-01'
    AND du.usage_date <  DATE '2024-10-01'
  GROUP BY du.service_id
),
usage_named AS (
  SELECT
    s.service_name,
    u.total_usage_minutes
  FROM usage_q3_2024 u
  JOIN dim_service s
    ON u.service_id = s.service_id
),
totals AS (
  SELECT
    SUM(total_usage_minutes) AS overall_usage_minutes,
    SUM(CASE WHEN service_name = 'Prime Video' THEN total_usage_minutes ELSE 0 END) AS prime_video_minutes,
    SUM(CASE WHEN service_name = 'Amazon Music' THEN total_usage_minutes ELSE 0 END) AS amazon_music_minutes
  FROM usage_named
)
SELECT
  ROUND(100.0 * prime_video_minutes / NULLIF(overall_usage_minutes, 0), 2) AS pct_prime_video,
  ROUND(100.0 * amazon_music_minutes / NULLIF(overall_usage_minutes, 0), 2) AS pct_amazon_music
FROM totals;