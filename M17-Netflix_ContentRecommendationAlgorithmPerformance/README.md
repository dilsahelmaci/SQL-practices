# **Content Recommendation Algorithm Performance**

## **Problem Overview**
You are a Data Analyst on the Content Discovery Team at Netflix, tasked with evaluating the impact of the recommendation algorithm on user engagement. Your team is focused on assessing how recommendations affect total watch time and categorizing user watch sessions to identify engagement patterns. The end goal is to refine the recommendation engine to enhance user satisfaction and drive more diverse content exploration.

*Tables:*

*fct_watch_history(watch_id, user_id, content_id, watch_time_minutes, watch_date)*

*dim_content(content_id, title, genre, release_date)*

*fct_recommendations(recommendation_id, user_id, content_id, recommended_date)*

---
## **Question 1**
What is the total watch time for content after it was recommended to users? To correctly attribute watch time to the recommendation, it is critical to only include watch time after the recommendation was made to the user. A content could get recommended to a user multiple times. If so, we want to use the first date that the content was recommended to a user.

## **Solution**
```sql
WITH first_reco AS (
    -- Get the earliest recommendation date per user and content
  SELECT
    user_id,
    content_id,
    MIN(recommended_date) AS first_recommended_date
  FROM fct_recommendations
  GROUP BY user_id, content_id
),
watch_after_reco AS (
  SELECT
    wh.watch_id,
    wh.user_id,
    wh.content_id,
    wh.watch_time_minutes,
    wh.watch_date
  FROM fct_watch_history AS wh
  JOIN first_reco AS fr
    ON wh.user_id = fr.user_id
   AND wh.content_id = fr.content_id
   AND wh.watch_date >= fr.first_recommended_date
)
SELECT
  SUM(watch_time_minutes) AS total_watch_time_mins
FROM watch_after_reco;
```

---
## **Question 2**
The team wants to know the total watch time for each genre in first quarter of 2024, split by whether or not the content was recommended vs. non-recommended to a user.

Watch time should be bucketed into 'Recommended' by joining on both user and content, regardless of when they watched it vs. when they received the recommendation.

## **Solution**
```sql
WITH watched_q1 AS (
  SELECT
    user_id, 
    content_id, 
    watch_time_minutes
  FROM fct_watch_history
  WHERE watch_date >= DATE '2024-01-01'
    AND watch_date < DATE '2024-04-01'
), 
reco_pairs AS (
  SELECT
    DISTINCT user_id, content_id,
    MIN(recommended_date) AS first_recommended_date
  FROM fct_recommendations
  GROUP BY user_id, content_id
)
SELECT
  dc.genre, 
  CASE WHEN first_recommended_date IS NOT NULL THEN 'Recommended'
    ELSE 'Not Recommended'
  END AS bucket, 
  SUM(watch_time_minutes) AS total_watch_time
FROM watched_q1 AS wq
LEFT JOIN dim_content AS dc 
  ON wq.content_id = dc.content_id
LEFT JOIN reco_pairs AS rp 
  ON wq.user_id = rp.user_id 
    AND wq.content_id = rp.content_id
GROUP BY dc.genre, bucket 
ORDER BY dc.genre, bucket DESC;
```

---
## **Question 3**
The team aims to categorize user watch sessions into 'Short', 'Medium', or 'Long' based on watch time for recommended content to identify engagement patterns.
'Short' for less than 60 minutes, 'Medium' for 60 to 120 minutes, and 'Long' for more than 120 minutes. Can you classify and count the sessions in Q1 2024 accordingly?

## **Solution**
```sql
WITH watched_q1 AS (
  SELECT user_id, content_id, watch_time_minutes
  FROM fct_watch_history
  WHERE watch_date >= DATE '2024-01-01'
    AND watch_date <  DATE '2024-04-01'
),
reco_pairs AS (
  SELECT DISTINCT user_id, content_id
  FROM fct_recommendations
)
SELECT
  CASE
    WHEN watch_time_minutes < 60 THEN 'Short'
    WHEN watch_time_minutes BETWEEN 60 AND 120 THEN 'Medium'
    ELSE 'Long'
  END AS bucket,
  COUNT(*) AS total_sessions
FROM watched_q1 AS wq
JOIN reco_pairs AS rp
  ON wq.user_id = rp.user_id
 AND wq.content_id = rp.content_id
GROUP BY bucket
ORDER BY bucket DESC;
```