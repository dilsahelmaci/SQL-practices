# **Fan Engagement Metrics for Sports Coverage**

## **Problem Overview**
As a Product Analyst for the X sports updates platform, your team is focused on enhancing user engagement with live sports content. You need to analyze user interactions with both live sports commentary and highlights to identify patterns and preferences. The insights will help prioritize content strategies and improve the user experience during live events.

*Tables:*

*fct_user_interactions(interaction_id, user_id, content_type, interaction_duration, interaction_date, category_id)*

*dim_sports_categories(category_id, category_name)*

---
## **Question 1**
What is the average duration of user interactions with live sports commentary during April 2024? Round the result to the nearest whole number.

## **Solution**
```sql
SELECT
  ROUND(AVG(interaction_duration)) AS avg_int_duration
FROM fct_user_interactions
WHERE interaction_date >= DATE '2024-04-01'
  AND interaction_date < DATE '2024-05-01'
  AND content_type = 'live sports commentary'; 
```

---
## **Question 2**
For the month of May 2024, determine the total number of users who interacted with live sports commentary and highlights. Ensure to include users who interacted with either or both content types.

## **Solution**
```sql
SELECT
  COUNT(DISTINCT user_id) AS total_user_cnt
FROM fct_user_interactions
WHERE interaction_date >= DATE '2024-05-01'
  AND interaction_date < DATE '2024-06-01'
  AND content_type IN ('live sports commentary', 'highlights')
```

---
## **Question 3**
Identify the top 3 performing sports categories for live sports commentary based on user engagement in May 2024. Focus on those with the highest total interaction time.

## **Solution**
```sql
WITH interactions_May AS (
  SELECT
    user_id, 
    interaction_duration, 
    category_id
  FROM fct_user_interactions
  WHERE interaction_date >= DATE '2024-05-01'
    AND interaction_date < DATE '2024-06-01'
    AND content_type = 'live sports commentary'
)
SELECT 
  sc.category_name,
  SUM(i.interaction_duration) AS total_interaction_time
FROM interactions_May AS i 
JOIN dim_sports_categories AS sc
  ON i.category_id = sc.category_id
GROUP BY sc.category_name
ORDER BY total_interaction_time DESC, category_name
LIMIT 3; 
```