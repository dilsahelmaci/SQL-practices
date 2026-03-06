# **Star Wars Game Player Storyline Engagement Analysis**

## **Problem Overview**
You are a Product Analyst for the Star Wars Game Development team investigating player storyline interactions. The team wants to understand how different narrative elements capture player attention and engagement. Your goal is to analyze player interaction patterns across various storyline components.

*Tables:*

*fct_storyline_interactions(interaction_id, player_id, storyline_component_id, interaction_date)*

*dim_storyline_components(storyline_component_id, component_name)*

---
## **Question 1**
For each storyline component, how many unique players interacted with that component during the entire month of May 2024? If a storyline component did not have any interactions, return the component name with the player count of 0.

## **Solution**
```sql
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
```

---
## **Question 2**
What is the total number of storyline interactions for each storyline component and player combination during May 2024? Consider only those players who have interacted with at least two different storyline components.

## **Solution**
```sql
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
```

---
## **Question 3**
Can you rank the storyline components by the average number of interactions per player during May 2024? Provide list of storyline component names and their ranking.

## **Solution**
```sql
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
  --avg_int_per_player,
  DENSE_RANK() OVER (ORDER BY avg_int_per_player DESC) AS rnk
FROM components_w_interaction_stats
ORDER BY rnk, component_name;
```