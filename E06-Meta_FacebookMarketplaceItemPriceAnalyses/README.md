# **Facebook Marketplace Item Price Analyses**

### **Problem Overview**
Your Product Manager of Facebook Marketplace wants to understand how items are priced across cities.

*Tables:*

*Listings(listing_id, category, price, city, user_id)*

### **Question 1**

Can you find the average price of items listed in each category on Facebook Marketplace? We want to understand the pricing trends across different categories.


### **Solution**
```sql
SELECT
  category, 
  AVG(price)::INT AS avg_price
FROM Listings
GROUP BY category;
```
### **Question 2**

Which city has the lowest average price? This will help us identify the most affordable cities for buyers.

### **Solution**
```sql
SELECT
  city, 
  AVG(price)::INT avg_price
FROM Listings
GROUP BY city
ORDER BY avg_price
LIMIT 1; 
```