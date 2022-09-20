USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) AS 'amount of copies'
FROM inventory
WHERE film_id IN   
	(SELECT film_id FROM film
	WHERE title = 'Hunchback Impossible');


-- 2. List all films whose length is longer than the average of all the films.
SELECT f.title AS 'title', f.length
FROM film f
WHERE length > (
  SELECT avg(length)
  FROM film f
) ORDER BY length DESC;


-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in
		(SELECT film_id FROM film
		WHERE title = 'Alone Trip'));


-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id in
	(SELECT film_id FROM film_category
	WHERE category_id in
		(SELECT category_id FROM category
		WHERE name = 'Family'));


-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins.
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.
SELECT first_name, last_name, email FROM customer
WHERE address_id IN (
	SELECT address_id FROM address
	WHERE city_id in
		(SELECT city_id FROM city
		WHERE country_id in
			(SELECT country_id FROM country
			WHERE country = 'Canada')));

SELECT c.first_name, c.last_name, c.email FROM customer c
JOIN address a
ON c.address_id = a.address_id
JOIN city ci
ON a.city_id = ci.city_id
JOIN country co
ON ci.country_id = co.country_id
WHERE country = 'Canada'
GROUP BY c.customer_id;


-- 6. Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to 
-- find the different films that he/she starred.
SELECT actor_id, COUNT(actor_id)
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(actor_id) DESC
LIMIT 1; -- The actor id is 107. The actor is GINA DEGERENES.

SELECT * FROM film 
WHERE film_id IN (
SELECT film_id FROM film_actor 
WHERE actor_id = '107');

SELECT film_id, title
FROM film_actor
LEFT JOIN film USING (film_id)
WHERE actor_id = (SELECT actor_id
					FROM(SELECT actor_id, COUNT(film_id)
							FROM film_actor
							GROUP BY actor_id
							ORDER BY COUNT(film_id) DESC
							LIMIT 1) sub1); -- can't have a limit at the end of subquery, have
									-- to add another layer


-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1; -- The customer id is 526 with amount of 221.55.

SELECT * FROM film
WHERE film_id IN (
	SELECT film_id FROM inventory 
	WHERE inventory_id IN (
		SELECT inventory_id FROM rental 
		WHERE customer_id = '526'));

SELECT title
FROM sakila.film
WHERE film_id IN(
	SELECT film_id FROM( 
		SELECT film_id FROM sakila.inventory i
		JOIN sakila.rental r USING(inventory_id)
		WHERE customer_id = (SELECT customer_id FROM (
			SELECT customer_id, SUM(amount) FROM sakila.payment
			GROUP BY customer_id
			ORDER BY SUM(amount) DESC
			LIMIT 1) sub1)) sub2);

-- 8. Customers who spent more than the average payments.

SELECT * FROM customer
WHERE customer_id IN (
	SELECT customer_id FROM payment 
	WHERE amount > 
		(SELECT AVG(amount) 
		FROM payment));