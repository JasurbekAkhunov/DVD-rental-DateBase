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
