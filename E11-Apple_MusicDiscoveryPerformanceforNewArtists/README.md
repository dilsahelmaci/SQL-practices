# **Music Discovery Performance for New Artists**

## **Problem Overview**
You are a Product Analyst on the Apple Music discovery team focused on enhancing artist recommendation algorithms. Your team aims to evaluate the diversity and effectiveness of new artist recommendations across different genres. The goal is to refine the recommendation system to boost user engagement and support emerging artists.

*Tables:*

*fct_artist_recommendations(recommendation_id, user_id, artist_id, recommendation_date, is_new_artist)*

---
## **Question 1**

How many unique artists were recommended to users in April 2024? This analysis will help determine the diversity of recommendations during that month.

## **Solution**
```sql
SELECT 
  COUNT(DISTINCT artist_id)
FROM fct_artist_recommendations
WHERE recommendation_date BETWEEN '2024-04-01' AND '2024-04-30'; 
```

---
## **Question 2**

What is the total number of recommendations for new artists in May 2024? This insight will help assess if our focus on emerging talent is working effectively.

## **Solution**
```sql
SELECT
  COUNT(artist_id)
FROM fct_artist_recommendations
WHERE (recommendation_date BETWEEN '2024-05-01' AND '2024-05-31')
  AND is_new_artist; 
```

---
## **Question 3**

For each month in Quarter 2 2024 (April through June 2024), how many distinct new artists were recommended to users? This breakdown will help identify trends in new artist recommendations over the quarter.

## **Solution**
```sql
SELECT
  TO_CHAR(recommendation_date, 'YYYY-MM') AS recommendation_month, 
  COUNT(DISTINCT artist_id) AS distinct_new_artist
FROM fct_artist_recommendations
WHERE recommendation_date BETWEEN '2024-04-01' AND '2024-06-30'
  AND is_new_artist
GROUP BY recommendation_month; 
```
