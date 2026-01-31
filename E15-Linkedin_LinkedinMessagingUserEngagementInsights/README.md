# **LinkedIn Messaging: User Engagement Insights**

## **Problem Overview**
You are a Product Analyst on the LinkedIn Messaging team focused on understanding user engagement with messaging features. Your team is interested in analyzing messaging patterns to identify key metrics that reflect user interaction and engagement levels. The aim is to leverage these insights to enhance the professional communication experience on the platform.

*Tables:*

*fct_messages(message_id, user_id, message_sent_date)*

---
## **Question 1**

What is the total number of messages sent during April 2024? This information will help us quantify overall engagement as a baseline for targeted product enhancements.

## **Solution**
```sql
SELECT
  COUNT(*) AS total_messages
FROM fct_messages
WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30'; 
```

---
## **Question 2**

What is the average number of messages sent per user during April 2024? Round your result to the nearest whole number. This metric provides insight into individual engagement levels for refining our communication features.

## **Solution 1**
```sql
WITH total_message_per_user AS(
  SELECT
    user_id, 
    COUNT(*) AS total_messages
  FROM fct_messages
  WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30'
  GROUP BY user_id
  )
SELECT
  ROUND(AVG(total_messages)) AS avg_message_per_user
FROM total_message_per_user; 
```

## **Solution 2**
```sql
SELECT
  ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT user_id), 0)) AS avg_message_per_user
FROM fct_messages
WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30';
```

---
## **Question 3**

What percentage of users sent more than 50 messages during April 2024? This calculation will help identify highly engaged users and support recommendations for enhancing messaging interactions.

## **Solution**
```sql
WITH total_message_per_user AS(
  SELECT
    user_id, 
    COUNT(*) AS total_messages
  FROM fct_messages
  WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30'
  GROUP BY user_id
  )
SELECT
  100.0 * COUNT(*) FILTER (WHERE total_messages > 50)
          / COUNT(*) AS pct_users_over_50
-- Another way to calculate the percentage of users sent more than 50 messages  
--  , 100.0 * SUM(CASE WHEN total_messages > 50 THEN 1 ELSE 0 END)
--          / COUNT(*) AS pct_users_over_50
FROM total_message_per_user; 
```
