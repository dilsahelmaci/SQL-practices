-- Question 1
SELECT
  ROUND(
    100.0 * 
    SUM(
      CASE WHEN query_domain IN ('technology', 'science') THEN 1 ELSE 0 
      END) / COUNT(*),
    2) AS pct_tech_science_queries
FROM fct_queries
WHERE query_timestamp >= '2024-07-01'
  AND query_timestamp <  '2024-08-01';

-- Question 2
SELECT
  EXTRACT(MONTH FROM query_timestamp) AS month_of_query_timestamp, 
  COUNT(query_id) AS total_query_cnt
FROM fct_queries
WHERE query_timestamp >= '2024-07-01' 
  AND query_timestamp < '2024-10-01'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1; 
  
-- Question 3
SELECT
  q.user_id,
  u.first_name, 
  u.last_name,
  COUNT(*) AS total_query_cnt
FROM fct_queries AS q
JOIN dim_users AS u
  ON q.user_id = u.user_id
WHERE q.query_timestamp >= '2024-08-01'
  AND q.query_timestamp < '2024-09-01'
GROUP BY 1, 2, 3
ORDER BY 4 DESC
LIMIT 5; 