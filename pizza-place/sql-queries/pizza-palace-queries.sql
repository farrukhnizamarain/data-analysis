/* Created Tables to be used for analysis*/

CREATE TABLE pizza_types ( 
			 pizza_type_id NVARCHAR(50) NOT NULL PRIMARY KEY,
			 name NVARCHAR(50) NOT NULL,
			 category NVARCHAR(50) NOT NULL,
			 ingredients NVARCHAR(100) NOT NULL
)

CREATE TABLE pizzas (
			 pizza_id NVARCHAR(50) NOT NULL PRIMARY KEY,
			 pizza_type_id NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES pizza_types(pizza_type_id),
			 size NVARCHAR(50) NOT NULL,
			 price FLOAT NOT NULL
)

CREATE TABLE orders (
			 order_id INT NOT NULL PRIMARY KEY,
			 date date NOT NULL,
			 time time NOT NULL
)

CREATE TABLE order_details (
			 order_details_id INT NOT NULL PRIMARY KEY,
			 order_id INT NOT NULL FOREIGN KEY REFERENCES orders(order_id),
			 pizza_id NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES pizzas(pizza_id),
			 quantity TINYINT NOT NULL
)

/* 1.	How many customers do we have each day? Are there any peak hours? */

SELECT date AS Date, FORMAT(CAST(date as DATE), 'dddd') AS Weekday, count(date) AS Number_of_Orders
FROM orders
GROUP BY date


SELECT FORMAT(CAST(date as DATE), 'dddd') AS Weekday, COUNT(FORMAT(CAST(date as DATE), 'dddd')) AS Number_of_Orders
FROM orders
GROUP BY FORMAT(CAST(date as DATE), 'dddd') 
ORDER BY COUNT(FORMAT(CAST(date as DATE), 'dddd')) DESC


SELECT FORMAT(CAST(time as TIME), 'hh')+':00' AS Hours, COUNT(FORMAT(CAST(time as TIME), 'hh')) As Number_of_Orders
FROM orders
GROUP BY FORMAT(CAST(time as TIME), 'hh')
ORDER BY COUNT(FORMAT(CAST(time as TIME), 'hh')) DESC


SELECT FORMAT(CAST(date as DATE), 'dddd') AS Weekday, FORMAT(CAST(time as TIME), 'hh')+':00' AS Time, COUNT(FORMAT(CAST(time as TIME), 'hh')) AS No_of_Orders
FROM orders
GROUP BY FORMAT(CAST(date as DATE), 'dddd'), FORMAT(CAST(time as TIME), 'hh')
ORDER BY
		CASE
			WHEN FORMAT(CAST(date as DATE), 'dddd') = 'Sunday' THEN 1
			WHEN FORMAT(CAST(date as DATE), 'dddd') = 'Monday' THEN 2
			WHEN FORMAT(CAST(date as DATE), 'dddd') = 'Tuesday' THEN 3
			WHEN FORMAT(CAST(date as DATE), 'dddd') = 'Wednesday' THEN 4
			WHEN FORMAT(CAST(date as DATE), 'dddd') = 'Thursday' THEN 5
			WHEN FORMAT(CAST(date as DATE), 'dddd') = 'Friday' THEN 6
			WHEN FORMAT(CAST(date as DATE), 'dddd') = 'Saturday' THEN 7
		END, FORMAT(CAST(time as TIME), 'hh') ASC


/* 2. How many pizzas are typically in an order? Do we have any bestsellers? */

-- I Created a Tempory Table to house all of the orders and quantity values

CREATE TABLE #number_of_order (
order_id INT,
quantity INT
)

-- Inserted all the required values into the Temporary Table

INSERT INTO #number_of_order
SELECT order_id AS Order_ID, COUNT(quantity) AS Quantity
FROM order_details
GROUP BY order_id
ORDER BY order_id ASC

-- Finally, calculated the quantities and divided it with the number of orders

SELECT COUNT(*) AS Number_of_Orders, (SUM(quantity) / (SELECT COUNT(*) FROM #number_of_order)) AS Average_Pizzas_per_Order
FROM #number_of_order

-- To Calculate the Top Sellers, I just added up the quantities ordered of different pizza flavors

SELECT TOP 10 pizza_id, SUM(quantity) AS Quantities_Ordered
FROM order_details
GROUP BY pizza_id
ORDER BY Quantities_Ordered DESC


/* 3. How much money did we make this year? Can we indentify any seasonality in the sales? */


-- First of all, I calcuclated the cost per quantities sold

SELECT order_details.pizza_id, order_details.quantity, pizzas.price, (order_details.quantity * pizzas.price) AS cost
FROM order_details 
INNER JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id

-- Now, We calaculated the items sold per year

SELECT SUM(quantity) As Items_Sold, SUM(order_details.quantity * pizzas.price) AS Sales
FROM order_details 
INNER JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id

-- Can we identify any seasonality in the sales?

SELECT DATENAME(month, orders.date) AS Sales_Month, SUM(order_details.quantity * pizzas.price) AS Sales
FROM order_details 
INNER JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
INNER JOIN orders ON order_details.order_id = orders.order_id
GROUP BY DATENAME(month, orders.date)
ORDER BY 
		CASE
		WHEN DATENAME(month, orders.date) = 'January' THEN 1
		WHEN DATENAME(month, orders.date) = 'February' THEN 2
		WHEN DATENAME(month, orders.date) = 'March' THEN 3
		WHEN DATENAME(month, orders.date) = 'April' THEN 4
		WHEN DATENAME(month, orders.date) = 'May' THEN 5
		WHEN DATENAME(month, orders.date) = 'June' THEN 6
		WHEN DATENAME(month, orders.date) = 'July' THEN 7
		WHEN DATENAME(month, orders.date) = 'August' THEN 8
		WHEN DATENAME(month, orders.date) = 'September' THEN 9
		WHEN DATENAME(month, orders.date) = 'October' THEN 10
		WHEN DATENAME(month, orders.date) = 'November' THEN 11
		WHEN DATENAME(month, orders.date) = 'December' THEN 12
		END

/* 4. Are there any pizzas we should take off the menu, or any promotions we could leverage? */

SELECT DATENAME(month, orders.date) AS Sales_Month, pizzas.pizza_type_id, SUM(order_details.quantity * pizzas.price) AS Sales
FROM order_details 
INNER JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
INNER JOIN orders ON order_details.order_id = orders.order_id
GROUP BY DATENAME(month, orders.date), pizzas.pizza_type_id
HAVING SUM(order_details.quantity * pizzas.price) < 1500
ORDER BY 
		CASE
		WHEN DATENAME(month, orders.date) = 'January' THEN 1
		WHEN DATENAME(month, orders.date) = 'February' THEN 2
		WHEN DATENAME(month, orders.date) = 'March' THEN 3
		WHEN DATENAME(month, orders.date) = 'April' THEN 4
		WHEN DATENAME(month, orders.date) = 'May' THEN 5
		WHEN DATENAME(month, orders.date) = 'June' THEN 6
		WHEN DATENAME(month, orders.date) = 'July' THEN 7
		WHEN DATENAME(month, orders.date) = 'August' THEN 8
		WHEN DATENAME(month, orders.date) = 'September' THEN 9
		WHEN DATENAME(month, orders.date) = 'October' THEN 10
		WHEN DATENAME(month, orders.date) = 'November' THEN 11
		WHEN DATENAME(month, orders.date) = 'December' THEN 12
		END, Sales ASC



