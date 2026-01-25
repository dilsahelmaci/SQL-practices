# **Gmail Label Usage and User Efficiency**

## **Problem Overview**
As a Data Scientist on the Gmail User Experience Research team, you are tasked with understanding how users create and utilize email labels for personal organization. Your goal is to analyze user label creation patterns, identify which labels are effectively managing email communication, and uncover insights that can inform product design improvements. By leveraging data, you will provide actionable insights to enhance user productivity and streamline email management.

*Tables:*

*email_labels(label_id, user_id, created_date)*

*emails(email_id, label_id)*

---
## **Question 1**

Can you find out the number of labels created by each user? We are interested in understanding how many labels users typically create to manage their emails.

## **Solution**
```sql
SELECT
  user_id, 
  COUNT(label_id) AS label_count
FROM email_labels
GROUP BY user_id; 
```

---
## **Question 2**

Your team wants to know which labels had more than 5 emails assigned to them. Can you retrieve these?

## **Solution**
```sql
SELECT
  label_id, 
  COUNT(email_id) AS email_count
FROM emails
GROUP BY label_id
HAVING COUNT(email_id) > 5;
```

---
## **Question 3**

For labels created in October 2024, determine the number of emails associated with each label. If any labels created in October did not have any emails associated with it, still return these labels in your output. This will help us understand the distribution of email usage across labels.

## **Solution**
```sql
SELECT
  email_labels.label_id, 
  COUNT(emails.email_id) AS email_count
FROM email_labels
LEFT JOIN emails
  ON email_labels.label_id = emails.label_id
WHERE created_date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY email_labels.label_id; 
```
