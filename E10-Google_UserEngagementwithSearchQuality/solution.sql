-- Question 1
SELECT
  COUNT(*) AS total_search_queries
FROM search_queries
WHERE (query_date BETWEEN '2024-10-01' AND '2024-10-31')
  AND (dwell_time_seconds > 30 OR clicks = 1);

-- Question 2
SELECT
  COUNT(*) AS total_search_queries
FROM search_queries
WHERE (query_date BETWEEN '2024-10-01' AND '2024-10-31')
  AND clicks = 1
  AND dwell_time_seconds > 30; 

-- Question 3
SELECT
  -- COUNT(columns) count only non-NULLs,
  -- so ignores NULLS introduced by the LEFT JOIN
  COUNT(search_queries.query_id) AS num_queries
FROM users
LEFT JOIN search_queries
  ON users.user_id = search_queries.user_id
WHERE users.signup_date BETWEEN '2024-10-01' AND '2024-10-07'; 