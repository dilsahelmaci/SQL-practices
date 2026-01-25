# **User Engagement with Photo Categorization Features**

## **Problem Overview**
As a Data Analyst on the Google Photos Machine Learning Team, you are tasked with understanding user engagement with our automatic photo categorization features. Your team aims to quantify how many photos have been categorized and identify the unique users interacting with this functionality. By analyzing this data, you will help prioritize enhancements to improve user experience and engagement with our photo management tools.

*Tables:*

*automatic_photo_categorization(photo_id, user_id, categorization_date)*

---
## **Question 1**

We need to measure initial user engagement with the categorization features. How many photos have been categorized by the system in January 2024?

## **Solution**
```sql
SELECT
COUNT(photo_id) AS photo_num
FROM automatic_photo_categorization
WHERE (categorization_date BETWEEN '2024-01-01' AND '2024-01-31')
  AND photo_id IS NOT NULL; 
```

---
## **Question 2**

What is the total number of unique users who have interacted with the categorization feature in February 2024?

## **Solution**
```sql
SELECT
  COUNT(DISTINCT user_id) AS user_num
FROM automatic_photo_categorization
WHERE categorization_date BETWEEN '2024-02-01' AND '2024-02-29'; 
```

---
## **Question 3**

For March 2024, calculate the total number of categorized photos per user and rename the resulting column to 'total_categorized_photos'. We want to identify the most active users for user research purposes.

## **Solution**
```sql
SELECT
  user_id, 
  COUNT(photo_id) AS total_categorized_photos
FROM automatic_photo_categorization
WHERE categorization_date BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY user_id; 
```