-- Question 1
SELECT
  ROUND(AVG(booking_cost), 2) AS avg_booking_cost
FROM fct_corporate_bookings
WHERE booking_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Question 2
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

-- Question 3
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