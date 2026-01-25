# **User Engagement in Interactive Content**

### **Problem Overview**
As a Data Scientist on the Interactive Content team, you are tasked with understanding viewer engagement with our choose-your-own-adventure shows. Your team aims to analyze unique viewer interactions, preferences in choices made, and specific interaction types to enhance the design and user experience of future interactive content. By leveraging data insights, you will help inform storytelling strategies that foster deeper viewer engagement.

*Tables:*

*viewer_interactions(interaction_id, viewer_id, content_id, interaction_type, interaction_date)*
*choices_made(choice_id, viewer_id, choice_description, choice_date)*


### **Question 1**

Using the viewer_interactions table, how many unique viewers have interacted with any interactive content in October 2024. Can you find out the number of distinct viewers?

### **Solution**
```sql
SELECT 
  COUNT(DISTINCT viewer_id) AS distinct_viewers
FROM viewer_interactions
WHERE (interaction_date BETWEEN '2024-10-01' AND '2024-10-31')
  AND content_id IS NOT NULL;
```
### **Question 2**

To understand viewer preferences, the team wants a list of all the unique choices made by viewers in November 2024. Can you provide this list sorted by choice description alphabetically?

### **Solution**
```sql
SELECT
  DISTINCT(choice_description) AS unique_choice_description
FROM choices_made
WHERE choice_date BETWEEN '2024-11-01' AND '2024-11-30'
ORDER BY 1 ASC; 
```

### **Question 3**

The team is interested in understanding which viewers interacted with content by pausing the video in December 2024. Can you provide a list of viewer IDs who did this action?

### **Solution**
```sql
SELECT
  DISTINCT(viewer_id) AS unique_viewer_id
FROM viewer_interactions
WHERE (interaction_date BETWEEN '2024-12-01' AND '2024-12-31')
  AND interaction_type = 'pause'; 
```