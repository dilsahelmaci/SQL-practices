-- Question 1
WITH sales_volume_July AS (
  SELECT
    product_id, 
    SUM(quantity_sold) AS sales_volume_by_product
  FROM fct_sales 
  WHERE sale_date >= DATE '2024-07-01'
    AND sale_date < DATE '2024-08-01'
  GROUP BY product_id
), 
essential_household_cat AS (
  SELECT 
    product_id
  FROM dim_products AS p 
  WHERE category = 'Essential Household'
)
SELECT 
  SUM(sales_volume_by_product) AS Total_Sales_Volume
FROM sales_volume_July
WHERE product_id IN (SELECT * FROM essential_household_cat);

-- Question 2
WITH product_avg_prices AS (
  SELECT
    product_id, 
    ROUND(AVG(unit_price), 2) AS avg_unit_price
  FROM fct_sales
  WHERE sale_date >= DATE '2024-07-01'
    AND sale_date < DATE '2024-08-01'
    AND product_id IN
      (SELECT product_id FROM dim_products
          WHERE category = 'Essential Household')
  GROUP BY product_id
)
SELECT 
  p.product_id, 
  p.product_name,
  CASE WHEN pap.avg_unit_price < 5 THEN 'Low'
      WHEN pap.avg_unit_price BETWEEN 5 AND 15 THEN 'Medium'
      ELSE 'High'
  END AS price_category
FROM product_avg_prices AS pap 
JOIN dim_products AS p
  ON pap.product_id = p.product_id; 
  
-- Question 3
WITH stats_per_product AS (
  SELECT
    product_id, 
    CASE WHEN AVG(unit_price) < 5 THEN 'Low'
        WHEN AVG(unit_price) BETWEEN 5 AND 15 THEN 'Medium'
        ELSE 'High'
    END AS Price_Range, 
    ROUND(SUM(quantity_sold), 2) AS Total_Sales_Volume
  FROM fct_sales
  WHERE sale_date >= DATE '2024-07-01'
    AND sale_date < DATE '2024-08-01'
    AND product_id IN 
      (SELECT product_id FROM dim_products WHERE category = 'Essential Household')
  GROUP BY product_id
)
SELECT
  price_range, 
  SUM(total_sales_volume) AS total_sales_volume
FROM stats_per_product
GROUP BY price_range
ORDER BY total_sales_volume DESC; 
