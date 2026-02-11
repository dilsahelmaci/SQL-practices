-- Question 1
SELECT
  ROUND(
    100.0 *
    COUNT(DISTINCT CASE WHEN e.user_id IS NOT NULL THEN u.user_id END)
    / COUNT(DISTINCT u.user_id)
  , 2) AS pct_endorsed_users
FROM dim_users u
LEFT JOIN fct_skill_endorsements e
  ON e.user_id = u.user_id
 AND e.endorsement_date >= DATE '2024-07-01'
 AND e.endorsement_date <  DATE '2024-08-01';
-- Question 2
-- Alternative approach 1 
WITH per_user AS (
  SELECT
    e.user_id,
    COUNT(e.endorsement_id) AS endorsement_cnt
  FROM fct_skill_endorsements e
  JOIN dim_skills s
    ON s.skill_id = e.skill_id
  WHERE e.endorsement_date >= DATE '2024-08-01'
    AND e.endorsement_date <  DATE '2024-09-01'
    AND s.skill_category = 'TECHNICAL'
  GROUP BY e.user_id
)
SELECT
  ROUND(AVG(endorsement_cnt::numeric), 2) AS avg_endorsements_per_endorsed_user
FROM per_user;

-- Alternative approach 2
SELECT
  ROUND(AVG(endorsement_cnt::numeric), 2) AS avg_endorsements_per_endorsed_user
FROM (  
  SELECT
    e.user_id,
    COUNT(e.endorsement_id) AS endorsement_cnt
  FROM fct_skill_endorsements e
  JOIN dim_skills s
    ON s.skill_id = e.skill_id
  WHERE e.endorsement_date >= DATE '2024-08-01'
    AND e.endorsement_date <  DATE '2024-09-01'
    AND s.skill_category = 'TECHNICAL'
  GROUP BY e.user_id
) AS per_user; 
  
-- Question 3
SELECT
  ROUND(
    100.0
    * COUNT(DISTINCT CASE
        WHEN e.endorsement_date >= DATE '2024-09-01'
         AND e.endorsement_date <  DATE '2024-10-01'
        THEN e.user_id
      END)
    / COUNT(DISTINCT e.user_id)
  , 2) AS pct_users_with_sep_2024_endorsement
FROM fct_skill_endorsements e
JOIN dim_skills s
  ON s.skill_id = e.skill_id
WHERE s.skill_category = 'MANAGEMENT';