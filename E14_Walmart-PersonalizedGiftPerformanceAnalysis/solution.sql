-- Question 1
SELECT
  product_id, 
  SUM(quantity) AS total_quantity
FROM fct_photo_gift_sales
WHERE purchase_date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY product_id; 

-- Question 2
SELECT
  transaction_id, 
  SUM(quantity) AS max_quantities
FROM fct_photo_gift_sales
WHERE purchase_date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY transaction_id
ORDER BY max_quantities DESC
LIMIT 1; 

-- Question 3
WITH per_customer_details AS (
  SELECT
    customer_id, 
    SUM(quantity) AS total_gift, 
    COUNT(transaction_id) AS transaction_num
  FROM fct_photo_gift_sales
  WHERE purchase_date BETWEEN '2024-04-01' AND '2024-04-30'
  GROUP BY customer_id
  )
SELECT 
  AVG(total_gift) AS avg_gifts_per_customer
FROM per_customer_details; 