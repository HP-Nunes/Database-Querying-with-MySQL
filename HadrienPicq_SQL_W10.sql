USE sakila;
# 1a: Display the first and last names of all actors from the table `actor`
SELECT * FROM actor;
# 1b: Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`
ALTER TABLE actor
ADD COLUMN actor_name VARCHAR(100) AFTER actor_id;
UPDATE actor
SET actor_name = concat(first_name, ' ', last_name);
SELECT * FROM actor;
# 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name from actor 
where actor_name like 'JOE%';
# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT last_name from actor 
where last_name like '%GEN%';
# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name from actor 
where last_name like '%LI%';
# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country 
WHERE country IN ('Afghanistan','Bangladesh','China');
# 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;
SELECT * FROM actor;
# 3b. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor MODIFY middle_name blob;
# 3c. Now delete the `middle_name` column.
ALTER TABLE actor 
DROP COLUMN `middle_name`;
# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name;
# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT DISTINCT last_name as last_name, COUNT(last_name) As count
FROM actor 
GROUP BY last_name 
HAVING count > 1;
# * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';
UPDATE actor
SET actor_name = concat(first_name, ' ', last_name);
SELECT actor_id, first_name, last_name, actor_name from actor 
where first_name = 'HARPO'; #verify the query worked properly
# 4d. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'MUCHO' 
WHERE actor_id = '172';
UPDATE actor
SET last_name = 'GROUCHO'
WHERE actor_id = '172';
UPDATE actor
SET actor_name = concat(first_name, ' ', last_name);
SELECT actor_id, first_name, last_name, actor_name from actor 
where actor_id = '172';
# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
DESCRIBE address;
# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
Select staff.first_name, staff.last_name, address.address from staff
Join address On (staff.address_id = address.address_id);
# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT * FROM staff;
Select staff_id, amount 
FROM payment WHERE DATE(payment_date) < '2005-05-30';
Select sum(payment.amount) as staff_expense from payment group by staff_id; #Numbers seem off
Select staff.first_name, staff.last_name from staff Join payment On (staff.staff_id = payment.staff_id); # Didn't work
	##Method 2##
Select sum(payment.amount) as staff_expense 
FROM 
(
Select staff_id 
From payment WHERE DATE(payment_date) < '2005-05-30' 
)
group by staff_id; # Nope
# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT * FROM film_actor;
SELECT * FROM film;

Select film.title, film_actor.actor_id from film
Inner Join film_actor On (film_actor.film_id = film.film_id);

Select title, film_id
from film
where film_id in (
Select count(actor_id) as actor_appearance_count
from film_actor group by actor_id);
