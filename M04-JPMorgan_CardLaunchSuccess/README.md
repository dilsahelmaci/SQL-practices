# **Card Launch Success**

## **Problem Overview**
Your team at JPMorgan Chase is soon launching a new credit card. You are asked to estimate how many cards you'll issue in the first month.

Before you can answer this question, you want to first get some perspective on how well new credit card launches typically do in their first month.

Write a query that outputs the name of the credit card, and how many cards were issued in its launch month. The launch month is the earliest record in the `monthly_cards_issued` table for a given card. Order the results starting from the biggest issued amount.

<img width="460" alt="image" src="https://github.com/user-attachments/assets/49514101-320f-4414-a651-39b455c722b6" />

---

## **Solution**
```sql
WITH cards_ranked AS (
  SELECT
    card_name, 
    issue_year,
    issue_month,
    issued_amount,
    -- Rank the issuance of each card type based on the earliest issue date
    RANK() OVER(
      PARTITION BY card_name  -- Ensures ranking is done within each card type
      ORDER BY issue_year, issue_month ASC  -- Orders by issue year and month in ascending order
    ) as ranked
  FROM monthly_cards_issued
) 

SELECT
  card_name,
  issued_amount
FROM cards_ranked
WHERE ranked = 1  -- Selects only the first issued record for each card type (launced time)
ORDER BY issued_amount DESC;  -- Orders the result by issued amount in descending order
```
### **Breakdown of the Query**
1. **Creating a temporary ranked table (`cards_ranked`)**:
- The query begins with a CTE to rank issuance records for each card type based on their chronological order. The `RANK()` function is used to assign a rank to each issuance entry within the same card type (PARTITION BY card_name), based on the order of issuance (ORDER BY issue_year, issue_month ASC). This means the first time a card is issued, it gets ranked = 1.

2. **Selecting the first issuance per card type**:
- The outer query retrieves only those records where ranked = 1, ensuring we only select the first issued instance of each card type.

3. **Sorting by issued amount**:
- The results are sorted in descending order by issued_amount, displaying the most widely issued first-issued card types at the top.
