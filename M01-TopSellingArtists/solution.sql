WITH ranked_artists AS (
    SELECT
        artist_name,                            
        concert_revenue,                        
        genre,                                  
        number_of_members,                      
        (concert_revenue / number_of_members) AS revenue_per_member, -- Revenue earned per band member
        DENSE_RANK() OVER (                     
            PARTITION BY genre                  -- Rank artists within their respective genres
            ORDER BY (concert_revenue / number_of_members) DESC
        ) AS rank_in_genre                      -- Assign a ranking based on revenue per member
    FROM concerts
)

SELECT
    artist_name,            
    concert_revenue,        
    genre,                  
    number_of_members,     
    revenue_per_member
FROM ranked_artists
WHERE rank_in_genre = 1      -- Select only the top-ranked artist(s) per genre
ORDER BY revenue_per_member DESC; -- Sort by highest revenue per member