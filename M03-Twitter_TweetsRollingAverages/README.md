# **Rolling 3-Day Average of Tweet Counts**

## **Problem Overview**

Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.

Notes:

A rolling average, also known as a moving average or running mean is a time-series technique that examines trends in data over a specified period of time.
In this case, we want to determine how the tweet count for each user changes over a 3-day period.

<img width="331" alt="image" src="https://github.com/user-attachments/assets/fab0abbc-54ea-4699-8312-052069ceb9f4" />

---
## **Solution**
```sql
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
```
### **Breakdown of the Query**

1.	**Partitioning by user**:
   The query calculates the rolling average separately for each user_id, ensuring that each user’s tweet data is processed independently.
2. **Ordering by date**:
   We order the data by tweet_date in ascending order to make sure the rolling average is calculated in chronological order.
3.	**Rolling window**:
   The ROWS BETWEEN 2 PRECEDING AND CURRENT ROW part tells SQL to calculate the average for the current row and the two previous rows (i.e., the last 3 days of data).
4.	**Averaging and rounding**:
   Finally, the AVG(tweet_count) calculates the average tweet count over the 3-day window, and the ROUND(..., 2) function ensures the result is rounded to two decimal places.
