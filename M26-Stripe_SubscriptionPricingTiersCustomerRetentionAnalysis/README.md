# **Subscription Pricing Tiers Customer Retention Analysis**

## **Problem Overview**
As a Product Analyst on the Billing & Subscriptions team at Stripe, you are tasked with evaluating how different pricing tiers affect customer retention and lifecycle. Your team is focused on understanding customer behavior across subscription levels to refine and optimize the pricing strategy. Your goal is to analyze subscription data to determine baseline subscription counts, assess retention effectiveness, and rank pricing tiers by retention rate.

*Tables:*

*fct_subscriptions(subscription_id, customer_id, pricing_tier, start_date, end_date, renewal_status)*

---
## **Question 1**
For Quarter 3 of 2024, what is the total number of distinct customers who started a subscription for each pricing tier? This query establishes baseline subscription counts for evaluating customer retention.

## **Solution**
```sql
SELECT
  pricing_tier, 
  COUNT(DISTINCT customer_id) AS distinct_customer_cnt
FROM fct_subscriptions
WHERE start_date >= DATE '2024-07-01'
  AND start_date < DATE '2024-10-01'
GROUP BY pricing_tier; 
```

---
## **Question 2**
Using subscriptions that started in Q3 2024, for each pricing tier, what percentage of subscriptions were renewed? Subscriptions that have been renewed will have a renewal status of 'Renewed'. This breakdown will help assess retention effectiveness across tiers.

## **Solution**
```sql
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
```

---
## **Question 3**
Based on subscriptions that started in Quarter 3 of 2024, rank the pricing tiers by their retention rate. We’d like to see both the retention rate and the rank for each tier, so we can identify which pricing model keeps customers engaged the longest.

## **Solution**
```sql
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
```