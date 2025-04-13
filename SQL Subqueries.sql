## Challenge
## Write SQL queries to perform the following tasks using the Sakila database:

## 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(i.inventory_id) AS number_of_copies
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

## Checking SQL outcome
## select * from film
## WHERE title = "Hunchback Impossible";

## select * from inventory
## WHERE film_id = "439";


## 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT length
FROM film
WHERE length > (SELECT AVG(length) FROM film);

## Checking :
## SELECT AVG(length) FROM film; -- answer = 115.27

## 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT f.title, f.film_id, fa.actor_id
FROM film f, film_actor fa
WHERE f.title = "Alone Trip";


## **Bonus**:
## 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films. 
select * from film_category;
select * from category;

SELECT DISTINCT c.name, f.title
FROM category c,
     film f,
     film_category fc
WHERE c.name= "Family";
     

## 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

## 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

-- Find the most prolific actor
SELECT actor_id, COUNT(film_id) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;   -- actor_id = 107 (42 films)

-- Retrieve the films for that actor
SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

-- Get the name of the actor
SELECT a.first_name, a.last_name, f.title
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE a.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

## 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
-- Use the payment table to calculate the total amount paid by each customer.
-- Identify the customer_id who paid the most.
-- Use that customer’s rentals to find the film titles they rented.

SELECT f.title, c.first_name, c.last_name, SUM(p.amount) AS total_spent
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE c.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
)
GROUP BY f.title, c.first_name, c.last_name
ORDER BY f.title;

## 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
-- 1. Calculate the total amount spent per client.
-- 2. Calculate the average of those totals (via a subquery).
-- 3. Filter to only return clients who spent more than that average.

SELECT customer_id AS client_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT customer_id, SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS client_totals
);