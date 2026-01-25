SELECT
    COALESCE(a.user_id, dp.user_id) AS user_id,
    CASE
        WHEN dp.paid IS NULL THEN 'CHURN'  -- User has no payment, considered churned
        WHEN dp.paid IS NOT NULL AND a.status = 'CHURN' THEN 'RESURRECT'  -- Previously churned but now paying
        WHEN dp.paid IS NOT NULL AND a.status IN ('NEW', 'EXISTING', 'RESURRECT') THEN 'EXISTING'  -- Already active user
        WHEN dp.paid IS NOT NULL AND a.status IS NULL THEN 'NEW'  -- New paying user with no prior status
    END AS new_status
FROM advertiser AS a
FULL OUTER JOIN daily_pay AS dp
    ON a.user_id = dp.user_id
ORDER BY user_id;
