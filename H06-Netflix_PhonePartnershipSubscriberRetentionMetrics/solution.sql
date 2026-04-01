-- Question 1
SELECT
    d.partner_name,
    COUNT(s.subscriber_id) AS new_subscribers
FROM fct_bundle_subscriptions s
JOIN dim_telecom_partners d
    ON s.partner_id = d.partner_id
WHERE s.conversion_date >= '2024-01-01'
    AND s.conversion_date < '2024-02-01'
GROUP BY d.partner_name
ORDER BY new_subscribers DESC
-- return the top partner including ties
FETCH FIRST 1 ROW WITH TIES;

-- Question 2
WITH longest_retention AS(
  SELECT
    partner_id, 
    subscriber_id,
    retention_days,
    bundle_id,
    RANK() OVER(PARTITION BY partner_id ORDER BY retention_days DESC) AS rnk
  FROM fct_bundle_subscriptions
  WHERE conversion_date >= DATE '2024-10-08'
    AND conversion_date < DATE '2024-10-15'
)
SELECT
  --l.partner_id, 
  d.partner_name,
  l.retention_days,
  l.bundle_id
FROM longest_retention l
JOIN dim_telecom_partners d 
  ON l.partner_id = d.partner_id
WHERE rnk = 1;
  
-- Question 3
WITH bundle_avg AS (
  SELECT
    partner_id,
    bundle_id,
    ROUND(AVG(engagement_score), 2) AS avg_score
  FROM fct_bundle_subscriptions
  WHERE conversion_date >= DATE '2024-11-01'
    AND conversion_date < DATE '2024-12-01'
  GROUP BY partner_id, bundle_id
), 
partner_max AS (  
  SELECT 
    partner_id, 
    MAX(engagement_score) AS max_score
  FROM fct_bundle_subscriptions
  GROUP BY partner_id
)
SELECT
  d.partner_name,
  b.bundle_id,
  b.avg_score,
  ROUND(100.0 * (b.avg_score / NULLIF(p.max_score, 0)), 2) AS pct_of_max
FROM bundle_avg b
JOIN partner_max p
  ON b.partner_id = p.partner_id
JOIN dim_telecom_partners d
  ON b.partner_id = d.partner_id
ORDER BY d.partner_name, b.bundle_id;
