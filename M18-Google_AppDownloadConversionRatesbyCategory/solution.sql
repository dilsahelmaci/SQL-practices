-- Question 1
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

-- Question 2
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
  
-- Question 3
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