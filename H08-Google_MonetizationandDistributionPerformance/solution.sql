-- Question 1
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

-- Question 2
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
-- Question 3
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