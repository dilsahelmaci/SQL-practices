# **Teams File Sharing Security and Collaboration Insights**

## **Problem Overview**
As a Product Analyst for Microsoft Teams, you are collaborating with the security team to enhance data security in file sharing and co-editing activities. Your team is focused on understanding how file naming conventions and co-editing practices vary across organizational segments. By analyzing these patterns, you aim to identify potential security risks and recommend targeted improvements to the platform.

*Tables:*

*fct_file_sharing(file_id, file_name, organization_id, shared_date, co_editing_user_id)*

*dim_organization(organization_id, organization_name, segment)*

---
## **Question 1**
What is the average length of the file names shared for each organizational segment in January 2024?

## **Solution**
```sql
WITH files_January AS (
  SELECT
    file_id,  
    LENGTH(file_name) AS file_name_lengths, 
    organization_id
  FROM fct_file_sharing
  WHERE shared_date >= DATE '2024-01-01' 
    AND shared_date < DATE '2024-02-01'
)
SELECT
  o.segment, 
  COALESCE(AVG(f.file_name_lengths), 0) AS avg_file_name_lengths
FROM dim_organization AS o
LEFT JOIN files_January AS f
  ON o.organization_id = f.organization_id
GROUP BY o.segment
ORDER BY o.segment; 
```

---
## **Question 2**
How many files were shared with names that start with the same prefix as the organization name, concatenated with a hyphen, in February 2024?

## **Solution**
```sql
SELECT
  COUNT(*) AS files_shared_cnt
FROM fct_file_sharing AS f
JOIN dim_organization AS o
  ON f.organization_id = o.organization_id
WHERE f.shared_date >= DATE '2024-02-01'
  AND f.shared_date <  DATE '2024-03-01'
  AND f.file_name LIKE (o.organization_name || '-%');
```

---
## **Question 3**
Identify the top 3 organizational segments with the highest number of files shared where the co-editing user is NULL, indicating a potential security risk, during the first quarter of 2024.

## **Solution**
```sql
SELECT
  o.segment, 
  COUNT(*) AS files_no_user_id
FROM fct_file_sharing AS f 
JOIN dim_organization AS o
  ON f.organization_id = o.organization_id
WHERE shared_date >= DATE '2024-01-01'
  AND shared_date < DATE '2024-04-01'
  AND co_editing_user_id IS NULL
GROUP BY o.segment
ORDER BY files_no_user_id DESC
LIMIT 3; 
```