# **User Playlist Retention and Discovery Rates**

## **Problem Overview**
You are a Data Scientist on the Apple Music Personalization Team, tasked with evaluating the effectiveness of recommendation algorithms in engaging users with new music. Your goal is to analyze user playlist interactions to determine how many users add recommended tracks to their playlists, the average number of recommended tracks added per user, and identify users who add non-recommended tracks. This analysis will help your team decide if the recommendation engine needs refinement to enhance user engagement and retention.

*Tables:*

*tracks_added(interaction_id, user_id, track_id, added_date, is_recommended)*

*users(user_id, user_name)*

---
## **Question 1**

How many unique users have added at least one recommended track to their playlists in October 2024?

## **Solution**
```sql
SELECT
  COUNT(DISTINCT user_id) AS users_added_recommended_tracks
FROM tracks_added
WHERE added_date BETWEEN '2024-10-01' AND '2024-10-31'
  AND is_recommended; 
```

---
## **Question 2**

Among the users who added recommended tracks in October 2024, what is the average number of recommended tracks added to their playlists? Please round this to 1 decimal place for better readability.

## **Solution**
```sql
SELECT
  ROUND(AVG(total_recommendation)::numeric, 1) AS avg_track_added
FROM (
  SELECT
    user_id, 
    COUNT(is_recommended) AS total_recommendation
  FROM tracks_added
  WHERE added_date BETWEEN '2024-10-01' AND '2024-10-31'
    AND is_recommended
  GROUP BY user_id
) recommendation_per_user; 
```

---
## **Question 3**

Can you give us the name(s) of users who added a non-recommended track to their playlist on October 2nd, 2024?

## **Solution**
```sql
SELECT
  DISTINCT tracks_added.user_id,
  user_name
FROM tracks_added
INNER JOIN users
  ON tracks_added.user_id = users.user_id
WHERE added_date = '2024-10-02'
  AND is_recommended = FALSE; 
```