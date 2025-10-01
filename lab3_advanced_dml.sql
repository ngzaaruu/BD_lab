/* part A */
DROP DATABASE IF EXISTS advanced_lab;
CREATE DATABASE advanced_lab;


DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INT DEFAULT 40000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INT,
    manager_id INT
);

DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

/* part B */
INSERT INTO employees (first_name, last_name, department)
VALUES ('Aru', 'Ngz', 'HR');

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Rau', 'Ord', 'Finance', DEFAULT, DEFAULT);

INSERT INTO employees (first_name, last_name, department,  salary,  hire_date)
VALUES ('Bulat', 'Ass', 'IT', 50000 * 1.1, CURRENT_DATE);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 200000, 1),
    ('HR', 150000, 2),
    ('Finance', 300000, 3);

DROP TABLE IF EXISTS temp_employees;
CREATE TEMPORARY TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';


/* part C */
UPDATE employees SET salary = salary * 1.10 WHERE status = 'Active';

UPDATE employees SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees SET department = CASE
WHEN salary > 80000 THEN 'Management'
WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
ELSE 'Junior' END WHERE status = 'Active';;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = sub.avg_salary * 1.2
FROM (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) sub
WHERE d.dept_name = sub.department;

UPDATE employees SET salary = salary * 1.15, status = 'Promoted'
WHERE department = 'Sales';

-- part D --

DELETE FROM employees WHERE status = 'Terminated';

DELETE FROM employees WHERE salary < 40000 AND hire_date > '2023-01-01' AND  department IS NULL;

DELETE FROM departments WHERE dept_id NOT IN (SELECT DISTINCT d.dept_id FROM departments d JOIN employees e ON e.department = d.dept_name
WHERE e.department IS NOT NULL);

DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

-- part E

INSERT INTO employees (first_name, last_name, salary, department, hire_date)
VALUES ('Null', 'Tester', NULL, NULL, CURRENT_DATE);

UPDATE employees
SET department = 'Unassigned' WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- part E

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Return', 'Example', 'IT', 60000, CURRENT_DATE)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- part G


INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Unique', 'Person', 'IT', 50000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Unique' AND last_name = 'Person'
);


UPDATE employees e
SET salary = salary * CASE
    WHEN d.budget > 100000 THEN 1.10
    ELSE 1.05
END
FROM departments d
WHERE e.department = d.dept_name;


INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
('Bulk1', 'Emp', 'Sales', 40000, CURRENT_DATE),
('Bulk2', 'Emp', 'Sales', 42000, CURRENT_DATE),
('Bulk3', 'Emp', 'Sales', 45000, CURRENT_DATE),
('Bulk4', 'Emp', 'Sales', 47000, CURRENT_DATE),
('Bulk5', 'Emp', 'Sales', 49000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Emp' AND first_name LIKE 'Bulk%';


CREATE TABLE IF NOT EXISTS employee_archive AS
TABLE employees WITH NO DATA;

INSERT INTO employee_archive
SELECT * FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';


UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (
          SELECT dept_name FROM departments d WHERE d.dept_id = p.dept_id
      )
  ) > 3;


