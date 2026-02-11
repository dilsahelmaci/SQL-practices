# **ChatGPT User Engagement and Query Patterns**

## **Problem Overview**
As a Product Analyst on the ChatGPT team, you are tasked with understanding user engagement patterns across different knowledge domains. Your team is particularly interested in identifying the proportion of queries related to technology and science, understanding monthly query volumes, and recognizing the most active users. The insights gained will help tailor user experience and prioritize outreach to highly engaged users.

*Tables:*

*fct_queries(query_id, user_id, query_text, query_domain, query_timestamp)*

*dim_users(user_id, first_name, last_name)*

---
## **Question 1**

What percentage of user queries in July 2024 were related to either 'technology' or 'science' domains?

## **Solution**
```sql
SELECT
  ROUND(
    100.0 * 
    SUM(
      CASE WHEN query_domain IN ('technology', 'science') THEN 1 ELSE 0 
      END) / COUNT(*),
    2) AS pct_tech_science_queries
FROM fct_queries
WHERE query_timestamp >= '2024-07-01'
  AND query_timestamp <  '2024-08-01';
```

---
## **Question 2**

Calculate the total number of queries per month in Q3 2024. Which month had the highest number of queries?

## **Solution**
```sql
SELECT
  EXTRACT(MONTH FROM query_timestamp) AS month_of_query_timestamp, 
  COUNT(query_id) AS total_query_cnt
FROM fct_queries
WHERE query_timestamp >= '2024-07-01' 
  AND query_timestamp < '2024-10-01'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1; 
```

---
## **Question 3**

Identify the top 5 users with the most queries in August 2024 by their first and last name. We want to interview our most active users and this information will be used in our outreach to these users.

## **Solution**
```sql
SELECT
  q.user_id,
  u.first_name, 
  u.last_name,
  COUNT(*) AS total_query_cnt
FROM fct_queries AS q
JOIN dim_users AS u
  ON q.user_id = u.user_id
WHERE q.query_timestamp >= '2024-08-01'
  AND q.query_timestamp < '2024-09-01'
GROUP BY 1, 2, 3
ORDER BY 4 DESC
LIMIT 5; 
```