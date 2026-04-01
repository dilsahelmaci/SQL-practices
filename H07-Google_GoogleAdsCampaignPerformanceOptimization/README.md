# **Google Ads Campaign Performance Optimization**

## **Problem Overview**
You are a Data Analyst on the Google Ads Performance team working to optimize ad campaign strategies. The goal is to assess the diversity of ad formats, identify high-reach campaigns, and evaluate the return on investment across different campaign segments. Your team will use these insights to make strategic budget allocations and targeting adjustments for future campaigns.

*Tables:*

*fct_ad_performance(campaign_id, ad_format, impressions, clicks, cost, revenue, campaign_date)*

*dim_campaign(campaign_id, segment)*

---
## **Question 1**
For each ad campaign segment, what are the unique ad formats used during July 2024? This will help us understand the diversity in our ad formats.

## **Solution**
```sql
SELECT
  c.segment,
  -- concatenates all distinct ad formats into a single readable string per segment
  STRING_AGG(DISTINCT a.ad_format, ', ' ORDER BY a.ad_format) AS ad_formats
  -- COUNT(DISTINCT a.ad_format) AS unique_format_count
FROM fct_ad_performance a
JOIN dim_campaign c
  ON a.campaign_id = c.campaign_id
WHERE a.campaign_date >= DATE '2024-07-01'
  AND a.campaign_date < DATE '2024-08-01'
GROUP BY c.segment
ORDER BY c.segment;
```

---
## **Question 2**
How many unique campaigns had at least one rolling 7-day period in August 2024 where their total impressions exceeded 1,000? We want to identify campaigns that had a high reach in at least one 7-day window during this month.

## **Solution**
```sql
WITH daily_impressions_August AS (
  SELECT
    campaign_id,
    campaign_date, 
    SUM(impressions) AS daily_impressions
  FROM fct_ad_performance
  WHERE campaign_date >= DATE '2024-08-01'
    AND campaign_date < DATE '2024-09-01'
  GROUP BY campaign_id, campaign_date
  ORDER BY campaign_id, campaign_date
),
rolling_7day AS (
  SELECT
    campaign_id, 
    campaign_date, 
    SUM(daily_impressions) OVER(
        PARTITION BY campaign_id
        ORDER BY campaign_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_impressions
  FROM daily_impressions_August
)
SELECT 
  COUNT(DISTINCT campaign_id) AS campaigns_with_high_impressions
FROM rolling_7day
WHERE rolling_impressions > 1000; 
```

---
## **Question 3**
What is the total ROI for each campaign segment in Q3 2024? And, how does it compare to the average ROI of all campaigns (return labels 'higher than average' or 'lower than average')? We will use this to identify which segments are outperforming the average.

Note 1: ROI is defined as (revenue - cost) / cost.

Note 2: For average ROI across segment, calculate the ROI per segment and then calculate the average ROI across segments.

## **Solution**
```sql
WITH segment_roi AS (
  SELECT
    c.segment, 
    ROUND((SUM(revenue) - SUM(cost))::numeric / NULLIF(SUM(cost), 0)::numeric, 2) AS roi
  FROM fct_ad_performance a 
  JOIN dim_campaign c 
    ON a.campaign_id = c.campaign_id
  WHERE a.campaign_date >= DATE '2024-07-01'
    AND a.campaign_date < DATE '2024-10-01'
  GROUP BY c.segment
)
SELECT
  segment, 
  roi, 
  CASE
    WHEN roi > AVG(roi) OVER() THEN 'higher than average'
    ELSE 'lower than average'
  END AS roi_vs_avg
FROM segment_roi
ORDER BY roi DESC;
```