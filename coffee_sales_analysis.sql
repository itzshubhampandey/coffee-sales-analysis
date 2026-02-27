create database coffee_db;
use coffee_db;

-- Coffee Shop Sales Analysis
select * from coffee;
describe coffee;

-- Convert transaction_date and transaction_time column to proper date and time format 

SET SQL_SAFE_UPDATES = 0;

UPDATE coffee
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y')
WHERE transaction_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';

UPDATE coffee
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s')
WHERE transaction_time REGEXP '^[0-9]{2}:[0-9]{2}:[0-9]{2}$';
SET SQL_SAFE_UPDATES = 1;

alter table coffee
modify column transaction_date date;
ALTER TABLE coffee
MODIFY transaction_time TIME;
SET SQL_SAFE_UPDATES = 0;
-- creating new columns
ALTER TABLE coffee
ADD COLUMN order_hour INT,
ADD COLUMN order_dayname VARCHAR(10),
ADD COLUMN order_month INT,
ADD COLUMN order_year INT;

UPDATE coffee
SET 
  order_hour = HOUR(transaction_time),
  order_dayname = DAYNAME(transaction_date),
  order_month = MONTH(transaction_date),
  order_year = YEAR(transaction_date)
WHERE transaction_date IS NOT NULL;

-- Total Revenue

select year(transaction_date) as year  ,round(sum(money)) as total_revenue from coffee
group by year(transaction_date)
order by year(transaction_date);

-- TOTAL SALES MOM difference & growth

WITH monthly_sales AS (
    SELECT 
        MONTH(transaction_date) AS month,
        SUM(money) AS total_sales
    FROM coffee
    GROUP BY MONTH(transaction_date)
)
SELECT
    month,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(total_sales - LAG(total_sales) OVER (ORDER BY month), 2) AS mom_difference,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY month)) 
        / LAG(total_sales) OVER (ORDER BY month) * 100, 
        2
    ) AS mom_growth_percentage
FROM monthly_sales
ORDER BY month;

-- TOTAL ORDERS

select count(transaction_date) as Total_Orders from coffee;

-- TOTAL Order MOM DIFFERENCE AND MOM GROWTH 

SELECT 
    MONTH(transaction_date) AS month,
    COUNT(transaction_date) AS total_orders,
    ROUND(
        (COUNT(transaction_date) - LAG(COUNT(transaction_date), 1) 
            OVER (ORDER BY MONTH(transaction_date))) 
        / LAG(COUNT(transaction_date), 1) 
            OVER (ORDER BY MONTH(transaction_date)) * 100,
        2
    ) AS mom_increase_percentage
FROM coffee
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

 -- Most used type of payment
 
 select cash_type,count(cash_type) as payment_type_count from coffee
 group by cash_type
 order by count(cash_type) desc ;
 
 -- % of Revenue by Category
 
 SELECT 
  coffee_name,
  ROUND(SUM(money),2) AS revenue,
  ROUND(SUM(money) / (SELECT SUM(money) FROM coffee) * 100, 2) AS revenue_pct
FROM coffee
GROUP BY coffee_name
ORDER BY revenue DESC;

-- Top 5 Products by Revenue

SELECT coffee_name, ROUND(SUM(money)) AS revenue
FROM coffee
GROUP BY coffee_name
ORDER BY revenue DESC
LIMIT 5;

-- Bottom 5 Products by Revenue

SELECT coffee_name, ROUND(SUM(money)) AS revenue
FROM coffee
GROUP BY coffee_name
ORDER BY revenue asc
LIMIT 5;

-- Top 5 by Quantity

SELECT coffee_name, count(transaction_date) AS qty
FROM coffee
GROUP BY coffee_name
ORDER BY qty DESC
LIMIT 5;

 -- Hourly Trend
SELECT order_hour, count(transaction_date) AS items_sold
FROM coffee
GROUP BY order_hour
ORDER BY order_hour;

-- Monthly Revenue
SELECT order_year, order_month, ROUND(SUM(money)) AS revenue
FROM coffee
GROUP BY order_year, order_month
ORDER BY order_year, order_month;
 
 
 
 
 
 
 


