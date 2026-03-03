# **Google Pay Digital Wallet Transaction Security Patterns**

## **Problem Overview**
You are a Product Analyst on the Google Pay security team focused on improving the reliability of digital payments. Your team needs to analyze transaction success and failure rates across various merchant categories to identify potential friction points in payment experiences. By understanding these patterns, you aim to guide product improvements for a smoother and more reliable payment process.

*Tables:*

*fct_transactions(transaction_id, merchant_category, transaction_status, transaction_date)*

---
## **Question 1**
For January 2024, what are the total counts of successful and failed transactions in each merchant category? This analysis will help the Google Pay security team identify potential friction points in payment processing.

## **Solution**
```sql
SELECT
  merchant_category,
  SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 ELSE 0 END) AS success_cnt, 
  SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_cnt
FROM fct_transactions
WHERE transaction_date >= DATE '2024-01-01'
  AND transaction_date < DATE '2024-02-01'
GROUP BY merchant_category
ORDER BY merchant_category; 
```

---
## **Question 2**
For the first quarter of 2024, which merchant categories recorded a transaction success rate below 90%? This insight will guide our prioritization of security enhancements to improve payment reliability.

## **Solution**
```sql
WITH transaction_success_rate AS (
  SELECT
    merchant_category, 
    ROUND(
      100.0 * COALESCE(SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 END), 0) 
      / NULLIF(COUNT(*), 0)
    , 2) AS success_rate
  FROM fct_transactions
  WHERE transaction_date >= DATE '2024-01-01'
    AND transaction_date < DATE '2024-04-01'
  GROUP BY merchant_category
)
SELECT 
  *
FROM transaction_success_rate
WHERE success_rate < 90.0
ORDER BY success_rate; 
```

---
## **Question 3**
From January 1st to March 31st, 2024, can you generate a list of merchant categories with their concatenated counts for successful and failed transactions? Then, rank the categories by total transaction volume. This ranking will support our assessment of areas where mixed transaction outcomes may affect user experience.

## **Solution**
```sql
WITH transaction_cnts_per_categories AS(
  SELECT 
    merchant_category, 
    COALESCE(SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 END), 0) AS success_cnt, 
    COALESCE(SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 END), 0) AS failed_cnt
  FROM fct_transactions
  WHERE transaction_date >= DATE '2024-01-01'
    AND transaction_date <= DATE '2024-03-31'
  GROUP BY merchant_category
)

SELECT
  merchant_category, 
  'SUCCESS: ' || success_cnt || ', ' || 'FAILED: ' || failed_cnt AS transaction_data, 
  DENSE_RANK() OVER(ORDER BY success_cnt+failed_cnt DESC) AS rnk
FROM transaction_cnts_per_categories; 
```
