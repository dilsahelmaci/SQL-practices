-- Question 1
SELECT
COUNT(photo_id) AS photo_num
FROM automatic_photo_categorization
WHERE (categorization_date BETWEEN '2024-01-01' AND '2024-01-31')
  AND photo_id IS NOT NULL; 

-- Question 2
SELECT
  COUNT(DISTINCT user_id) AS user_num
FROM automatic_photo_categorization
WHERE categorization_date BETWEEN '2024-02-01' AND '2024-02-29'; 

-- Question 3
SELECT
  user_id, 
  COUNT(photo_id) AS total_categorized_photos
FROM automatic_photo_categorization
WHERE categorization_date BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY user_id; 