-- Question 1
SELECT
  zone_name, 
  MIN(acceptance_rate) AS min_acceptance_rate
FROM fct_zone_daily_rides
WHERE ride_date BETWEEN '2024-04-01' AND '2024-06-30'
GROUP BY zone_name;

-- Question 2
SELECT
  DISTINCT zone_name
FROM fct_zone_daily_rides
WHERE ride_date BETWEEN '2024-04-01' AND '2024-06-30' AND acceptance_rate < 0.5;

-- Question 3
SELECT
  zone_name
FROM fct_zone_daily_rides
WHERE ride_date BETWEEN '2024-04-01' AND '2024-06-30' AND declined_requests >= 10
ORDER BY acceptance_rate ASC
LIMIT 1; 