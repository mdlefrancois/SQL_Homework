use sakila;

-- Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT first_name AS 'Actor Name'
FROM actor
UNION
SELECT last_name
FROM actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- Find all actors whose last name contain the letters GEN
SELECT first_name, last_name
FROM actor
WHERE last_name IN
(
SELECT last_name
FROM actor
WHERE last_name LIKE '%G%E%N%'
);

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name IN
(
SELECT last_name
FROM actor
WHERE last_name LIKE '%L%I%'
);

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN
(
SELECT country
FROM country
WHERE country = 'Afghanistan' OR
country = 'Bangladesh' OR
country = 'China'
);

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD description BLOB NOT NULL;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(last_name) AS CountOf FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
-- SELECT DISTINCT last_name, COUNT(last_name) AS CountOf from actor GROUP BY last_name; 

SELECT last_name, count(last_name) AS 'Last Name Count'
FROM actor
GROUP BY last_name
HAVING 'Last Name Count' >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO', last_name= 'WILLIAMS'
WHERE actor_id = 172; -- looked up actor_id in table

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, adress.address
FROM staff staff
INNER JOIN address adress
ON (staff.address_id = adress.address_id);
-- or with aliases
-- SELCT s.first_name, s.last_name, a.address
-- FROM staff s
-- INNER JOIN address a
-- ON (s.address_id = a.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount)
FROM staff s
INNER JOIN payment p
ON (p.staff_id = s.staff_id)
WHERE MONTH(p.payment_date) = 08 AND YEAR(p.payment_date) = 2005
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(a.actor_id) AS 'ACTOR'
FROM film_actor a
INNER JOIN film f
ON f.film_id = a.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory_id) AS '# copies of film'
FROM film
INNER JOIN inventory
USING (film_id)
WHERE title = 'Hunchback Impossible'
GROUP BY title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total Amount Paid'
FROM payment AS p
JOIN customer AS c
ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title AS 'Film Title'
FROM film
WHERE title IN
(
SELECT title
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%'
)
AND language_id IN
(
SELECT language_id
FROM language
WHERE name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id =
(
SELECT film_id
FROM film
WHERE title = "Alone Trip"
)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer c
JOIN address a
ON (c.address_id = a.address_id) -- line up the addresses of each customer 
JOIN city city
ON (a.city_id = city.city_id) -- line up the cities of each address
JOIN country ctr
ON (city.country_id = ctr.country_id) -- line up the cities that are within Canada
WHERE ctr.country = 'canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT rating, title
FROM film
WHERE rating IN
(
SELECT rating
FROM film
WHERE rating = 'PG' OR
rating = 'G'
)
ORDER BY rating ASC;

-- 7e. Display the most frequently rented movies in descending order.
SELECT title ,SUM(rental_duration) AS 'Highest Duration Rentals'
FROM film GROUP BY rental_duration DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff_id ,SUM(amount) AS 'Business Per Store ($)'
FROM payment GROUP BY staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city_id, district
FROM store s
JOIN address a
ON (s.address_id = a.address_id);
 
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

-- pulling name from category table
-- pulling amount from payment table
SELECT name AS 'Genre', concat('$',format(SUM(amount),2)) AS 'Gross Revenue ($)'
FROM category
JOIN film_category ON category.category_id=film_category.category_id -- join using category and film_category tables
JOIN inventory ON film_category.film_id=inventory.film_id -- join using inventory and film_category tables
JOIN rental ON inventory.inventory_id=rental.inventory_id -- join rental and inventory tables
JOIN payment ON rental.rental_id=payment.rental_id -- join payment and rental tables
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five AS
SELECT name AS 'Genre', concat('$',format(SUM(amount),2)) AS 'Gross Revenue ($)'
FROM category
JOIN film_category ON category.category_id=film_category.category_id -- join using category and film_category tables
JOIN inventory ON film_category.film_id=inventory.film_id -- join using inventory and film_category tables
JOIN rental ON inventory.inventory_id=rental.inventory_id -- join rental and inventory tables
JOIN payment ON rental.rental_id=payment.rental_id -- join payment and rental tables
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_Five;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five;
