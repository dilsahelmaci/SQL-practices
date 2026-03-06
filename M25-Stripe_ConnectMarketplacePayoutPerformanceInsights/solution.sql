-- Question 1
SELECT
  s.seller_segment,
  COUNT(p.payout_id) AS total_payouts_cnt
FROM dim_sellers AS s
LEFT JOIN fct_payouts AS p
  ON p.seller_id = s.seller_id
 AND p.payout_date >= DATE '2024-07-01'
 AND p.payout_date <  DATE '2024-08-01'
GROUP BY s.seller_segment
ORDER BY total_payouts_cnt DESC;

-- Question 2
WITH july AS (
  SELECT
    s.seller_segment,
    p.payout_status
  FROM fct_payouts p
  JOIN dim_sellers s
    ON s.seller_id = p.seller_id
  WHERE p.payout_date >= DATE '2024-07-01'
    AND p.payout_date <  DATE '2024-08-01'
    AND p.payout_status IN ('successful', 'failed')
),
payouts_by_segment AS (
  SELECT
    seller_segment,
    SUM(CASE WHEN payout_status = 'successful' THEN 1 ELSE 0 END) AS successful_payouts,
    SUM(CASE WHEN payout_status = 'failed' THEN 1 ELSE 0 END) AS failed_payouts
  FROM july
  GROUP BY seller_segment
)
SELECT
  seller_segment,
  successful_payouts,
  failed_payouts,
  ROUND(100.0 * successful_payouts / NULLIF(successful_payouts + failed_payouts, 0), 2) AS success_rate_pct
FROM payouts_by_segment
ORDER BY success_rate_pct DESC
LIMIT 1;
  
-- Question 3
WITH payout_analytics AS ( 
  SELECT
    s.seller_segment, 
    SUM(CASE WHEN p.payout_status = 'successful' THEN 1 END) AS successful_payouts,
    SUM(CASE WHEN p.payout_status = 'failed' THEN 1 END) AS failed_payouts,
    COUNT(*) AS total_payouts
  FROM fct_payouts AS p 
  JOIN dim_sellers AS s 
    ON p.seller_id = s.seller_id
  WHERE p.payout_date >= DATE '2024-07-01'
    AND p.payout_date <  DATE '2024-08-01'
    AND p.payout_status IN ('successful', 'failed')
  GROUP BY s.seller_segment
), 
rates AS (
  SELECT
    seller_segment, 
    ROUND(100.0 * successful_payouts / NULLIF(total_payouts, 0), 2) AS success_rate, 
    ROUND(100.0 * failed_payouts / NULLIF(total_payouts, 0), 2) AS fail_rate
  FROM payout_analytics
)
SELECT
  seller_segment, 
  'Success : ' || success_rate || ' ; ' || 'Fail : ' || fail_rate AS rate_pct
FROM rates; 
