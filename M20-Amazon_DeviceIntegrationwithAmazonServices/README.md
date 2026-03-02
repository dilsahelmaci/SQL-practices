# **Device Integration with Amazon Services**
As a Data Analyst on the Amazon Devices team, you are tasked with evaluating the usage patterns of Amazon services on devices like Echo, Fire TV, and Kindle. Your goal is to categorize device usage, assess overall engagement levels, and analyze the contribution of Prime Video and Amazon Music to total usage. This analysis will inform strategies to optimize service offerings and improve customer satisfaction.

## **Problem Overview**

*Tables:*

*fct_device_usage(usage_id, device_id, service_id, usage_duration_minutes, usage_date)*

*dim_device(device_id, device_name)*

*dim_service(service_id, service_name)*

---
## **Question 1**
The team wants to identify the total usage duration of the services for each device type by extracting the primary device category from the device name for the period from July 1, 2024 to September 30, 2024. The primary device category is derived from the first word of the device name.

## **Solution**
```sql
--  total usage of service per primary device category from July 1 to September 30 2024
WITH usage_q3_2024 AS (
  SELECT
    device_id, 
    SUM(usage_duration_minutes) AS total_usage_duration_min
  FROM fct_device_usage
  WHERE usage_date >= DATE '2024-07-01'
    AND usage_date <= DATE '2024-09-30'
  GROUP BY device_id
), 
  device_cat_usage AS (
SELECT
    dd.device_id, 
    u.total_usage_duration_min,
    SPLIT_PART(dd.device_name, ' ', 1) AS primary_category
  FROM dim_device AS dd 
  LEFT JOIN usage_q3_2024 AS u
    ON dd.device_id = u.device_id
)
SELECT
  primary_category, 
  COALESCE(SUM(total_usage_duration_min), 0) AS total_usage_duration_min
FROM device_cat_usage
GROUP BY primary_category;
```

---
## **Question 2**
The team also wants to label the usage of each device category into 'Low' or 'High' based on usage duration from July 1, 2024 to September 30, 2024. If the total usage time was less than 300 minutes, we'll category it as 'Low'. Otherwise, we'll categorize it as 'high'. Can you return a report with device ID, usage category and total usage time?

## **Solution**
```sql
 WITH usage_q3_2024 AS (
  SELECT
    device_id, 
    SUM(usage_duration_minutes) AS total_usage_duration_min
  FROM fct_device_usage
  WHERE usage_date >= DATE '2024-07-01'
    AND usage_date <= DATE '2024-09-30'
  GROUP BY device_id
)
SELECT
  device_id, 
  CASE WHEN total_usage_duration_min < 300 THEN 'Low'
    ELSE 'High'
  END AS usage_category, 
  total_usage_duration_min
FROM usage_q3_2024; 
```

---
## **Question 3**
The team is considering bundling the Prime Video and Amazon Music subscription. They want to understand what percentage of total usage time comes from Prime Video and Amazon Music services respectively. Please use data from July 1, 2024 to September 30, 2024.

## **Solution**
## Approach 1 
```sql
WITH usage_q3_2024 AS (
  SELECT
    service_id, 
    SUM(usage_duration_minutes) AS total_usage_duration_min
  FROM fct_device_usage
  WHERE usage_date >= DATE '2024-07-01'
    AND usage_date <= DATE '2024-09-30'
  GROUP BY service_id
), 
usage_per_service AS (
  SELECT
    s.service_id, 
    s.service_name,
    u.total_usage_duration_min, 
    SUM(total_usage_duration_min) OVER() AS total_usage_all
  FROM dim_service AS s 
  LEFT JOIN usage_q3_2024 AS u 
    ON s.service_id = u.service_id
)
SELECT
  service_name, 
  ROUND(100.0 * total_usage_duration_min / NULLIF(total_usage_all, 0), 2) AS pct_usage_duration
FROM usage_per_service 
WHERE service_name IN ('Prime Video' , 'Amazon Music'); 
```

## Approach 2
```sql
WITH usage_q3_2024 AS (
  SELECT
    du.service_id,
    SUM(du.usage_duration_minutes) AS total_usage_minutes
  FROM fct_device_usage du
  WHERE du.usage_date >= DATE '2024-07-01'
    AND du.usage_date <  DATE '2024-10-01'
  GROUP BY du.service_id
),
usage_named AS (
  SELECT
    s.service_name,
    u.total_usage_minutes
  FROM usage_q3_2024 u
  JOIN dim_service s
    ON u.service_id = s.service_id
),
totals AS (
  SELECT
    SUM(total_usage_minutes) AS overall_usage_minutes,
    SUM(CASE WHEN service_name = 'Prime Video' THEN total_usage_minutes ELSE 0 END) AS prime_video_minutes,
    SUM(CASE WHEN service_name = 'Amazon Music' THEN total_usage_minutes ELSE 0 END) AS amazon_music_minutes
  FROM usage_named
)
SELECT
  ROUND(100.0 * prime_video_minutes / NULLIF(overall_usage_minutes, 0), 2) AS pct_prime_video,
  ROUND(100.0 * amazon_music_minutes / NULLIF(overall_usage_minutes, 0), 2) AS pct_amazon_music
FROM totals;
```