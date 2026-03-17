# **Creators Growth: Engagement and Follower Metrics**

## **Problem Overview**
You are a Data Analyst on the Creator Growth team at Meta, focused on evaluating how different content types influence creator success. Your team aims to determine which content types most effectively drive engagement and follower growth for creators. The ultimate goal is to provide creators with actionable insights to optimize their content strategies for maximum audience expansion.

*Tables:*

*fct_creator_content(content_id, creator_id, published_date, content_type, impressions_count, likes_count, comments_count, shares_count, new_followers_count)*

*dim_creator(creator_id, creator_name, category)*

---
## **Question 1**
For content published in May 2024, which creator IDs show the highest new follower growth within each content type? If a creator published multiple of the same content type, we want to look at the total new follower growth from that content type.

## **Solution**
```sql
WITH total_new_followers AS (
  SELECT
    creator_id,
    content_type,
    SUM(new_followers_count) AS total_followers_count
  FROM fct_creator_content
  WHERE published_date >= DATE '2024-05-01'
    AND published_date < DATE '2024-06-01'
  GROUP BY creator_id, content_type
),
followers_count_ranked AS (
  SELECT
    content_type, 
    creator_id, 
    total_followers_count,
    RANK() OVER(PARTITION BY content_type ORDER BY total_followers_count DESC) AS rnk
  FROM total_new_followers
)
SELECT
  content_type, 
  creator_id, 
  total_followers_count
FROM followers_count_ranked
WHERE rnk = 1; 
```

---
## **Question 2**
Your Product Manager requests a report that shows impressions, likes, comments, and shares for each content type between April 8 and 21, 2024. She specifically requests that engagement metrics are unpivoted into a single 'metric type' column.

## **Solution**
```sql
WITH aggregated_metrics AS (
  SELECT
    content_type, 
    SUM(impressions_count) AS total_impressions_count,
    SUM(likes_count) AS total_likes_count, 
    SUM(comments_count) AS total_comments_count, 
    SUM(shares_count) AS total_shares_count
  FROM fct_creator_content
  WHERE published_date >= DATE '2024-04-08'
    AND published_date < DATE '2024-04-22'
  GROUP BY content_type
)
SELECT
  content_type, 
  'Impressions' AS metric_type, 
  total_impressions_count AS metric_value
FROM aggregated_metrics
UNION ALL 
SELECT
  content_type, 
  'Likes' AS metric_type, 
  total_likes_count AS metric_value
FROM aggregated_metrics
UNION ALL 
SELECT
  content_type, 
  'Comments' AS metric_type, 
  total_comments_count AS metric_value
FROM aggregated_metrics
UNION ALL 
SELECT
  content_type, 
  'Shares' AS metric_type, 
  total_shares_count AS metric_value
FROM aggregated_metrics;
```

---
## **Question 3**
For content published between April and June 2024, can you calculate for each creator, what % of their new followers came from each content type?

## **Solution**
```sql
WITH creator_content_new_followers AS (
  SELECT
  creator_id, 
  content_type, 
  SUM(new_followers_count) AS total_new_followers
FROM fct_creator_content
WHERE published_date >= DATE '2024-04-01'
  AND published_date < DATE '2024-07-01'
GROUP BY creator_id, content_type
)
SELECT
  f.creator_id,
  c.creator_name,
  f.content_type, 
  --total_new_followers,
  --SUM(total_new_followers) OVER(PARTITION BY creator_id) AS total_followers_per_creator, 
  ROUND(100.0 * f.total_new_followers / SUM(f.total_new_followers) OVER(PARTITION BY f.creator_id), 2) AS pct_of_creator_new_followers
FROM creator_content_new_followers AS f
JOIN dim_creator AS c
  ON f.creator_id = c.creator_id; 
```