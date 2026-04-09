# **Google Monetization and Distribution Performance**

## **Problem Overview**
You are a Data Analyst on the Google Play Developer Ecosystem team. Your team is focused on understanding how different app categories and monetization models influence developer revenue and app distribution. The goal is to provide strategic insights to optimize developer monetization strategies and enhance platform engagement.

*Tables:*

*fct_app_revenue(app_id, category_id, revenue_date, revenue_amount)*

*dim_app_category(category_id, category_name)*

*dim_monetization_model(app_id, monetization_type)*

---
## **Question 1**
For the month of April 2024, which app categories generated the highest total revenue (top 10 only)? This insight will be used to refine monetization strategies for developers.

## **Solution**
```sql
SELECT
  r.category_id, 
  c.category_name, 
  SUM(revenue_amount) AS total_revenue
FROM fct_app_revenue r 
JOIN dim_app_category c 
  ON r.category_id = c.category_id
WHERE DATE_TRUNC('month', revenue_date) = DATE '2024-04-01'
GROUP BY r.category_id, c.category_name
ORDER BY total_revenue DESC
LIMIT 10; 
```

---
## **Question 2**
During the second quarter of 2024, how does the weekly revenue ranking of each app category change? The team will use this analysis to identify performance trends and adjust engagement efforts.

## **Solution**
```sql
WITH revenue_second_quarter AS (
  SELECT
    category_id, 
    DATE_TRUNC('week', revenue_date) AS revenue_weekly,
    revenue_amount
  FROM fct_app_revenue
  WHERE revenue_date >= DATE '2024-04-01'
    AND revenue_date < DATE '2024-07-01'
),
revenue_weekly_categories AS (  
  SELECT
    rsq.category_id, 
    c.category_name, 
    rsq.revenue_weekly, 
    SUM(revenue_amount) AS weekly_total_revenue
  FROM revenue_second_quarter rsq 
  JOIN dim_app_category c 
    ON rsq.category_id = c.category_id
  GROUP BY rsq.category_id, c.category_name, rsq.revenue_weekly
)
SELECT
  category_id, 
  category_name, 
  revenue_weekly,
  weekly_total_revenue,
  DENSE_RANK() OVER(PARTITION BY revenue_weekly ORDER BY weekly_total_revenue DESC) AS rnk
FROM revenue_weekly_categories;
```

---
## **Question 3**
For apps using a subscription monetization model, can you give us the running total revenue by app for every day in April 2024? We are investigating a complaint from app developers about a slow down in revenue in that month.

## **Solution**
```sql
WITH subscription_monetization_models AS (
  SELECT
    app_id
  FROM dim_monetization_model
  WHERE monetization_type = 'subscription'
)
SELECT
  app_id, 
  revenue_date, 
  --revenue_amount, 
  SUM(revenue_amount) 
    OVER(PARTITION BY app_id ORDER BY revenue_date) AS running_total_revenue
FROM fct_app_revenue
WHERE app_id IN (SELECT app_id FROM subscription_monetization_models)
  AND (revenue_date >= DATE '2024-04-01'
        AND revenue_date < DATE '2024-05-01')
ORDER BY app_id, revenue_date; 
```