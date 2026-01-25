# **Users Who Confirmed on the Second Day**

## **Problem Overview**

Assume you're given tables with information about TikTok user sign-ups and confirmations through email and text. New users on TikTok sign up using their email addresses, and upon sign-up, each user receives a text message confirmation to activate their account.

Write a query to display the user IDs of those who did not confirm their sign-up on the first day, but confirmed on the second day.

Definition:
  - action_date refers to the date when users activated their accounts and confirmed their sign-up through text messages.  
<img width="350" alt="image" src="https://github.com/user-attachments/assets/6fe80db7-4c42-46fa-b5b3-9673ad1e7371" />

---
## **Solution**

```sql
SELECT DISTINCT user_id
FROM emails
INNER JOIN texts
  ON emails.email_id = texts.email_id
WHERE signup_action = 'Confirmed'
  AND (action_date::DATE) - (signup_date::DATE) = 1;
```
### **Breakdown of the Query**
1. **Joining Emails and Texts Tables**
```sql
INNER JOIN texts ON emails.email_id = texts.email_id
```
- Connects the `emails` and `texts` tables using `email_id` to link sign-up records with confirmation records.

2. **Filtering Users Who Confirmed on the Second Day**
```sql
WHERE signup_action = 'Confirmed'
AND (action_date::DATE) - (signup_date::DATE) = 1
```
- Ensures we only consider users who confirmed their sign-up (`signup_action = 'Confirmed'`).
- Filters users whose confirmation (`action_date`) happened exactly one day after signing up (`signup_date`).
- `::DATE` casts timestamps into date format to avoid time mismatches.

3. **Returning Unique Users**
```sql
SELECT DISTINCT user_id
```
- Ensures that each user ID appears only once in the results.



