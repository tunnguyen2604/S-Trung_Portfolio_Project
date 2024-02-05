CREATE DATABASE DATAGOTTALENT;
USE DATAGOTTALENT;

-- Số lượng khách hàng hiện tại
SELECT COUNT(DISTINCT customerid) FROM customer

-- Phân tích nhân khẩu học của khách hàng
	-- Giới tính
	SELECT 
		gender,
		COUNT(gender)
	FROM customer 
	GROUP BY gender

	-- Tình trạng việc làm
	SELECT 
		DISTINCT job,
		COUNT(job)
	FROM customer c
	GROUP BY job

	-- Độ tuổi của khách hàng
	SELECT  
		generation,
		COUNT(generation) AS total
	FROM
	(SELECT 
		age, 
		CASE 
			WHEN age BETWEEN 0 AND 14 THEN 'Chưa biết đặt tên gì'
	    	WHEN age BETWEEN 15 AND 26 THEN 'Gen Z' 
	        WHEN age BETWEEN 27 AND 41 THEN 'Millennials' 
	        WHEN age BETWEEN 42 AND 58 THEN 'Gen Xers' 
	        WHEN age BETWEEN 59 AND 77 THEN 'Boomers' 
	    	ELSE 'The Elderly' 
	    END AS generation
	FROM
	(SELECT
		2023 - REPLACE(EXTRACT(YEAR FROM DOB),',','') as age
	FROM customer) m 
	ORDER BY age ASC) n
	GROUP BY generation

-- Phân tích doanh thu trong tháng 5
-- Tổng doanh thu đã thu được trong tháng 5
SELECT 
	SUM(total) 
FROM
(SELECT
	orderid,
	SUM(`ticket price`) as total
FROM ticket t
GROUP BY orderid) m

-- Trung bình số lượng giao dịch trong 1 ngày
SELECT ROUND(AVG(total_orders),0) FROM
(SELECT
	saledate,
	COUNT(orderid) as total_orders
FROM ticket
WHERE saledate IS NOT NULL
GROUP BY saledate
ORDER BY saledate) m

-- Số lượng đơn hàng trong tháng 5
SELECT 
	COUNT(*) 
FROM (
	SELECT orderid as total_order 
	FROM ticket 
	GROUP BY orderid) m
	
-- Số lượng khách hàng trong tháng 5
SELECT COUNT(DISTINCT customerid) as total_customer 
FROM (
	SELECT DISTINCT orderid, customerid 
	FROM ticket ) m

-- Doanh thu theo độ tuổi
SELECT 
	generation,
	COUNT(generation),
	SUM(total)
FROM 
(SELECT
	DISTINCT orderid,
	total,
	CASE 
		WHEN age BETWEEN 0 AND 14 THEN 'Gen Alpha'
    	WHEN age BETWEEN 15 AND 26 THEN 'Gen Z' 
        WHEN age BETWEEN 27 AND 41 THEN 'Millennials' 
        WHEN age BETWEEN 42 AND 58 THEN 'Gen Xers' 
        WHEN age BETWEEN 59 AND 77 THEN 'Boomers' 
    	ELSE 'The Elderly' 
    END AS generation
FROM
(SELECT
	orderid,
	total,
	2023 - REPLACE(EXTRACT(YEAR FROM DOB),',','') AS age
FROM ticket t JOIN customer c 
ON t.customerid = c.customerid 
WHERE orderid != 'NULL') m ) n
GROUP BY generation
	
-- Giá trị trung bình trên 1 đơn hàng 
SELECT ROUND(AVG(total),1) FROM
(SELECT 
	DISTINCT orderid,
	total
FROM ticket ) m

-- Trung bình số lượng vé khách hàng đặt trên mỗi đơn hàng 
SELECT AVG(total_ticket)
FROM
(SELECT 
	DISTINCT orderid,
	total_ticket
FROM
(SELECT 
	orderid, 
	ticketcode,
	COUNT(ticketcode) OVER (PARTITION BY orderid) AS total_ticket
FROM ticket) m
ORDER BY total_ticket DESC) n

-- Tần suất của số lượng vé khách hàng đặt trên mỗi đơn hàng 
SELECT 
	total_ticket,
	COUNT(total_ticket)
FROM
(SELECT 
	DISTINCT orderid,
	total_ticket
FROM
(SELECT 
	orderid, 
	COUNT(slot) OVER (PARTITION BY orderid) AS total_ticket
FROM ticket) m
ORDER BY total_ticket DESC) n
GROUP BY total_ticket 
ORDER BY total_ticket 

-- Thời gian khách hàng đi xem phim trong tuần 
SELECT 
	DAYNAME(date) AS day_name,
	COUNT(ticketcode) AS total_customers
FROM ticket
GROUP BY day_name
ORDER BY total_customers

-- Thời gian khách hàng đi xem phim trong tháng 
SELECT 
	date,
	COUNT(ticketcode) AS total_customers
FROM ticket
GROUP BY date
ORDER BY date

-- Thời gian khách hàng đi xem phim theo tuần trong tháng
SELECT 
	CEIL(DAYOFMONTH(date) / 7) AS week_of_month,
	COUNT(ticketcode) AS total_customers
FROM ticket
GROUP BY week_of_month
ORDER BY week_of_month

-- Thời gian khách hàng đi xem phim trong ngày
SELECT 
    COUNT(customerid) as total_customer,
    CASE 
        WHEN time BETWEEN '01:00:00' AND '10:59:00' THEN 'Morning'
        WHEN time BETWEEN '11:00:00' AND '12:59:00' THEN 'Midday'
        WHEN time BETWEEN '13:00:00' AND '18:59:00' THEN 'Afternoon'
        WHEN time BETWEEN '19:00:00' AND '21:59:00' THEN 'Evening'
        WHEN time BETWEEN '22:00:00' AND '24:59:00' THEN 'Night'
    END AS time_of_day
FROM ticket 
GROUP BY time_of_day
ORDER BY time_of_day;

-- Khung giờ khách hàng đi xem trong ngày 
SELECT 
	time,
	COUNT(ticketcode) AS total_ticket
FROM ticket 
GROUP BY time
ORDER BY time

-- Số lượng đơn hàng đặt vé trước 
SELECT COUNT(*) FROM
(SELECT DISTINCT orderid, date, saledate, the_distance FROM 
(SELECT 
	*,
	saledate - date as the_distance
FROM ticket t) m 
WHERE the_distance != 0 AND the_distance IS NOT NULL ) n

-- Thời gian đặt trước của khách hàng
SELECT DISTINCT orderid, date, saledate, the_distance FROM 
(SELECT 
	*,
	saledate - date as the_distance
FROM ticket t) m 
WHERE the_distance != 0 AND the_distance IS NOT NULL

-- Các loại vé đã được bán ra 
SELECT 
	`slot type`,
	COUNT(`slot type`)
FROM ticket
GROUP BY `slot type`

-- Số lượng các loại khách hàng
SELECT 
	`ticket type`,
	COUNT(`ticket type`)
FROM ticket
GROUP BY `ticket type`

-- Số lượng người mua popcorn
SELECT 
	popcorn, 
	COUNT(customerid)
FROM ticket
GROUP BY popcorn

-- Ai là người đã mua popcorn 
SELECT 
	popcorn,
	generation,
	COUNT(popcorn) AS total_buyers
FROM
(SELECT 
	*,
	CASE 
		WHEN age BETWEEN 0 AND 14 THEN 'Gen Alpha'
    	WHEN age BETWEEN 15 AND 26 THEN 'Gen Z' 
        WHEN age BETWEEN 27 AND 41 THEN 'Millennials' 
        WHEN age BETWEEN 42 AND 58 THEN 'Gen Xers' 
        WHEN age BETWEEN 59 AND 77 THEN 'Boomers' 
    	ELSE 'The Elderly' 
    END AS generation
FROM
(SELECT 
	DOB,
	popcorn,
	2023 - REPLACE(EXTRACT(YEAR FROM DOB),',','') AS age,
	ticketcode,
	time
FROM customer c
JOIN ticket t 
ON c.customerid = t.customerid) m ) n 
WHERE popcorn ='Có'
GROUP BY popcorn, generation

-- Các loại vé đã bán ra dựa trên giá tiền
SELECT 
	`ticket price`,
	COUNT(`ticket price`)
FROM ticket
GROUP BY `ticket price` 

-- Số lượng khách hàng theo giá vé và độ tuổi
SELECT 
	`ticket price`, 
	CASE 
		WHEN age BETWEEN 0 AND 14 THEN 'Gen Alpha'
    	WHEN age BETWEEN 15 AND 26 THEN 'Gen Z' 
        WHEN age BETWEEN 27 AND 41 THEN 'Millennials' 
        WHEN age BETWEEN 42 AND 58 THEN 'Gen Xers' 
        WHEN age BETWEEN 59 AND 77 THEN 'Boomers' 
    	ELSE 'The Elderly' 
    END AS generation,
	COUNT(`ticket price`) as total
FROM
(SELECT 
	`ticket price`,
	2023 - REPLACE(EXTRACT(YEAR FROM DOB),',','') as age
FROM customer c 
JOIN ticket t ON c.customerid = t.customerid) m
GROUP BY `ticket price`, generation
ORDER BY `ticket price`, total

-- Phân tích film
-- Các thể loại rating đã được sản xuất 
SELECT 
	rating,
	COUNT(rating) as total
FROM film
GROUP BY rating
ORDER BY total

-- Số lượng phim sản xuất ở mỗi quốc gia
SELECT 
	country_split,
	COUNT(country_split)
FROM film
GROUP BY country_split 

-- Các thể loại phim được sản xuất
SELECT 
	listed_in_split,
	COUNT(listed_in_split)
FROM film
GROUP BY listed_in_split