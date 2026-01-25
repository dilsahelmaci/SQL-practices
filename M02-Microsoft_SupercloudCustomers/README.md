# **Microsoft Azure Supercloud Customer**

## **Problem Overview**

A Microsoft Azure Supercloud customer is defined as a customer who has purchased at least one product from every product category listed in the products table.

Write a query that identifies the customer IDs of these Supercloud customers.

<img width="353" alt="Screenshot 2025-03-29 at 11 08 22" src="https://github.com/user-attachments/assets/608df7ae-68cc-4873-aecc-88caa1fba627" />

---
## **Solution**
```sql
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

SELECT customer_id 
FROM supercloud_customers
WHERE product_count = (SELECT COUNT(DISTINCT product_category) FROM products);  -- Compare each customer's count with the total number of unique categories
```
### **Breakdown of the Query**
1. **Identifying Unique Product Categories per Customer (using CTE)**:
   - The `supercloud_customers` CTE calculates how many distinct product categories each customer has purchased from.
   - It joins the `customer_contracts` table, which records customer purchases, with the `products` table to retrieve category details.
   - It then groups by `customer_id` and counts the distinct product categories for each customer.

2. **Filtering Supercloud Customers**:
   - The final selection retrieves customers whose distinct product category count is equal to the total number of unique product categories in the `products` table.
   - Therefore, this ensures only customers who have purchased from every available product category are included in the result.
