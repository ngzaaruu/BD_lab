
-- Drop tables if they already exist
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;

-- Create tables
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

-- Insert sample data
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
 (1, 'John Smith', 101, 50000),
 (2, 'Jane Doe', 102, 60000),
 (3, 'Mike Johnson', 101, 55000),
 (4, 'Sarah Williams', 103, 65000),
 (5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
 (101, 'IT', 'Building A'),
 (102, 'HR', 'Building B'),
 (103, 'Finance', 'Building C'),
 (104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
 (1, 'Website Redesign', 101, 100000),
 (2, 'Employee Training', 102, 50000),
 (3, 'Budget Analysis', 103, 75000),
 (4, 'Cloud Migration', 101, 150000),
 (5, 'AI Research', NULL, 200000);

-- Part 2: CROSS JOIN Exercises

-- Exercise 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;
-- Result = 5 employees × 4 departments = 20 rows

-- Exercise 2.2(a): CROSS JOIN using comma notation
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- Exercise 2.2(b): CROSS JOIN using INNER JOIN with TRUE condition
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;

-- Exercise 2.3: Practical CROSS JOIN (Employee × Project)
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;
-- Useful for availability matrix

-- Part 3: INNER JOIN Exercises

-- Exercise 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- Tom Brown not included because dept_id is NULL

-- Exercise 3.2: INNER JOIN using USING clause
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- USING hides duplicate join column

-- Exercise 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- NATURAL joins automatically on columns with same name

-- Exercise 3.4: Multi-table INNER JOIN
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

-- Part 4: LEFT JOIN Exercises

-- Exercise 4.1: Basic LEFT JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Tom Brown appears with NULL department

-- Exercise 4.2: LEFT JOIN using USING clause
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

-- Exercise 4.3: Find employees without department
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Exercise 4.4: LEFT JOIN with aggregation
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- Part 5: RIGHT JOIN Exercises

-- Exercise 5.1: Basic RIGHT JOIN
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 5.2: Convert to LEFT JOIN (reverse table order)
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id;

-- Exercise 5.3: Departments without employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- Part 6: FULL JOIN Exercises

-- Exercise 6.1: Basic FULL JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- NULL on left = departments without employees
-- NULL on right = employees without departments

-- Exercise 6.2: FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

-- Exercise 6.3: Orphaned records (no match on either side)
SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

-- Part 7: ON vs WHERE Clause

-- Exercise 7.1: Filter in ON clause (LEFT JOIN)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

-- Exercise 7.2: Filter in WHERE clause (LEFT JOIN)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Query 1 keeps all employees, Query 2 excludes non-matching ones

-- Exercise 7.3: ON vs WHERE with INNER JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- For INNER JOIN both queries are identical

-- Part 8: Complex JOIN Scenarios

-- Exercise 8.1: Multiple JOINs with different types
SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Exercise 8.2: Self JOIN (Employee ↔ Manager)
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id IN (1, 2, 4, 5);
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Exercise 8.3: JOIN with Subquery
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;
