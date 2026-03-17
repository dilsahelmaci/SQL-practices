# **Corporate Social Responsibility Community Program Impact**

## **Problem Overview**
As a Data Analyst on Apple's Corporate Social Responsibility team, you are tasked with evaluating the effectiveness of recent philanthropic initiatives. Your focus is on understanding participant engagement across different communities and programs. The insights you gather will guide strategic decisions for resource allocation and future program expansions.

*Tables:*

*fct_philanthropic_initiatives(program_id, community_id, event_date, participants, program_name)*

*dim_community(community_id, community_name, region)*

---
## **Question 1**
Apple's Corporate Social Responsibility team wants a summary report of philanthropic initiatives in January 2024. Please compile a report that aggregates participant numbers by community and by program.

## **Solution**
```sql
WITH initiatives_Jan AS (
  SELECT
    community_id, 
    participants,
    program_name
  FROM fct_philanthropic_initiatives
  WHERE event_date >= DATE '2024-01-01'
    AND event_date < DATE '2024-02-01'
)
SELECT
  c.community_name,
  i.program_name,
  SUM(i.participants) AS participants_cnt
FROM initiatives_Jan AS i  
JOIN dim_community AS c 
ON i.community_id = c.community_id
GROUP BY c.community_name, i.program_name; 
```

---
## **Question 2**
The team is reviewing the execution of February 2024 philanthropic programs. For each initiative, provide details along with the earliest event date recorded within each program campaign to understand start timings.

## **Solution**
```sql
WITH initiatives_Feb_ranked AS (
  SELECT
    program_id, 
    program_name, 
    community_id, 
    event_date,
    participants,
    ROW_NUMBER() OVER(PARTITION BY program_id ORDER BY event_date) AS event_rank
  FROM fct_philanthropic_initiatives
  WHERE event_date >= DATE '2024-02-01'
    AND event_date < DATE '2024-03-01'
)
SELECT
  i.program_id,
  i.program_name,
  c.community_name,
  c.region, 
  i.event_date,
  i.participants
FROM initiatives_Feb_ranked AS i
JOIN dim_community AS c
ON i.community_id = c.community_id
WHERE i.event_rank = 1; 
```

---
## **Question 3**
For a refined analysis of initiatives held during the first week of March 2024, include for each program the maximum participation count recorded in any event. This information will help highlight the highest engagement levels within each campaign.


## **Solution**
```sql
WITH initiatives_Mar_ranked AS (
  SELECT
    program_id,
    community_id,
    event_date,
    participants, 
    program_name,
    ROW_NUMBER() OVER(PARTITION BY program_id ORDER BY participants DESC) AS participants_rank
  FROM fct_philanthropic_initiatives
  WHERE event_date >= DATE '2024-03-01'
    AND event_date <= DATE '2024-03-07'
)

SELECT
  i.program_id,
  i.program_name,
  c.community_name,
  c.region, 
  i.event_date,
  i.participants
FROM initiatives_Mar_ranked AS i
JOIN dim_community AS c
ON i.community_id = c.community_id
WHERE i.participants_rank = 1; 
```