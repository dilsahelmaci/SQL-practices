-- Question 1
SELECT 
  COUNT(DISTINCT artist_id)
FROM fct_artist_recommendations
WHERE recommendation_date BETWEEN '2024-04-01' AND '2024-04-30'; 

-- Question 2
SELECT
  COUNT(artist_id)
FROM fct_artist_recommendations
WHERE (recommendation_date BETWEEN '2024-05-01' AND '2024-05-31')
  AND is_new_artist; 

-- Question 3
SELECT
  TO_CHAR(recommendation_date, 'YYYY-MM') AS recommendation_month, 
  COUNT(DISTINCT artist_id) AS distinct_new_artist
FROM fct_artist_recommendations
WHERE recommendation_date BETWEEN '2024-04-01' AND '2024-06-30'
  AND is_new_artist
GROUP BY recommendation_month; 