-- Question 1
WITH reorders_q4 AS(
  SELECT
    product_id, 
    SUM(reorder_flag) AS total_reorders
  FROM fct_orders 
  WHERE order_date >= DATE '2024-10-01'
    AND order_date < DATE '2025-01-01'
  GROUP BY product_id
  HAVING  SUM(reorder_flag) > 0
)
SELECT
  LEFT(dp.product_code, 3) AS product_category_code, 
  SUM(o.total_reorders) AS total_reorders
FROM dim_products AS dp 
LEFT JOIN reorders_q4 AS o 
  ON dp.product_id = o.product_id
GROUP BY LEFT(dp.product_code, 3)
ORDER BY product_category_code; 

-- Question 2
WITH reorders_per_product_user AS (
  SELECT
    customer_id, 
    product_id, 
    SUM(reorder_flag) AS total_reorder
  FROM fct_orders
  WHERE order_date >= DATE '2024-10-01'
    AND order_date < DATE '2025-01-01'
  GROUP BY customer_id, product_id
  HAVING SUM(reorder_flag) > 0
)
SELECT 
  dc.customer_id, 
  dc.customer_name, 
  --rpu.product_id, 
  dp.product_code
FROM dim_customers AS dc 
JOIN reorders_per_product_user AS rpu 
  ON dc.customer_id = rpu.customer_id
LEFT JOIN dim_products AS dp 
  ON rpu.product_id = dp.product_id
ORDER BY 1, 2, 3; 
  
-- Question 3
WITH reorders_per_product AS (
  SELECT
    product_id, 
    COALESCE(SUM(reorder_flag), 0) AS total_reorders
  FROM fct_orders
  WHERE order_date >= DATE '2024-10-01'
    AND order_date < DATE '2025-01-01'
  GROUP BY product_id
)
SELECT
  dp.category, 
  ROUND(SUM(total_reorders) / NULLIF(COUNT(*), 0), 2) AS avg_total_reorders
FROM dim_products AS dp
LEFT JOIN reorders_per_product AS rpp 
  ON dp.product_id = rpp.product_id
GROUP BY dp.category; 
