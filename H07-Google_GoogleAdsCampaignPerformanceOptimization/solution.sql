-- Question 1
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

-- Question 2
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
  
-- Question 3
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
