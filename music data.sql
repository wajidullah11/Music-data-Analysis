--this is a music project 

-- this is a basic analysis

--Q1: who is the most senior employee of the Organization?
select * from employee
order by levels desc
limit 1;
--Madan-Mohan, Senior General Manager, L7, 1961-01-26



--Q2: which country have the most invoices?
select count (*) as country, billing_country
from invoice
group by billing_country
order by country desc;
--USA has the most invoices


--Q3: what are the top three values of invoices?
select total from invoice
order by total desc
limit 3;
--23, 20, 20 


--Q4: which city has the best customers with higher invoices of sum?
select sum(total) as invoices_total, billing_city
from invoice
group by billing_city
order by invoices_total desc;
--prague has the most invoices


--Q5: which customer spent the most ?
select customer.customer_id, customer.first_name, customer.last_name, customer.country, customer.city, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id 
order by total desc
limit 1;
--R Madhsv from "Czech Republic" and the city name is  "Prague" spent the most on music


--Question Set 2 - Moderate

/*Q1: Write query to return the email, first name, last name, & Genre 
    of all Rock Music listeners. Return your list ordered alphabetically 
    by email starting with A.*/
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name ILIKE 'Rock'
  AND c.email ILIKE 'a%'
ORDER BY c.email ASC;


/*Q2: Let's invite the artists who have written the most rock music in our dataset. 
    Write a query that returns the Artist name and total track count of the 
    top 10 rock bands.*/
SELECT artist.artist_id, artist.name, count(artist.artist_id) AS total_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
group by artist.artist_id
ORDER BY total_songs DESC
LIMIT 10;
--"Led Zeppelin" has the most songs



/*Q3: Return all the track names that have a song length longer than the 
    average song length. Return the Name and Milliseconds of each track. 
    Order by the song length with the longest first.*/
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;



--Advance Questions set


/*Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent.*/
SELECT c.First_Name || ' ' || c.Last_Name AS Customer_Name,ar.Name AS Artist_Name,
SUM(il.Unit_Price * il.Quantity) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.customer_id = i.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Album al ON t.Album_Id = al.Album_Id
JOIN Artist ar ON al.Artist_Id = ar.Artist_Id
GROUP BY Customer_Name, Artist_Name
ORDER BY Customer_Name, TotalSpent DESC;


/*Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared, return all Genres.*/
WITH popular_genre AS 
(SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC)SELECT * FROM popular_genre WHERE RowNo <= 1


/*Q3:Write a query that determines the customer that has spent the most on music
for each country write a query that return the country along with the top customer
and how much they spent for countries where the top amount spent is shared provide 
all customer who spend this amount*/
WITH customer_spending AS (
SELECT c.customer_id,c.first_name || ' ' || c.last_name AS customer_name,c.country,
SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name, c.country),max_spending_per_country AS (
SELECT country,
MAX(total_spent) AS max_spent
FROM customer_spending
GROUP BY country)
SELECT cs.country, cs.customer_name, cs.total_spent
FROM customer_spending cs
JOIN max_spending_per_country mspc
ON cs.country = mspc.country AND cs.total_spent = mspc.max_spent
ORDER BY total_spent desc;
--a man form "Czech Republic" whose name is  "R Madhav" is spent the most money of 144.54 on music 

