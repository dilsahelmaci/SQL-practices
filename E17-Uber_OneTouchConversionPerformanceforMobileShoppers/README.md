# **One Touch Conversion Performance for Mobile Shoppers**

## **Problem Overview**
As a Product Analyst on the PayPal One Touch team, you are investigating mobile checkout conversion rates for the One Touch login feature. Your team wants to understand how different login methods impact transaction completion across mobile platforms. You will use transaction data to evaluate login method performance and user engagement.

*Tables:*

*fct_mobile_transactions(transaction_id, user_id, transaction_date, login_method, transaction_status)*

---
## **Question 1**

For our analysis of the PayPal One Touch feature, what is the total number of mobile transactions that used One Touch during July 2024? You might notice that the login_method doesn't have consistent capitalization, so make sure to account for this in your query!

## **Solution**
```sql
SELECT 
  COUNT(*) AS total_transaction
FROM fct_mobile_transactions
WHERE transaction_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND LOWER(login_method) = 'one touch';
```

---
## **Question 2**

To determine user adoption of the One Touch feature, how many distinct users had sucesssful mobile transactions using One Touch during July 2024? Rename the column for user counts to 'Unique_Users'. This information will support our investigation of transaction engagement.

## **Solution**
```sql
SELECT
  COUNT(DISTINCT user_id) AS Unique_Users
FROM fct_mobile_transactions
WHERE transaction_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND LOWER(login_method) = 'one touch'
  AND transaction_status = 'Success';
```
---
## **Question 3**

We want to understand the adoption of One Touch vs. Standard features. How many of successful transactions were there in July 2024 respectively for One Touch and Standard? Recall that the data in login_method has inconsistent capitalization, so we want to handle for this!

## **Solution**
```sql
SELECT
  SUM(
    CASE WHEN LOWER(login_method)= 'one touch' THEN 1 ELSE 0 END
  ) AS One_Touch_Transaction,   
  SUM(
    CASE WHEN LOWER(login_method)= 'standard' THEN 1 ELSE 0 END
  ) AS Standard_Transaction   
FROM fct_mobile_transactions
WHERE transaction_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND transaction_status = 'Success';
```
