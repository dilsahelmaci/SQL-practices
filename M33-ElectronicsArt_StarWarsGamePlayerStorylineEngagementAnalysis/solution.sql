-- Question 1
WITH users_interacted_May AS (
  SELECT
    storyline_component_id,
    COUNT(DISTINCT player_id) AS player_cnt
  FROM fct_storyline_interactions
  WHERE interaction_date >= DATE '2024-05-01'
    AND interaction_date < DATE '2024-06-01'
  GROUP BY storyline_component_id
)
SELECT 
  sc.component_name, 
  COALESCE(player_cnt, 0) AS player_cnt
FROM dim_storyline_components AS sc 
LEFT JOIN users_interacted_May AS ui 
  ON sc.storyline_component_id = ui.storyline_component_id
ORDER BY player_cnt DESC; 

-- Question 2
WITH users_w_storylines AS (
  SELECT
    player_id,
    COUNT(DISTINCT storyline_component_id) AS distinct_component_cnt
  FROM fct_storyline_interactions
  WHERE interaction_date >= DATE '2024-05-01'
    AND interaction_date <  DATE '2024-06-01'
  GROUP BY player_id
  HAVING COUNT(DISTINCT storyline_component_id) >= 2
)
SELECT
  si.player_id,
  --si.storyline_component_id,
  sc.component_name,
  COUNT(si.interaction_id) AS total_interaction_cnt
FROM fct_storyline_interactions si
JOIN users_w_storylines u
  ON si.player_id = u.player_id
JOIN dim_storyline_components sc
  ON si.storyline_component_id = sc.storyline_component_id
WHERE si.interaction_date >= DATE '2024-05-01'
  AND si.interaction_date <  DATE '2024-06-01'
GROUP BY
  si.player_id,
  si.storyline_component_id,
  sc.component_name
ORDER BY
  si.player_id,
  sc.component_name;
  
-- Question 3
WITH stats_per_storyline AS (
  SELECT
    storyline_component_id,
    COUNT(*) AS interaction_cnt,
    COUNT(DISTINCT player_id) AS player_cnt
  FROM fct_storyline_interactions
  WHERE interaction_date >= DATE '2024-05-01'
    AND interaction_date <  DATE '2024-06-01'
  GROUP BY storyline_component_id
),
components_w_interaction_stats AS (
  SELECT
    sc.component_name,
    ROUND(interaction_cnt::numeric / NULLIF(player_cnt, 0), 2) AS avg_int_per_player
  FROM stats_per_storyline ss
  JOIN dim_storyline_components sc
    ON ss.storyline_component_id = sc.storyline_component_id
)
SELECT
  component_name,
  avg_int_per_player,
  DENSE_RANK() OVER (ORDER BY avg_int_per_player DESC) AS rnk
FROM components_w_interaction_stats
ORDER BY rnk, component_name;
