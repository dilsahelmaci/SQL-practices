-- Question 1
SELECT
  s.store_name,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (ct.checkout_end_time - ct.checkout_start_time)) / 60.0),
    2
  ) AS avg_checkout_minutes
FROM fct_checkout_times AS ct
JOIN dim_stores AS s
  ON ct.store_id = s.store_id
WHERE ct.checkout_start_time >= '2024-07-01'
  AND ct.checkout_start_time <  '2024-08-01'
GROUP BY s.store_name;

-- Question 2
WITH checkout_minutes AS (
  SELECT
    ct.store_id,
    s.store_name,
    ct.checkout_start_time, 
    EXTRACT(HOUR FROM ct.checkout_start_time AT TIME ZONE 'Europe/Berlin') AS hour_of_day,
    EXTRACT(EPOCH FROM (ct.checkout_end_time - ct.checkout_start_time)) / 60.0
      AS checkout_minutes
  FROM fct_checkout_times ct
  JOIN dim_stores s
    ON ct.store_id = s.store_id
  WHERE ct.checkout_start_time >= '2024-07-01'
    AND ct.checkout_start_time <  '2024-08-01'
)
, slow_stores AS (
  SELECT
    store_id
  FROM checkout_minutes
  GROUP BY store_id
  HAVING AVG(checkout_minutes) > 10
)
SELECT
  cm.store_name,
  cm.hour_of_day,
  ROUND(AVG(cm.checkout_minutes), 2) AS avg_checkout_minutes
FROM checkout_minutes cm
JOIN slow_stores ss
  ON cm.store_id = ss.store_id
GROUP BY
  cm.store_name,
  cm.hour_of_day
ORDER BY
  cm.store_name,
  cm.hour_of_day;
  
-- Question 3
SELECT
  EXTRACT(HOUR FROM ct.checkout_start_time AT TIME ZONE 'Europe/Berlin') AS hour_of_day,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (ct.checkout_end_time - ct.checkout_start_time)) / 60.0),
    2
  ) AS avg_checkout_minutes
FROM fct_checkout_times ct
WHERE ct.checkout_start_time >= '2024-07-01'
  AND ct.checkout_start_time <  '2024-08-01'
GROUP BY 1
ORDER BY avg_checkout_minutes DESC
LIMIT 1;