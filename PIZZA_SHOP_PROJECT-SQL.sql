-- PROJECT PIZZA SHOP

-- CREATE DATABASE
CREATE DATABASE pizza_shop;

-- IMPORT DATA BY RIGHT CLICKING ON THE DATABASE NAME.
-- CREATE TABLE AND INSERT DATA INTO TABLE BY RIGHT CLICKING ON THE TABLE THEN IMPORT THE DATA
-- CREATE TABLES
CREATE TABLE orders (
	order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
	PRIMARY KEY (order_id)
);

CREATE TABLE orders_details (
	order_details_id INT NOT NULL,
	order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
	PRIMARY KEY (order_details_id)
);

-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS Total_orders
FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(o.quantity * p.price),2) AS Total_revenue
FROM orders_details o
JOIN pizzas p
	ON o.pizza_id =p.pizza_id;

-- Identify the highest-priced pizza.
SELECT name, price
FROM pizzas p
JOIN pizza_types pt
	ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT p.size, COUNT(o.order_id) AS Tota_orders
FROM pizzas p
JOIN orders_details o
	ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY Tota_orders DESC;   

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS Quantity
FROM pizza_types pt
JOIN pizzas p
	ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details od
	ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY Quantity DESC
LIMIT 5;

-- The total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS Total_quantity
FROM pizza_types pt
JOIN pizzas p
	ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details od
	ON od.pizza_id = p.pizza_id 
GROUP BY category
ORDER BY Total_quantity DESC;    

-- Determine the distribution of orders by hour of the day.
SELECT COUNT(order_id) AS Total_orders, HOUR(order_time) AS hour
FROM orders
GROUP BY Hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category,  COUNT(name) AS Total_pizza
FROM pizza_types
GROUP BY category
ORDER BY Total_pizza DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(Total_quantity)) Pizza_ordered_per_day 
FROM (
SELECT order_date, SUM(quantity) AS Total_quantity
FROM orders o
JOIN orders_details od
	ON o.order_id = od.order_id
GROUP BY order_date
) AS orders_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT name, ROUND(SUM(o.quantity * p.price),2) AS Total_revenue
FROM orders_details o
JOIN pizzas p
	ON o.pizza_id =p.pizza_id
JOIN pizza_types pt
	ON pt.pizza_type_id = p.pizza_type_id
GROUP BY name 
ORDER BY Total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT category, (ROUND(SUM(o.quantity * p.price) / 
(SELECT ROUND(SUM(o.quantity * p.price),2) 
FROM orders_details o
JOIN pizzas p
	ON o.pizza_id =p.pizza_id)* 100, 2)) AS revenue
FROM orders_details o
JOIN pizzas p
	ON o.pizza_id =p.pizza_id
JOIN pizza_types pt
	ON pt.pizza_type_id = p.pizza_type_id
GROUP BY category 
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT order_date, 
SUM(revenue) OVER(ORDER BY order_date ) AS Cum_revenue
FROM
(SELECT order_date, SUM(od.quantity * p.price) AS revenue 
FROM orders o
JOIN orders_details od
	ON o.order_id = od.order_id
JOIN pizzas p
	ON od.pizza_id = p.pizza_id 
GROUP BY order_date
ORDER BY revenue DESC) AS sales;   

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, category, Total_revenue
FROM(
SELECT category, name, Total_revenue,
RANK() OVER(PARTITION BY category ORDER BY Total_revenue DESC) AS rn
FROM 
(SELECT name, category, 
ROUND(SUM(o.quantity * p.price),2) AS Total_revenue
FROM orders_details o
JOIN pizzas p
	ON o.pizza_id =p.pizza_id
JOIN pizza_types pt
	ON pt.pizza_type_id = p.pizza_type_id
GROUP BY name, category)
AS a) AS b
WHERE rn <= 3;    
