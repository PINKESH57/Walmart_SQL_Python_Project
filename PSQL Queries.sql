SELECT * FROM walmart;

----
SELECT COUNT(*) FROM walmart;


SELECT
      payment_method,
	  COUNT(*)
FROM walmart
GROUP BY payment_method


SELECT 
    COUNT(DISTINCT branch)
FROM walmart;


SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold.

SELECT 
     payment_method,
	 COUNT(*) AS no_payments,
	 sum(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;



--Q.2 Identify the Highest-Rated category in each branch, displaying the branch, category, AVG rating.

SELECT *
FROM
(
  SELECT 
       branch,
	   category,
	   AVG(rating) AS avg_rating,
	   RANK() OVER(PARTITION BY branch ORDER BY avg(rating) DESC) as rank
  FROM walmart
  GROUP BY 1, 2
)
WHERE rank =1;



--Q.3 Identify the busiest day for each branch based on the number of transactions.

SELECT *
FROM
(
SELECT 
     branch,
	 TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day') as day_name,
	 COUNT(*) as no_transactions,
	 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1,2
)
WHERE  rank = 1;


--Q.4 Calculate the total quantity of items sold per payment method.
--    List payment_method and total_quantity.

SELECT 
     payment_method,
	 sum(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;


--Q.5 Determine the average, minimum, and maximum rating of products for each city
-- List city , average_rating, min_rating, and max_rating.

SELECT 
      city,
	  category,
      AVG(rating) as avg_rating,
	  MIN(rating) as min_rating,
	  MAX(rating) as max_rating
FROM walmart
GROUP BY 1,2;


--Q.6 Calculate the total profit for each category by considering total_profit as
--(unit_price * quantity * profit_margin).
--List category and total_profit, ordered from highest to lowest profit.

SELECT
      category,
	  SUM(total) as total_revenue,
	  SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1



--Q.7 Determine the most common payment method for each Branch.
--Display branch and prefered_payment_method.

WITH cte
AS
(
SELECT
      branch,
	  payment_method,
	  COUNT(*) AS total_trans,
	  RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
)
SELECT * FROM cte
WHERE rank =1



--Q.8 Categorize sales into 3 group MORNING, AFTERNOON EVENING
--    Find out each of the shift and number of invoices

SELECT
     branch,
CASE
	    WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;


--Q.9 Identify 5 branch with highest decrese ratio in
-- revenue compare to last year(current year 2023 and last year 2022)

--rdr == last_rev - cr_rev / ls_rev * 100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
    SELECT
        branch,
	    sum(total) as revenue
    from walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022  --PSQL
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022     ----MySQL 
    GROUP BY 1
),

revenue_2023
AS
(
    SELECT
        branch,
	    sum(total) as revenue
    from walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY 1
)

SELECT
     ls.branch,
	 ls.revenue as last_year_revenue,
     cs.revenue as cr_year_revenue,
	 ROUND(
	      (ls.revenue - cs.revenue)::numeric/
	      ls.revenue::numeric * 100,
		  2) AS rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE
     ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5
	 











