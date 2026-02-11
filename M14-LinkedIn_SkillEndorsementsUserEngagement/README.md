# **LinkedIn Skill Endorsements User Engagement**

## **Problem Overview**
As a Product Analyst on the LinkedIn Recommendations team, you are exploring how skill endorsements contribute to professional profiles. Your team is focused on understanding the patterns and factors that drive meaningful skill recognition among users. The goal is to identify key metrics that reflect how endorsements validate skills in different categories, such as 'TECHNICAL' and 'MANAGEMENT'.

*Tables:*

*fct_skill_endorsements(endorsement_id, user_id, skill_id, endorsement_date)*

*dim_skills(skill_id, skill_name, skill_category)*

*dim_users(user_id, user_name, profile_creation_date)*

---
## **Question 1**

What percentage of users have at least one skill endorsed by others during July 2024?

## **Solution**
```sql
SELECT
  ROUND(
    100.0 *
    COUNT(DISTINCT CASE WHEN e.user_id IS NOT NULL THEN u.user_id END)
    / COUNT(DISTINCT u.user_id)
  , 2) AS pct_endorsed_users
FROM dim_users u
LEFT JOIN fct_skill_endorsements e
  ON e.user_id = u.user_id
 AND e.endorsement_date >= DATE '2024-07-01'
 AND e.endorsement_date <  DATE '2024-08-01';
```

---
## **Question 2**
What is the average number of endorsements received per user for skills categorized as 'TECHNICAL' during August 2024?

## **Solution 1 with CTE**
```sql
WITH per_user AS (
  SELECT
    e.user_id,
    COUNT(e.endorsement_id) AS endorsement_cnt
  FROM fct_skill_endorsements e
  JOIN dim_skills s
    ON s.skill_id = e.skill_id
  WHERE e.endorsement_date >= DATE '2024-08-01'
    AND e.endorsement_date <  DATE '2024-09-01'
    AND s.skill_category = 'TECHNICAL'
  GROUP BY e.user_id
)
SELECT
  ROUND(AVG(endorsement_cnt::numeric), 2) AS avg_endorsements_per_endorsed_user
FROM per_user;
```

## **Solution 2 with subquery**
```sql
SELECT
  ROUND(AVG(endorsement_cnt::numeric), 2) AS avg_endorsements_per_endorsed_user
FROM (  
  SELECT
    e.user_id,
    COUNT(e.endorsement_id) AS endorsement_cnt
  FROM fct_skill_endorsements e
  JOIN dim_skills s
    ON s.skill_id = e.skill_id
  WHERE e.endorsement_date >= DATE '2024-08-01'
    AND e.endorsement_date <  DATE '2024-09-01'
    AND s.skill_category = 'TECHNICAL'
  GROUP BY e.user_id
) AS per_user; 
```
---
## **Question 3**
For the MANAGEMENT skill category, what percentage of users who have ever received an endorsement for that skill received at least one endorsement in September 2024?

## **Solution**
```sql
SELECT
  ROUND(
    100.0
    * COUNT(DISTINCT CASE
        WHEN e.endorsement_date >= DATE '2024-09-01'
         AND e.endorsement_date <  DATE '2024-10-01'
        THEN e.user_id
      END)
    / COUNT(DISTINCT e.user_id)
  , 2) AS pct_users_with_sep_2024_endorsement
FROM fct_skill_endorsements e
JOIN dim_skills s
  ON s.skill_id = e.skill_id
WHERE s.skill_category = 'MANAGEMENT';
```