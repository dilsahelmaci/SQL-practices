# **Third-Party Seller Fees and Performance Metrics**

## **Problem Overview**
You are a Data Analyst on the Amazon Marketplace Analytics team focused on optimizing fee structures for third-party sellers. Your goal is to analyze how transaction amounts and fee percentages impact seller performance, with an emphasis on identifying top sales, weekly trends, and cumulative transaction counts. The insights you uncover will guide strategic fee adjustments to incentivize high-performing sellers and enhance overall marketplace efficiency.

*Tables:*

*fct_seller_sales(sale_id, seller_id, sale_amount, fee_amount_percentage, sale_date)*

*dim_seller(seller_id, seller_name)*

---
## **Question 1**
For each seller, please identify their top sale transaction in April 2024 based on sale amount. If there are multiple transactions with the same sale amount, select the one with the most recent sale_date.

## **Solution**
```sql
WITH sales_ranked_April AS (
  SELECT
    seller_id, 
    sale_amount, 
    sale_date,
    ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY sale_amount DESC, sale_date DESC) AS sale_rnk
  FROM fct_seller_sales
  WHERE sale_date >= DATE '2024-04-01'
    AND sale_date < DATE '2024-05-01'
)
SELECT
  ds.seller_id,
  ds.seller_name, 
  sr.sale_amount, 
  sr.sale_date
FROM dim_seller AS ds
LEFT JOIN sales_ranked_April AS sr
  ON ds.seller_id = sr.seller_id
  AND sr.sale_rnk = 1; 
```

---
## **Question 2**
Within May 2024, for each seller ID, please generate a weekly summary that reports the total number of sales transactions and shows the fee amount from the most recent sale in that week. This analysis will let us correlate fee changes with weekly seller performance trends.

## **Solution**
```sql
WITH sales_may AS (
  SELECT
    sale_id,
    seller_id,
    fee_amount_percentage,
    sale_date,
    DATE_TRUNC('week', sale_date) AS week_start,
    ROW_NUMBER() OVER(
      PARTITION BY seller_id, DATE_TRUNC('week', sale_date)
      ORDER BY sale_date DESC, sale_id DESC
    ) AS rnk
  FROM fct_seller_sales
  WHERE sale_date >= DATE '2024-05-01'
    AND sale_date < DATE '2024-06-01'
)
SELECT
  seller_id,
  week_start,
  COUNT(*) AS total_sales_transactions,
  MAX(CASE WHEN rnk = 1 THEN fee_amount_percentage END) AS latest_fee_amount_percentage
FROM sales_may
GROUP BY seller_id, week_start
ORDER BY seller_id, week_start;
```

---
## **Question 3**
Using June 2024, for each seller, create a daily report that computes a cumulative count of transactions up to that day.

## **Solution**
```sql
WITH cumulative_sales AS (
  SELECT
    seller_id, 
    sale_date,
    sale_amount,
    COUNT(*) OVER(PARTITION BY seller_id ORDER BY sale_date) AS cumulative_cnt
  FROM fct_seller_sales
  WHERE sale_date >= DATE '2024-06-01'
    AND sale_date < DATE '2024-07-01'
)
SELECT
  ds.seller_id, 
  ds.seller_name, 
  cs.sale_date, 
  cs.cumulative_cnt
FROM dim_seller AS ds
LEFT JOIN cumulative_sales AS cs
  ON ds.seller_id = cs.seller_id
ORDER BY seller_id, sale_date; 
```