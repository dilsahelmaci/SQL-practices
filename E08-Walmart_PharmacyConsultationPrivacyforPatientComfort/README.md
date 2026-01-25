# **Pharmacy Consultation Privacy for Patient Comfort**

## **Problem Overview**
You are a Data Analyst on the Walmart Pharmacy team tasked with evaluating patient consultation privacy concerns. Your team is focused on understanding how different consultation room types and their associated privacy levels affect patient comfort and confidentiality. By analyzing consultation frequencies, room types, and privacy scores, you will recommend improvements to enhance patient privacy in pharmacy consultation spaces.

*Tables:*

*fct_consultations(consultation_id, pharmacy_name, consultation_date, consultation_room_type, privacy_level_score)*

---
## **Question 1**

What are the names of the 3 pharmacies that conducted the fewest number of consultations in July 2024? This will help us identify locations with potentially less crowded consultation spaces.

## **Solution**
```sql
SELECT
  pharmacy_name, 
  COUNT(*) AS consultation_count
FROM fct_consultations
WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
GROUP BY pharmacy_name
ORDER BY consultation_count ASC
LIMIT 3; 
```

---
## **Question 2**

For the pharmacies identified in the previous question (ie. the 3 pharmacies with a fewest consultations in July 2024), what is the uppercase version of the consultation room types available? Understanding the room types can provide insights into the privacy features offered.

## **Solution**
```sql
SELECT
  DISTINCT UPPER(consultation_room_type) AS room_type_upper
FROM fct_consultations
WHERE pharmacy_name IN (
  SELECT pharmacy_name
  FROM (
    SELECT pharmacy_name, COUNT(*) AS consultation_count
    FROM fct_consultations
    WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
    GROUP BY pharmacy_name
    ORDER BY consultation_count ASC
    LIMIT 3
  )
);
```

---
## **Question 3**

So far, we have identified the 3 pharmacies with a fewest consultations in July 2024. Among these 3 pharmacies, what is the minimum privacy level score for each consultation room type in July 2024?

## **Solution 1 (with LIMIT)**
```sql
WITH bottom_3_pharmacies AS (
  SELECT
    pharmacy_name
  FROM fct_consultations
  WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
  GROUP BY pharmacy_name
  ORDER BY COUNT(*) ASC
  LIMIT 3
)
SELECT 
  consultation_room_type, 
  MIN(privacy_level_score) AS min_privacy_level_score
FROM fct_consultations
WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND pharmacy_name IN (SELECT pharmacy_name FROM bottom_3_pharmacies)
GROUP BY consultation_room_type;
```

## **Solution 2 (with ROW_NUMBER())**
```sql
WITH bottom_3_pharmacies AS (
  SELECT
    pharmacy_name,
    COUNT(*) AS consultation_count,
    ROW_NUMBER() OVER(ORDER BY COUNT(*))
  FROM fct_consultations
  WHERE consultation_date BETWEEN '2024-07-01' AND '2024-07-31'
  GROUP BY pharmacy_name
)

SELECT
  consultation_room_type, 
  MIN(privacy_level_score)
FROM fct_consultations
WHERE (consultation_date BETWEEN '2024-07-01' AND '2024-07-31')
  AND (pharmacy_name IN (SELECT pharmacy_name FROM bottom_3_pharmacies WHERE row_number <= 3))
GROUP BY consultation_room_type; 
```