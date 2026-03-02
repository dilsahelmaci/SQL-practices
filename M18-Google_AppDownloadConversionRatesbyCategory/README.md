# **App Download Conversion Rates by Category**

## **Problem Overview**
You are on the Google Play store's App Marketplace team. You and your team want to understand how different app categories convert from browsing to actual downloads. This analysis is critical in informing future product placement and marketing strategies for app developers and users.

*Tables:*

*dim_app(app_id, app_name, category, app_type)*

*fct_app_browsing(app_id, browse_date, browse_count)*

*fct_app_downloads(app_id, download_date, download_count)*

---
## **Question 1**
The marketplace team wants to identify high and low performing app categories. Provide the total downloads for the app categories for November 2024. If there were no downloads for that category, return the value as 0.

## **Solution**
```sql
WITH downloads_nov AS (
  -- aggregate total downloads per app in November 2024
  SELECT
    app_id,
    SUM(download_count) AS total_downloads
  FROM fct_app_downloads
  WHERE download_date >= DATE '2024-11-01'
    AND download_date <  DATE '2024-12-01'
  GROUP BY app_id
)
SELECT
  -- join aggregated downloads to app dimension
  a.category,
  COALESCE(SUM(d.total_downloads), 0) AS total_downloads
FROM dim_app a
-- use left join to keep the categories with no downloads
LEFT JOIN downloads_nov d
  ON a.app_id = d.app_id
-- aggregate at category level
GROUP BY a.category
ORDER BY total_downloads DESC, a.category;
```

---
## **Question 2**
Our team's goal is download conversion rate -- defined as downloads per browse event. For each app category, calculate the download conversion rate in December, removing categories where browsing counts are be zero.

## **Solution**
```sql
-- qownload conversion rate per category in Dec 2024
-- conversion_rate = total_downloads / total_browses
-- exclude categories where total_browses = 0
WITH browses_dec AS (
  SELECT
    app_id,
    SUM(browse_count) AS total_browses
  FROM fct_app_browsing
  WHERE browse_date >= DATE '2024-12-01'
    AND browse_date <  DATE '2025-01-01'
  GROUP BY app_id
),
downloads_dec AS (
  SELECT
    app_id,
    SUM(download_count) AS total_downloads
  FROM fct_app_downloads
  WHERE download_date >= DATE '2024-12-01'
    AND download_date <  DATE '2025-01-01'
  GROUP BY app_id
),
category_totals AS (
  SELECT
    a.category,
    SUM(COALESCE(b.total_browses, 0)) AS total_browses,
    SUM(COALESCE(d.total_downloads, 0)) AS total_downloads
  FROM dim_app AS a
  LEFT JOIN browses_dec AS b
    ON a.app_id = b.app_id
  LEFT JOIN downloads_dec AS d
    ON a.app_id = d.app_id
  GROUP BY a.category
)
SELECT
  category,
  ROUND(
    (total_downloads::numeric / NULLIF(total_browses, 0)),
    2
  ) AS conversion_rate
FROM category_totals
WHERE total_browses > 0
ORDER BY conversion_rate DESC, category;
```

---
## **Question 3**
The team wants to compare conversion rates between free and premium apps across all categories. Combine the conversion data for both app types to present a unified view for Q4 2024.

## **Solution**
```sql
WITH browses_dec AS (
  SELECT
    app_id, 
    SUM(browse_count) AS total_browses
  FROM fct_app_browsing
  WHERE browse_date >= DATE '2024-10-01'
    AND browse_date < DATE '2025-01-01'
  GROUP BY app_id
),
downloads_dec AS (
  SELECT
    app_id, 
    SUM(download_count) AS total_downloads
  FROM fct_app_downloads
  WHERE download_date >= DATE '2024-10-01'
    AND download_date < DATE '2025-01-01'
  GROUP BY app_id
), 
types_total AS (
  SELECT 
    a.app_id, 
    a.app_type, 
    SUM(COALESCE(b.total_browses, 0)) AS total_browses,
    SUM(COALESCE(d.total_downloads, 0)) AS total_downloads
  FROM dim_app AS a 
  LEFT JOIN browses_dec AS b
    ON a.app_id = b.app_id
  LEFT JOIN downloads_dec AS d
    ON a.app_id = d.app_id
  GROUP BY a.app_id, a.app_type
)
SELECT 
  app_type, 
  ROUND(
    SUM(total_downloads)::numeric / NULLIF(SUM(total_browses), 0), 
    2
  ) AS conversion_rate
FROM types_total
GROUP BY app_type
ORDER BY conversion_rate DESC, app_type;
```