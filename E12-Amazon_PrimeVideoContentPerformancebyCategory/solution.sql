-- Question 1
SELECT
  category, 
  SUM(views) AS total_views
FROM content_views_daily_agg
WHERE view_date BETWEEN '2024-08-01' AND '2024-08-31'
GROUP BY category; 

-- Question 2
SELECT
  category, 
  SUM(views) AS total_views
FROM content_views_daily_agg
WHERE view_date BETWEEN '2024-07-01' AND '2024-09-30'
GROUP BY category
HAVING SUM(views) > 100000; 

-- Question 3
SELECT
  category,
  SUM(views) AS total_views
FROM content_views_daily_agg
WHERE view_date BETWEEN '2024-09-01' AND '2024-09-30'
GROUP BY category
HAVING SUM(views) > 500000; 