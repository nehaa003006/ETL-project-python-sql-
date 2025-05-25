CREATE database master;
create table df_orders(
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state  varchar(20),
postal_code  varchar(20),
region  varchar(20),
category  varchar(20),
sub_category  varchar(20),
product_id  varchar(50),
quantity int,
discount decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2))
select * from df_orders;

use master;
select * from df_orders;
-- find the top highest revenue generating product
select  product_id,round(sum(sales_price*quantity),2) as total_sales from df_orders
group by product_id 
order by total_sales desc
limit 10;

-- find the top 5 highest selling product in each region
with cte as (select region,product_id,sum(sales_price*quantity) as s from df_orders
group by region,product_id),
cte_2 as (select *, rank() over (partition by region order by s desc)  as rn from cte)

select * from cte_2 where rn<6

-- find month over month growth comparison for 2022 and 2023 sales
with cte as (select year(order_date) as order_year, month(order_date) as order_month,sum(sales_price*quantity)as sales from df_orders
group by year(order_date), month(order_date))

select order_month, sum(case when  order_year=2022 then sales else 0 end ) as sales_2022,
sum(case when order_year=2023 then sales else 0  end )as sales_2023 from cte
group by order_month
order by order_month 

-- for each category which month has the highest sales
with cte as
(select category, date_format(order_date,'%y %m') as order_year_month,round(sum(sales_price*quantity),2) as sales from df_orders
group by category, date_format(order_date,'%y %m'))

select * from 
(select * , row_number() over (partition by category order by sales desc) as rn from cte) abc 
where rn=1
 
 -- which sub category had highest growth by profit in 2023 compare to 2022
 with cte as (select  sub_category,year(order_date) as order_year,sum(sales_price*quantity)as sales from df_orders
group by  sub_category,year(order_date)),cte2 as (select sub_category, sum(case when  order_year=2022 then sales else 0 end ) as sales_2022,
sum(case when order_year=2023 then sales else 0  end )as sales_2023 from cte
group by sub_category)


select * ,(sales_2023-sales_2022)*100/sales_2022  as growth from cte2 order by (sales_2023-sales_2022)*100/sales_2022  desc limit 1





