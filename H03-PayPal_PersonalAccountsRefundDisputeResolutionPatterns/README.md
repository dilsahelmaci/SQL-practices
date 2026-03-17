# **Personal Accounts Refund Dispute Resolution Patterns**

## **Problem Overview**
You are a Product Analyst investigating customer refund dispute characteristics across transaction types. Your team wants to optimize the buyer protection process for more efficient resolutions. The goal is to analyze dispute metrics and develop targeted process improvements.

*Tables:*

*fct_disputed_transactions(transaction_id, dispute_initiated_date, refund_amount, resolution_time_days, product_type, transaction_category)*

---
## **Question 1**
For disputes involving digital goods (where the product_type begins with ''DIG''), what is the average refund amount for disputes initiated from October 1st to October 7th, 2024? This metric helps quantify the financial impact of digital goods disputes.

## **Solution**
```sql
SELECT
  ROUND(AVG(refund_amount), 2) AS avg_refund_amount
FROM fct_disputed_transactions
WHERE product_type ILIKE 'DIG%'
  AND dispute_initiated_date >= DATE '2024-10-01'
    AND dispute_initiated_date <= DATE '2024-10-07';
```

---
## **Question 2**
For disputes in October 2024, first find the top 5 transaction categories by the number of disputes. Among these top 5 categories, identify the category with the highest average dispute resolution time. Report both the category name and its average resolution time to target process improvements.

## **Solution**
```sql
WITH disputes_Octo AS (
  SELECT
    transaction_id,
    transaction_category, 
    refund_amount, 
    resolution_time_days,
    product_type
  FROM fct_disputed_transactions
  WHERE dispute_initiated_date >= DATE '2024-10-01'
    AND dispute_initiated_date < DATE '2024-11-01'
), 
top5_categories AS (
  SELECT
    transaction_category, 
    COUNT(*) AS dispute_cnt
  FROM disputes_Octo
  GROUP BY transaction_category
  ORDER BY dispute_cnt DESC, transaction_category
  LIMIT 5
)
SELECT 
  transaction_category, 
  ROUND(AVG(resolution_time_days), 2) AS avg_resolution_time_days
FROM disputes_Octo
WHERE transaction_category IN (SELECT transaction_category FROM top5_categories)
GROUP BY transaction_category
ORDER BY avg_resolution_time_days DESC, transaction_category
LIMIT 1;
```

---
## **Question 3**
Segment all disputes from October 2024 into quartiles based on the resolution time. What percentage of disputes in the highest resolution time quartile involve physical goods (i.e. product_type values not starting with ''DIG'')? This analysis will guide recommendations to reduce overall dispute resolution time.

## **Solution**
```sql
WITH disputes_segmented_Octo AS ( 
  SELECT
    transaction_category, 
    product_type, 
    refund_amount, 
    resolution_time_days, 
    NTILE(4) OVER(ORDER BY resolution_time_days DESC) AS segment
    --PERCENT_RANK() OVER (ORDER BY resolution_time_days) AS resolution_pct
  FROM fct_disputed_transactions
  WHERE dispute_initiated_date >= DATE '2024-10-01'
    AND dispute_initiated_date < DATE '2024-11-01'
),
disputes_highest_resolution_time AS (
  SELECT
    transaction_category,
    product_type, 
    resolution_time_days
  FROM disputes_segmented_Octo
  WHERE segment = 1
  --WHERE resolution_pct >= 0.75
)
SELECT 
  ROUND(100.0 * COUNT(CASE WHEN product_type NOT ILIKE 'DIG%' THEN resolution_time_days END)::numeric
    / NULLIF(COUNT(*), 0)
  , 2) AS disputes_highest_resolution_pct
FROM disputes_highest_resolution_time;
```