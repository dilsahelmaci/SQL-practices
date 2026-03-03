# **Pro Content Creator Mac Software Usage Insights**
As a Product Analyst on the Mac software team, you are tasked with understanding user engagement with multimedia tools. Your team aims to identify key usage patterns and determine how much time users spend on these tools. The end goal is to use these insights to enhance product features and improve user experience.

## **Problem Overview**

*Tables:*

*fct_multimedia_usage(user_id, usage_date, hours_spent)*

---
## **Question 1**
As a Product Analyst on the Mac software team, you need to understand the engagement of professional content creators with multimedia tools. What is the number of distinct users on the last day in July 2024?

## **Solution**
```sql
SELECT
  COUNT(DISTINCT user_id) AS distinct_user_cnt
FROM fct_multimedia_usage
WHERE usage_date = DATE '2024-07-31';
```

---
## **Question 2**
As a Product Analyst on the Mac software team, you are assessing how much time professional content creators spend using multimedia tools. What is the average number of hours spent by users during August 2024? Round the result up to the nearest whole number.

## **Solution**
```sql
WITH hours_spend_per_user AS (
  SELECT
    user_id, 
    SUM(hours_spent) AS total_hrs_spent
  FROM fct_multimedia_usage
  WHERE usage_date >= DATE '2024-08-01'
      AND usage_date < DATE '2024-09-01'
  GROUP BY user_id
)
SELECT
  CEIL(SUM(total_hrs_spent)::numeric / NULLIF(COUNT(user_id), 0)) AS avg_hrs_spent
FROM hours_spend_per_user; 
```

---
## **Question 3**
As a Product Analyst on the Mac software team, you are investigating exceptional daily usage patterns in September 2024. For each day, determine the distinct user count and the total hours spent using multimedia tools. Which days have both metrics above the respective average daily values for September 2024?

## **Solution**
```sql
WITH actv_metrics_Sep2024 AS (
  SELECT
    usage_date,
    COUNT(DISTINCT user_id) AS distinct_user_cnt, 
    SUM(hours_spent) AS total_hrs_spent
  FROM fct_multimedia_usage
  WHERE usage_date >= DATE '2024-09-01'
    AND usage_date < DATE '2024-10-01'
  GROUP BY usage_date
  ORDER BY usage_date
), 
avg_actv_metrics AS (
  SELECT 
    ROUND(AVG(distinct_user_cnt), 2) AS avg_distinct_user_cnt, 
    ROUND(AVG(total_hrs_spent), 2) AS avg_total_hrs_spent
  FROM actv_metrics_Sep2024
)
SELECT 
  *
FROM actv_metrics_Sep2024
WHERE distinct_user_cnt > (SELECT avg_distinct_user_cnt FROM avg_actv_metrics)
  AND total_hrs_spent > (SELECT avg_total_hrs_spent FROM avg_actv_metrics); 
```