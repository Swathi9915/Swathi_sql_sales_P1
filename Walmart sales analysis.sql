create table if not exists sales_walmart
like walmartsalesdata;

insert sales_walmart
select * from 
walmartsalesdata;

select * from sales_walmart;

CREATE TABLE walmart_sales_new (
  invoice_id varchar(30) not null ,
  Branch varchar(5) not null,
  City varchar(30) not null,
  Customer_type varchar(30) not null,
  Gender varchar(10) not null,
  Product_line varchar(100) not null,
  Unit_price decimal (10,2) not NULL,
  Quantity int not NULL,
  VAT float(6)  not NULL,
  Total decimal (10, 2) not NULL,
  `Date` datetime not null,
  `Time` time not null,
  Payment_method varchar(15) not null,
  cogs decimal(10, 2) not NULL,
  gross_margin_pct float (11) not  NULL,
  gross_income decimal (12, 4) not NULL,
  Rating float(2) not NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from walmart_sales_new;

insert walmart_sales_new
select * from sales_walmart;
-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------Feature Engineering------------------------------------------------------------------
-- time_0f_day
select 
   time,
   (
   case 
   when time between "00:00:00" and "12:00:00" then "Morning"
   when time between "12:01:00" and "16:00:00" then  "Afternoon"
   else "Evening"
   end
   ) as time_of_day
from walmart_sales_new;

alter table walmart_sales_new add column time_of_day varchar(20);

update  walmart_sales_new
set time_of_day =
(
   case 
      when time between "00:00:00" and "12:00:00" then "Morning"
      when time between "12:01:00" and "16:00:00" then  "Afternoon"
      else "Evening"
   end
   );
   
    -- day_name
    select 
    date,
    dayname(date)
    from walmart_sales_new;
    
    alter table walmart_sales_new add column day_name varchar(20);
   
   update walmart_sales_new
   set day_name= dayname(date);
  
  -- month_name
  select 
  date,
  monthname(date)
  from walmart_sales_new;
   
   alter table walmart_sales_new add column month_name varchar(20);
   
   update walmart_sales_new
   set month_name= monthname(date);
   -- ----------------------------------------------------------------------------------------------------------------------------------------
   
   
   -- ----------------------------------------------------------------------------------------------------------------------------------------
   -- -----------------------------------------------------Exploaratory Data Analysis---------------------------------------------------------
   
   -- --------------------------------------Generic---------------------------------------------------
   
   -- How many unique cities does the data have?
   
   select
   distinct(city)
   from walmart_sales_new;
   
   -- In which city is each branch?
   
   select
    distinct(city) , branch
   from walmart_sales_new
   order by 2;
   -- ----------------------------------------------------------------------------------------------------------------------------------------
   -- -------------------------------------Product------------------------------------------------
   
   -- How many unique product lines does the data have?
   select 
   count(distinct product_line)
   from walmart_sales_new;
   
   -- What is the most common payment method?
   
   select
   payment_method,
   count(payment_method) as cnt
   from walmart_sales_new
   group by payment_method
   order by cnt desc ;
   
   -- What is the most selling product line?
   
   select 
   Product_line,
   sum(quantity) as cnt
   from walmart_sales_new
   group by Product_line
   order by cnt desc;
   
   -- What is the total revenue by month?
   select
   month_name,
   sum(total) as Total_revenue
   from walmart_sales_new
   group by 1
   order by total_revenue desc;
   
   -- What month had the largest COGS?
   select
   month_name,
   sum(cogs) as total_cogs
   from walmart_sales_new
   group by 1
   order by 2 desc;
   
   -- What product line had the largest revenue?
   select
   product_line,
   sum(total) as Total_revenue
   from walmart_sales_new
   group by 1
   order by total_revenue desc;

-- What is the city with the largest revenue?
select
branch, 
city,
sum(total) as total_revenue
from walmart_sales_new
group by 1,2
order by 3 desc;

-- What product line had the largest VAT?
select 
product_line,
avg(VAT) as avg_tax
from walmart_sales_new
group by 1
order by 2 desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select 
avg(quantity) as avg_qty
from walmart_sales_new;

SELECT product_line, AVG(quantity) avg_qnty,
	CASE
	WHEN AVG(quantity) > (SELECT AVG(quantity) FROM walmart_sales_new) THEN 'Good'
    ELSE 'Bad'
    END AS remark
FROM walmart_sales_new
GROUP BY product_line;

-- Which branch sold more products than average product sold?
select 
branch,
sum(quantity) as qty
from walmart_sales_new
group by 1
having sum(quantity) > (select avg(quantity) from walmart_sales_new);

-- What is the most common product line by gender?
select 
gender,
product_line,
count(product_line) as total_cnt
from walmart_sales_new
group by 1,2
order by 3 desc;

-- What is the average rating of each product line?
select 
  product_line,
  round(avg(rating),2) as avg_rating
from walmart_sales_new
group by 1
order by 2 desc;
-- ------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------Sales--------------------------------------------------------
-- Number of sales made in each time of the day per weekday

SELECT 
    time_of_day,
    COUNT(*) AS total_sales
FROM walmart_sales_new
WHERE day_name IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?

select
customer_type,
sum(total) as total_revenue
FROM walmart_sales_new
group by 1
order by 2 desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select 
city,
round(avg(VAT),2) as avg_tax
from walmart_sales_new
group by 1
order by 2 desc;

-- Which customer type pays the most in VAT?

select 
customer_type,
round(avg(VAT),2) as VAT
from walmart_sales_new
group by 1
order by 2 desc;

-- --------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------Customer-------------------------------------------------------------------
-- How many unique customer types does the data have?

select
distinct customer_type
from walmart_sales_new;

-- How many unique payment methods does the data have?
select
distinct payment_method
from walmart_sales_new;

-- What is the most common customer type?
select
customer_type,
count(*) as cnt
from walmart_sales_new
group by 1
order by 2 desc;

-- Which customer type buys the most?
select 
customer_type,
count(*) as total_sales
from walmart_sales_new
group by 1
order by 2 desc;

-- What is the gender of most of the customers?
select 
gender,
count(*) as total_sales
from walmart_sales_new
group by 1
order by 2 desc;

-- What is the gender distribution per branch?
select 
gender,
count(*) as total_sales
from walmart_sales_new
where branch = "a"
group by 1
order by 2 desc;

-- Which time of the day do customers give most ratings?
select 
time_of_day,
avg(rating) as avg_ratings
from walmart_sales_new
group by 1
order by 2 desc;

-- Which time of the day do customers give most ratings per branch?
select 
distinct branch
from walmart_sales_new
order by 1;
 
select 
time_of_day,
avg(rating) as avg_ratings
from walmart_sales_new
where branch = "A"
group by 1
order by 2 desc;

-- Which day for the week has the best avg ratings?
select 
day_name,
avg(rating) as avg_rating
from walmart_sales_new
group by 1
order by 2 desc;

-- Which day of the week has the best average ratings per branch?
select 
distinct branch
from walmart_sales_new
order by 1;

select 
day_name,
avg(rating) as avg_rating
from walmart_sales_new
where branch = "c"
group by 1
order by 2 desc;

















