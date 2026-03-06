-- Question 1
SELECT
  ROUND(AVG(interaction_duration)) AS avg_int_duration
FROM fct_user_interactions
WHERE interaction_date >= DATE '2024-04-01'
  AND interaction_date < DATE '2024-05-01'
  AND content_type = 'live sports commentary'; 

-- Question 2
SELECT
  COUNT(DISTINCT user_id) AS total_user_cnt
FROM fct_user_interactions
WHERE interaction_date >= DATE '2024-05-01'
  AND interaction_date < DATE '2024-06-01'
  AND content_type IN ('live sports commentary', 'highlights'); 
  
-- Question 3
WITH interactions_May AS (
  SELECT
    user_id, 
    interaction_duration, 
    category_id
  FROM fct_user_interactions
  WHERE interaction_date >= DATE '2024-05-01'
    AND interaction_date < DATE '2024-06-01'
    AND content_type = 'live sports commentary'
)
SELECT 
  sc.category_name,
  SUM(i.interaction_duration) AS total_interaction_time
FROM interactions_May AS i 
JOIN dim_sports_categories AS sc
  ON i.category_id = sc.category_id
GROUP BY sc.category_name
ORDER BY total_interaction_time DESC, category_name
LIMIT 3; 
