# **Reorder Patterns for Amazon Fresh**
As a Data Analyst on the Amazon Fresh product team, you and your team are focused on enhancing the customer experience by streamlining the process for customers to reorder their favorite grocery items. Your goal is to identify the most frequently reordered product categories, understand customer preferences for these products, and calculate the average reorder frequency across categories. By analyzing these metrics, you aim to provide actionable insights that will inform strategies to improve customer satisfaction and retention.

## **Problem Overview**

*Tables:*

*fct_orders(order_id, customer_id, product_id, reorder_flag, order_date)*

*dim_products(product_id, product_code, category)*

*dim_customers(customer_id, customer_name)*

---
## **Question 1**
The product team wants to analyze the most frequently reordered product categories. Can you provide a list of the product category codes (using first 3 letters of product code) and their reorder counts for Q4 2024?

## **Solution**
```sql
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
```

---
## **Question 2**
To better understand customer preferences, the team needs to know the details of customers who reorder specific products. Can you retrieve the customer information along with their reordered product code(s) for Q4 2024?

## **Solution**
```sql
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
```

---
## **Question 3**
When calculating the average reorder frequency, it's important to handle cases where reorder counts may be missing or zero. Can you compute the average reorder frequency across the product categories, ensuring that any missing or null values are appropriately managed for Q4 2024?

## **Solution**
```sql
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
```