/* GOAL: The goal is to derive actionable business insights from transactional data to improve customer experience, optimize operations,
 and maximize profitability.*/

USE project;
SELECT *
FROM walmart;

-- ---------------------------------------------------------------------------------------------------------------------------------
#1 PAYMENT METHODS ANALYSIS
SELECT 
    payment_method,                   # grouping column
    COUNT(*) AS total_transactions,   # counts rows = number of transaction
    SUM(quantity) AS total_items_sold # total items sold
FROM
    walmart
GROUP BY payment_method;              # splits data by payment method

/* Analyzed transaction count and quantity sold across different payment methods to understand customer payment preferences.
Helps optimize payment infrastructure and prioritize popular payment options for better customer experience.*/

-- ---------------------------------------------------------------------------------------------------------------------------------
#2 HIGHEST RATED CATEGORY PER BRANCH
WITH rating_cte AS (
SELECT 
	branch,
    category,
    ROUND(AVG(rating),2) AS avg_rating, 
    DENSE_RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk 	# rank categories inside each branch and highest rating = rank 1
FROM walmart
GROUP BY branch,category) 														# get avg rating
SELECT 
	branch,category,avg_rating
FROM rating_cte
WHERE rnk = 1; 																	#keep only top category

/*Calculated average ratings per category within each branch and identified the top-performing category. 
Enables branch-level marketing focus and promotes high-performing categories to improve customer satisfaction */
 
-- ---------------------------------------------------------------------------------------------------------------------------------
#3 BUSIEST DAY PER BRANCH
SELECT branch, day_name, total_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(date) AS day_name,											#gets day (Monday, Tuesday…)
        COUNT(*) AS total_transactions,										#number of transactions
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk		#finds busiest day inside each branch
    FROM walmart
    GROUP BY branch, DAYNAME(date) 											#grouping branch + day
) t
WHERE rnk = 1;																# filtering top day only

/*Extracted day of the week from transaction dates and identified peak transaction days for each branch.
Supports better staffing, inventory planning, and operational efficiency during high-demand days.*/

-- ---------------------------------------------------------------------------------------------------------------------------------
#4 QUANTITY BY PAYMENT METHOD
SELECT 
    payment_method,
    SUM(quantity) AS total_items_sold # total number of items sold
FROM walmart
GROUP BY payment_method 			# splits results by each payment type
ORDER BY total_items_sold DESC;		# sorting according most used payment method

/*Aggregated total quantity sold for each payment method to analyze purchasing volume trends.
Helps understand which payment methods drive higher sales volume, aiding strategic decisions. */

-- ---------------------------------------------------------------------------------------------------------------------------------
#5 CATEGORY RATING BY CITY
SELECT 
    city,
    category,
    ROUND(AVG(rating),2) AS avg_rating, # average satisfaction and cleaner output
    MIN(rating) AS min_rating, 			# worst case
    MAX(rating) AS max_rating  			# best case
FROM walmart
GROUP BY city, category 	   			# creates combinations of city and category
ORDER BY city, category;

/*Analyzed average, minimum, and maximum ratings for each category across different cities.
Reveals regional preferences and performance gaps, enabling targeted improvements and localized strategies.*/

-- ---------------------------------------------------------------------------------------------------------------------------------
#6 PROFIT BY CATEGORY
SELECT 
    category,
    ROUND(SUM(total * profit_margin),2) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

/* Calculated total profit per category using revenue and profit margin, then ranked categories by profitability.
Helps identify high-profit categories for better pricing, promotions, and inventory prioritization.*/

-- ---------------------------------------------------------------------------------------------------------------------------------
#7 MOST COMMON PAYMENT PER BRANCH
WITH payment_cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_transactions,											# number of transactions
        DENSE_RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk	# rank inside each branch and highest count first
    FROM walmart
    GROUP BY branch, payment_method												# count per combination
)
SELECT branch, payment_method, total_transactions
FROM payment_cte
WHERE rnk = 1;																	#filtered most common method

/*Identified the most frequently used payment method within each branch using transaction counts.
Allows branches to streamline payment systems and improve checkout efficiency based on customer behavior.*/

-- ---------------------------------------------------------------------------------------------------------------------------------
#8 SALES BY TIME SHIFT
SELECT 
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning' 				# HOUR(time) → extracts hour from time
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY shift
ORDER BY total_transactions DESC;

/* Segmented transactions into time-based shifts and analyzed sales distribution across the day.
Helps optimize staffing, inventory restocking, and promotional strategies based on peak hours.*/
-- ---------------------------------------------------------------------------------------------------------------------------------
#9 REVENUE DECLINE (YEAR - OVER - YEAR)
WITH yearly_revenue AS (				# Aggregate revenue per branch per year
    SELECT 
        branch,
        YEAR(date) AS year,
        SUM(total) AS revenue
    FROM walmart
    GROUP BY branch, YEAR(date)
),
revenue_comparison AS (					# Use LAG() to get previous year
    SELECT 
        branch,
        year,
        revenue,
        LAG(revenue) OVER (PARTITION BY branch ORDER BY year) AS prev_year_revenue
    FROM yearly_revenue
),
revenue_change_calc AS (				# Calculate revenue difference
    SELECT 
        branch,
        year,
        revenue,
        prev_year_revenue,
        (revenue - prev_year_revenue) AS revenue_change
    FROM revenue_comparison
)
SELECT *								# Filter decline + get biggest drop
FROM revenue_change_calc
WHERE revenue_change < 0
ORDER BY revenue_change ASC
LIMIT 1;

/*Compared yearly revenue per branch using window functions to identify declines over time.
This approach helps identify underperforming branches and enables targeted interventions to improve sales.*/

-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------
