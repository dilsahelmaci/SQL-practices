-- Question 1
SELECT
  COUNT(*) AS total_messages
FROM fct_messages
WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30'; 

-- Question 2
-- Alternative 1 
WITH total_message_per_user AS(
  SELECT
    user_id, 
    COUNT(*) AS total_messages
  FROM fct_messages
  WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30'
  GROUP BY user_id
  )
SELECT
  ROUND(AVG(total_messages)) AS avg_message_per_user
FROM total_message_per_user; 

-- Alternative 2
SELECT
  ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT user_id), 0)) AS avg_message_per_user
FROM fct_messages
WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30';

-- Question 3
WITH total_message_per_user AS(
  SELECT
    user_id, 
    COUNT(*) AS total_messages
  FROM fct_messages
  WHERE message_sent_date BETWEEN '2024-04-01' AND '2024-04-30'
  GROUP BY user_id
  )
SELECT
  100.0 * COUNT(*) FILTER (WHERE total_messages > 50)
          / COUNT(*) AS pct_users_over_50
-- Another way to calculate the percentage of users sent more than 50 messages  
--  , 100.0 * SUM(CASE WHEN total_messages > 50 THEN 1 ELSE 0 END)
--          / COUNT(*) AS pct_users_over_50
FROM total_message_per_user; 