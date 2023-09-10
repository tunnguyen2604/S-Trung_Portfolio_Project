USE `Customer Data`;

-- Cleaning & Standardizing data

-- Standardizing Date Format 
	UPDATE online_store_customer_data
	SET Transaction_date = CAST(STR_TO_DATE(Transaction_date, '%m/%d/%Y') AS DATE);

-- Adding new column "Generation" 
	ALTER TABLE online_store_customer_data 
	ADD Generation VARCHAR(50);
	
	UPDATE online_store_customer_data 
	SET Generation = CASE 
                    WHEN Age BETWEEN 15 AND 26 THEN 'Gen Z' 
                    WHEN Age BETWEEN 27 AND 41 THEN 'Millennials' 
                    WHEN Age BETWEEN 42 AND 58 THEN 'Gen Xers' 
                    WHEN Age BETWEEN 59 AND 77 THEN 'Boomers' 
                    ELSE 'The Elderly' 
                END;
               
-- Converting Data Types of Column "Referal"               
	ALTER TABLE online_store_customer_data
	MODIFY COLUMN Referral VARCHAR(50);

-- Change 1 and 0 to Referred and Not Referred in "Referal" field
	UPDATE online_store_customer_data
	SET Referal = CASE
                  WHEN Referal = 1 THEN 'Referred'
                  ELSE 'Not referred'
              END;
             
-- Change the null value to 0 in the column amount_spent
 	UPDATE online_store_customer_data 
	SET Amount_spent = 0
	WHERE amount_spent IS NULL; 

-- Check and delete missing values in the column Gender
	DELETE FROM online_store_customer_data 
	WHERE Gender <> 'Female' AND Gender <> 'Male';


-- Analyze the 
	-- Revenue and transactions by year and month
		SELECT 
			REPLACE(EXTRACT(YEAR FROM Transaction_date), ',','') AS Year,
			EXTRACT(MONTH FROM Transaction_date) AS Month,
			ROUND(SUM(Amount_spent),0) AS Total_spent,
			COUNT(Transaction_id) AS Total_Transaction 
		FROM online_store_customer_data oscd 
		GROUP BY Year, Month; 
	
	-- Which month has the highest number of transactions?
		SELECT 
			EXTRACT(MONTH FROM Transaction_date) AS Month,
			COUNT(Transaction_id) as total_order 
		FROM online_store_customer_data oscd  
		GROUP BY Month;
	
	-- Top 10 cities with the highest revenue 
		SELECT 
			State_names,
			ROUND(SUM(Amount_spent),0) AS Total_spent 
		FROM online_store_customer_data oscd 
		GROUP BY State_names 
		ORDER BY Total_spent DESC
		LIMIT 10;
	
	-- Number of completed transactions
		WITH CustomerStats AS (
		    SELECT
		        CASE WHEN Amount_spent <> 0 THEN 1 ELSE 0 END AS Successfully,
		        CASE WHEN Amount_spent = 0 THEN 1 ELSE 0 END AS Cancelled
		    FROM online_store_customer_data
		)
		SELECT
		    SUM(Successfully) AS Successfully,
		    SUM(Cancelled) AS Cancelled
		FROM CustomerStats;

	-- Number of transactions and revenue by each age group of customers
			SELECT 
			  Generation, 
			  COUNT(Transaction_ID) AS Count,
			  ROUND(SUM(Amount_spent),0) AS Spent
			FROM online_store_customer_data
			GROUP BY Generation;
		
	-- Are there any differences between married and single customers based on gender?
		SELECT 
			gender,
			Marital_status,
			ROUND(SUM(Amount_spent),0) AS total_spent
		FROM online_store_customer_data oscd
		GROUP BY gender, Marital_status; 
	
	-- Total amount spent and transactions based on employment status
	    SELECT 
		    Employees_status AS Status, 
		    COUNT(Employees_status) AS `Count`, 
		    ROUND(SUM(Amount_spent),0) AS Total_spent,
		    ROUND(COUNT(Transaction_ID) / (SELECT COUNT(Transaction_id) FROM online_store_customer_data) * 100,0) AS Percent 
		FROM online_store_customer_data
		WHERE Employees_status IS NOT NULL 
		GROUP BY Employees_status;
	
	-- Total amount spent and transactions based on the payment method
	    	SELECT 
	    		Payment_method AS method, 
	    		Count(Payment_method) AS Count, 
	    		ROUND(SUM(Amount_spent),0) AS Spent  
	    	FROM online_store_customer_data oscd 
	    	GROUP BY Payment_method
	    	ORDER BY Count DESC;
	    
	-- Do referrals spend more than non-referrals?
	    	SELECT 
	    		Referal, 
	    		Count(Transaction_id) AS Count, 
	    		ROUND(SUM(Amount_spent),0) AS Spent  
	    	FROM online_store_customer_data oscd 
	    	GROUP BY referal;
	    
	-- Customer spending level
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

	-- Frequency of purchases of Generation on a quarterly basis
		SELECT 
			CASE 
				WHEN EXTRACT(Quarter FROM Transaction_date) = 1 THEN 'Q1'
				WHEN EXTRACT(Quarter FROM Transaction_date) = 2 THEN 'Q2'
				WHEN EXTRACT(Quarter FROM Transaction_date) = 3 THEN 'Q3'
				ELSE 'Q4'
			END AS `Quarter`, 
				SUM(IF(Generation = 'Gen Z', 1, 0)) AS `Gen Z`,
				SUM(IF(Generation = 'Millennials', 1, 0)) AS Millennials,
				SUM(IF(Generation = 'Gen Xers',1,0)) AS `Gen Xers`,
				SUM(IF(Generation = 'Boomers',1,0)) AS Boomers, 
				SUM(IF(Generation = 'The Elderly',1,0)) AS `The Elderly`
		FROM online_store_customer_data oscd 
		GROUP BY `Quarter`;	
	
		