# **Work Travel Expense Tracking and Optimization**

## **Problem Overview**
As a Business Analyst on the Airbnb for Work team, your task is to analyze corporate travel expense patterns to identify potential cost-saving opportunities. Your team is particularly interested in understanding the average booking costs, company-specific spending behaviors, and the impact of booking timing on costs. By analyzing these aspects, you aim to provide actionable insights that can help optimize corporate travel expenses.

*Tables:*

*fct_corporate_bookings(booking_id, company_id, employee_id, booking_cost, booking_date, travel_date)*

*dim_companies(company_id, company_name)*

---
## **Question 1**

What is the average booking cost for corporate travelers? For this question, let's look only at trips which were booked in January 2024

## **Solution**
```sql
SELECT
  ROUND(AVG(booking_cost), 2) AS avg_booking_cost
FROM fct_corporate_bookings
WHERE booking_date BETWEEN '2024-01-01' AND '2024-01-31';
```

---
## **Question 2**

Identify the top 5 companies with the highest average booking cost per employee for trips taken during the first quarter of 2024. Note that if an employee takes multiple trips, each booking will show up as a separate row in fct_corporate_bookings.

## **Solution**
```sql
SELECT
  fcb.company_id,
  dc.company_name, 
  ROUND(SUM(fcb.booking_cost)/ COUNT(DISTINCT fcb.employee_id), 2) AS cost_per_employee
FROM fct_corporate_bookings AS fcb
LEFT JOIN dim_companies AS dc
  ON fcb.company_id = dc.company_id
WHERE travel_date BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY fcb.company_id, dc.company_name
ORDER BY cost_per_employee DESC
LIMIT 5; 
```
---
## **Question 3**

For bookings made in February 2024, what percentage of bookings were made more than 30 days in advance? Use this to recommend strategies for reducing booking costs.

## **Solution**
```sql
WITH booking_inadvance AS (
  SELECT 
    *, 
    CASE WHEN travel_date - booking_date > 30 THEN 1 ELSE 0 END AS is_booked_30plus_days_ahead
  FROM fct_corporate_bookings
)
SELECT 
  ROUND(100.0 * SUM(is_booked_30plus_days_ahead) / COUNT(*), 2) AS pct_booking_inadvance
FROM booking_inadvance
WHERE booking_date BETWEEN '2024-02-01' AND '2024-02-29'; 
```
