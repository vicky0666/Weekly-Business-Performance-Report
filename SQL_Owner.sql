create database Retail_sales;
use Retail_sales;

select * from superstore;
# ------------------------------------------------------------------------------------------------------
#   Data Cleaning 

select count(*) as no_of_records 
from superstore;

select `Row ID` , Count(*) as Duplicate_records
from superstore 
group by `Row ID` 
having Count(*)  > 1;

select `Order ID` , Count(*) as Duplicate_records
from superstore 
group by `Order ID` 
having Count(*)  > 1;

select * from 
superstore 
where `order Id` = 'CA-2011-115812';

Select
    sum(`Order ID` IS NULL) AS missing_order_id,
    sum(`Order Date` IS NULL) AS missing_order_date,
    sum(`Ship Date` IS NULL) AS missing_ship_date,
    sum(`Customer ID` IS NULL) AS missing_customer_id,
    sum(`Product ID` IS NULL) AS missing_product_id,
    sum(`Product Name` IS NULL) AS missing_product_name,
    sum(Sales IS NULL) AS missing_sales,
    sum(Quantity IS NULL) AS missing_quantity,
    sum(Profit IS NULL) AS missing_profit
FROM superstore;
     
    SELECT
    sum(TRIM(`Order ID`) = '') AS blank_order_id,
    sum(TRIM(`Customer ID`) = '') AS blank_customer_id,
    sum(TRIM(`Product ID`) = '') AS blank_product_id,
    sum(TRIM(`Product Name`) = '') AS blank_product_name,
    sum(TRIM(Category) = '') AS blank_category
FROM superstore; 
      
      SELECT
    `Order Date`,
    `Ship Date`
FROM superstore
LIMIT 5;

select 
  str_to_date(`Order Date` , '%Y-%M-%D') as Order_date 
  from superstore;
  
select 
  str_to_date(`Ship Date` , '%D-%M-%Y') as Ship_date
  from superstore;
  
SELECT
    `Order Date`,
    STR_TO_DATE(`Order Date`, '%Y-%m-%d') AS converted_order_date,
    `Ship Date`,
    STR_TO_DATE(`Ship Date`, '%d-%m-%Y') AS converted_ship_date
FROM superstore
LIMIT 15;

SELECT
    COUNT(*) AS total_records,
    SUM(
        STR_TO_DATE(`Order Date`, '%Y-%m-%d') IS NULL
    ) AS invalid_order_dates,
    SUM(
        STR_TO_DATE(`Ship Date`, '%d-%m-%Y') IS NULL
    ) AS invalid_ship_dates

FROM superstore;

#-----------------------------------------------
# Busines Performance 

CREATE TABLE superstore_clean AS
SELECT
    `Row ID`, `Order ID`,
    STR_TO_DATE(`Order Date`, '%Y-%m-%d') AS `Order Date`,
    STR_TO_DATE(`Ship Date`, '%d-%m-%Y') AS `Ship Date`,
    `Ship Mode`, `Customer ID`, `Customer Name`, Segment, Country, City, State, `Postal Code`, Region,`Product ID`,Category,
    `Sub-Category`,`Product Name`,Sales,Quantity,Discount,Profit
FROM superstore;

select * from superstore_clean;

SELECT COUNT(*) AS exact_duplicate_groups
FROM (
    SELECT
        `Row ID`,`Order ID`,`Order Date`,`Ship Date`,`Ship Mode`,`Customer ID`,`Customer Name`, Segment, Country, City, State,
        `Postal Code`,Region,`Product ID`,Category,`Sub-Category`,`Product Name`, Sales, Quantity, Discount, Profit
    FROM superstore_clean
    GROUP BY
        `Row ID`,`Order ID`,`Order Date`,`Ship Date`,`Ship Mode`,`Customer ID`,`Customer Name`,Segment,Country,City,State,
        `Postal Code`,Region,`Product ID`,Category,`Sub-Category`,`Product Name`,Sales,Quantity,Discount,Profit
    HAVING COUNT(*) > 1
) AS duplicates;


select `Order Date` , 
max(sales) as Highest_sales , min(sales) as lowest_sales ,
max(Discount) as Highest_discount , min(Discount) as lowest_discount ,
max(profit) as Highest_profit , min(profit) as lowest_discount
from superstore_clean
group by `Order Date` 
order by `Order Date` ;

# ------ Daily Sales -----
SELECT
    `Order Date`,
   count(distinct(`Order ID`)) as Total_orders ,
   round(sum(sales),2) as Daily_sales ,
   round(sum(profit),2) as Daily_profit,
   round(sum(Quantity),2) as Total_quantity
FROM superstore_clean
GROUP BY `Order Date`
ORDER BY `Order Date`;

# --- Weekly sales ---

select 
  year(`Order Date`) as Years ,
  week(`Order Date`) as Weekly ,
  count(distinct(`Order ID`)) as Total_orders ,
   round(sum(sales),2) as Weekly_sales ,
   round(sum(profit),2) as Weekly_profit,
   round(sum(Quantity),2) as Total_quantity
from superstore_clean
group by year(`Order Date`) , week(`Order Date`) 
order by year(`Order Date`) ,  week(`Order Date`) ;

# ---- Week Highest_sales ----

select Years , Weekly , Total_orders ,  Weekly_sales 
from (
select 
  year(`Order Date`) as Years ,
  week(`Order Date`) as Weekly ,
  count(distinct(`Order ID`)) as Total_orders ,
   round(sum(sales),2) as Weekly_sales 
from superstore_clean
group by year(`Order Date`) , week(`Order Date`) 
order by year(`Order Date`) ,  week(`Order Date`) 
) as Highest
order by Weekly_sales DESC
limit 1; 

# --- Weekly Lowest Sales ----
select Years , Weekly , Total_orders ,  Weekly_sales 
from (
select 
  year(`Order Date`) as Years ,
  week(`Order Date`) as Weekly ,
  count(distinct(`Order ID`)) as Total_orders ,
   round(sum(sales),2) as Weekly_sales 
from superstore_clean
group by year(`Order Date`) , week(`Order Date`) 
order by year(`Order Date`) ,  week(`Order Date`) 
) as Lowest
order by Weekly_sales 
limit 1; 

# --- Weekly Highest Profit ----
select Years , Weekly , Total_orders ,  Weekly_profit
from (
select 
  year(`Order Date`) as Years ,
  week(`Order Date`) as Weekly ,
  count(distinct(`Order ID`)) as Total_orders ,
   round(sum(profit),2) as Weekly_profit 
from superstore_clean
group by year(`Order Date`) , week(`Order Date`) 
order by year(`Order Date`) ,  week(`Order Date`) 
) as Highest
order by Weekly_profit DESC
limit 1;

# --- Weekly Lowest Profit ----
select Years , Weekly , Total_orders ,  Weekly_profit
from (
select 
  year(`Order Date`) as Years ,
  week(`Order Date`) as Weekly ,
  count(distinct(`Order ID`)) as Total_orders ,
   round(sum(profit),2) as Weekly_profit 
from superstore_clean
group by year(`Order Date`) , week(`Order Date`) 
order by year(`Order Date`) ,  week(`Order Date`) 
) as Highest
order by Weekly_profit 
limit 1;

# --- Weekly Sales Analysis ---- 
select 
  year(`Order Date`) as Years_num,
  week(`Order Date`,3) as Weekly_num ,
  count(distinct(`Order ID`)) as Total_orders ,
   round(sum(sales),2) as Weekly_sales ,
      round(sum(profit),2) as Weekly_profit 
from superstore_clean
group by year(`Order Date`) , week(`Order Date`,3) 
order by Years_num , Weekly_num;

# --- Week Over Week Comparison

with weekly_sales as (
select 
      year(`Order Date`) as Year_num ,
      week(`Order Date`,3) as Week_num ,
      round(sum(sales),2) as Weekly_sales ,
	  round(sum(profit),2) as Weekly_profit , 
      count(distinct(`Order ID`) ) as total_orders
      from superstore_clean
      group by  year(`Order Date`) ,
      week(`Order Date`,3)
      ) ,
	week_comp as ( 
         select Year_num , Week_num , Weekly_sales , 
               lag(Weekly_sales) over(order by Year_num , Week_num) as prev_week_sales
               from weekly_sales) 
               
select * , round(Weekly_sales - prev_week_sales,2) as Sales_diff , 
round((Weekly_sales - prev_week_sales) / prev_week_sales *100 ,2)as Sales_Growth
from week_comp;

# --- Same Week Last Month Comparison ----

 WITH weekly_sales AS (
    SELECT
        DATE_SUB(
            `Order Date`,
            INTERVAL WEEKDAY(`Order Date`) DAY
        ) AS week_start,
        round(SUM(Sales),2)AS weekly_sales,
        round(SUM(Profit),2) AS weekly_profit,
        COUNT(DISTINCT `Order ID`) AS total_orders
    FROM superstore_clean
    GROUP BY week_start
)

SELECT
    c.week_start,
    c.weekly_sales,
    p.weekly_sales AS last_month_sales,

    ROUND(c.weekly_sales - p.weekly_sales, 2)
        AS sales_difference,

    ROUND(
        (c.weekly_sales - p.weekly_sales)
        / NULLIF(p.weekly_sales, 0) * 100, 2
    ) AS monthly_change_percentage

FROM weekly_sales c
LEFT JOIN weekly_sales p
    ON p.week_start = DATE_SUB(
        DATE_SUB(c.week_start, INTERVAL 1 MONTH),
        INTERVAL WEEKDAY(
            DATE_SUB(c.week_start, INTERVAL 1 MONTH)
        ) DAY
    )
ORDER BY c.week_start;

# --- Daily Sales Report ----
select 
      Date(`Order Date`) as Sales_date ,
      Count(distinct(`Order ID`)) as total_order ,
      round(sum(sales),2) as total_sales ,
      round(sum(profit),2) as total_profit ,
      sum(Quantity) as total_quantity
      from superstore_clean
      group by Date(`Order Date`) ;
      
# --- Sales By Category --- 
select 
      category ,
      Count(distinct(`Order ID`)) as total_order ,
      round(sum(sales),2) as total_sales ,
      round(sum(profit),2) as total_profit ,
      sum(Quantity) as total_quantity
      from superstore_clean
      group by category;
      
# --- Top 10 Product by sales ---
select 
`Product ID` , `Product Name` ,
Count(distinct(`Order ID`)) as total_order ,
      round(sum(sales),2) as total_sales ,
      round(sum(profit),2) as total_profit ,
      sum(Quantity) as total_quantity
      from superstore_clean
      group by `Product ID` , `Product Name` 
      order by total_sales DESC
      limit 10;
      
# --- Sales By Region --- 
select 
     Region ,
     Count(distinct(`Order ID`)) as total_order ,
      round(sum(sales),2) as total_sales ,
      round(sum(profit),2) as total_profit ,
      sum(Quantity) as total_quantity
      from superstore_clean
      group by Region
      order by total_sales DESC;
      
# --- Profit and Loss Analysis ---
select 
     category ,
     round(sum(sales),2) as total_sales,
     round(sum(profit),2) as total_profit ,
     round(sum(profit)/sum(sales)*100,2) as profit_margin ,
     case 
          when sum(profit) > 0 then "Profitable"
          when sum(profit) < 0 then "Loss Making" 
          else "Unknow Sales"
          end as business_Flag 
	from superstore_clean
    group by category;
    
   # --- Detect Unusual Sales Days ----
   
   with daily_sales as (
       select date(`Order Date`) as sales_date ,
       round(sum(sales),2) as daily_revenue
       from superstore_clean
       group by sales_date) ,
  sales_comp as ( 
          select 
          sales_date , daily_revenue , lag(daily_revenue) over(order by sales_date) as Prev_day_sales
          from daily_sales) 

select * , 
          round((daily_revenue - Prev_day_sales) / Prev_day_sales * 100, 2) as sales_change_diff ,
          case 
              when daily_revenue <= Prev_day_sales * 0.7 then "Unusual Sales Drop"
              when daily_revenue >= Prev_day_sales * 1.5 then "Unusual sales Increase"
              else "Normal" 
              end as Sales_flag
          from sales_comp;

# ---- View for Business Report ----
CREATE OR REPLACE VIEW vw_weekly_business_report AS

WITH weekly_sales AS (
    SELECT
        DATE_SUB(
            `Order Date`,
            INTERVAL WEEKDAY(`Order Date`) DAY
        ) AS week_start,

        round(SUM(Sales),2) AS weekly_sales,
        round( SUM(Profit),2) AS weekly_profit,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        SUM(Quantity) AS total_quantity

    FROM superstore_clean
    GROUP BY week_start
)

SELECT
    c.week_start,
    c.weekly_sales,
    c.weekly_profit,
    c.total_orders,
    c.total_quantity,

    p.weekly_sales AS previous_week_sales,

    ROUND(
        c.weekly_sales - p.weekly_sales, 2
    ) AS sales_difference,

    ROUND(
        (c.weekly_sales - p.weekly_sales)
        /(p.weekly_sales) * 100, 2
    ) AS sales_change_percentage

FROM weekly_sales c

LEFT JOIN weekly_sales p
    ON p.week_start = DATE_SUB(
        c.week_start, INTERVAL 7 DAY
    );

SELECT *
FROM vw_weekly_business_report
ORDER BY week_start;

CREATE OR REPLACE VIEW vw_daily_sales_anomalies AS

WITH daily_sales AS (
    SELECT
        DATE(`Order Date`) AS sales_date,
        SUM(Sales) AS daily_sales
    FROM superstore_clean
    GROUP BY DATE(`Order Date`)
),

sales_comparison AS (
    SELECT
        sales_date,
        daily_sales,

        LAG(daily_sales) OVER (
            ORDER BY sales_date
        ) AS previous_day_sales

    FROM daily_sales
)

SELECT
    sales_date,
    daily_sales,
    previous_day_sales,

    ROUND(
        (daily_sales - previous_day_sales)
	   /(previous_day_sales) * 100,
        2
    ) AS sales_change_percentage,

    CASE
        WHEN daily_sales <= previous_day_sales * 0.70
            THEN 'Unusual Sales Drop'

        WHEN daily_sales >= previous_day_sales * 1.50
            THEN 'Unusual Sales Increase'

        ELSE 'Normal'
    END AS sales_flag

FROM sales_comparison;