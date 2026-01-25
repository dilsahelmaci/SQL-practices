# **Ranking Top Revenue-Generating Artists by Genre**

## **Problem Overview**

As the lead data analyst for a prominent music event management company, you have been entrusted with a dataset containing concert revenue and detailed information about various artists.

Your mission is to unlock valuable insights by analyzing the concert revenue data and identifying the top revenue-generating artists within each music genre.

Write a query to rank the artists within each genre based on their revenue per member and extract the top revenue-generating artist from each genre. Display the output of the artist name, genre, concert revenue, number of members, and revenue per band member, sorted by the highest revenue per member within each genre.
<img width="954" alt="image" src="https://github.com/user-attachments/assets/ed054596-66a7-45ce-8cef-fb5eda3e5869" />

---
## **Solution**
```sql
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
```
### **Breakdown of the Query**
1. **Ranking Artists per Genre:**
   - The `DENSE_RANK()` function ranks artists within their genre based on revenue per band member in descending order.
   - The `PARTITION BY genre` ensures ranking is done separately for each genre.
   
2. **Finding Top Artists:**
   - We select only the artists ranked `1` to get the highest revenue per band member in each genre.
   - Sorting the final results by `revenue_per_member` ensures the most profitable artist per member appears first in the result table.

- **PS**: With DENSE_RANK(), we ensure that even if multiple artists have the same revenue per member in a genre, they are all included.
