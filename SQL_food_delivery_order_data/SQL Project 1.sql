#find top 3 outlets by cuisine type without using limit and top function 
with cte as(select cuisine, restaurant_id, count(*) as no_of_orders
from orders 
group by 1,2)
select * from(select *, 
row_number() OVER(partition by cuisine order by no_of_orders desc) as rn
from cte) a 
where rn<4;

#Find daily new customer from launch date (everyday how many new customers are we acquiring)
with cte as(select customer_code, cast(min(placed_at) as date) as first_order_date
from orders
group by 1)

select first_order_date as datee,count(*) as no_of_new_cx
from cte 
group by 1;

#Count of all users who were acquired in Jan 2025 and only placed one order in Jan and did not place any other
select customer_code, count(*) as no_of_orders 
from orders
where month(placed_at)=1 and year(placed_at)=2025
and customer_code not in(select distinct customer_code
from orders
where not (month(placed_at)=1 and year(placed_at)=2025))
group by 1
having count(*)=1;

#List of all customers with no order in last 7 days but were acquired one month ago with their first order on promo
with cte as(select customer_code, min(placed_at) as first_order_date, 
max(placed_at) as latest_order_date
from orders
group by customer_code)
select cte.*, orders.promo_code_name as first_order_promo from cte
join orders on cte.customer_code=orders.customer_code and cte.first_order_date=orders.placed_at
where latest_order_date < DATE_SUB(CURDATE(), INTERVAL 7 DAY)
and first_order_date< date_sub(curdate(), interval 1 month) and orders.promo_code_name is not null;

#Growth team is planning to create a trigger that will target customers after their every third order
#with a personalized communication and they have asked you to create query for this
with cte as(select *, 
row_number() over(partition by customer_code order by placed_at) as order_number 
from orders)
select * from cte
where order_number%3=0;
#Assuming company sends alert on a daily basis we can write cast(placed_at) as date = cast(curdate) as date.
#This will trigger alert only for those customers who placed 3rd order today so that we do not send alert again again to same cx


#list of customers who placed more than 1 order and all their orders on a promo only 
select customer_code
from orders
group by 1
having count(order_id)>1 and count(order_id)=count(promo_code_name);

#what percent of customers were organically aquired in Jan 2025(Placed their first order without promo code)
with cte as(select customer_code, placed_at,promo_code_name
from orders
where promo_code_name is null
)
select distinct customer_code
from cte 
group by 1
having(month(min(placed_at)))=1

