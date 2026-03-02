-- Question 1
SELECT
    c.country_name,
    COALESCE(SUM(ms.amount_spent), 0) AS total_marketing_spend
FROM dimension_country AS c
LEFT JOIN fact_marketing_spend AS ms
  ON c.country_id = ms.country_id
  AND ms.campaign_date >= DATE '2024-01-01'
  AND ms.campaign_date <  DATE '2024-04-01'
GROUP BY c.country_name
ORDER BY total_marketing_spend DESC;

-- Question 2
SELECT
  c.country_id, 
  c.country_name,
  COALESCE(SUM(ds.num_new_subscribers), 0) AS new_subscribers
FROM dimension_country AS c
LEFT JOIN fact_daily_subscriptions AS ds
  ON c.country_id = ds.country_id
  AND ds.signup_date >= DATE '2024-01-01'
  AND ds.signup_date < DATE '2024-02-01'
GROUP BY c.country_id, c.country_name
ORDER BY new_subscribers DESC;
  
-- Question 3
WITH marketing_spent_q1 AS (
  SELECT
    c.country_id,
    c.country_name,
    COALESCE(SUM(ms.amount_spent), 0) AS amount_spent
  FROM dimension_country AS c
  LEFT JOIN fact_marketing_spend AS ms
    ON c.country_id = ms.country_id
    AND ms.campaign_date >= DATE '2024-01-01'
    AND ms.campaign_date <  DATE '2024-04-01'
  GROUP BY c.country_id, c.country_name
),
new_subscribers_q1 AS (
  SELECT
    c.country_id,
    c.country_name,
    COALESCE(SUM(ds.num_new_subscribers), 0) AS num_new_subscribers
  FROM dimension_country AS c
  LEFT JOIN fact_daily_subscriptions AS ds
    ON c.country_id = ds.country_id
    AND ds.signup_date >= DATE '2024-01-01'
    AND ds.signup_date <  DATE '2024-04-01'
  GROUP BY c.country_id, c.country_name
)
SELECT
  ms.country_id,
  ms.country_name,
  -- to avoid division-by-zero error for countries with no new subscribers
  CEIL(ms.amount_spent / NULLIF(ns.num_new_subscribers, 0)) AS avg_marketing_spend_per_new_subs
FROM marketing_spent_q1 AS ms
JOIN new_subscribers_q1 AS ns
  ON ms.country_id = ns.country_id
ORDER BY avg_marketing_spend_per_new_subs DESC NULLS LAST;