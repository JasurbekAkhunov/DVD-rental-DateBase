/*
Using windows functins
*/
SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER(ORDER BY occurred_at) AS running_total
FROM orders

/*
Now adding PARTITION BY to the running_total
*/
SELECT standard_amt_usd,
       DATE_TRUNC('month', occurred_at),
       SUM(standard_amt_usd) OVER( PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders


/*
Ranking total paper ordered by account
*/
SELECT id,
       account_id,
       total,
       RANK() OVER(PARTITION BY account_id  ORDER BY total DESC) AS total_rank
FROM orders


/*
Derek's query
*/

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders

--------------------------------

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders




SELECT total_sum,
       occurred_at,
       LEAD(total_sum) OVER (ORDER BY total_sum) AS lead,
       LEAD(total_sum) OVER (ORDER BY total_sum) - total_sum AS lead_difference
FROM (
      SELECT account_id,
             occurred_at,
             SUM(total_amt_usd) AS total_sum
      FROM orders 
      GROUP BY 1,2
     ) sub



/*
task 1
*/
SELECT  account_id,
        occurred_at,
        standard_qty,
        NTILE(4) OVER (PARTITION BY standard_qty ORDER BY standard_qty) AS standard_quartile
FROM orders

/*
task 2
*/
SELECT  account_id,
        occurred_at,
        gloss_qty,
        NTILE(2) OVER (PARTITION BY gloss_qty ORDER BY gloss_qty) AS gloss_half
FROM orders

/*
task 3
*/
SELECT  account_id,
        occurred_at,
        total_amt_usd,
        NTILE(100) OVER (PARTITION BY total_amt_usd ORDER BY total_amt_usd) AS total_percentile
FROM orders





SELECT *
FROM accounts a
FULL OUTER JOIN sales_reps sr 
ON a.sales_rep_id = sr.id
WHERE a.sales_rep_id IS NULL OR sr.id IS NULL




SELECT a.name as account_name,
       a.primary_poc as poc_name,
       sr.name as sales_rep_name
FROM accounts a
LEFT JOIN sales_reps sr
ON a.sales_rep_id = sr.id
AND a.primary_poc < sr.name





SELECT we1.channel AS we1_channel,
       we2.channel AS we2_channel,
       we1.id AS we1_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at
  FROM web_events we1
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we2.occurred_at > we1.occurred_at
  AND we2.occurred_at <= we1.occurred_at + INTERVAL '1 days'
ORDER BY we1.account_id, we1.occurred_at


---------------------------------------------
✅

SELECT *
FROM accounts AS a1


UNION ALL

SELECT *
FROM accounts AS a2

---------------------------------------------
✅

SELECT *
FROM accounts AS a1
WHERE name = 'Walmart'

UNION ALL

SELECT *
FROM accounts AS a2
WHERE name = 'Disney'

-----------------------------------------------
❌ - corrected


WITH double_accounts AS 
              (
               SELECT *
               FROM accounts AS a1
               
               UNION ALL
               
               SELECT *
               FROM accounts AS a2
              )

SElECT name,
       COUNT(*)
FROM double_accounts
GROUP BY 1




SELECT COUNT(CITY) - COUNT(DISTINCT CITY)
FROM STATION;




-----------------------------------------


SELECT  city, 
        LENGTH(city) 
FROM station 
ORDER BY LENGTH(city), city 
LIMIT 1;

SELECT  city, 
        LENGTH(city) 
FROM station 
ORDER BY LENGTH(city) DESC, city 
LIMIT 1;


----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

PROJECT on PorstgreSQL


SELECT CONCAT(first_name,' ', last_name) AS full_name,
	   title,
	   description,
	   length
FROM actor
JOIN film_actor
ON film_actor.actor_id = actor.actor_id
JOIN film
ON film_actor.film_id = film.film_id;


SELECT actor_id,
	   CONCAT(first_name,' ', last_name) AS full_name,
	   title,
	   length
FROM actor
JOIN film_actor
ON film_actor.actor_id = actor.actor_id
JOIN film
ON film_actor.film_id = film.film_id
WHERE length > 60;



SELECT a.first_name, 
       a.last_name, 
       a.first_name || ' ' || a.last_name AS full_name, 
       f.title, 
       f.length 
FROM film_actor fa 
 JOIN actor a 
  ON fa.actor_id = a.actor_id 
 JOIN film f 
  ON f.film_id = fa.film_id;



SELECT actorid, 
       full_name, 
       COUNT(filmtitle) film_count_peractor 
FROM (SELECT a.actor_id actorid, 
               a.first_name,
               a.last_name,
               a.first_name || ' ' || a.last_name AS full_name,
               f.title filmtitle
        FROM film_actor fa
        JOIN actor a
        ON fa.actor_id = a.actor_id
        JOIN film f
        ON f.film_id = fa.film_id
        ) t1
GROUP BY 1, 2
ORDER BY 3 DESC


/*
actor's full name, film title,
length of movie, and a column name
"filmlen_groups" that classifies movies
based on their length
*/



        SELECT CONCAT(first_name,' ', last_name) AS full_name,
             f.title,
             f.length,
             CASE WHEN f.length <= 60 THEN '1 hour or less'
                  WHEN f.length > 60 AND f.length < 120 THEN 'Between 1-2 hours'
                  WHEN f.length BETWEEN 120 AND 180 THEN ' Between 2-3 hours'
                  WHEN f.length > 180 THEN 'More than 3 hours'
                  END AS filmlen_group
      FROM actor a
      JOIN film_actor fa
      ON fa.actor_id = a.actor_id
      JOIN film f
      ON fa.film_id = f.film_id;






WITH total AS(
        SELECT 
             f.title,
             CASE WHEN f.length <= 60                THEN '1 hour or less'
                  WHEN f.length BETWEEN 60 AND 120   THEN 'Between 1-2 hours'
                  WHEN f.length BETWEEN 120 AND 180  THEN 'Between 2-3 hours'
                  WHEN f.length > 180                THEN 'More than 3 hours'
                  END AS filmlen_group
      FROM film f
)

SELECT total.filmlen_group,
       COUNT(total.filmlen_group)
FROM total
GROUP BY 1
ORDER BY 2 DESC;






--Question Set I
--Question 1
--We want to understand more about the movies that families 
--are watching. The following categories are considered family movies: 
--Animation, Children, Classics, Comedy, Family and Music.


SELECT f.title AS film_name,
       c.name AS category_name,
       COUNT(r.rental_id) AS rental_count
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title, c.name
WHERE category_name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY c.name, f.title;




--Question 2
--Now we need to know how the length of rental duration
--of these family-friendly movies
--compares to the duration that all movies are rented for.

SELECT f.title,
       c.name,
       f.rental_duration,
       NTILE(4) OVER (PARTITION BY f.rental_duration) AS quartile_duration
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')



--Question 3
--Finally, provide a table with the family-friendly film
--category, each of the quartiles, and the corresponding count
--of movies within each combination of film
--category for each corresponding rental duration category.

WITH total AS (
   SELECT f.title,
          c.name,
          f.rental_duration,
          CASE WHEN NTILE(4) OVER (PARTITION BY f.rental_duration) = 1 THEN 'first_quarter'
               WHEN NTILE(4) OVER (PARTITION BY f.rental_duration) = 2 THEN 'second_quarter'
               WHEN NTILE(4) OVER (PARTITION BY f.rental_duration) = 3 THEN 'third_quarter'
               ELSE 'final_quarter'
          END AS quartile_duration
   FROM film f
   JOIN film_category fc ON f.film_id = fc.film_id
   JOIN category c ON fc.category_id = c.category_id
   WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
)

SELECT total.name, quartile_duration, COUNT(*)
FROM total
GROUP BY 1, 2
ORDER BY 1, 2








--Question Set II
--Question 1:
--We want to find out how the two stores compare in their count of
--rental orders during every month for all the years we have data for.

SELECT DATE_PART('month', r.rental_date) AS Rental_month,
       DATE_PART('year', r.rental_date) AS Rental_year,
       s.store_id,
       COUNT(*)
FROM rental r
JOIN staff s
ON r.staff_id = s.staff_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC




--Question 2
--We would like to know who were our top 10 paying customers,
--how many payments they made on a monthly
--basis during 2007, and what was the amount of the monthly payments.

SELECT DATE_TRUNC('month', p.payment_date) AS pay_mon,
       CONCAT(c.first_name, ' ', c.last_name) AS full_name,
       
       COUNT(p.payment_id) AS pay_countpermon,
       SUM(p.amount) AS pay_amount      
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
--WHERE CONCAT(c.first_name, ' ', c.last_name) = 'Ana Bradley'
GROUP BY 1, 2
ORDER BY 4 DESC
LIMIT 10;




--Question 3
--Finally, for each of these top 10 paying customers,
--I would like to find out the
--difference across their monthly payments during 2007.

WITH top_customers AS (
                       SELECT
                   	  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
                   	  RANK() OVER(ORDER BY SUM(p.amount) DESC) AS customer_rank,
                   	  c.customer_id
                   FROM customer c
                   JOIN payment p
                   ON p.customer_id = c.customer_id
                   WHERE DATE_TRUNC('year', p.payment_date) = '2007-01-01'
                   GROUP BY 1, 3
                )            
SELECT t.full_name, 
       DATE_TRUNC('month', p.payment_date) AS pay_month,
LEAD(SUM(p.amount)) OVER (PARTITION BY p.customer_id ORDER BY DATE_TRUNC('month', p.payment_date)) - SUM(p.amount) AS difference  
FROM payment p
JOIN top_customers t ON p.customer_id = t.customer_id
WHERE DATE_TRUNC('year', p.payment_date) = '2007-01-01'
GROUP BY t.full_name, pay_month, t.customer_rank,p.customer_id
ORDER BY t.customer_rank, pay_month;


----------------------------------------------------

WITH top_customers AS (
	SELECT
	  CONCAT(c.first_name, ' ', c.last_name) AS full_name,
	  RANK() OVER(ORDER BY SUM(p.amount) DESC) AS customer_rank,
	  c.customer_id
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
WHERE DATE_TRUNC('year', p.payment_date) = '2007-01-01'
GROUP BY 1, 3
)

SELECT t.full_name, 
	DATE_TRUNC('month', p.payment_date) AS pay_month,
	LEAD(SUM(p.amount)) OVER(PARTITION BY p.customer_id ORDER BY DATE_TRUNC('month', p.payment_date)) - SUM(p.amount) AS difference
FROM payment p 
JOIN top_customers t
ON p.customer_id = t.customer_id
WHERE DATE_TRUNC('year', p.payment_date) = '2007-01-01'
GROUP BY t.full_name, pay_month, p.customer_id, t.customer_rank









