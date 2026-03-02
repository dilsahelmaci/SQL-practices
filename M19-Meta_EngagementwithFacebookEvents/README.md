# **Engagement with Facebook Events**

## **Problem Overview**
As a Data Scientist on the Facebook Events Discovery team, you are tasked with analyzing user interaction with event recommendations to enhance the relevance of these suggestions. Your goal is to identify which event categories receive the most user clicks, determine if users are engaging with events in their preferred categories, and understand user engagement patterns by analyzing click data. This analysis will help optimize recommendation algorithms to increase user satisfaction and event attendance.

*Tables:*

*fct_event_clicks(click_id, user_id, event_id, click_date)*

*dim_events(event_id, category_name)*

*dim_users(user_id, first_name, last_name, preferred_category)*

---
## **Question 1**
How many times did users click on event recommendations for each event category in March 2024? Show the category name and the total clicks.

## **Solution**
```sql
-- For each event category, # of clicks in March 2024 --> category : total # of clicks
WITH clicks_March AS (
  SELECT
    event_id, 
    click_date
  FROM fct_event_clicks
  WHERE click_date >= DATE '2024-03-01'
    AND click_date < DATE '2024-04-01'
)
SELECT 
  e.category_name, 
  COALESCE(COUNT(cm.event_id), 0) AS total_clicks
FROM dim_events AS e 
LEFT JOIN clicks_March AS cm 
  ON e.event_id = cm.event_id
GROUP BY e.category_name; 
```

---
## **Question 2**
For event clicks in March 2024, identify whether each user clicked on an event in their preferred category. Return the user ID, event category, and a label indicating if it was a preferred category ('Yes' or 'No').

## **Solution**
```sql
WITH click_events_per_user AS (
  SELECT
    fec.user_id, 
    fec.event_id,
    de.category_name
  FROM fct_event_clicks AS fec
  LEFT JOIN dim_events AS de
    ON fec.event_id = de.event_id
  WHERE click_date >= DATE '2024-03-01'
    AND click_date < DATE '2024-04-01'
)
SELECT 
  ce.user_id, 
  ce.category_name AS event_category, 
  --du.preferred_category,
  CASE WHEN ce.category_name = du.preferred_category THEN 'Yes'
    ELSE 'No'
  END AS is_preferred
FROM click_events_per_user AS ce 
LEFT JOIN dim_users AS du 
  ON ce.user_id = du.user_id
ORDER BY 1,2; 
```

---
## **Question 3**
Generate a report that combines the user ID, their full name (first and last name), and the total clicks for events they interacted with in March 2024. Sort the report by user ID in ascending order.

## **Solution**
```sql
WITH total_click_March AS (
  SELECT
    user_id, 
    COUNT(*) AS total_clicks
  FROM fct_event_clicks
  WHERE click_date >= DATE '2024-03-01'
    AND click_date < DATE '2024-04-01'
  GROUP BY user_id
)
SELECT
  du.user_id, 
  --du.first_name || ' ' || du.last_name AS full_name,
  CONCAT(du.first_name, ' ', du.last_name) AS full_name,
  COALESCE(total_clicks, 0) AS total_clicks
FROM dim_users AS du
LEFT JOIN total_click_March AS tc 
  ON du.user_id = tc.user_id
ORDER BY 1; 
```