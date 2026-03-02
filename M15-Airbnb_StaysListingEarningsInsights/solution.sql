-- Question 1
SELECT
  ROUND(AVG(b.nightly_price), 2) AS avg_nighly_price
FROM fct_bookings AS b
JOIN dim_listings AS l
  ON b.listing_id = l.listing_id
WHERE booking_date >= '2024-07-01'
  AND booking_date < '2024-08-01'
  AND (l.amenities LIKE '%pool%' OR l.amenities LIKE '%ocean view%'); 

-- Question 2
SELECT
    ROUND(
        AVG(CASE WHEN cleaning_fee IS NULL THEN nightly_price END)
        - AVG(CASE WHEN cleaning_fee IS NOT NULL THEN nightly_price END)
    , 2) AS avg_price_difference
FROM fct_bookings
WHERE booking_date >= '2024-07-01'
  AND booking_date < '2024-08-01';
  
-- Question 3
WITH july_earnings AS (
    SELECT
        listing_id,
        SUM(nightly_price * booked_nights) AS total_earnings
    FROM fct_bookings
    WHERE booking_date >= DATE '2024-07-01'
      AND booking_date < DATE '2024-08-01'
    GROUP BY listing_id
),
ranked_listings AS (
    SELECT
        listing_id,
        total_earnings,
        PERCENT_RANK() OVER (
            ORDER BY total_earnings DESC
        ) AS percent_rnk
    FROM july_earnings
),
top_50_percent AS (
    SELECT listing_id
    FROM ranked_listings
    WHERE percent_rnk <= 0.5
)
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN l.amenities ILIKE '%ocean view%' THEN 1 END)
          /
        COUNT(*)
    , 2) AS pct_ocean_view
FROM top_50_percent t
JOIN dim_listings l
    ON t.listing_id = l.listing_id;