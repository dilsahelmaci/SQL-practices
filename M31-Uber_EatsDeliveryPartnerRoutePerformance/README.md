# **Eats Delivery Partner Route Performance**

## **Problem Overview**
You are a Product Analyst investigating how delivery partners manage multiple order pickups. The team wants to understand the efficiency of order clustering and routing strategies. The goal is to optimize delivery route performance to support partner earnings and operational effectiveness.

*Tables:*

*fct_delivery_routes(route_id, delivery_partner_id, pickup_count, delivery_time, earnings, route_date)*

---
## **Question 1**
For all delivery routes between October 1st and December 31st, 2024, what percentage of routes had multiple (ie. 2 or more) order pickups? This metric will quantify how often order bundling occurs to help evaluate routing efficiency.

## **Solution**
```sql
SELECT
  ROUND(100.0 * SUM(CASE WHEN pickup_count > 1 THEN 1 ELSE 0 END)
    / NULLIF(COUNT(*), 0), 2) AS multiple_pickup_pct
FROM fct_delivery_routes
WHERE route_date >= DATE '2024-10-01'
  AND route_date <= DATE '2024-12-31'; 
```

---
## **Question 2**
For delivery routes with multiple pickups between October 1st and December 31st, 2024, how does the average delivery time differ between routes with exactly 2 orders and routes with 3 or more orders? Use a CASE statement to segment the routes accordingly. This analysis will clarify the impact of different levels of order clustering on delivery performance.

## **Solution**
```sql
WITH del_time_orders AS (
  SELECT
    ROUND(AVG(CASE WHEN pickup_count = 2 THEN delivery_time END)::numeric, 2) AS avg_time_2_orders, 
    ROUND(AVG(CASE WHEN pickup_count > 2 THEN delivery_time END)::numeric, 2) AS avg_time_more_3_orders
  FROM fct_delivery_routes
  WHERE route_date >= DATE '2024-10-01'
    AND route_date <= DATE '2024-12-31'
)
SELECT 
  ABS(avg_time_more_3_orders - avg_time_2_orders) AS delivery_time_diff
FROM del_time_orders; 
```

---
## **Question 3**
What is the average earnings per pickup across all routes?

 Note: Some rows have missing values in the earnings column. Before calculating the final value, replace any missing earnings with the average earnings value.

## **Solution**
```sql
WITH pickups_earnings AS (
  SELECT
    pickup_count,
    COALESCE(earnings, ROUND(AVG(earnings) OVER()::numeric, 2)) AS earnings_updated
  FROM fct_delivery_routes
)
SELECT
  ROUND((SUM(earnings_updated)::numeric / NULLIF(SUM(pickup_count), 0))::numeric, 2) AS avg_earning_per_pickup
FROM pickups_earnings; 
```