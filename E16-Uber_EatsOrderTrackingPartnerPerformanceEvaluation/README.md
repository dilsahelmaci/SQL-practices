# **Eats Order Tracking Partner Performance Evaluation**

## **Problem Overview**
You are a Product Analyst on the Uber Eats team investigating delivery partner performance. The team wants to understand how accurately delivery partners are meeting expected delivery times. Your goal is to evaluate current tracking precision and identify potential improvements.

*Tables:*

*fct_orders(order_id, delivery_partner_id, delivery_partner_name, expected_delivery_time, actual_delivery_time, order_date)*

---
## **Question 1**

What is the percentage of orders delivered on time in January 2024? Consider an order on time if its actual_delivery_time is less than or equal to its expected_delivery_time. This will help us assess overall tracking precision.

## **Solution**
```sql
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
```

---
## **Question 2**

List the top 5 delivery partners in January 2024 ranked by the highest percentage of on-time deliveries. Use the delivery_partner_name field from the records. This will help us identify which partners perform best.

## **Solution**
```sql
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
```
---
## **Question 3**

Identify the delivery partner(s) in January 2024 whose on-time delivery percentage is below 50%. Return their partner names in uppercase. We need to work with these delivery partners to improve their on-time delivery rates.

## **Solution**
```sql
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
```
