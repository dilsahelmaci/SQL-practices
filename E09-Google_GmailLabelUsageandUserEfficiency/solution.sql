-- Question 1
SELECT
  user_id, 
  COUNT(label_id) AS label_count
FROM email_labels
GROUP BY user_id; 

-- Question 2
SELECT
  label_id, 
  COUNT(email_id) AS email_count
FROM emails
GROUP BY label_id
HAVING COUNT(email_id) > 5;

-- Question 3
SELECT
  email_labels.label_id, 
  COUNT(emails.email_id) AS email_count
FROM email_labels
LEFT JOIN emails
  ON email_labels.label_id = emails.label_id
WHERE created_date BETWEEN '2024-10-01' AND '2024-10-31'
GROUP BY email_labels.label_id; 