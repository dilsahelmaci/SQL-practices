-- Question 1
SELECT
  SUM(perf.impressions) AS total_ad_impression
FROM ad_performance AS perf
INNER JOIN audience_segments AS seg
  ON perf.audience_segment_id = seg.audience_segment_id
WHERE perf.date BETWEEN '2024-10-01' AND '2024-10-31'
  AND seg.segment_name LIKE 'Custom Audience%'; 

-- Question 2
SELECT
  seg.segment_name,
  SUM(perf.conversions) AS total_conversion
FROM ad_performance AS perf
INNER JOIN audience_segments AS seg
  ON perf.audience_segment_id = seg.audience_segment_id
WHERE perf.date BETWEEN '2024-10-01' AND '2024-10-31'
    AND seg.segment_name LIKE 'Custom Audience%'
GROUP BY seg.segment_name; 

-- Question 3
SELECT
  seg.segment_name, 
  ROUND(SUM(perf.ad_spend) / SUM(perf.conversions), 2) AS cost_per_conversion
FROM ad_performance AS perf
INNER JOIN audience_segments AS seg
  ON perf.audience_segment_id = seg.audience_segment_id
WHERE seg.segment_name LIKE 'Custom Audience%'
  OR seg.segment_name LIKE 'Lookalike Audience%'
GROUP BY seg.audience_segment_id, seg.segment_name
HAVING SUM(perf.ad_spend) > 0 AND SUM(perf.conversions) > 0
ORDER BY cost_per_conversion DESC; 