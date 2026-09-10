-- SQL DATA ANALYTICS PORTFOLIO
-- Practice: LeetCode-style SQL + Data Analyst SQL Tasks
-- Dialect: MySQL

/* ============================================================
   SECTION 1 — LEETCODE-STYLE SQL
   ============================================================ */

-- Q1. Combine Two Tables
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Address;

CREATE TABLE Person (
    personId INT PRIMARY KEY,
    firstName VARCHAR(50),
    lastName VARCHAR(50)
);

CREATE TABLE Address (
    addressId INT PRIMARY KEY,
    personId INT,
    city VARCHAR(50),
    state VARCHAR(50)
);

INSERT INTO Person (personId, firstName, lastName)
VALUES
(1, 'Allen', 'Wang'),
(2, 'Bob', 'Alice');

INSERT INTO Address (addressId, personId, city, state)
VALUES
(1, 2, 'New York City', 'New York');

SELECT
    p.firstName,
    p.lastName,
    a.city,
    a.state
FROM Person p
LEFT JOIN Address a
    ON p.personId = a.personId;


-- Q2. Second Highest Salary
DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
    id INT PRIMARY KEY,
    salary INT
);

INSERT INTO Employee (id, salary)
VALUES
(1, 100),
(2, 200),
(3, 300);

SELECT
    (
        SELECT DISTINCT salary
        FROM Employee
        ORDER BY salary DESC
        LIMIT 1 OFFSET 1
    ) AS SecondHighestSalary;


-- Q3. Customers Who Never Order
CREATE DATABASE IF NOT EXISTS leetcode;
USE leetcode;

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Orders (
    id INT PRIMARY KEY,
    customerId INT
);

INSERT INTO Customers (id, name) VALUES
(1, 'Joe'),
(2, 'Henry'),
(3, 'Sam'),
(4, 'Max'),
(5, 'Bob');

INSERT INTO Orders (id, customerId) VALUES
(1, 3),
(2, 1),
(3, 2),
(4, 1);

SELECT c.name AS Customers
FROM Customers c
LEFT JOIN Orders o
    ON c.id = o.customerId
WHERE o.customerId IS NULL;


-- Q4. Department Highest Salary
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Employee (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    salary INT,
    departmentId INT,
    FOREIGN KEY (departmentId) REFERENCES Department(id)
);

INSERT INTO Department VALUES
(1, 'IT'),
(2, 'Sales');

INSERT INTO Employee VALUES
(1, 'Joe', 70000, 1),
(2, 'Jim', 90000, 1),
(3, 'Henry', 80000, 2),
(4, 'Sam', 60000, 2),
(5, 'Max', 90000, 1);

SELECT
    d.name AS Department,
    e.name AS Employee,
    e.salary AS Salary
FROM Employee e
JOIN Department d
    ON e.departmentId = d.id
WHERE (e.salary, e.departmentId) IN (
    SELECT MAX(salary), departmentId
    FROM Employee
    GROUP BY departmentId
);


-- Q5. Delete Duplicate Emails
DROP TABLE IF EXISTS Person;

CREATE TABLE Person (
    id INT PRIMARY KEY,
    email VARCHAR(255)
);

INSERT INTO Person (id, email) VALUES
(1, 'john@example.com'),
(2, 'bob@example.com'),
(3, 'john@example.com'),
(4, 'alice@example.com'),
(5, 'bob@example.com');

SET SQL_SAFE_UPDATES = 0;

DELETE p1
FROM Person p1
JOIN Person p2
    ON p1.email = p2.email
    AND p1.id > p2.id;

SET SQL_SAFE_UPDATES = 1;


/* ============================================================
   SECTION 2 — DATA ANALYST SQL TASKS
   ============================================================ */

-- Q6. Customer Age Grouping
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    age INT,
    region VARCHAR(50)
);

INSERT INTO customers VALUES
(1, 'Ravi', 16, 'South'),
(2, 'Priya', 25, 'North'),
(3, 'Amit', 45, 'East'),
(4, 'Sita', 62, 'West');

SELECT
    customer_id,
    customer_name,
    age,
    region,
    CASE
        WHEN age < 18 THEN 'Teen'
        WHEN age BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN age BETWEEN 36 AND 60 THEN 'Adult'
        WHEN age > 60 THEN 'Senior'
    END AS age_group
FROM customers;


-- Q7. Employee Salary Band
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary INT,
    department VARCHAR(50)
);

INSERT INTO employees VALUES
(1, 'Arjun', 25000, 'HR'),
(2, 'Meena', 45000, 'IT'),
(3, 'Rahul', 65000, 'Finance'),
(4, 'Sonia', 85000, 'Marketing');

SELECT
    emp_id,
    emp_name,
    salary,
    department,
    CASE
        WHEN salary < 30000 THEN 'Low'
        WHEN salary BETWEEN 30000 AND 70000 THEN 'Medium'
        WHEN salary > 70000 THEN 'High'
    END AS salary_band
FROM employees;


-- Q8. Rank Students Within Class
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    class VARCHAR(20),
    total_score INT
);

INSERT INTO students VALUES
(1, 'Amit', 'Class A', 95),
(2, 'Riya', 'Class A', 88),
(3, 'Suresh', 'Class A', 95),
(4, 'Kiran', 'Class B', 90),
(5, 'Neha', 'Class B', 75),
(6, 'Arjun', 'Class B', 85);

SELECT
    student_id,
    student_name,
    class,
    total_score,
    RANK() OVER (
        PARTITION BY class
        ORDER BY total_score DESC
    ) AS class_rank
FROM students;


-- Q9. Salary Difference From Department Average
-- Source task assumes an existing employees table containing
-- employee IDs 101–105 and an existing departments table.
-- The original task adds dept_id and updates those IDs.

ALTER TABLE employees
ADD dept_id INT;

UPDATE employees SET dept_id = 1 WHERE emp_id = 101;
UPDATE employees SET dept_id = 1 WHERE emp_id = 102;
UPDATE employees SET dept_id = 2 WHERE emp_id = 103;
UPDATE employees SET dept_id = 2 WHERE emp_id = 104;
UPDATE employees SET dept_id = 3 WHERE emp_id = 105;

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    e.salary,
    AVG(e.salary) OVER (PARTITION BY e.dept_id) AS dept_avg_salary,
    e.salary - AVG(e.salary) OVER (PARTITION BY e.dept_id) AS salary_difference
FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id;


-- Q10. Count Orders Above Average
SELECT
    COUNT(*) AS orders_above_average
FROM orders
WHERE order_amount > (
    SELECT AVG(order_amount)
    FROM orders
);


-- Q11. Product Sales Contribution
DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    sale_amount INT,
    sale_date DATE
);

INSERT INTO sales VALUES
(1, 101, 2000, '2024-01-01'),
(2, 101, 3000, '2024-01-02'),
(3, 101, 5000, '2024-01-03'),
(4, 102, 4000, '2024-01-01'),
(5, 102, 6000, '2024-01-02');

SELECT
    sale_id,
    product_id,
    sale_amount,
    SUM(sale_amount) OVER (
        PARTITION BY product_id
    ) AS total_product_sales,
    (sale_amount / SUM(sale_amount) OVER (
        PARTITION BY product_id
    )) * 100 AS percentage_contribution
FROM sales;


-- Q12. Students Above Class Average
TRUNCATE TABLE students;

INSERT INTO students VALUES
(1, 'Amit', 'Class A', 95),
(2, 'Riya', 'Class A', 70),
(3, 'Suresh', 'Class A', 85),
(4, 'Kiran', 'Class B', 90),
(5, 'Neha', 'Class B', 60),
(6, 'Arjun', 'Class B', 80);

SELECT
    s.student_id,
    s.student_name,
    s.class,
    s.total_score
FROM students s
JOIN (
    SELECT class, AVG(total_score) AS avg_score
    FROM students
    GROUP BY class
) class_avg
    ON s.class = class_avg.class
WHERE s.total_score > class_avg.avg_score;


-- Q13. Employees Above Department Average
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM employees e
JOIN (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) dept_avg
    ON e.dept_id = dept_avg.dept_id
WHERE e.salary > dept_avg.avg_salary;


-- Q14. Replace NULL Prices With Average Price
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products VALUES
(1, 'Laptop', 50000),
(2, 'Mobile', NULL),
(3, 'Tablet', 30000),
(4, 'Headphones', NULL),
(5, 'Monitor', 20000);

SELECT AVG(price) AS avg_price
FROM products;

SELECT
    product_id,
    product_name,
    IFNULL(price, (SELECT AVG(price) FROM products)) AS updated_price
FROM products;


-- Q15. Cumulative Product Sales & Performance
SELECT
    sale_id,
    product_id,
    sale_amount,
    sale_date,
    SUM(sale_amount) OVER (
        PARTITION BY product_id
        ORDER BY sale_date
    ) AS cumulative_sales,
    CASE
        WHEN SUM(sale_amount) OVER (
            PARTITION BY product_id
            ORDER BY sale_date
        ) < 5000 THEN 'Underperforming'
        WHEN SUM(sale_amount) OVER (
            PARTITION BY product_id
            ORDER BY sale_date
        ) BETWEEN 5000 AND 10000 THEN 'Meeting Expectations'
        ELSE 'Exceeding Expectations'
    END AS sales_performance
FROM sales;
