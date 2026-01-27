# **Instagram Creative Post Engagement and Sharing Patterns**

## **Problem Overview**
You are a Product Analyst on the Instagram Stories team focused on understanding user engagement with creative content sharing. Your team wants to identify highly engaged users and analyze sharing patterns to enhance features that promote content sharing. Your insights will guide product managers in improving user interaction and content distribution on the platform.

*Tables:*

*agg_daily_creative_shares(user_id, content_type, share_count, share_date)*

---
## **Question 1**

Which users shared creative photos or videos (i.e. total sum of shares) more than 10 times in April 2024? This analysis will help determine which users are highly engaged in content sharing.

## **Solution**
```sql
SELECT
  user_id, 
  SUM(share_count) AS total_shares
FROM agg_daily_creative_shares
WHERE share_date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY user_id
HAVING SUM(share_count) > 10; 
```

---
## **Question 2**

What is the average number of shares for creative content by users in May 2024, among users who shared at least once? We want to first get the aggregated shares per user in May 2024, and then calculate the average over all the users.

## **Solution**
```sql
WITH agg_shares AS (
  SELECT
    user_id, 
    SUM(share_count) AS total_shares
  FROM agg_daily_creative_shares
  WHERE (share_date BETWEEN '2024-05-01' AND '2024-05-31')
    AND share_count >= 1
  GROUP BY user_id
  )
SELECT 
  AVG(total_shares) AS avg_shares
FROM agg_shares;
```

---
## **Question 3**

For each Instagram user who shared creative content, what is the floor value of their average daily shares during the second quarter of 2024? Only include users with an average of at least 5 shares per day.

Note: the agg_daily_creatives_share table is on the agg_daily_creative_shares table is at the grain of content type, user, and day. So make sure you're aggregating to the user-day level, before calculating the average.

## **Solution**
```sql
WITH agg_shares AS (
  SELECT
    user_id,
    SUM(share_count) AS total_shares,
    COUNT(DISTINCT share_date) AS share_days
  FROM agg_daily_creative_shares
  WHERE share_date BETWEEN '2024-04-01' AND '2024-06-30'
    AND content_type IS NOT NULL
  GROUP BY user_id
),
scored AS (
  SELECT
    user_id,
    FLOOR(total_shares::numeric / NULLIF(share_days, 0)) AS avg_shares_daily
  FROM agg_shares
)
SELECT
  user_id,
  avg_shares_daily
FROM scored
WHERE avg_shares_daily >= 5;
```
