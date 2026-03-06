-- Question 1
SELECT
  pricing_tier, 
  COUNT(DISTINCT customer_id) AS distinct_customer_cnt
FROM fct_subscriptions
WHERE start_date >= DATE '2024-07-01'
  AND start_date < DATE '2024-10-01'
GROUP BY pricing_tier; 

-- Question 2
WITH subs_stats_per_tier AS (
  SELECT
    pricing_tier, 
    SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END) AS renewed_subscriptions,
    COUNT(*) AS all_subscriptions
  FROM fct_subscriptions
  WHERE start_date >= DATE '2024-07-01'
    AND start_date < DATE '2024-10-01'
  GROUP BY pricing_tier
)
SELECT
  pricing_tier, 
  ROUND(100.0 * renewed_subscriptions / NULLIF(all_subscriptions, 0), 2) AS renewed_subs_pct
FROM subs_stats_per_tier; 
  
-- Question 3
WITH subs_stats_per_tier AS (
  SELECT
    pricing_tier, 
    SUM(CASE WHEN renewal_status = 'Renewed' THEN 1 ELSE 0 END) AS renewed_subscriptions, 
    COUNT(*) AS all_subscriptions
  FROM fct_subscriptions
  WHERE start_date >= DATE '2024-07-01'
    AND start_date < DATE '2024-10-01'
  GROUP BY pricing_tier
), 
retention_rate AS (
  SELECT
    pricing_tier, 
    ROUND(renewed_subscriptions::numeric / NULLIF(all_subscriptions, 0), 2) AS retention_rate
  FROM subs_stats_per_tier
)
SELECT
  pricing_tier,
  retention_rate,
  RANK() OVER(ORDER BY retention_rate DESC) AS retention_rate_rnk
FROM retention_rate; 
