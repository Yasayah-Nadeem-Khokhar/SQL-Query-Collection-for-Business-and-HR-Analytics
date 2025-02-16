-- ===============================================
-- SQL Query Collection for Business & HR Analytics
-- ===============================================

-- ===============================================
-- Author: Yasayah Nadeem Khokhar
-- GitHub: https://github.com/Yasayah-Nadeem-Khokhar/SQL-Query-Collection-for-Business-and-HR-Analytics
-- ===============================================

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Description:
-- This SQL file contains a collection of queries designed for business insights,
-- HR analytics, sales performance tracking, transport system management, and 
-- metadata exploration. The queries can be executed on relational databases 
-- like MySQL, PostgreSQL, or SQL Server.

-- Usage Instructions:
-- - Ensure you have access to the required databases (Sales, HR, EmployeesCSV, SBMS).
-- - Execute queries based on your analytical needs.
-- - Modify filters (e.g., date range, department name) as needed.
-- - For best results, understand the database schema before running queries.

-- =======================================================
-- =======================================================


/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
Can we identify top-performing departments or teams 
based on their current-year performance metrics like 
sales, productivity, or other relevant KPIs?
*/
# hr DB
use hr;
select d.DEPARTMENT_NAME, count(*) as job from jobs j
join job_history h on j.JOB_ID = h.JOB_ID
join departments d on h.DEPARTMENT_ID =d.DEPARTMENT_ID
group by d.DEPARTMENT_ID
order by job desc 
limit 2;

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
"How can I retrieve the specific data type
associated with the column named 'product_code'
within the 'products' table of the 'sales' database
schema using metadata information?"
*/
# Sales DB
use sales;
select column_name, data_type
from information_schema.columns
where table_schema = 'sales' 
  and table_name = 'products' 
  and column_name = 'product_code';

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
Could you generate a report that shows the
count of orders for each product type across
different years based on the transaction records?"
*/  
# Sales DB
use sales;
select p.product_type, Year(order_date) as sales_year, count(*) as orders from products p
join transactions t on p.product_code = t.product_code
group by product_type, sales_year
order by sales_year desc, product_type;

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
"How much did each customer spend annually on purchases,
in millions, along with their names and the corresponding 
purchase years?"
*/
use sales;
select custmer_name, concat(round(sum(sales_amount)/1000000,2),' ','M') as total_pkr, year(order_date) as Purchase_Year from customers c
join transactions t on c.customer_code = t.customer_code
group by c.customer_code, Purchase_Year
order by Purchase_Year desc, total_pkr  desc;

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
"How can we identify the second and third top customers in terms
of their yearly purchase amounts, considering our sales data? The
desired output should display the customers' names, their respective
total yearly purchase amounts in millions ('M' denomination), and
the corresponding year of the purchases. The solution to this inquiry
involve analyzing the data by grouping customers based on their 
yearly spending and selecting the customers ranked second and
third within each year."
*/
USE sales;
select custmer_name, total_rup, order_year
from(
	select 
		custmer_name, 
		concat(round(sum(sales_amount)/1000000,2),' ', 'M') as total_rup,
		year(order_date) as order_year,
        row_number() over (partition by year(order_date) order by sum(sales_amount) desc) as rank_per_year
	from customers c
	join transactions t on c.customer_code = t.customer_code
	group by c.customer_code, order_year
) ranked
where rank_per_year in(2,3)
order by order_year desc, total_rup desc;

/*total sales amount by the year and the best market in that year*/
SELECT 
    total_sales.year,
	MAX(total_sales.rup_million) AS total_rup_million,
    MAX(as_per_the_ranking.markets_name) AS best_market_of_year,
    MAX(as_per_the_ranking.rup_million) AS market_amount
FROM(
        SELECT 
            markets_name, 
            CONCAT(ROUND(SUM(sales_amount)/1000000), ' ', 'million') AS rup_million, 
            YEAR(order_date) AS Yearr,
            ROW_NUMBER() OVER(PARTITION BY YEAR(order_date) ORDER BY SUM(sales_amount) DESC) AS rankk
        FROM markets m 
        JOIN transactions t ON m.markets_code = t.market_code
        GROUP BY markets_name, Yearr
    ) as_per_the_ranking
JOIN(
        SELECT YEAR(order_date) AS year, CONCAT(ROUND(SUM(sales_amount)/1000000), ' ', 'million') AS rup_million
        FROM sales.transactions
        GROUP BY year(order_date)
    ) total_sales
ON as_per_the_ranking.Yearr = total_sales.year
WHERE as_per_the_ranking.rankk = 1
GROUP BY total_sales.year
ORDER BY total_sales.year DESC;

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
"What are the details of the employee(s) 
with the highest salary in the 'employeesscsv'
dataset, including their first name, hire date, 
and salary?"
*/
# employeesscsv DB
SELECT 
	FIRST_NAME, 
    HIRE_DATE, 
    SALARY 
FROM employeesscsv 
WHERE SALARY = (SELECT MAX(SALARY) FROM employeesscsv);

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
"Which employee(s) were hired most recently 
in the 'employeesscsv' dataset?"
*/
SELECT * 
FROM employeesscsv 
WHERE HIRE_DATE = (SELECT MAX(HIRE_DATE) FROM employeesscsv);

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
"What employee(s) were hired earliest among
 all the entries in the 'employeesscsv' dataset?"
 */
SELECT * 
FROM employeesscsv 
WHERE HIRE_DATE = (SELECT MIN(HIRE_DATE) FROM employeesscsv);

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
"Can you provide a list of employees from the
'employeesscsv' dataset along with their respective
managers, if applicable, ordered by employee ID?"
*/
SELECT e1.*, e2.FIRST_NAME  AS MANGER FROM employeesscsv e1
LEFT JOIN employeesscsv e2 ON e1.MANAGER_ID = e2.IEMPLOYEE_ID ORDER BY IEMPLOYEE_ID;

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	What is the hire date of employee Steven King?
*/
		SELECT HIRE_DATE FROM employeesscsv WHERE FIRST_NAME = 'Steven' AND LAST_NAME='King';
/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	Who is the manager of the employee with the last name 'Vollman'?
*/
		SELECT *
		FROM
		(SELECT 
			e1.*, 
			e2.FIRST_NAME  AS MANGER 
		FROM employeesscsv e1
		LEFT JOIN employeesscsv e2 
			ON e1.MANAGER_ID = e2.IEMPLOYEE_ID 
		ORDER BY IEMPLOYEE_ID) tb 
		WHERE LAST_NAME = 'Vollman';
/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	What is the job title of employee number 117?
*/
		SELECT JOB_ID
		FROM employeesscsv
		WHERE IEMPLOYEE_ID =117;
        
/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	Can you provide the email and phone number of Neena Kochhar?
*/
		SELECT 
			concat(FIRST_NAME,' ', LAST_NAME) AS FULL_NAME,
            Email,
            PHONE_NUMBER
		FROM employeesscsv 
        WHERE FIRST_NAME = 'Neena' AND LAST_NAME='Kochhar';

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	How many employees have 'ST_CLERK' as their job title?
*/
		SELECT 
			count(JOB_ID)
		FROM employeesscsv 
        WHERE JOB_ID = 'ST_CLERK';

/*     
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ   
	Who is the highest-paid employee in the 'Finance' department?
*/
		SELECT * 
        FROM employeesscsv 
        WHERE JOB_ID LIKE 'FI%' ORDER BY SALARY DESC LIMIT 1;
/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	List the employees hired in July 1987.
*/
		SELECT * 
        FROM employeesscsv 
        WHERE HIRE_DATE BETWEEN '7/1/1987' AND  '7/31/1987';
/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	Who is the manager of the employee with the email 'IMIKKILI'?
*/
		SELECT 
			e1.*, 
			CONCAT(e2.FIRST_NAME,' ',e2.LAST_NAME) AS MANGER 
		FROM employeesscsv e1
		LEFT JOIN employeesscsv e2 
			ON e1.MANAGER_ID = e2.IEMPLOYEE_ID 
		WHERE e1.EMAIL = 'IMIKKILI'
		ORDER BY IEMPLOYEE_ID;
/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	Which department has the most employees?
*/
		SELECT 
			DEPARTMENT_ID,
            COUNT(DEPARTMENT_ID) AS Num_Of_Emp 
		FROM employeesscsv
		GROUP BY DEPARTMENT_ID 
        ORDER BY Num_Of_Emp DESC;

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	Create updated mails of all employeess.
*/
		SELECT 
			IEMPLOYEE_ID,
            FIRST_NAME, 
            LAST_NAME, 
            PHONE_NUMBER, 
            concat(lower(FIRST_NAME),lower(LAST_NAME),'@company.pk') AS update_mail 
		FROM employeesscsv;

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
Which employee has the highest salary relative 
	to their department's average salary?
*/    
    SELECT 
		IEMPLOYEE_ID, 
		FIRST_NAME, 
        SALARY, 
        DEPARTMENT_ID 
        FROM (
				SELECT 
					*,
					ROW_NUMBER() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY DESC) AS hightest_sal
				FROM employeesscsv
			) high_sala
		WHERE hightest_sal = 1;

/*    
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
	Can you identify the hierarchical structure by 
	determining the number of levels in the management
    chain within the 'Finance' department?
*/
    SELECT 
		e1.IEMPLOYEE_ID, 
		e1.FIRST_NAME, 
        e1.JOB_ID, 
        e1.PHONE_NUMBER, 
        e2.IEMPLOYEE_ID AS MAN_ID, 
        e2.FIRST_NAME AS MAN_NAME , 
        e2.PHONE_NUMBER AS MAN_CELL 
	FROM employeesscsv e1
	JOIN employeesscsv e2 
		ON e1.MANAGER_ID =e2.IEMPLOYEE_ID
	WHERE e1.JOB_ID LIKE 'FI%';

/*
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
Country from each alphabet
*/
# world DB
USE world;
select Name from (
SELECT 
    Name,
    ROW_NUMBER() OVER (PARTITION BY SUBSTRING(Name, 1, 1) ORDER BY Name ASC) AS ranking
FROM 
    world.country) rankker
WHERE ranking = 1;


# employeesscsv DB
SELECT 
	e1.IEMPLOYEE_ID,e1.FIRST_NAME,e2.IEMPLOYEE_ID AS MAN_ID,e2.FIRST_NAME, e2.MANAGER_ID, e3.FIRST_NAME, e3.MANAGER_ID, e4.FIRST_NAME, e4.MANAGER_ID
FROM assignment.employeesscsv e1
LEFT JOIN employeesscsv e2 
ON e1.MANAGER_ID = e2.IEMPLOYEE_ID
LEFT JOIN employeesscsv e3
ON e2.MANAGER_ID = e3.IEMPLOYEE_ID
LEFT JOIN employeesscsv e4
ON e3.MANAGER_ID = e4.IEMPLOYEE_ID;

-- ===============================================
# Creating Trigeer
-- ===============================================

CREATE TABLE IF NOT EXISTS sales (
    sales_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_code VARCHAR(255),
    product_code VARCHAR(255),
    sales_amount DECIMAL(10, 2),
    sales_qty INT,
    order_date DATE,
    route_id INT
);


CREATE TABLE IF NOT EXISTS routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS revenue_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    route_name VARCHAR(255),
    route_rev VARCHAR(255),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
	
    
DELIMITER //
CREATE TRIGGER calculate_route_revenue AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    DECLARE route_REV VARCHAR(255);
    
    SELECT CONCAT('$', ' ', ROUND(SUM(s.sales_amount))) 
    INTO route_REV
    FROM sales s
    WHERE s.route_id = NEW.route_id
    GROUP BY s.route_id;

    INSERT INTO revenue_log (route_id, route_name, route_rev)
    SELECT r.route_id, r.route_name, route_REV
    FROM routes r
    WHERE r.route_id = NEW.route_id;
END//
DELIMITER ;



INSERT INTO sales (customer_code, product_code, sales_amount, sales_qty, order_date, route_id)
VALUES ('C001', 'P001', 100.00, 1, '2024-07-29', 1);

INSERT INTO routes (route_name)
VALUES ('Route 1');

SELECT * FROM sales;




-- ===============================================
# Creating View
-- ===============================================

CREATE OR REPLACE VIEW route_revenue_view AS
SELECT r.route_name, CONCAT('$',' ',ROUND(SUM(s.sales_amount))) AS route_REV
FROM sales s
JOIN routes r ON s.route_id = r.route_id
GROUP BY r.route_id;


SELECT * FROM route_revenue_view;

-- ===============================================
# Creating Procedure 
-- ===============================================

DELIMITER //
CREATE PROCEDURE CalculateAndLogRouteRevenue(IN route_id INT)
BEGIN
    DECLARE route_REV VARCHAR(255);
    
    -- Calculate the route revenue
    SELECT CONCAT('$', ' ', ROUND(SUM(s.sales_amount))) 
    INTO route_REV
    FROM sales s
    WHERE s.route_id = route_id
    GROUP BY s.route_id;

    -- Insert the calculated revenue into the log table
    INSERT INTO revenue_log (route_id, route_name, route_rev)
    SELECT r.route_id, r.route_name, route_REV
    FROM routes r
    WHERE r.route_id = route_id;
END//
DELIMITER ;


CALL CalculateAndLogRouteRevenue(1);


-- Insert sample data into sales table
INSERT INTO sales (customer_code, product_code, sales_amount, sales_qty, order_date, route_id)
VALUES ('C001', 'P001', 100.00, 1, '2024-07-29', 1),
       ('C002', 'P002', 200.00, 2, '2024-07-29', 1);

-- Insert sample data into routes table
INSERT INTO routes (route_name)
VALUES ('Route 1');


CALL CalculateAndLogRouteRevenue(1);


SELECT * FROM revenue_log;

-- ===============================================
-- ===============================================
-- ===============================================
# THE END @:-)























