# **Supplier Performance Metrics**

## **Problem Overview**
As a Data Analyst on the Supply Chain Procurement Team, you are tasked with assessing supplier performance to ensure reliable delivery of critical components. Your goal is to identify the most active suppliers, understand which suppliers dominate in specific manufacturing regions, and pinpoint any gaps in supply to the Asia region. By leveraging data, you will help optimize vendor selection strategies and mitigate potential supply chain risks.

*Tables:*

*supplier_deliveries(supplier_id, delivery_date, component_count, manufacturing_region)*

*suppliers(supplier_id, supplier_name)*

---
## **Question 1**

We need to know who our most active suppliers are. Identify the top 5 suppliers based on the total volume of components delivered in October 2024.

## **Solution**
```sql
SELECT
  supplier_deliveries.supplier_id,
  supplier_name, 
  SUM(component_count) AS total_component_count
FROM supplier_deliveries
INNER JOIN suppliers
  ON supplier_deliveries.supplier_id = suppliers.supplier_id
WHERE delivery_date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY supplier_deliveries.supplier_id, supplier_name
ORDER BY total_component_count DESC
LIMIT 5; 
```

---
## **Question 2**

For each region, find the supplier ID that delivered the highest number of components in November 2024. This will help us understand which supplier is handling the most volume per market.

## **Solution**
```sql
WITH component_volume_by_region_supplier AS(
  SELECT
    manufacturing_region,
    supplier_id,
    SUM(component_count) AS total_component_count
  FROM supplier_deliveries
  WHERE delivery_date BETWEEN '2024-11-01' AND '2024-11-30'
  GROUP BY manufacturing_region, supplier_id
),
ranked_suppliers AS(
  SELECT
    manufacturing_region, 
    supplier_id, 
    total_component_count,
    RANK() OVER(PARTITION BY manufacturing_region ORDER BY total_component_count DESC) AS ranking
  FROM component_volume_by_region_supplier 
)
SELECT 
  manufacturing_region, 
  supplier_id
--  ranking
FROM ranked_suppliers
WHERE ranking = 1;
```
---
## **Question 3**

We need to identify potential gaps in our supply chain for Asia. List all suppliers by name who have not delivered any components to the 'Asia' manufacturing region in December 2024.

## **Solution 1 with EXCEPT**
```sql
SELECT
  DISTINCT(supplier_id),
  supplier_name
FROM suppliers
  
EXCEPT
  
SELECT
  DISTINCT(supplier_deliveries.supplier_id),
  supplier_name
FROM supplier_deliveries
INNER JOIN suppliers
  ON supplier_deliveries.supplier_id = suppliers.supplier_id
WHERE delivery_date BETWEEN '2024-12-01' AND '2024-12-31'
  AND manufacturing_region = 'Asia'
  AND component_count > 0; 
```

## **Solution 2 with Anti-Join**
```sql
SELECT
  supplier_id,
  supplier_name
FROM suppliers 
WHERE supplier_id NOT IN (
    SELECT supplier_id
    FROM supplier_deliveries
    WHERE manufacturing_region = 'Asia'
      AND delivery_date BETWEEN '2024-12-01' AND '2024-12-31'
      AND component_count > 0
);
```
## **Solution 3 with LEFT JOIN**
```sql
SELECT
  suppliers.supplier_id,
  supplier_name
FROM suppliers
LEFT JOIN supplier_deliveries
  ON suppliers.supplier_id = supplier_deliveries.supplier_id
  AND manufacturing_region = 'Asia'
  AND delivery_date BETWEEN '2024-12-01' AND '2024-12-31'
  AND component_count > 0
WHERE supplier_deliveries.supplier_id IS NULL
ORDER BY supplier_name;
```