--Q1 wo is the sr. most employee based on job title?
select * from employee
order by levels desc
limit 1;

--Q2 which country have most invoices
select count(*), billing_country

from invoice
group by billing_country
order by count(*) desc;

--Q3 wht are top 3 values of toal invoice?
select total
from invoice
order by total desc
limit 3;

/*
Q4, Which city has the best customers? We would like to throw a promotional
Music Festival in the city we made the most money. Write a query that returns
one city that has the highest sum of invoice totals. Return both the city name 
& sum of all invoice totals
*/

select sum(total) as invoice_total, billing_city

from invoice
group by billing_city
order by invoice_total desc;

/*
Q5 Who is the best customer? The customer who has spent the most
money will be declared the best customer. Write a query that returns
the person who has spent the most money
*/

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total
from customer c
join invoice i on
c.customer_id=i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total desc
limit 1;

---------------------------Question Set 2 – Moderate-----------------
/*
1. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A
*/

select distinct c.email, c.first_name, c.last_name
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
where il.track_id in
(select track_id from track t
join genre g on t.genre_id= g.genre_id
where g.name='Rock')
order by c.email;

/*
Q5 Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the Artist name and total track count of the top 10 rock bands
*/

select at.artist_id,at.name, count(at.artist_id) as number_ofsongs
from track t
join album a on a.album_id=t.album_id
join artist at on at.artist_id=a.artist_id
join genre g on g.genre_id=t.genre_id
where g.name like 'Rock'
group by at.artist_id
order by number_ofsongs desc
limit 10;

/*Q3
Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the longest
songs listed first
*/

select name, milliseconds
from track
where milliseconds >
(select avg(milliseconds) as Avg_length from track
)
order by milliseconds desc;
