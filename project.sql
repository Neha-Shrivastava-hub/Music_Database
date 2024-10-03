Q.1: WhO is senior most employee based on job title?

select * from employee
order by levels desc

SELECT TOP 1 *
FROM employee
ORDER BY levels DESC;

Q.2: Which countries have the most Invoices?

select * from invoice
select count(*) as c,billing_country
from invoice
group by billing_country
order by c desc

Q.3: what are top 3 value of total invoice?

select total from invoice 
order by total desc

SELECT TOP 3 *
FROM invoice
ORDER BY total DESC;

Q.4: Which city has the best customer? we would like to throw a promotional music festival in the city we made most money. 
write a query returns one city that has the highest sum of invoice totals.
Return the both the city name and sum of all invoice totals?

select sum(total) as total_invoice, billing_city from invoice
group by billing_city
order by total_invoice desc

Q.5: Who is best customer? The customer who has spent the most money will be declared the best customer. 
write a query that returns the person who has spent the most money?

select Top 1 sum(invoice.total)as total,customer.customer_id ,customer.first_name ,customer.last_name from invoice
join customer on invoice.customer_id=customer.customer_id
group by customer.customer_id,customer.first_name ,customer.last_name 
order by total desc

Q.6: Write query to return the email, first name, last name,and genre of all rock music listener.
Returns your ordered alphabetically by email starting with A.

select distinct email,first_name,last_name from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id= invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name LIKE 'Rock'
)
order by email;

Q.7:Lets the artists who have written the most rock music in our dataset.
Write a query that returns the artist name and total track count of the top 10 rock bands

SELECT TOP 10 artist.artist_id, artist.name, COUNT(track.track_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC;

Q.8:Return all the track names that have a song length longer than the average song length. 
Reaturn the name and millisecond for each track.
order by the song length with the longest song listed first.

SELECT name, milliseconds 
FROM track
WHERE milliseconds>(
    SELECT AVG(milliseconds) AS avg_track_length 
    FROM track)
ORDER BY milliseconds DESC;

Q.9:Find how much amount spent by each customer on artist? Write a query customer name, artist name and total spent.

WITH best_selling_artist AS (
SELECT TOP 1
artist.artist_id AS artist_id,
artist.name AS artist_name,
SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY artist.artist_id,artist.name
ORDER BY total_sales DESC
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id  
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name
ORDER BY
    amount_spent DESC;

Q.10:We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre
with the highest amount of purchases.

WITH popular_genre AS (
SELECT SUM(CAST(invoice_line.quantity AS INT)) AS purchases,customer.country,genre.name AS genre_name,genre.genre_id,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY SUM(CAST(invoice_line.quantity AS INT)) DESC) AS RowNo
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY customer.country, genre.name, genre.genre_id
)
SELECT * FROM popular_genre
WHERE RowNo = 1
ORDER BY purchases DESC;

Q.11:Write a query that determines the customer that has spent the most on music for each country.
Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH Customter_with_country AS (
SELECT customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country,
SUM(invoice.total) AS total_spending,
ROW_NUMBER() OVER (PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS RowNo
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
)
SELECT * FROM Customter_with_country
WHERE RowNo = 1
ORDER BY billing_country ASC, total_spending DESC;
