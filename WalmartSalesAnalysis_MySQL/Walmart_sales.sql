------Data Wrangling-------
--------This is the first step where inspection of data is done to make sure NULL values and missing values are detected
--- and data replacement methods are used to replace, missing or NULL values.
--1.	Build a database
--2.	Create table and insert the data.
--3.	Select columns with null values in them. There are no null values in our database as in creating the tables, 
--we set NOT NULL for each field, hence null values are filtered out.

  -- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;
use walmartsales;


-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);




SELECT * FROM walmartsales.sales;

-- -------------------------------------------------------------------------------------------------------
-- ----------------------------------2.	Feature Engineering---------------------------------------------
-- 1. Add a new column named time_of_day 
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

-- now lets create one new colum as time_of_day and will insert the data
alter table sales add column time_of_day varchar(20);
select * from sales;

update sales
set time_of_day =(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- --2. Add a new column named day_name

select date, dayname(date) as day_name
from sales;

Alter table sales add column day_name varchar(10);
update sales
set day_name= dayname(date);

-- -----------------------3.	Add a new column named month_name 
select date,
monthname(date) as month_name
from sales;

Alter table sales add column month_name varchar(12);

update sales
set month_name= monthname(date);

-- ------------------------------------------EDA------------------------------
-- --------------- Generic Questions ---------------------
-- 1.	How many unique cities does the data have?
select distinct(city) as city
from sales;

-- 2.	In which city is each branch?
select distinct city,
branch
from sales;

-- -------------------------- Products ------------------------------
-- 1.	How many unique product lines does the data have?
select distinct(product_line)
from sales;

-- 2.	What is the most common payment method?
select payment, count(payment) as count
from sales
group by payment;

-- 3.	What is the most selling product line?
select
product_line, count(product_line) as cnt
from sales
group by product_line
order by cnt desc;

-- 4.	What is the total revenue by month?
select 
month_name,
sum(cogs) as Sales
from sales
group by month_name
order by sales desc;

-- 5.	What month had the largest COGS?
select
month_name,
sum(cogs) as cogs
from sales
group by month_name;

-- 6.	What product line had the largest revenue?
select
product_line,
sum(cogs) as Revenue
from sales
group by product_line
order by revenue desc;

-- 7.	What is the city with the largest revenue?
select
city,branch, sum(cogs) as revenue
from sales
group by city, branch
order by revenue desc;

-- 8.	What product line had the largest VAT?
select product_line,
max(tax_pct) as Tax
from sales
group by product_line
order by tax desc;

-- 9.	Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales




-- 10.	Which branch sold more products than average product sold?
select
branch,
sum(quantity) as qty
from sales
group by branch
having qty > (select avg(quantity) from sales);

-- 11.	What is the most common product line by gender?
select 
gender,
product_line,
count(gender) as gen
from sales
group by gender, product_line
order by gen desc;

-- 12.	What is the average rating of each product line?
select
round(avg(rating), 2) as Rat,
product_line
from sales
group by product_line
order by rat desc;


-- ----------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------Sales -------------------------------------------

-- 1.	Number of sales made in each time of the day per weekday
select
time_of_day, day_name,
count(*) as cogs
from sales
where day_name='Sunday'
group by time_of_day, day_name
order by cogs desc;

-- 2.	Which of the customer types brings the most revenue?
select 
customer_type,
sum(cogs) as total
from sales
group by customer_type
order by total desc;

-- 3.	Which city has the largest tax percent/ VAT (Value Added Tax)?
select
city,
sum(tax_pct) as value
from sales
group by city
order by value desc;

-- 4.	Which customer type pays the most in VAT?
select
customer_type,
avg(tax_pct) as avgtax
from sales
group by customer_type
order by avgtax desc;

-- -------------------------------------------------------------------------------------------------------------
-- ---------------------------------------Customer ---------------------------------------------
-- 1.	How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- ---------------