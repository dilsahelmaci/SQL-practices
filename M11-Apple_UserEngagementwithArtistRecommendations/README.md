# **User Engagement with Artist Recommendations**

## **Problem Overview**
You are a Data Analyst on the Apple Music Personalization Team. Your team is focused on evaluating the effectiveness of the recommendation algorithm for artist discovery. The goal is to analyze user interactions with recommended artists to enhance the recommendation engine and improve user engagement.

*Tables:*

*user_streams(stream_id, user_id, artist_id, stream_date)*

*artist_recommendations(recommendation_id, user_id, artist_id, recommendation_date)*

---
## **Question 1**

How many unique users have streamed an artist on or after the date it was recommended to them?

## **Solution**
```sql
SELECT
  COUNT(DISTINCT us.user_id) AS unique_users
FROM user_streams us
JOIN artist_recommendations ar
  ON us.user_id = ar.user_id AND us.artist_id = ar.artist_id
WHERE stream_date >=recommendation_date; 
```

---
## **Question 2**

What is the average number of times a recommended artist is streamed by users in May 2024? Similar to the previous question, only include streams on or after the date the artist was recommended to them.

## **Solution**
```sql
WITH total_stream_per_user_artist AS (
  SELECT
    us.user_id,
    us.artist_id,
    COUNT(us.stream_id) AS total_stream
  FROM user_streams us
  JOIN artist_recommendations ar
    ON us.user_id = ar.user_id AND us.artist_id = ar.artist_id
  WHERE stream_date >=recommendation_date 
    AND us.stream_date BETWEEN '2024-05-01' AND '2024-05-31'
  GROUP BY us.user_id, us.artist_id
)
SELECT
  ROUND(AVG(total_stream), 2) AS avg_total_stream
FROM total_stream_per_user_artist; 
```

---
## **Question 3**

Across users who listened to at least one recommended artist, what is the average number of distinct recommended artists they listened to? As in the previous question, only include streams that occurred on or after the date the artist was recommended to the user.

## **Solution**
```sql
WITH unique_artist_listened_per_user AS (
  SELECT
    us.user_id, 
    COUNT(DISTINCT us.artist_id) AS unique_artist_listened
  FROM user_streams us
  JOIN artist_recommendations ar
    ON us.user_id = ar.user_id AND us.artist_id = ar.artist_id
  WHERE us.stream_date >= ar.recommendation_date
  GROUP BY us.user_id
)
SELECT
  ROUND(AVG(unique_artist_listened)) AS average_distinct_recommended_artists
FROM unique_artist_listened_per_user; 
```