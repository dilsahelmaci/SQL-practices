-- Question 1
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

-- Question 2
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

-- Question 3
-- Alternative approach 1
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

-- Alternative approach 2
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

-- Alternative approach 3
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