USE sakila;

#How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(*) AS number_copies
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

#List all films whose length is longer than the average of all the films.

SELECT AVG(length) AS average_length
FROM film;

SELECT f.title AS film_title, f.length
FROM film f
WHERE f.length > (SELECT AVG(length) FROM film);

#Use subqueries to display all actors who appear in the film Alone Trip.

SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

#Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.

SELECT f.title AS film_title, c.name AS category_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

#Get name and email from customers from Canada using subqueries. Do the same with joins. 
#Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
#that will help you get the relevant information.


SELECT first_name, last_name, email
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);

SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

#Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
#First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT a.actor_id, a.first_name, a.last_name, COUNT(*) AS film_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY film_count DESC
LIMIT 1;


SELECT f.title AS film_title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM (
        SELECT actor_id, COUNT(*) AS film_count
        FROM film_actor
        GROUP BY actor_id
        ORDER BY film_count DESC
        LIMIT 1
    ) AS most_prolific
);

#Films rented by most profitable customer. 
#You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_payments
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_payments DESC
LIMIT 1;

SELECT f.title AS film_title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
WHERE p.customer_id = (
    SELECT c.customer_id
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    ORDER BY SUM(p.amount) DESC
    LIMIT 1
)
GROUP BY f.title
LIMIT 5;


#Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent 
#by each client.

SELECT c.customer_id AS client_id, SUM(p.amount) AS total_amount_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING total_amount_spent > (
    SELECT AVG(total_amount)
    FROM (
        SELECT c.customer_id, SUM(p.amount) AS total_amount
        FROM customer c
        JOIN payment p ON c.customer_id = p.customer_id
        GROUP BY c.customer_id
    ) AS avg_table
)
ORDER BY total_amount_spent DESC;






