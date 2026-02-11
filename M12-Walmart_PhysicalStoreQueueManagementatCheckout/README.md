# **Physical Store Queue Management at Checkout**

## **Problem Overview**
As a Business Analyst for the Store Operations team at Walmart, you are tasked with examining checkout wait times to enhance the customer shopping experience. Your team aims to identify which stores have longer wait times and determine specific hours when these delays are most pronounced. The insights you provide will guide staffing strategies to reduce customer wait times and improve overall efficiency.

*Tables:*

*fct_checkout_times(store_id, transaction_id, checkout_start_time, checkout_end_time)*

*dim_stores(store_id, store_name, location)*

---
## **Question 1**

What is the average checkout wait time in minutes for each Walmart store during July 2024? Include the store name from the dim_stores table to identify location-specific impacts. This metric will help determine which stores have longer customer wait times.

## **Solution**
```sql
SELECT
  s.store_name,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (ct.checkout_end_time - ct.checkout_start_time)) / 60.0),
    2
  ) AS avg_checkout_minutes
FROM fct_checkout_times AS ct
JOIN dim_stores AS s
  ON ct.store_id = s.store_id
WHERE ct.checkout_start_time >= '2024-07-01'
  AND ct.checkout_start_time <  '2024-08-01'
GROUP BY s.store_name;
```

---
## **Question 2**

For the stores with an average checkout wait time exceeding 10 minutes in July 2024, what are the average checkout wait times in minutes broken down by each hour of the day? Use the store information from dim_stores to ensure proper identification of each store. This detail will help pinpoint specific hours when wait times are particularly long.

## **Solution**
```sql
WITH checkout_minutes AS (
  SELECT
    ct.store_id,
    s.store_name,
    ct.checkout_start_time, 
    EXTRACT(HOUR FROM ct.checkout_start_time AT TIME ZONE 'Europe/Berlin') AS hour_of_day,
    EXTRACT(EPOCH FROM (ct.checkout_end_time - ct.checkout_start_time)) / 60.0
      AS checkout_minutes
  FROM fct_checkout_times ct
  JOIN dim_stores s
    ON ct.store_id = s.store_id
  WHERE ct.checkout_start_time >= '2024-07-01'
    AND ct.checkout_start_time <  '2024-08-01'
)
, slow_stores AS (
  SELECT
    store_id
  FROM checkout_minutes
  GROUP BY store_id
  HAVING AVG(checkout_minutes) > 10
)
SELECT
  cm.store_name,
  cm.hour_of_day,
  ROUND(AVG(cm.checkout_minutes), 2) AS avg_checkout_minutes
FROM checkout_minutes cm
JOIN slow_stores ss
  ON cm.store_id = ss.store_id
GROUP BY
  cm.store_name,
  cm.hour_of_day
ORDER BY
  cm.store_name,
  cm.hour_of_day;
```

---
## **Question 3**

Across all stores in July 2024, which hours exhibit the longest average checkout wait times in minutes? This analysis will guide recommendations for optimal staffing strategies.

## **Solution**
```sql
SELECT
  EXTRACT(HOUR FROM ct.checkout_start_time AT TIME ZONE 'Europe/Berlin') AS hour_of_day,
  ROUND(
    AVG(EXTRACT(EPOCH FROM (ct.checkout_end_time - ct.checkout_start_time)) / 60.0),
    2
  ) AS avg_checkout_minutes
FROM fct_checkout_times ct
WHERE ct.checkout_start_time >= '2024-07-01'
  AND ct.checkout_start_time <  '2024-08-01'
GROUP BY 1
ORDER BY avg_checkout_minutes DESC
LIMIT 1;
```