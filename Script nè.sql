USE `Customer Data`;
/* 
 	Skill used:
	   CTE's
	   Aggregate Functions
	   Creating Views
	   Creating Tables
	   Converting Data Types 
*/


-- Analysis 
	
	-- Doanh thu theo năm 
		SELECT 
			REPLACE(EXTRACT(YEAR FROM CAST(STR_TO_DATE(Transaction_date, '%m/%d/%Y') AS DATE)), ',','') AS Year,
			ROUND(SUM(Amount_spent),0) AS Total_spent
		FROM Customer c
		GROUP BY Year; 
	-- Doanh thu theo tháng	
		SELECT 
			EXTRACT(MONTH FROM CAST(STR_TO_DATE(Transaction_date, '%m/%d/%Y') AS DATE)) AS Month,
			ROUND(SUM(Amount_spent),0) AS Total_spent
		FROM Customer c 
		GROUP BY Month; 
	-- Top 10 thành phố đem lại doanh thu cao nhất   
		SELECT 
			State_names,
			ROUND(SUM(Amount_spent),0) AS Total_spent 
		FROM Customer c 
		GROUP BY State_names 
		ORDER BY Total_spent DESC
		LIMIT 10;
	-- Số lượng giao dịch hoàn thành 
		SELECT  
			COUNT(Amount_spent) AS Successfully,
			COUNT(Transaction_ID) - COUNT(Amount_spent) AS Canceled
		FROM Customer c;
 

-- Phân tích khách hàng 

	-- Dựa theo độ tuổi 
		CREATE TABLE Generations AS
			SELECT 
			  CASE 
			    WHEN Age BETWEEN 15 AND 26 THEN 'Gen Z' 
			    WHEN Age BETWEEN 27 AND 41 THEN 'Millennials' 
			    WHEN Age BETWEEN 42 AND 58 THEN 'Gen Xers' 
			    WHEN Age BETWEEN 59 AND 77 THEN 'Boomers' 
			    ELSE 'The Elderly' 
			  END AS Generation, 
			  COUNT(Transaction_ID) AS Count,
			  ROUND(SUM(Amount_spent),0) AS Spent
			FROM online_store_customer_data
			GROUP BY Generation;
	-- Dựa theo giới tính  
		CREATE TABLE Gender AS 
			SELECT Gender, Count(Gender) AS Count, ROUND(SUM(Amount_spent),0) AS Spent  
			FROM online_store_customer_data oscd3 
			WHERE Gender IS NOT NULL 
			GROUP BY Gender;
	-- Dựa theo tình trạng hôn nhân 
		CREATE TABLE Marital_Status AS 
		SELECT Marital_status, COUNT(Marital_status) AS Count, ROUND(SUM(Amount_spent),0) AS Spent 
		FROM online_store_customer_data oscd 
		GROUP BY Marital_status ;
	-- Dựa theo thành phố 
		CREATE TABLE Location AS 
			SELECT 
				State_names, 
				Count(State_names) AS Count,
				ROUND(SUM(Amount_spent),0) AS Total_spent 	
			FROM online_store_customer_data oscd 
			GROUP BY State_names 
			ORDER BY Total_spent DESC;
	-- Dựa theo tình trạng việc làm 
	    CREATE TABLE Employees_Status AS	
	    SELECT 
		    Employees_status AS Status, 
		    COUNT(Employees_status) AS `Count`, 
		    ROUND(SUM(Amount_spent),0) AS Total_spent,
		    ROUND(COUNT(Transaction_ID) / (SELECT COUNT(Transaction_id) FROM online_store_customer_data) * 100,0) AS Percent 
		FROM online_store_customer_data
		WHERE Employees_status IS NOT NULL 
		GROUP BY Employees_status;
	-- Dựa theo phương thức tính tiền
	    CREATE TABLE Payment_Method AS	
	    	SELECT Payment_method AS method, Count(Payment_method) AS Count, ROUND(SUM(Amount_spent),0) AS Spent  
	    	FROM online_store_customer_data oscd 
	    	GROUP BY Payment_method
	    	ORDER BY Count DESC;
	-- Dựa theo referal	
	    CREATE TABLE Referal AS
	    	SELECT Referal, Count(Referal) AS Count, ROUND(SUM(Amount_spent),0) AS Spent  
	    	FROM online_store_customer_data oscd 
	    	WHERE Referal IS NOT NULL 
	    	GROUP BY Referal;
	-- Mức độ chi tiêu của khách hàng 
		SELECT	
		CASE
			WHEN Amount_spent < 101 THEN 'Low Price'
			WHEN Amount_spent BETWEEN 101 AND 500 THEN 'Medium Price'
			WHEN Amount_spent BETWEEN 501 AND 1000 THEN 'High Price'
			ELSE 'Very High Price'
		END AS `Spending level`,
		Count(Amount_Spent) AS `Number of Transactions`,
		ROUND(SUM(Amount_spent),0) AS Total_Spent 
	FROM online_store_customer_data oscd 
	GROUP BY `Spending level` 
	ORDER BY `Number of Transactions` ASC; 
	-- Thời gian mua hàng
		SELECT 
			CASE 
				WHEN EXTRACT(Quarter FROM CAST(STR_TO_DATE(Transaction_date, '%m/%d/%Y') AS DATE)) = 1 THEN 'Q1'
				WHEN EXTRACT(Quarter FROM CAST(STR_TO_DATE(Transaction_date, '%m/%d/%Y') AS DATE)) = 2 THEN 'Q2'
				WHEN EXTRACT(Quarter FROM CAST(STR_TO_DATE(Transaction_date, '%m/%d/%Y') AS DATE)) = 3 THEN 'Q3'
				ELSE 'Q4'
			END AS `Quarter`, 
			SUM(IF(Generation = 'Gen Z', 1, 0)) AS `Gen Z`,
				SUM(IF(Generation = 'Millennials', 1, 0)) AS Millennials,
				SUM(IF(Generation = 'Gen Xers',1,0)) AS `Gen Xers`,
				SUM(IF(Generation = 'Boomers',1,0)) AS Boomers, 
				SUM(IF(Generation = 'The Elderly',1,0)) AS `The Elderly`
		FROM Customer 
		GROUP BY `Quarter`;
	
	
		