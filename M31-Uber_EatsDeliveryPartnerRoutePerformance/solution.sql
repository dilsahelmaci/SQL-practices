-- Question 1
SELECT
  ROUND(100.0 * SUM(CASE WHEN pickup_count > 1 THEN 1 ELSE 0 END)
    / NULLIF(COUNT(*), 0), 2) AS multiple_pickup_pct
FROM fct_delivery_routes
WHERE route_date >= DATE '2024-10-01'
  AND route_date <= DATE '2024-12-31';

-- Question 2
WITH del_time_orders AS (
  SELECT
    ROUND(AVG(CASE WHEN pickup_count = 2 THEN delivery_time END)::numeric, 2) AS avg_time_2_orders, 
    ROUND(AVG(CASE WHEN pickup_count > 2 THEN delivery_time END)::numeric, 2) AS avg_time_more_3_orders
  FROM fct_delivery_routes
  WHERE route_date >= DATE '2024-10-01'
    AND route_date <= DATE '2024-12-31'
)
SELECT 
  ABS(avg_time_more_3_orders - avg_time_2_orders) AS delivery_time_diff
FROM del_time_orders; 
  
-- Question 3
WITH pickups_earnings AS (
  SELECT
    pickup_count,
    COALESCE(earnings, ROUND(AVG(earnings) OVER()::numeric, 2)) AS earnings_updated
  FROM fct_delivery_routes
)
SELECT
  ROUND((SUM(earnings_updated)::numeric / NULLIF(SUM(pickup_count), 0))::numeric, 2) AS avg_earning_per_pickup
FROM pickups_earnings; 
