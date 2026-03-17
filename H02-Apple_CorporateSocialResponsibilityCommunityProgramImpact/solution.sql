-- Question 1
WITH initiatives_Jan AS (
  SELECT
    community_id, 
    participants,
    program_name
  FROM fct_philanthropic_initiatives
  WHERE event_date >= DATE '2024-01-01'
    AND event_date < DATE '2024-02-01'
)
SELECT
  c.community_name,
  i.program_name,
  SUM(i.participants) AS participants_cnt
FROM initiatives_Jan AS i  
JOIN dim_community AS c 
ON i.community_id = c.community_id
GROUP BY c.community_name, i.program_name; 

-- Question 2
WITH initiatives_Feb_ranked AS (
  SELECT
    program_id, 
    program_name, 
    community_id, 
    event_date,
    participants,
    ROW_NUMBER() OVER(PARTITION BY program_id ORDER BY event_date) AS event_rank
  FROM fct_philanthropic_initiatives
  WHERE event_date >= DATE '2024-02-01'
    AND event_date < DATE '2024-03-01'
)
SELECT
  i.program_id,
  i.program_name,
  c.community_name,
  c.region, 
  i.event_date,
  i.participants
FROM initiatives_Feb_ranked AS i
JOIN dim_community AS c
ON i.community_id = c.community_id
WHERE i.event_rank = 1; 
  
-- Question 3
WITH initiatives_Mar_ranked AS (
  SELECT
    program_id,
    community_id,
    event_date,
    participants, 
    program_name,
    ROW_NUMBER() OVER(PARTITION BY program_id ORDER BY participants DESC) AS participants_rank
  FROM fct_philanthropic_initiatives
  WHERE event_date >= DATE '2024-03-01'
    AND event_date <= DATE '2024-03-07'
)

SELECT
  i.program_id,
  i.program_name,
  c.community_name,
  c.region, 
  i.event_date,
  i.participants
FROM initiatives_Mar_ranked AS i
JOIN dim_community AS c
ON i.community_id = c.community_id
WHERE i.participants_rank = 1; 
