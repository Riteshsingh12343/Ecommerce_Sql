create database Ecommerce;
use Ecommerce ;

create table List_of_order (

	order_id text,
	order_Date text,
	customer varchar(50),
	state varchar(50),
	city varchar(50)
	);

	create table order_details (
	Order_id text,
	amount int,
	profit int,
	quantity int ,
	category varchar(50),
	sub_category varchar(50)
	);

	create table Target (
	month_of text,
	category varchar(50),
	target int

);

-- Q1 Query to join Orders and Order Details:-- 
	SELECT o.order_id, o.Order_Date, o.Customer, od.Amount, od.Profit, od.Quantity, od.Category, od.Sub_Category
	FROM list_of_order o
	JOIN Order_details od ON o.Order_ID = od.Order_ID;
 
 
 -- Q2 Total Sales per Customer:
	SELECT o.Customer, SUM(od.Amount) AS TotalSales
	FROM list_of_order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID
	GROUP BY o.Customer;

-- Q3 Profit by Category:
 
		 SELECT od.Category, SUM(od.Profit) AS TotalProfit
		FROM Order_Details od
		GROUP BY od.Category;

-- Q4 Top Customers by Sales:
	SELECT o.Customer as cutomer_name, SUM(od.Amount) AS TotalSales
	FROM list_of_Order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID
	GROUP BY o.Customer
	ORDER BY TotalSales DESC
	LIMIT 10;

-- Q5 Top-Selling Products
  SELECT od.Sub_Category, SUM(od.Quantity) AS TotalQuantitySold
	FROM Order_Details od
	GROUP BY od.Sub_Category
	ORDER BY TotalQuantitySold DESC
	LIMIT 10;
    
-- Q6 Average Profit by Category
   SELECT od.Category, AVG(od.Profit) AS AvgProfit
	FROM Order_Details od
	GROUP BY od.Category;
    
-- Q7 Sales by State and City
 SELECT o.State, o.City, SUM(od.Amount) AS TotalSales
	FROM list_of_Order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID
	GROUP BY o.State, o.City
	ORDER BY TotalSales DESC;

-- Q8 Most Profitable Customers
	SELECT o.Customer as customer_name, SUM(od.Profit) AS TotalProfit
	FROM list_of_Order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID
	GROUP BY o.Customer
	ORDER BY TotalProfit DESC
	LIMIT 10;

-- Q9  Product Profitability Analysis
	 SELECT od.Sub_Category, SUM(od.Profit) AS TotalProfit
	FROM Order_Details od
	GROUP BY od.Sub_Category
	ORDER BY TotalProfit DESC;

-- Q10 Low-Performing Products
	SELECT od.Sub_Category, SUM(od.Amount) AS TotalSales, SUM(od.Profit) AS TotalProfit
	FROM Order_Details od
	GROUP BY od.Sub_Category
	HAVING TotalSales < 5000 OR TotalProfit < 0
	ORDER BY TotalProfit ASC;

-- Q11  Repeat Customers
	SELECT o.Customer as customerName, COUNT(DISTINCT o.Order_ID) AS PurchaseCount
	FROM list_of_order o
	GROUP BY o.Customer
	HAVING PurchaseCount > 1
	ORDER BY PurchaseCount DESC;
    
--   Q12  Ranking Customers by Total Sales 
    SELECT o.Customer as customerName, 
       SUM(od.Amount) AS TotalSales,
       RANK() OVER (ORDER BY SUM(od.Amount) DESC) AS SalesRank
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer;


-- Q13  Running Total of Sales by Month 
     SELECT DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month, 
       SUM(od.Amount) AS MonthlySales,
       SUM(SUM(od.Amount)) OVER (ORDER BY DATE_FORMAT(o.Order_Date, '%Y-%m')) AS RunningTotal
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY Month
		ORDER BY Month ASC;


-- Q14 Finding the Most Profitable Category 
		SELECT od.Category, 
		   SUM(od.Profit) AS TotalProfit,
		   MAX(SUM(od.Profit)) OVER () AS MaxProfit
			FROM Order_Details od
			GROUP BY od.Category
			ORDER BY TotalProfit DESC;
			
-- Q15   CTE: Monthly Sales with Growth
			WITH MonthlySales AS (
	  SELECT DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month, SUM(od.Amount) AS TotalSales
	  FROM list_of_order o
	  JOIN Order_Details od ON o.Order_ID = od.Order_ID
	  GROUP BY Month
	)
	SELECT Month, 
		   TotalSales,
		   TotalSales - LAG(TotalSales) OVER (ORDER BY Month) AS SalesGrowth
	FROM MonthlySales;
    
-- Q16 Top 3 Customers by Profit
    WITH CustomerProfit AS (
	  SELECT o.Customer, SUM(od.Profit) AS TotalProfit
	  FROM list_of_order o
	  JOIN Order_Details od ON o.Order_ID = od.Order_ID
	  GROUP BY o.Customer
		)
		SELECT Customer as customerName, TotalProfit,
         RANK() OVER (ORDER BY TotalProfit DESC) as ProfitRank
		FROM CustomerProfit;
        
-- Q17  Moving Average of Sales
		SELECT DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month, 
       SUM(od.Amount) AS TotalSales,
       AVG(SUM(od.Amount)) OVER (ORDER BY DATE_FORMAT(o.Order_Date, '%Y-%m') ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY Month
		ORDER BY Month ASC;
        
        
        
-- Q18 Percent of Total Sales  
       SELECT o.Customer, 
       SUM(od.Amount) AS CustomerSales,
       SUM(od.Amount) / SUM(SUM(od.Amount)) OVER () * 100 AS PercentOfTotalSales
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer
		ORDER BY PercentOfTotalSales DESC;
        
-- Q19  Highest Sales Month per Category 
		 WITH CategorySales AS (
		  SELECT od.Category, DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month, SUM(od.Amount) AS MonthlySales
		  FROM list_of_order o
		  JOIN Order_Details od ON o.Order_ID = od.Order_ID
		  GROUP BY od.Category, Month
		),
		RankedSales AS (
		  SELECT Category, Month, MonthlySales,
				 RANK() OVER (PARTITION BY Category ORDER BY MonthlySales DESC) AS SalesRank
		  FROM CategorySales
		)
		SELECT Category, Month, MonthlySales, SalesRank
		FROM RankedSales
		WHERE SalesRank = 1;

-- Q20 Last Purchase Date for Each Customer
		with purchage_date as (
		SELECT *,
			   ROW_NUMBER() OVER (PARTITION BY Customer ORDER BY Order_Date DESC) AS RowNumber
		FROM list_of_order  )
		select Customer, Order_Date
		from purchage_date
		WHERE RowNumber = 1;
        
  --  Q21 Check if a customer’s total sales exceed a certain threshold. (IF Statement:)
			SELECT o.Customer, 
			   SUM(od.Amount) AS TotalSales,
			   IF(SUM(od.Amount) < 10000, 'VIP', 'Regular') AS CustomerType
			FROM list_of_order o
			JOIN Order_Details od ON o.Order_ID = od.Order_ID
			GROUP BY o.Customer;

-- Q22 Categorize customers into multiple types based on total sales.  (Nested IF:)
			SELECT o.Customer, 
			   SUM(od.Amount) AS TotalSales,
			   IF(SUM(od.Amount) > 20000, 'Platinum', 
				  IF(SUM(od.Amount) > 10000, 'Gold', 'Regular')) AS CustomerType
			FROM list_of_order o
			JOIN Order_Details od ON o.Order_ID = od.Order_ID
			GROUP BY o.Customer;
-- Q23  Get orders placed by customers from certain cities.
		SELECT * 
		FROM list_of_order
		WHERE City IN ('Ahmedabad', 'Pune', 'Jaipur');


-- Q24	Get orders placed by customers not from certain cities.
	SELECT * 
	FROM list_of_order
	WHERE City NOT IN ('Ahmedabad', 'Pune', 'Jaipur');

-- Q25	Find orders with total amounts between specific values
		SELECT * 
		FROM order_details
		WHERE Amount BETWEEN 100 AND 500;

-- Q26 Find orders with amounts not in a certain range.
		SELECT * 
		FROM order_details
		WHERE Amount NOT BETWEEN 100 AND 500;

-- Q27 Find customers whose names start with "B"
		SELECT * 
		FROM list_of_order
		WHERE Customer LIKE 'B%';
        
-- Q28 Find customers whose names do not start with "B".
		SELECT * 
		FROM list_of_order
		WHERE Customer not LIKE 'B%';
        
-- Q29 Rank customers by total sales.
		SELECT o.Customer, SUM(od.Amount) AS TotalSales, 
        RANK() OVER (ORDER BY SUM(od.Amount) DESC) AS SalesRank
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer;

-- Q30 Assign dense rank to customers by total sales.
		SELECT o.Customer, SUM(od.Amount) AS TotalSales, 
		DENSE_RANK() OVER (ORDER BY SUM(od.Amount) DESC) AS DenseRank
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer;
        
-- Q31 Assign a row number to each customer.
	SELECT o.Customer, SUM(od.Amount) AS TotalSales, 
       ROW_NUMBER() OVER (ORDER BY SUM(od.Amount) DESC) AS RowNum
	FROM list_of_order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID
	GROUP BY o.Customer;

 -- Q32 Calculate running total of sales.
		SELECT o.Customer, SUM(od.Amount) AS TotalSales, 
		SUM(SUM(od.Amount)) OVER (ORDER BY SUM(od.Amount)) AS RunningTotal
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer;

-- Q33 Calculate average sales by customer.
		SELECT o.Customer, AVG(od.Amount) AS AvgSales
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer;

-- Q34 Find maximum and minimum sales by customer
	SELECT o.Customer, MAX(od.Amount) AS MaxSale, MIN(od.Amount) AS MinSale
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer;

-- Q35 Assign a percentile rank to each customer’s total sales.
	SELECT o.Customer, SUM(od.Amount) AS TotalSales, 
       PERCENT_RANK() OVER (ORDER BY SUM(od.Amount)) AS PercentRank
		FROM list_of_order o	
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer;

-- Q36 Calculate a moving average over 3 orders.  (ROWS BETWEEN N PRECEDING AND N FOLLOWING:)
	SELECT o.Customer, od.Amount,
       AVG(od.Amount) OVER (ORDER BY od.Amount ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS MovingAvg
		FROM list_of_order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID;

-- Q37 Create a view for monthly sales
	CREATE VIEW MonthlySales AS
	SELECT DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month, SUM(od.Amount) AS TotalSales
	FROM list_of_order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID
	GROUP BY Month;

-- Q38 Pivot sales data to show total sales for each category per month.
		SELECT 
		DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month, 
		SUM(CASE WHEN od.Category = 'Furniture' THEN od.Amount ELSE 0 END) AS Furniture,
		SUM(CASE WHEN od.Category = 'Clothing' THEN od.Amount ELSE 0 END) AS Clothing,
		SUM(CASE WHEN od.Category = 'Electronics' THEN od.Amount ELSE 0 END) AS Electronics
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY Month
		ORDER BY Month;

-- Q39  Categorize orders based on their profit.
			SELECT od.Order_ID, od.Amount, od.Profit,
			CASE 
				WHEN od.Profit > 500 THEN 'High Profit'
				WHEN od.Profit BETWEEN 0 AND 500 THEN 'Moderate Profit'
			ELSE 'Loss'
				END AS ProfitCategory
			FROM Order_Details od;

-- Q40 Find customers who have placed more than one order.
		SELECT o.Customer
		FROM list_of_order o
		WHERE EXISTS (
		SELECT 1 
		FROM list_of_order o2 
		WHERE o.Customer = o2.Customer 
		GROUP BY o2.Customer
		HAVING COUNT(o2.Order_ID) > 1
	);

-- Q41 Find customers whose total sales exceed the average sales across all customers
	SELECT o.Customer, SUM(od.Amount) AS TotalSales
		FROM list_of_order o
		JOIN Order_Details od ON o.Order_ID = od.Order_ID
		GROUP BY o.Customer
		HAVING SUM(od.Amount) > (
    SELECT AVG(CustomerTotalSales)
    FROM (
			SELECT o2.Customer, SUM(od2.Amount) AS CustomerTotalSales
			FROM list_of_order o2
			JOIN Order_Details od2 ON o2.Order_ID = od2.Order_ID
			GROUP BY o2.Customer
		) AS CustomerSalesSummary
	);

-- Q42 Concatenate customer name with their city in uppercase.
			SELECT CONCAT(UPPER(o.Customer), ' from ', UPPER(o.City)) AS CustomerLocation
			FROM list_of_order o;

-- Q43 Create a stored procedure to get customer sales
		DELIMITER $$
	CREATE PROCEDURE GetCustomerSales(IN cust_name VARCHAR(50))
	BEGIN
	SELECT o.Customer, SUM(od.Amount) AS TotalSales
	FROM list_of_order o
	JOIN Order_Details od ON o.Order_ID = od.Order_ID
	WHERE o.Customer = cust_name
	GROUP BY o.Customer;
	END $$
	DELIMITER ;
 
 
 
 
 
 
 
 
 