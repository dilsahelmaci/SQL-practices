# **Ad Segment Performance Analysis**

## **Problem Overview**
As a Data Analyst on the Marketing Performance team, you are tasked with evaluating the effectiveness of our custom audience segments and lookalike audiences in driving user acquisition and conversions. Your team aims to optimize advertising strategies by analyzing key performance metrics such as ad impressions, total conversions, and cost per conversion across different audience segments. By leveraging this data, you will provide actionable insights to enhance campaign efficiency and improve overall marketing performance.

*Tables:*

*ad_performance(ad_id, audience_segment_id, impressions, conversions, ad_spend, date)*

*audience_segments(audience_segment_id, segment_name)*

---
## **Question 1**

How many total ad impressions did we receive from custom audience segments in October 2024?

## **Solution**
```sql
SELECT
  SUM(perf.impressions) AS total_ad_impression
FROM ad_performance AS perf
INNER JOIN audience_segments AS seg
  ON perf.audience_segment_id = seg.audience_segment_id
WHERE perf.date BETWEEN '2024-10-01' AND '2024-10-31'
  AND seg.segment_name LIKE 'Custom Audience%'; 
```

---
## **Question 2**

What is the total number of conversions we achieved from each custom audience segment in October 2024?

## **Solution**
```sql
SELECT
  seg.segment_name,
  SUM(perf.conversions) AS total_conversion
FROM ad_performance AS perf
INNER JOIN audience_segments AS seg
  ON perf.audience_segment_id = seg.audience_segment_id
WHERE perf.date BETWEEN '2024-10-01' AND '2024-10-31'
    AND seg.segment_name LIKE 'Custom Audience%'
GROUP BY seg.segment_name; 
```
---
## **Question 3**

For each custom audience or lookalike segment, calculate the cost per conversion. Only return this for segments that had non-zero spend and non-zero conversions.

## **Solution**
```sql
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
```
