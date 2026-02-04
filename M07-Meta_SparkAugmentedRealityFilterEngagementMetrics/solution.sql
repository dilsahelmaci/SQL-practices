-- Question 1
SELECT
  DISTINCT ar_filter_engagements.filter_id, 
  ar_filters.filter_name
FROM ar_filter_engagements
INNER JOIN ar_filters
  ON ar_filter_engagements.filter_id = ar_filters.filter_id
WHERE ar_filter_engagements.engagement_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND ar_filter_engagements.interaction_count IS NOT NULL AND ar_filter_engagements.interaction_count > 0;

-- Question 2
SELECT
  --ar_filter_engagements.filter_id, 
  ar_filters.filter_name,
  SUM(ar_filter_engagements.interaction_count) AS total_interaction_count
FROM ar_filter_engagements
INNER JOIN ar_filters
  ON ar_filter_engagements.filter_id = ar_filters.filter_id
WHERE ar_filter_engagements.engagement_date BETWEEN '2024-08-01' AND '2024-08-31'
GROUP BY ar_filter_engagements.filter_id, ar_filters.filter_name
HAVING SUM(ar_filter_engagements.interaction_count) > 1000;

-- Question 3
SELECT
  ar_filter_engagements.filter_id, 
  ar_filters.filter_name,
  SUM(ar_filter_engagements.interaction_count) AS total_interaction_count
FROM ar_filter_engagements
INNER JOIN ar_filters
  ON ar_filter_engagements.filter_id = ar_filters.filter_id
WHERE ar_filter_engagements.engagement_date BETWEEN '2024-09-01' AND '2024-09-30'
GROUP BY ar_filter_engagements.filter_id, ar_filters.filter_name
ORDER BY total_interaction_count DESC
LIMIT 3;