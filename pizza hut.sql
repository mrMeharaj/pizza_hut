create database pizza_hut;
use pizza_hut;

select * from pizzas;

select * from pizza_types;

create table orders (
order_id int not null primary key ,
order_date date not null ,
order_time time not null );

select * from orders;

create table orders_details (
orders_details_id int not null primary key,
order_id int not null ,
pizza_id text not null ,
quantity int not null );

select * from orders_details;

-- 1. Retrieve the total number of orders placed.
select sum(order_id) as total_orders from  orders;

-- 2.Calculate the total revenue generated from pizza sales.

select sum(orders_details.quantity * pizzas.price) as total_revenue from orders_details
join  pizzas
on orders_details.pizza_id = pizzas.pizza_id;

-- 3.Identify the highest-priced pizza

select pizza_types.name,pizzas.Price from pizzas
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc 
limit 1;

-- 4.Identify the most common pizza size ordered.

select size ,count(*) from  pizzas
group by size
limit 1;

-- 5.List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name,sum(orders_details.quantity) from pizza_types
join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by sum(orders_details.quantity) desc 
limit 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
 
select pizza_types.category,sum(orders_details.quantity) from pizza_types
join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by sum(orders_details.quantity) desc 
limit 5;

-- 7.Determine the distribution of orders by hour of the day

select hour(order_time),count(order_id)  from orders
group by hour(order_time);

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

select category ,count(name) from pizza_types
group by category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(quantity) from
(select orders.order_date,sum(orders_details.quantity) as quantity from orders
join orders_details
on orders.order_id = orders_details.order_id
group by orders.order_date) as order_quantity;

-- 10. Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,sum(orders_details.quantity * pizzas.price) as revenue from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by sum(orders_details.quantity * pizzas.price) desc 
limit 3;

-- 11.Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,(sum(orders_details.quantity * pizzas.price) / (select sum(orders_details.quantity * pizzas.price) as total_revenue from orders_details
join  pizzas
on orders_details.pizza_id = pizzas.pizza_id) ) * 100 as revenue from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on  pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.category
order by revenue desc ;

-- 12. Analyze the cumulative revenue generated over time.

select order_date,sum(revenue) over(order by order_date) as cum_rev from 
(select orders.order_date, sum(orders_details.quantity* pizzas.price) as revenue from orders_details
join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from 
(select category,name,revenue ,rank() over(partition by category order by revenue desc)  as rn from 
(select pizza_types.category,pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b ;












