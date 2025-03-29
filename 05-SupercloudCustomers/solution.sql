-- Create CTE to count the number of unique product categories that each customer has purchased from
WITH supercloud_customers AS (
    SELECT 
        cc.customer_id, 
        COUNT(DISTINCT p.product_category) AS product_count  -- Count distinct product categories for each customer
    FROM customer_contracts AS cc
    INNER JOIN products AS p  
        ON cc.product_id = p.product_id
    GROUP BY cc.customer_id  -- Group by customer to be able to calculate category count per customer
    ORDER BY cc.customer_id ASC  
)

-- Select customers who have purchased from all available product categories
SELECT customer_id 
FROM supercloud_customers
WHERE product_count = (SELECT COUNT(DISTINCT product_category) FROM products);  -- Compare each customer's count with the total number of unique categories