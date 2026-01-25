# **User Status Classification for Facebook Advertisers**

## **Problem Overview**

You are provided with two tables:

1. **`advertiser`**: Contains information about advertisers and their respective current payment status.
2. **`daily_pay`**: Contains information about advertisers who have made payments, including the current payment data.

The task is to update the payment status of advertisers based on the information in the **daily_pay** table. Specifically, the output should include the **user_id** and their updated payment status (**new_status**), sorted by **user_id**.

### **Advertiser Status Categories**

The payment status of advertisers can be classified into four categories:
1.	**New**: Advertisers who are newly registered and have made their first payment.
2.	**Existing**: Advertisers who have made payments in the past and have recently made a payment.
3.	**Churn**: Advertisers who have made payments in the past but have not made any recent payment.
4.	**Resurrect**: Advertisers who have not made a recent payment but may have made a previous payment and have made a payment again recently.
 
 ### **Status Transition Rules**
The status of an advertiser can transition based on whether or not a payment has been made on a specific day (denoted as "T"). The transitions follow these rules:

| #  | **Current Status** | **Updated Status** | **Payment on Day T** |
|----|--------------------|--------------------|----------------------|
| 1  | NEW                | EXISTING           | Paid                 |
| 2  | NEW                | CHURN              | Not paid             |
| 3  | EXISTING           | EXISTING           | Paid                 |
| 4  | EXISTING           | CHURN              | Not paid             |
| 5  | CHURN              | RESURRECT          | Paid                 |
| 6  | CHURN              | CHURN              | Not paid             |
| 7  | RESURRECT          | EXISTING           | Paid                 |
| 8  | RESURRECT          | CHURN              | Not paid             |

### **Explanation of Status Transitions**:
- **Rows 2, 4, 6, and 8**: If an advertiser does not make a payment on day T (i.e., "Not paid"), their status transitions to **CHURN**, regardless of their previous status.
- **Rows 1, 3, 5, and 7**: If an advertiser makes a payment on day T (i.e., "Paid"), the status is updated to either **EXISTING** or **RESURRECT**, depending on their previous status. 
  - If the previous status was **CHURN**, the updated status will be **RESURRECT**.
  - If the previous status was **NEW**, **EXISTING**, or **RESURRECT**, the updated status will be **EXISTING**.

---
## **Solution**
```sql
SELECT 
    COALESCE(a.user_id, dp.user_id) AS user_id, 
    CASE 
        WHEN dp.paid IS NULL THEN 'CHURN'  -- User has no payment, considered churned
        WHEN dp.paid IS NOT NULL AND a.status = 'CHURN' THEN 'RESURRECT'  -- Previously churned but now paying
        WHEN dp.paid IS NOT NULL AND a.status IN ('NEW', 'EXISTING', 'RESURRECT') THEN 'EXISTING'  -- Already active user
        WHEN dp.paid IS NOT NULL AND a.status IS NULL THEN 'NEW'  -- New paying user with no prior status
    END AS new_status
FROM advertiser AS a
FULL OUTER JOIN daily_pay AS dp 
    ON a.user_id = dp.user_id
ORDER BY user_id;
```

### **Query Overview**

This SQL query is written to classify users into different statuses (CHURN, RESURRECT, EXISTING, NEW) based on their payment activity. It combines data from two tables:
- **`advertiser (a)`**: Contains user information and their current status (NEW, EXISTING, CHURN, etc.).
- **`daily_pay (dp)`**: Contains user payment data, indicating whether a user has made a payment (paid column).

### **Query Breakdown**

**1. Handling Users from Both Tables (with FULL OUTER JOIN)**

```sql
FROM advertiser AS a
FULL OUTER JOIN daily_pay AS dp 
    ON a.user_id = dp.user_id
```

- This ensures that all users from both tables are included, even if they do not exist in one of them.
- If a user exists in advertiser but not in daily_pay, their payment info will be NULL.
- If a user exists in daily_pay but not in advertiser, their status will be NULL.

**2. Ensuring a Unified user_id with COALESCE**

```sql
COALESCE(a.user_id, dp.user_id) AS user_id
```
- If a.user_id is available, it is used.
- If a.user_id is NULL (meaning the user exists only in daily_pay), then dp.user_id is used.
- This ensures every row has a user_id even if they exist in only one table.

**3. Classifying Users Based on paid and status**

```sql
CASE 
    WHEN dp.paid IS NULL THEN 'CHURN'
    WHEN dp.paid IS NOT NULL AND a.status = 'CHURN' THEN 'RESURRECT'
    WHEN dp.paid IS NOT NULL AND a.status IN ('NEW', 'EXISTING', 'RESURRECT') THEN 'EXISTING'
    WHEN dp.paid IS NOT NULL AND a.status IS NULL THEN 'NEW'
END AS new_status
```

#### **Classification Rules:**

**1. CHURN**:
   - If a user has no payment record (`paid IS NULL`), they are considered churned (inactive).
   
**2. RESURRECT**:
   - If a user has made a payment (`paid IS NOT NULL`) but was previously churned, they are considered resurrected (returned after inactivity).
   
**3. EXISTING**:
   - If a user has paid and was already active (status in `NEW`, `EXISTING`, or `RESURRECT`), they remain existing.
   
**4. NEW**:
   - If a user has paid but has no recorded status (`status IS NULL`), they are classified as new.

**4. Sorting the Results**

```sql
ORDER BY user_id;
```
- Ensures that the output is sorted by user_id for easier readability and tracking.
