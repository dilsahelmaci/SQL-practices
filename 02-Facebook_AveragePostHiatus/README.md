# **Days Between First and Last Post in 2021**

## **Problem Overview**
Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021. Output the user and the number of days between their first and last post.

<img width="1027" alt="image" src="https://github.com/user-attachments/assets/0c8aadb9-32d5-4833-8bb1-98dfe980d0bb" />

<img width="309" alt="image" src="https://github.com/user-attachments/assets/ea7becec-cfe6-4620-8e2e-0ea9be3af4df" />

---
# **Solution**
**Final Query**
```sql
SELECT
  user_id,
  MAX(post_date::DATE) - MIN(post_date::DATE) AS days_between
FROM posts
WHERE DATE_PART('year', post_date) = 2021
GROUP BY user_id
HAVING COUNT(post_id) > 1;
```
### Query Breakdown
1. **Filtering for 2021:**
   ```sql
   WHERE DATE_PART('year', post_date) = 2021
   ```
   - Extracts the year from `post_date` and ensures we only consider posts from 2021.

2. **Grouping by User:**
   ```sql
   GROUP BY user_id
   ```
   - Groups the posts by `user_id` so that we can calculate the first and last post for each user.

3. **Finding First and Last Post Dates:**
   ```sql
   MAX(post_date::DATE) - MIN(post_date::DATE) AS days_between
   ```
   - `MIN(post_date::DATE)`: Gets the first post date of the year.
   - `MAX(post_date::DATE)`: Gets the last post date of the year.
   - The subtraction gives the number of days between the first and last post.

4. **Filtering Users with at Least Two Posts:**
   ```sql
   HAVING COUNT(post_id) > 1
   ```
   - Ensures only users who posted at least twice in 2021 are included in the results.

