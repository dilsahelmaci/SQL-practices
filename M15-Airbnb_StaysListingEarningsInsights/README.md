# **Stays Listing Earnings Insights**

## **Problem Overview**
As a Product Analyst on the Airbnb Stays team, you are investigating how listing amenities and pricing strategies impact hosts' supplemental income. Your focus is on understanding the influence of features like pools or ocean views, and the effect of cleaning fees on pricing. Your goal is to derive insights that will help build a pricing recommendation framework to optimize potential nightly earnings for hosts.

*Tables:*

*fct_bookings(booking_id, listing_id, booking_date, nightly_price, cleaning_fee, booked_nights)*

*dim_listings(listing_id, amenities, location)*

---
## **Question 1**

What is the overall average nightly price for listings with either a 'pool' or 'ocean view' in July 2024? Consider only listings that have been booked at least once during this period.

## **Solution**
```sql
SELECT
  ROUND(AVG(b.nightly_price), 2) AS avg_nighly_price
FROM fct_bookings AS b
JOIN dim_listings AS l
  ON b.listing_id = l.listing_id
WHERE booking_date >= '2024-07-01'
  AND booking_date < '2024-08-01'
  AND (l.amenities LIKE '%pool%' OR l.amenities LIKE '%ocean view%'); 
```

---
## **Question 2**
For listings with no cleaning fee (ie. NULL values in the 'cleaning_fee' column), what is the average difference in nightly price compared to listings with a cleaning fee in July 2024?

## **Solution**
```sql
SELECT
    ROUND(
        AVG(CASE WHEN cleaning_fee IS NULL THEN nightly_price END)
        - AVG(CASE WHEN cleaning_fee IS NOT NULL THEN nightly_price END)
    , 2) AS avg_price_difference
FROM fct_bookings
WHERE booking_date >= '2024-07-01'
  AND booking_date < '2024-08-01';
```

---
## **Question 3**
Based on the top 50% of listings by earnings in July 2024, what percentage of these listings have ‘ocean view’ as an amenity? For this analysis, look at bookings that were made in July 2024.

## **Solution**
```sql
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
```