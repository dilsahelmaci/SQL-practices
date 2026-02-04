-- Question 1
SELECT
  COUNT(DISTINCT user_id) AS users_added_recommended_tracks
FROM tracks_added
WHERE added_date BETWEEN '2024-10-01' AND '2024-10-31'
  AND is_recommended; 

-- Question 2
SELECT
  ROUND(AVG(total_recommendation)::numeric, 1) AS avg_track_added
FROM (
  SELECT
    user_id, 
    COUNT(is_recommended) AS total_recommendation
  FROM tracks_added
  WHERE added_date BETWEEN '2024-10-01' AND '2024-10-31'
    AND is_recommended
  GROUP BY user_id
) recommendation_per_user;

-- Question 3
SELECT
  DISTINCT tracks_added.user_id,
  user_name
FROM tracks_added
INNER JOIN users
  ON tracks_added.user_id = users.user_id
WHERE added_date = '2024-10-02'
  AND is_recommended = FALSE; 