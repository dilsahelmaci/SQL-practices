-- Question 1
SELECT 
  -- COUNT only counts non-NULL values, so we omit ELSE 0.
  -- If ELSE 0 were included, COUNT would still count those rows,
  -- which would inflate the result.
  100.0 * COUNT(
    CASE 
      WHEN actual_delivery_time <= expected_delivery_time THEN 1
    END)
    / COUNT(*) AS on_time_pct
FROM fct_orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'; 

-- Question 2
WITH delivery_on_time AS (
  SELECT
  order_id,
  delivery_partner_id, 
  delivery_partner_name,
  CASE 
    WHEN actual_delivery_time <= expected_delivery_time THEN 1 ELSE 0
  END AS is_ontime
FROM fct_orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'),
delivery_per_partner AS (
  SELECT
    delivery_partner_id, 
    delivery_partner_name, 
    SUM(is_ontime) AS total_ontime, 
    COUNT(is_ontime) AS total_delivery
  FROM delivery_on_time
  GROUP BY delivery_partner_id, delivery_partner_name
)
SELECT
--  delivery_partner_id, 
  delivery_partner_name,
  ROUND(100.0 * total_ontime / total_delivery, 2) AS delivery_ontime_pct
FROM delivery_per_partner
ORDER BY delivery_ontime_pct DESC
LIMIT 5; 

-- Question 3
WITH delivery_stats AS (
  SELECT
    delivery_partner_name,
    SUM(CASE WHEN actual_delivery_time <= expected_delivery_time THEN 1 ELSE 0 END) AS on_time_deliveries,
    COUNT(*) AS total_deliveries
  FROM fct_orders
  WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'
  GROUP BY delivery_partner_id, delivery_partner_name
)
SELECT
  UPPER(delivery_partner_name) AS partner_name
FROM delivery_stats
WHERE (on_time_deliveries * 100.0 / total_deliveries) < 50;