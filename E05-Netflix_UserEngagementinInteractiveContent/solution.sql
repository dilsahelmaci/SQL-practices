-- Question 1
SELECT 
  COUNT(DISTINCT viewer_id) AS distinct_viewers
FROM viewer_interactions
WHERE (interaction_date BETWEEN '2024-10-01' AND '2024-10-31')
  AND content_id IS NOT NULL; 

-- Question 2
SELECT
  DISTINCT(choice_description) AS unique_choice_description
FROM choices_made
WHERE choice_date BETWEEN '2024-11-01' AND '2024-11-30'
ORDER BY 1 ASC; 

-- Question 3
SELECT
  DISTINCT(viewer_id) AS unique_viewer_id
FROM viewer_interactions
WHERE (interaction_date BETWEEN '2024-12-01' AND '2024-12-31')
  AND interaction_type = 'pause'; 