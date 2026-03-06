-- Question 1
WITH files_January AS (
  SELECT
    file_id,  
    LENGTH(file_name) AS file_name_lengths, 
    organization_id
  FROM fct_file_sharing
  WHERE shared_date >= DATE '2024-01-01' 
    AND shared_date < DATE '2024-02-01'
)
SELECT
  o.segment, 
  COALESCE(AVG(f.file_name_lengths), 0) AS avg_file_name_lengths
FROM dim_organization AS o
LEFT JOIN files_January AS f
  ON o.organization_id = f.organization_id
GROUP BY o.segment
ORDER BY o.segment; 

-- Question 2
SELECT
  COUNT(*) AS files_shared_cnt
FROM fct_file_sharing AS f
JOIN dim_organization AS o
  ON f.organization_id = o.organization_id
WHERE f.shared_date >= DATE '2024-02-01'
  AND f.shared_date <  DATE '2024-03-01'
  AND f.file_name LIKE (o.organization_name || '-%');

-- Question 3
SELECT
  o.segment, 
  COUNT(*) AS files_no_user_id
FROM fct_file_sharing AS f 
JOIN dim_organization AS o
  ON f.organization_id = o.organization_id
WHERE shared_date >= DATE '2024-01-01'
  AND shared_date < DATE '2024-04-01'
  AND co_editing_user_id IS NULL
GROUP BY o.segment
ORDER BY files_no_user_id DESC
LIMIT 3; 
