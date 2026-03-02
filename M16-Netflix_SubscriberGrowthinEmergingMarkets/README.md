# **Subscriber Growth in Emerging Markets**

## **Problem Overview**
As a Data Analyst on the Netflix Marketing Data Team, you are tasked with analyzing the efficiency of marketing spend in various emerging markets. Your analysis will focus on understanding the allocation of marketing budgets and the resulting subscriber acquisition. The end goal is to provide insights that will guide the team in optimizing marketing strategies and budget distribution across different countries.

*Tables:*

*fact_marketing_spend(spend_id, country_id, campaign_date, amount_spent)*

*fact_daily_subscriptions(subscription_id, country_id, signup_date, num_new_subscribers)*

*dimension_country(country_id, country_name)*

---
## **Question 1**

Retrieve the total marketing spend in each country for Q1 2024 to help inform budget distribution across regions.

## **Solution**
```sql
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
```

---
## **Question 2**
List the number of new subscribers acquired in each country (with name) during January 2024, renaming the subscriber count column to 'new_subscribers' for clearer reporting purposes.

## **Solution**
```sql
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
```

---
## **Question 3**
Determine the average marketing spend per new subscriber for each country in Q1 2024 by rounding up to the nearest whole number to evaluate campaign efficiency.

## **Solution**
```sql
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
```