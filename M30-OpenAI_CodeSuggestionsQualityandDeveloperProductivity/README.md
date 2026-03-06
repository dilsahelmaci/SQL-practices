# **Code Suggestions Quality and Developer Productivity**

## **Problem Overview**
You are a Product Analyst on the OpenAI Codex team, focusing on optimizing AI-driven code suggestions. Your team aims to enhance developer productivity by improving coding speed and reducing errors across various programming languages. By analyzing current performance metrics, you will identify areas for improvement and validate the effectiveness of existing code suggestions.

*Tables:*

*fct_code_suggestions(suggestion_id, developer_id, programming_language, complexity_level, coding_speed_improvement, error_reduction_percentage, suggestion_date)*

---
## **Question 1**
What is the average coding speed improvement percentage for each programming language in April 2024? This analysis will help us determine if current suggestions are effectively boosting coding speed.

## **Solution**
```sql
SELECT
  programming_language, 
  ROUND(AVG(coding_speed_improvement), 2) AS avg_coding_speed_improvement
FROM fct_code_suggestions
WHERE suggestion_date >= DATE '2024-04-01'
  AND suggestion_date < DATE '2024-05-01'
GROUP BY programming_language
ORDER BY avg_coding_speed_improvement;
```

---
## **Question 2**
For each programming language in April 2024, what is the minimum error reduction percentage observed across all AI-driven code suggestions? This will help pinpoint languages where error reduction is lagging and may need targeted improvements.

## **Solution**
```sql
SELECT
  programming_language, 
  MIN(error_reduction_percentage) AS min_error_reduction_pct
FROM fct_code_suggestions
WHERE suggestion_date >= DATE '2024-04-01'
  AND suggestion_date < DATE '2024-05-01'
GROUP BY programming_language
ORDER BY min_error_reduction_pct DESC;
```

---
## **Question 3**
For April 2024, first concatenate the programming language and complexity level to form a unique identifier. Then, using the average of coding speed improvement and error reduction percentage as a combined metric, which concatenated combination shows the highest aggregated improvement? This final analysis directly informs efforts to achieve a targeted increase in developer productivity and error reduction.

## **Solution**
```sql
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
```