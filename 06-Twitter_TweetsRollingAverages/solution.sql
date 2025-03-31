SELECT
  user_id,
  tweet_date,
  --tweet_count,
  ROUND(AVG(tweet_count) OVER( -- Calculate the rolling average of tweet counts
    PARTITION BY user_id -- Calculate the rolling average per user
    ORDER BY tweet_date ASC -- Order the data chronologically
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW -- Include the current row and the two previous rows (so 3-day window)
  ), 2) as rolling_avg_3d -- Round the average to 2 decimal places
FROM tweets;