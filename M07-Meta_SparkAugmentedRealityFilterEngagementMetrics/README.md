# **Spark Augmented Reality (AR) Filter Engagement Metrics**

## **Problem Overview**
As a member of the Marketing Analytics team at Meta, you are tasked with evaluating the performance of branded AR filters. Your goal is to identify which filters are driving the highest user interactions and shares to inform future campaign strategies for brands using the Spark AR platform. By analyzing engagement data, your team aims to provide actionable insights that will enhance campaign effectiveness and audience targeting.

*Tables:*

*ar_filter_engagements(engagement_id, filter_id, interaction_count, engagement_date)*

*ar_filters(filter_id, filter_name)*

---
## **Question 1**

Which AR filters have generated user interactions in July 2024? List the filters by name.

## **Solution**
```sql
SELECT
  DISTINCT ar_filter_engagements.filter_id, 
  ar_filters.filter_name
FROM ar_filter_engagements
INNER JOIN ar_filters
  ON ar_filter_engagements.filter_id = ar_filters.filter_id
WHERE ar_filter_engagements.engagement_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND ar_filter_engagements.interaction_count IS NOT NULL AND ar_filter_engagements.interaction_count > 0;
```

---
## **Question 2**

How many total interactions did each AR filter receive in August 2024? Return only filter names that received over 1000 interactions, and their respective interaction counts.

## **Solution**
```sql
SELECT
  --ar_filter_engagements.filter_id, 
  ar_filters.filter_name,
  SUM(ar_filter_engagements.interaction_count) AS total_interaction_count
FROM ar_filter_engagements
INNER JOIN ar_filters
  ON ar_filter_engagements.filter_id = ar_filters.filter_id
WHERE ar_filter_engagements.engagement_date BETWEEN '2024-08-01' AND '2024-08-31'
GROUP BY ar_filter_engagements.filter_id, ar_filters.filter_name
HAVING SUM(ar_filter_engagements.interaction_count) > 1000;
```
---
## **Question 3**

What are the top 3 AR filters with the highest number of interactions in September 2024, and how many interactions did each receive?

## **Solution**
```sql
SELECT
  ar_filter_engagements.filter_id, 
  ar_filters.filter_name,
  SUM(ar_filter_engagements.interaction_count) AS total_interaction_count
FROM ar_filter_engagements
INNER JOIN ar_filters
  ON ar_filter_engagements.filter_id = ar_filters.filter_id
WHERE ar_filter_engagements.engagement_date BETWEEN '2024-09-01' AND '2024-09-30'
GROUP BY ar_filter_engagements.filter_id, ar_filters.filter_name
ORDER BY total_interaction_count DESC
LIMIT 3;
```
