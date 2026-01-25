-- Question 1
SELECT
  department_id,
  FLOOR(AVG(satisfaction_score)) AS avg_satisfaction_score
FROM employee_satisfaction
GROUP BY department_id;

-- Question 2
SELECT
  job_category_id,
  CEIL(AVG(satisfaction_score)) AS avg_satisfaction_score
FROM employee_satisfaction
GROUP BY job_category_id;

-- Question 3
SELECT
  department_id, 
  job_category_id,
  FLOOR(AVG(satisfaction_score)) AS Floor_Avg_Satisfaction,
  CEIL(AVG(satisfaction_score)) AS Ceil_Avg_Satisfaction
FROM employee_satisfaction
GROUP BY department_id, job_category_id;