-- Question 1
SELECT
  pharmacy_name, 
  COUNT(*) AS consultation_count
FROM fct_consultations
WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY pharmacy_name
ORDER BY consultation_count ASC
LIMIT 3; 

-- Question 2
SELECT
  DISTINCT UPPER(consultation_room_type) AS room_type_upper
FROM fct_consultations
WHERE pharmacy_name IN (
  SELECT pharmacy_name
  FROM (
    SELECT pharmacy_name, COUNT(*) AS consultation_count
    FROM fct_consultations
    WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
    GROUP BY pharmacy_name
    ORDER BY consultation_count ASC
    LIMIT 3
  )
);

-- Question 3
-- Alternative approach 1 
WITH bottom_3_pharmacies AS (
  SELECT
    pharmacy_name
  FROM fct_consultations
  WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
  GROUP BY pharmacy_name
  ORDER BY COUNT(*) ASC
  LIMIT 3
)
SELECT 
  consultation_room_type, 
  MIN(privacy_level_score) AS min_privacy_level_score
FROM fct_consultations
WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND pharmacy_name IN (SELECT pharmacy_name FROM bottom_3_pharmacies)
GROUP BY consultation_room_type;

-- Alternative approach 2
WITH bottom_3_pharmacies AS (
  SELECT
    pharmacy_name,
    COUNT(*) AS consultation_count,
    ROW_NUMBER() OVER(ORDER BY COUNT(*))
  FROM fct_consultations
  WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
  GROUP BY pharmacy_name
)

SELECT
  consultation_room_type, 
  MIN(privacy_level_score)
FROM fct_consultations
WHERE (consultation_date BETWEEN '2024-07-01' AND '2024-07-31')
  AND (pharmacy_name IN (SELECT pharmacy_name FROM bottom_3_pharmacies WHERE row_number <= 3))
GROUP BY consultation_room_type;