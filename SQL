-- Basic Business Questions

-- 1 What is the total number of employees in the workforce table? 
   SELECT COUNT(*) 
   FROM WORKFORCE ;
   
-- 2 How many employees are there in each department?  
   SELECT department,
		  COUNT(*) AS total_emp
          FROM workforce 
          GROUP BY department;
          
-- 3 What is the average monthly income of employees in each department?
    SELECT DEPARTMENT,
		   AVG(monthlyincome) AS AVG_SAL
           FROM WORKFORCE 
           GROUP BY DEPARTMENT;
           
-- 4 How many employees have left the company (Attrition = 'Yes') in each department?          
    SELECT DEPARTMENT,
		   SUM(CASE WHEN attrition  = 'YES' THEN 1 ELSE 0 END) AS LEFT_EMPLOYEES
           FROM WORKFORCE 
           GROUP BY DEPARTMENT;
           
-- 5 What is the average age of employees in each job role
     SELECT JOBROLE,
			AVG(AGE) AS AVG_AGE
            FROM WORKFORCE 
            GROUP BY JOBROLE ;
            
-- 6 What is the total monthly income paid to employees in each department?
    SELECT DEPARTMENT,
			SUM(MONTHLYINCOME) AS TOTAL_MONTHLY_INCOME 
            FROM WORKFORCE 
            GROUP BY DEPARTMENT;
            
-- 7 How many employees are working overtime in each department?
    SELECT DEPARTMENT,
			SUM(CASE WHEN OVERTIME = 'YES' THEN  1 ELSE 0 END ) AS EMP_WITH_OVERTIME 
            FROM WORKFORCE 
            GROUP BY DEPARTMENT; 
            
-- 8 What is the average monthly income for employees who work overtime versus those who do not?
SELECT  OVERTIME,
		AVG(MONTHLYINCOME) AS AVG_MONTHLY_INCOME 
        FROM WORKFORCE 
        GROUP BY OVERTIME ;
        
-- 9 How many employees are there in each job level?
SELECT JOBLEVEL,
	   COUNT(*) AS COUNT_EMP 
       FROM WORKFORCE 
       GROUP BY JOBLEVEL 
       ORDER BY COUNT_EMP DESC;
       
-- 10 What is the attrition rate (%) for each department?
SELECT DEPARTMENT,
       SUM(CASE WHEN ATTRITION = 'YES' THEN 1 ELSE 0 END ) * 100/COUNT(*) AS ATTRITION_RATE
       FROM WORKFORCE 
       GROUP BY DEPARTMENT;

-- ==================================================================================================================================================    
-- Hard / Advanced Business Questions | Q1/5  

-- Q11. Which employees have a MonthlyIncome greater than 10,000?
SELECT EmployeeID, MonthlyIncome
FROM workforce
WHERE MonthlyIncome > 10000;


-- Q12. What is the average MonthlyIncome of employees in the Sales department?
SELECT AVG(MonthlyIncome) AS Avg_MonthlyIncome
FROM workforce
WHERE Department = 'Sales';


-- Q13. Which departments have more than 1,000 employees?
SELECT Department,
       COUNT(*) AS Total_Employees
FROM workforce
GROUP BY Department
HAVING COUNT(*) > 1000;


-- Q14. What are the top 10 employees with the highest MonthlyIncome?
SELECT EmployeeID, MonthlyIncome
FROM workforce
ORDER BY MonthlyIncome DESC
LIMIT 10;


-- Q15. What is the minimum, maximum, and average MonthlyIncome of employees?
SELECT 
    MIN(MonthlyIncome) AS Min_Income,
    MAX(MonthlyIncome) AS Max_Income,
    AVG(MonthlyIncome) AS Avg_Income
FROM workforce;
-- ================================================================================================================================           

-- Subqueries | Q1/5

-- Q1. Find employees whose MonthlyIncome is higher than the overall average income.

SELECT 
    EmployeeID,
    MonthlyIncome
FROM workforce
WHERE MonthlyIncome > (
    SELECT AVG(MonthlyIncome)
    FROM workforce
);


-- Q2. Find the employee(s) with the highest MonthlyIncome.

SELECT 
    EmployeeID,
    MonthlyIncome
FROM workforce
WHERE MonthlyIncome = (
    SELECT MAX(MonthlyIncome)
    FROM workforce
);


-- Q3. Find employees who have the same JobRole as employees in the Sales department.

SELECT 
    EmployeeID,
    JobRole
FROM workforce
WHERE JobRole IN (
    SELECT DISTINCT JobRole
    FROM workforce
    WHERE Department = 'Sales'
);


-- Q4. Find employees whose MonthlyIncome is higher than
-- the average MonthlyIncome of their own department.
-- (Correlated Subquery)

-- SELECT 
--     E.EmployeeID,
--     E.Department,
--     E.MonthlyIncome
-- FROM workforce E
-- WHERE E.MonthlyIncome > (
--     SELECT AVG(W.MonthlyIncome)
--     FROM workforce W
--     WHERE W.Department = E.Department
-- );


-- Q5. Find employees whose MonthlyIncome is equal to
-- the highest MonthlyIncome in their own department.
-- (Correlated Subquery)

-- SELECT 
--     E.EmployeeID,
--     E.Department,
--     E.MonthlyIncome
-- FROM workforce E
-- WHERE E.MonthlyIncome = (
--     SELECT MAX(W.MonthlyIncome)
--     FROM workforce W
--     WHERE W.Department = E.Department
-- );

-- ================================================================================================================================           
-- JOIN / SELF JOIN | Q1/2

-- Q1. Find employees who work in the same department as EmployeeID = 1001.

SELECT 
    E1.EmployeeID,
    E1.Department
FROM workforce E1
JOIN workforce E2
    ON E1.Department = E2.Department
WHERE E2.EmployeeID = 1001
  AND E1.EmployeeID <> 1001;


-- Q2. Find pairs of employees where one employee earns more than another employee
-- in the same department.

SELECT 
    E1.EmployeeID AS Higher_Paid_Employee,
    E2.EmployeeID AS Lower_Paid_Employee,
    E1.Department,
    E1.MonthlyIncome AS Higher_Salary,
    E2.MonthlyIncome AS Lower_Salary
FROM workforce E1
JOIN workforce E2
    ON E1.Department = E2.Department
   AND E1.MonthlyIncome > E2.MonthlyIncome
   AND E1.EmployeeID <> E2.EmployeeID;

-- ================================================================================================================================================
-- Window Functions | Q1/5

-- Q1. Find the salary rank of each employee based on MonthlyIncome,
-- from highest to lowest.

SELECT 
    EmployeeID,
    Department,
    MonthlyIncome,
    RANK() OVER (ORDER BY MonthlyIncome DESC) AS Salary_Rank
FROM workforce;


-- Q2. Find the top 3 highest-paid employees in each department.

WITH RankedEmployees AS (
    SELECT 
        EmployeeID,
        Department,
        MonthlyIncome,
        RANK() OVER (
            PARTITION BY Department 
            ORDER BY MonthlyIncome DESC
        ) AS Salary_Rank
    FROM workforce
)
SELECT 
    EmployeeID,
    Department,
    MonthlyIncome,
    Salary_Rank
FROM RankedEmployees
WHERE Salary_Rank <= 3;


-- Q3. Show each employee's salary along with the average salary
-- of their department.

SELECT 
    EmployeeID,
    Department,
    MonthlyIncome,
    AVG(MonthlyIncome) OVER (
        PARTITION BY Department
    ) AS Dept_Avg_Salary
FROM workforce;


-- Q4. Assign a row number to employees based on MonthlyIncome,
-- with the highest salary first.

SELECT 
    EmployeeID,
    MonthlyIncome,
    ROW_NUMBER() OVER (
        ORDER BY MonthlyIncome DESC
    ) AS Row_Num
FROM workforce;


-- Q5. Show each employee's MonthlyIncome and the previous employee's
-- MonthlyIncome when employees are ordered by salary.

SELECT 
    EmployeeID,
    MonthlyIncome,
    LAG(MonthlyIncome) OVER (
        ORDER BY MonthlyIncome DESC
    ) AS Previous_Income
FROM workforce;

-- ======================================================================================================================================
-- CTE | Q1/5

-- Q1. Find the total number of employees in each department using a CTE.

WITH DEPT_EMPLOYEES AS (
    SELECT 
        Department,
        COUNT(*) AS Total_Employees
    FROM workforce
    GROUP BY Department
)
SELECT *
FROM DEPT_EMPLOYEES;


-- Q2. Find the average MonthlyIncome for each department using a CTE.

WITH DEPT_AVG_INCOME AS (
    SELECT 
        Department,
        AVG(MonthlyIncome) AS Avg_MonthlyIncome
    FROM workforce
    GROUP BY Department
)
SELECT *
FROM DEPT_AVG_INCOME;


-- Q3. Find the number of employees who have left the company in each department.

WITH DEPT_ATTRITION AS (
    SELECT 
        Department,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Count
    FROM workforce
    GROUP BY Department
)
SELECT *
FROM DEPT_ATTRITION;


-- Q4. Find the average MonthlyIncome of employees who work overtime
-- in each department.

WITH OVERTIME_INCOME AS (
    SELECT 
        Department,
        AVG(MonthlyIncome) AS Avg_Overtime_Income
    FROM workforce
    WHERE OverTime = 'Yes'
    GROUP BY Department
)
SELECT *
FROM OVERTIME_INCOME;


-- Q5. Find departments where the average MonthlyIncome is greater than 5,000.

WITH DEPT_INCOME AS (
    SELECT 
        Department,
        AVG(MonthlyIncome) AS Avg_MonthlyIncome
    FROM workforce
    GROUP BY Department
)
SELECT *
FROM DEPT_INCOME
WHERE Avg_MonthlyIncome > 5000;

-- ================================================================================================================================================
-- Stored Procedures | Q1/2

-- Q1. Create a stored procedure to display all employees from a given department.

DELIMITER //

CREATE PROCEDURE GetEmployeesByDepartment(IN DeptName VARCHAR(50))
BEGIN
    SELECT *
    FROM workforce
    WHERE Department = DeptName;
END //

DELIMITER ;

CALL GetEmployeesByDepartment('Sales');


-- Q2. Create a stored procedure to display employees earning above a given MonthlyIncome.

DELIMITER //

CREATE PROCEDURE GetEmployeesByIncome(IN MinIncome INT)
BEGIN
    SELECT 
        EmployeeID,
        Department,
        MonthlyIncome
    FROM workforce
    WHERE MonthlyIncome > MinIncome;
END //

DELIMITER ;

CALL GetEmployeesByIncome(10000);

-- =======================================================================================================================================================
-- Views | Q1/2

-- Q1. Create a view showing EmployeeID, Department, JobRole and MonthlyIncome.

CREATE VIEW Employee_Income_View AS
SELECT 
    EmployeeID,
    Department,
    JobRole,
    MonthlyIncome
FROM workforce;

SELECT * FROM Employee_Income_view;

-- Q2. Create a view showing department-wise employee count.

CREATE VIEW Department_Employee_View AS
SELECT 
    Department,
    COUNT(*) AS Total_Employees
FROM workforce
GROUP BY Department;           
           
SELECT * FROM Department_Employee_View;           
           
-- =====================================================================================================================================================           
           
           
           
           
           
           
