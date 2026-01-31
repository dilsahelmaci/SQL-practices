# **Photo Center: Personalized Gift Performance Analysis**

## **Problem Overview**
As a Data Analyst for the Walmart Photo Center team, you are tasked with evaluating the performance of personalized photo gifts. Your team aims to enhance customer satisfaction and refine product offerings by analyzing customer engagement and product popularity. The objective is to identify key purchasing behaviors and trends to inform inventory and marketing strategies.

*Tables:*

*fct_photo_gift_sales(transaction_id, customer_id, product_id, purchase_date, quantity)*

---
## **Question 1**

For each personalized photo gift product, what is the total quantity purchased in April 2024? This result will provide a clear measure of product performance for our inventory strategies.

## **Solution**
```sql
SELECT
  product_id, 
  SUM(quantity) AS total_quantity
FROM fct_photo_gift_sales
WHERE purchase_date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY product_id; 
```

---
## **Question 2**

What is the maximum number of personalized photo gifts purchased in a single transaction during April 2024? This information will highlight peak purchasing behavior for individual transactions.

## **Solution**
```sql
SELECT
  transaction_id, 
  SUM(quantity) AS max_quantities
FROM fct_photo_gift_sales
WHERE purchase_date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY transaction_id
ORDER BY max_quantities DESC
LIMIT 1; 
```

---
## **Question 3**

What is the overall average number of personalized photo gifts purchased per customer during April 2024? That is, for each customer, calculate the total number of personalized photo gifts they purchased in April 2024 — then return the average of those values across all customer.

## **Solution**
```sql
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
```
