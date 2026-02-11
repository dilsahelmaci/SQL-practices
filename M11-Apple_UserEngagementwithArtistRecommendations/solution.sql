-- Question 1
SELECT
  COUNT(DISTINCT us.user_id) AS unique_users
FROM user_streams us
JOIN artist_recommendations ar
  ON us.user_id = ar.user_id AND us.artist_id = ar.artist_id
WHERE stream_date >=recommendation_date; 

-- Question 2
WITH total_stream_per_user_artist AS (
  SELECT
    us.user_id,
    us.artist_id,
    COUNT(us.stream_id) AS total_stream
  FROM user_streams us
  JOIN artist_recommendations ar
    ON us.user_id = ar.user_id AND us.artist_id = ar.artist_id
  WHERE stream_date >=recommendation_date 
    AND us.stream_date BETWEEN '2024-05-01' AND '2024-05-31'
  GROUP BY us.user_id, us.artist_id
)
SELECT
  ROUND(AVG(total_stream), 2) AS avg_total_stream
FROM total_stream_per_user_artist; 

-- Question 3
WITH unique_artist_listened_per_user AS (
  SELECT
    us.user_id, 
    COUNT(DISTINCT us.artist_id) AS unique_artist_listened
  FROM user_streams us
  JOIN artist_recommendations ar
    ON us.user_id = ar.user_id AND us.artist_id = ar.artist_id
  WHERE us.stream_date >= ar.recommendation_date
  GROUP BY us.user_id
)
SELECT
  ROUND(AVG(unique_artist_listened)) AS average_distinct_recommended_artists
FROM unique_artist_listened_per_user