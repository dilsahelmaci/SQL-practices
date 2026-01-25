# **User Engagement with Search Quality**

## **Problem Overview**
As a Data Analyst on the Google Search Quality team, you are tasked with understanding user engagement with search results. Your goal is to analyze how different user interactions, such as clicking on links and spending time on the results page, impact overall satisfaction. By leveraging query data, your team aims to identify areas for improving search result relevance and enhancing the user experience.

*Tables:*

*search_queries(query_id, user_id, clicks, dwell_time_seconds, query_date)*

*users(user_id, user_name, signup_date)*

---
## **Question 1**

How many search queries had either a link click or more than 30 second dwell time in October 2024?

## **Solution**
```sql
SELECT
  COUNT(*) AS total_search_queries
FROM search_queries
WHERE (query_date BETWEEN '2024-10-01' AND '2024-10-31')
  AND (dwell_time_seconds > 30 OR clicks = 1);
```

---
## **Question 2**

Can you find out how many search queries in October 2024 were made by users who clicked on a link and spent more than 30 seconds on the search results page?

## **Solution**
```sql
SELECT
  COUNT(*) AS total_search_queries
FROM search_queries
WHERE (query_date BETWEEN '2024-10-01' AND '2024-10-31')
  AND clicks = 1
  AND dwell_time_seconds > 30; 
```

---
## **Question 3**

For users who signed up in the first week of October 2024 (e.g. October 1 - 7), how many search queries did they make in total?

## **Solution**
```sql
SELECT
  -- COUNT(columns) count only non-NULLs,
  -- so ignores NULLS introduced by the LEFT JOIN
  COUNT(search_queries.query_id) AS num_queries
FROM users
LEFT JOIN search_queries
  ON users.user_id = search_queries.user_id
WHERE users.signup_date BETWEEN '2024-10-01' AND '2024-10-07'; 
```
