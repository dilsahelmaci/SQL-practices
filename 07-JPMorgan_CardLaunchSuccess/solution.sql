WITH cards_ranked AS (
  SELECT
    card_name, 
    issue_year,
    issue_month,
    issued_amount,
    -- Rank the issuance of each card type based on the earliest issue date
    RANK() OVER(
      PARTITION BY card_name  -- Ensures ranking is done within each card type
      ORDER BY issue_year, issue_month ASC  -- Orders by issue year and month in ascending order
    ) as ranked
  FROM monthly_cards_issued
) 

SELECT
  card_name,
  issued_amount
FROM cards_ranked
WHERE ranked = 1  -- Selects only the first issued record for each card type (launced time)
ORDER BY issued_amount DESC;  -- Orders the result by issued amount in descending order