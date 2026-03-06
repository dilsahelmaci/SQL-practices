-- Question 1
SELECT
  programming_language, 
  ROUND(AVG(coding_speed_improvement), 2) AS avg_coding_speed_improvement
FROM fct_code_suggestions
WHERE suggestion_date >= DATE '2024-04-01'
  AND suggestion_date < DATE '2024-05-01'
GROUP BY programming_language
ORDER BY avg_coding_speed_improvement;

-- Question 2
SELECT
  programming_language, 
  MIN(error_reduction_percentage) AS min_error_reduction_pct
FROM fct_code_suggestions
WHERE suggestion_date >= DATE '2024-04-01'
  AND suggestion_date < DATE '2024-05-01'
GROUP BY programming_language
ORDER BY min_error_reduction_pct DESC;
  
-- Question 3
WITH stats_per_identifier AS (
  SELECT
    programming_language || ' ' || complexity_level AS identifier,
    ROUND(AVG(coding_speed_improvement), 2) AS avg_coding_speed_improvement,
    ROUND(AVG(error_reduction_percentage), 2) AS avg_error_reduction_percentage
  FROM fct_code_suggestions
  WHERE suggestion_date >= DATE '2024-04-01'
    AND suggestion_date < DATE '2024-05-01'
  GROUP BY 1
)
SELECT
  identifier, 
  ROUND((avg_coding_speed_improvement + avg_error_reduction_percentage) / 2, 2) AS avg_agg_improvement
FROM stats_per_identifier
ORDER BY avg_agg_improvement DESC
LIMIT 1; 
