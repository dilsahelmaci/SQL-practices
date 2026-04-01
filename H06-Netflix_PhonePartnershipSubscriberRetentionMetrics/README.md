# **Phone Partnership Subscriber Retention Metrics**

## **Problem Overview**

*Tables:*

*fct_bundle_subscriptions(subscriber_id, partner_id, bundle_id, conversion_date, retention_days, engagement_score)*

*dim_telecom_partners(partner_id, partner_name)*

---
## **Question 1**
For subscribers who converted in January 2024, give us the name of the Telecom partner that led to acquiring the most new subscribers?

## **Solution**
```sql
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
FETCH FIRST 1 ROW WITH TIES;;
```

---
## **Question 2**
For each telecom partner, what is the longest number of days that a subscriber remained active after conversion and which bundle(s) did they subscribe on? For this analysis, only look at conversions between October 8th, 2024 and October 14th, 2024. If there are multiple bundles resulting in the same highest retention, return all the bundles.

## **Solution**
```sql
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
```

---
## **Question 3**
For subscribers who converted in November 2024, what is the average engagement score for each bundle within each telecom partner?

How does each bundle’s average engagement score compare to the all-time highest engagement score recorded by its respective telecom partner expressed as a percentage of that maximum?

## **Solution**
```sql
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
```