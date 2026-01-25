-- Question 1
SELECT
  category, 
  AVG(price)::INT AS avg_price
FROM Listings
GROUP BY category;

-- Question 2
SELECT
  city, 
  AVG(price)::INT avg_price
FROM Listings
GROUP BY city
ORDER BY avg_price
LIMIT 1; 
