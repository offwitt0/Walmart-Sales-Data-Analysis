IF NOT EXISTS (
    SELECT name 
    FROM sys.databases 
    WHERE name = N'SalesDataWalmart'
)
-------------------------------------
CREATE DATABASE SalesDataWalmart;
-------------------------------------
USE SalesDataWalmart;
-------------------------------------
CREATE TABLE SalesData (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT NOT NULL,
    total DECIMAL(12, 2) NOT NULL,
	date DATETIME NOT NULL,
	time TIME NOT NULL,
	payment_method VARCHAR(15) NOT NULL,
	cogs DECIMAL(10, 2) NOT NULL,
	gross_margin_pct FLOAT,
	gross_income DECIMAL(12, 4) NOT NULL,
	rating FLOAT 
);
-------------------------------------
select  * from WalmartSalesData

--------Feature Engineering----------
SELECT 
    CASE 
        WHEN Time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN Time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM
    walmartSalesData;
--
ALTER TABLE WalmartSalesData
ADD time_of_day VARCHAR(20);
--
update walmartSalesData
set time_of_day = ( 
	CASE 
        WHEN Time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN Time BETWEEN '12:00:00' AND '15:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END
	);
--
SELECT  
    DATENAME(dw, date)
FROM 
    WalmartSalesData;
--
ALTER TABLE WalmartSalesData
add day_name varchar(10);
--
update WalmartSalesData
set day_name = DATENAME(dw, date)
--
SELECT
    DATENAME(month, date)
FROM 
    WalmartSalesData;
--
ALTER TABLE WalmartSalesData
add month_name varchar(10);
--
update WalmartSalesData
set month_name = DATENAME(month, date)

----------------EDA------------------
-- Generic Question
-------------------------------------
-- Q1 How many unique cities does the data have?
select distinct 
	city
from
	WalmartSalesData
-- Q2 In which city is each branch?
select distinct 
	city, Branch
from
	WalmartSalesData
-------------------------------------
-- Product
-------------------------------------
-- Q1 How many unique product lines does the data have?
select distinct 
	Product_line
from
	WalmartSalesData
-- Q2 What is the most common payment method?
select 
	Payment, count(payment) as cnt
from
	WalmartSalesData
group by
	payment
order by
	cnt desc;
-- Q3 What is the most selling product line?
select 
	Product_line, count(Product_line) as cnt
from
	WalmartSalesData
group by
	Product_line
order by
	cnt desc;
-- Q4 What is the total revenue by month?
select 
	month_name as month, sum(Total) as total_rev
from
	WalmartSalesData
group by
	month_name
order by
	total_rev desc;
-- Q5 What month had the largest COGS?
select 
	month_name as month, sum(cogs) as cogs
from
	WalmartSalesData
group by
	month_name
order by
	cogs desc;
-- Q6 What product line had the largest revenue?
select 
	Product_line, sum(Total) as total_rev
from
	WalmartSalesData
group by
	Product_line
order by
	total_rev desc;
-- Q7 What is the city with the largest revenue?
select 
	city, branch, sum(Total) as total_rev
from
	WalmartSalesData
group by
	city, branch
order by
	total_rev desc;
-- Q8 What product line had the largest VAT?
select 
	Product_line, avg(tax_5) as avg_tax
from
	WalmartSalesData
group by
	Product_line
order by
	avg_tax desc;
-- Q9 Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales?
WITH AverageSales AS (
    SELECT
        product_line,
        AVG(Total) AS avg_sales
    FROM
        WalmartSalesData
    GROUP BY
        product_line
),

SalesEvaluation AS (
    SELECT
        s.product_line,
        s.Total,
        CASE
            WHEN s.Total > a.avg_sales THEN 'Good'
            ELSE 'Bad'
        END AS sales_evaluation
    FROM
        WalmartSalesData s
    JOIN
        AverageSales a ON s.product_line = a.product_line
)
SELECT
    product_line,
    Total,
    sales_evaluation
FROM
    SalesEvaluation;
-- Q10 Which branch sold more products than average product sold?
select 
	Branch, sum(Quantity) as aty
from
	WalmartSalesData
group by
	Branch
having
	sum(Quantity) > (select avg(Quantity) from WalmartSalesData)
order by
	aty desc;
-- Q11 What is the most common product line by gender?
select 
	gender, product_line, count(Gender) as gen_count
from
	WalmartSalesData
group by
	gender, product_line
order by
	gen_count desc;
-- Q12 What is the average rating of each product line?
select 
	round(avg(Rating), 2) as avg_rat, product_line
from
	WalmartSalesData
group by
	product_line
order by
	avg_rat desc;
-------------------------------------
-- Sales
-------------------------------------
-- Q1 Number of sales made in each time of the day per weekday?
select 
	time_of_day, count(*) as total_sales
from
	WalmartSalesData
group by
	time_of_day
order by
	total_sales desc;
-- Q2 Which of the customer types brings the most revenue?
select 
	Customer_type, sum(Total) as total_rev
from
	WalmartSalesData
group by
	Customer_type
order by
	total_rev desc;
-- Q3 Which city has the largest tax percent/ VAT (Value Added Tax)?
select 
	City, round(avg(Tax_5), 2) as vat
from
	WalmartSalesData
group by
	City
order by
	vat desc;
-- Q4 Which customer type pays the most in VAT?
select 
	Customer_type, round(avg(Tax_5), 2) as vat
from
	WalmartSalesData
group by
	Customer_type
order by
	vat desc;
-------------------------------------
-- Cus tomer
-------------------------------------
-- Q1 How many unique customer types does the data have?
select distinct
	customer_type
from
	WalmartSalesData;
-- Q2 How many unique payment methods does the data have?
select distinct
	Payment
from
	WalmartSalesData;
-- Q3 What is the most common customer type?
SELECT
	customer_type, count(*) as count
FROM 
	WalmartSalesData
GROUP BY 
	customer_type
ORDER BY 
	count DESC;
-- Q4 Which customer type buys the most?
SELECT
	customer_type, COUNT(*)
FROM 
	WalmartSalesData
GROUP BY 
	customer_type;
-- Q5 What is the gender of most of the customers?
SELECT
	gender, COUNT(*)
FROM 
	WalmartSalesData
GROUP BY 
	gender;
-- Q6 What is the gender distribution per branch?
SELECT
	branch, gender, COUNT(*)
FROM 
	WalmartSalesData
GROUP BY 
	branch, gender;
-- Q7 Which time of the day do customers give most ratings?
SELECT
	time_of_day, round(avg(Rating), 2) as avg_rat
FROM 
	WalmartSalesData
GROUP BY 
	time_of_day
order by avg_rat;
-- Q8 Which time of the day do customers give most ratings per branch?
SELECT
	Branch, time_of_day, round(avg(Rating), 2) as avg_rat
FROM 
	WalmartSalesData
GROUP BY 
	Branch, time_of_day
order by avg_rat;
-- Q9 Which day fo the week has the best avg ratings?
SELECT
	day_name, round(avg(Rating), 2) as avg_rat
FROM 
	WalmartSalesData
GROUP BY 
	day_name
order by avg_rat;
-- Q10 Which day of the week has the best average ratings per branch?
SELECT
	Branch, day_name, round(avg(Rating), 2) as avg_rat
FROM 
	WalmartSalesData
GROUP BY 
	Branch, day_name
order by avg_rat;