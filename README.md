# Pizza_sales_project
 In this Pizza Project, we aim to analyze various aspects of the pizza restaurant's operations by querying the database.

-- CREATE DATABASE
CREATE DATABASE pizza_shop;

-- CREATE TABLE AND INSERT DATA INTO TABLE.
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

-- BASIC QUERRIES
--1. The total number of orders placed.
SELECT COUNT(*) AS Total_Orders
FROM orders; 

-- 2. The total revenue generated from pizza sales.
SELECT ROUND(SUM(t1.quantity * t2.price), 2) AS Total_Revenue
FROM orders_details t1
JOIN pizzas t2
	ON t1.pizza_id = t2.pizza_id;
    
-- 3. The highest-priced pizza. 
SELECT name, price 
FROM pizza_types p1
JOIN pizzas p2
	ON p1.pizza_type_id = p2.pizza_type_id
ORDER BY price DESC
LIMIT 1 ;    

-- 4. The most common pizza size ordered.
SELECT t1.size, COUNT(t2.order_details_id) AS Order_Count
FROM pizzas t1
JOIN orders_details t2
	ON t1.pizza_id = t2.pizza_id
GROUP BY t1.size
ORDER BY Order_Count DESC;

-- ADVANCE QUERRIES

-- 5. The top 5 most ordered pizza types along with their quantities.
SELECT p1.name, SUM(p3.quantity) AS Quantity
FROM pizza_types p1
JOIN pizzas p2
	ON p1.pizza_type_id = p2.pizza_type_id
JOIN orders_details p3 
	ON p3.pizza_id = p2.pizza_id
GROUP BY p1.name
ORDER BY Quantity DESC
LIMIT 5;    

-- 6. The total quantity of each pizza category ordered.
SELECT category, SUM(quantity) AS Total_Quantity
FROM pizza_types p1
JOIN pizzas p2
	ON p1.pizza_type_id = p2.pizza_type_id
JOIN orders_details p3 
	ON p3.pizza_id = p2.pizza_id
GROUP BY category
ORDER BY Total_Quantity DESC;

-- 7. Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS Per_hour, COUNT(order_id) Total_Order
FROM orders
GROUP BY Per_hour;    

-- 8. the category-wise distribution of pizzas.
SELECT category, COUNT(pizza_type_id)
FROM pizza_types p1
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(Quantity), 0) Avg_quantity_per_day FROM 
(SELECT order_date, SUM(quantity) AS Quantity
FROM orders_details o1
JOIN orders o2
	ON o1.order_id = o2.order_id
GROUP BY order_date) AS Order_quantity;    

-- 10. The top 3 most ordered pizza types based on revenue.
SELECT name, ROUND(SUM(t1.quantity * t2.price), 2) AS Total_Revenue
FROM orders_details t1
JOIN pizzas t2
	ON t1.pizza_id = t2.pizza_id
JOIN pizza_types t3
	ON t2.pizza_type_id = t3.pizza_type_id
GROUP BY name
ORDER BY Total_Revenue DESC
LIMIT 3	;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT category, 
	   ROUND(SUM(quantity * price) / (SELECT
	   ROUND(SUM(quantity * price), 2) AS Total_Revenue
       FROM orders_details t1
       JOIN pizzas t2
			ON t2.pizza_id = t1.pizza_id) *100, 2) AS revenue             
FROM pizza_types
JOIN pizzas
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
	ON orders_details.pizza_id = pizzas.pizza_id	
GROUP BY category
ORDER BY revenue DESC ;

-- 12. Analyze the cumulative revenue generated over time.
SELECT order_date,
SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(SELECT orders.order_date, 
SUM(orders_details.quantity * pizzas.price) AS revenue
FROM orders_details
JOIN pizzas
	ON orders_details.pizza_id = pizzas.pizza_id
JOIN orders
	ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS sales; 

-- 13. The top 3 most ordered pizza types based on revenue for each pizza category.  
SELECT category, name, revenue 
FROM
(SELECT category, name, revenue, 
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT pizza_types.category, pizza_types.name, 
SUM((orders_details.quantity) * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
	ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
	ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3; 


-- THANK YOU --
 
