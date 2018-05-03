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

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, write a query to fix the record.
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
SELECT * FROM payment;

Select s.first_name, s.last_name, sum(p.amount) AS total_amount
	from staff s
    Join payment p
		On s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-05%'
group by s.staff_id;

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT * FROM film_actor;
SELECT * FROM film;

Select f.title, count(fa.actor_id)
	from film f
	Inner Join film_actor fa
		On fa.film_id = f.film_id
group by f.title; 
		# The result checks out, I verified the unique count of film_id in table fa:
							# SELECT film_id, COUNT(*) as count 
                            # FROM film_actor GROUP BY film_id 
                            # ORDER BY count DESC;
                            
# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film_id 
	FROM film
	where title = "Hunchback Impossible"; # id = 439

SELECT * FROM inventory;

SELECT film_id, Count(*)
	FROM inventory 
    Where film_id = 439; # Count = 6

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT * FROM payment;

SELECT * FROM customer;

Select c.last_name, sum(p.amount) as Customer_Spending
	from customer c
	Inner Join payment p
		On c.customer_id = p.customer_id
group by c.last_name
order by c.last_name; 

# 7a. Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT * FROM language; # ID of 1 = English 
Select distinct(language_id) from film; # Shows only values with ID of 1. Thus all films are in English.

SELECT * FROM film;

SELECT title 
	FROM film
Where title LIKE 'K%' or title LIKE 'Q%' ;

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
Select f.title, fa.actor_id
	from film f
	Inner Join film_actor fa
		On fa.film_id = f.film_id
where f.title = 'Alone Trip'; 

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT * FROM customer; # email
SELECT * FROM address; # city id
SELECT * FROM city; #country id
SELECT * FROM country; # country

Create view email_list as 
Select c.email, co.country
From customer c
Join address ad
On (c.address_id = ad.address_id)
join city ci
on (ad.city_id = ci.city_id)
join country co
on (ci.country_id = co.country_id)
where co.country = 'Canada';

SELECT * FROM email_list;

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT * FROM film_category; 

Create view family_list as 
Select f.title
From category ca
Join film_category fca
On (ca.category_id = fca.category_id)
Join film f
On (fca.film_id = f.film_id)
where ca.name = 'Family';

SELECT * FROM family_list; # country

# 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental; #inventory_id
SELECT * FROM inventory; #film_id

Select count(r.inventory_id) as rental_count, f.title
	From rental r
	Join inventory i
	On (r.inventory_id = i.inventory_id)
	Join film f
	On (i.film_id = f.film_id)
    group by f.title;
;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store; # manager_staff_id is the same as staff_id in payment Table ?
SELECT * FROM payment; # staff_id, amount, payment_id

SELECT p.staff_id, sum(p.amount) as total_revenue # Staff ID corresponds to the Store ID
FROM payment p
group by p.staff_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store; # store_id, address_id
SELECT * FROM address; # address, city_id
SELECT * FROM city; # city
SELECT * FROM country; # rental_id, customer_id

SELECT s.store_id, c.city, a.address, co.country
	FROM store s
    Join address a
    On (s.address_id = a.address_id)
    Join city c
    On (a.city_id = c.city_id)
    Join country co
    On (c.country_id = co.country_id)
	group by s.store_id;

# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category; # category_id, name
SELECT * FROM film_category; # film_id, category_id
SELECT * FROM inventory; # film_id, store_id, inventory_id
SELECT * FROM payment; # payment_id, rental_id, amount
SELECT * FROM rental; # inventory_id, rental_id,

SELECT c.name, sum(p.amount) as revenue
	FROM category c
    Join film_category fc
    On (c.category_id = fc.category_id)
    Join inventory i
    On (fc.film_id = i.film_id)
    Join rental r
    On (i.inventory_id = r.inventory_id)
    Join payment p
    On (r.rental_id = p.rental_id)
	group by c.name
ORDER BY revenue DESC;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you have not solved 7h, you can substitute another query to create a view.
SELECT c.name, sum(p.amount) as revenue
	FROM category c
    Join film_category fc
    On (c.category_id = fc.category_id)
    Join inventory i
    On (fc.film_id = i.film_id)
    Join rental r
    On (i.inventory_id = r.inventory_id)
    Join payment p
    On (r.rental_id = p.rental_id)
	group by c.name
ORDER BY revenue DESC
limit 5;

# 8b. How would you display the view that you created in 8a?
Create view top_sellers as 
SELECT c.name, sum(p.amount) as revenue
	FROM category c
    Join film_category fc
    On (c.category_id = fc.category_id)
    Join inventory i
    On (fc.film_id = i.film_id)
    Join rental r
    On (i.inventory_id = r.inventory_id)
    Join payment p
    On (r.rental_id = p.rental_id)
	group by c.name
ORDER BY revenue DESC
limit 5;
SELECT * FROM top_sellers;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
	# Attempt 1:
Delete from top_sellers
limit 5; # Not updatable...
	# Attempt 2:
Update top_sellers
Set top_sellers = 
(
SELECT c.name, sum(p.amount) as revenue
	FROM category c
    Join film_category fc
    On (c.category_id = fc.category_id)
    Join inventory i
    On (fc.film_id = i.film_id)
    Join rental r
    On (i.inventory_id = r.inventory_id)
    Join payment p
    On (r.rental_id = p.rental_id)
	group by c.name
ORDER BY revenue DESC
); # Didn't work either... :(
	# Reference: https://stackoverflow.com/questions/9080403/update-with-order-by-and-limit-not-working-in-mysql

	# OK, I'll do it the stupid way....:
Drop View top_sellers;
Create view top_sellers as 
SELECT c.name, sum(p.amount) as revenue
	FROM category c
    Join film_category fc
    On (c.category_id = fc.category_id)
    Join inventory i
    On (fc.film_id = i.film_id)
    Join rental r
    On (i.inventory_id = r.inventory_id)
    Join payment p
    On (r.rental_id = p.rental_id)
	group by c.name
ORDER BY revenue DESC;
SELECT * FROM top_sellers;