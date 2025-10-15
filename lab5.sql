-- Task 1.1: Basic CHECK Constraint
DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);
-- Task 1.2: Named CHECK Constraint
DROP TABLE if exists products_catalog CASCADE;
CREATE TABLE products_catalog (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);
-- Task 1.3: Multiple Column CHECK
DROP TABLE if exists bookings CASCADE;
CREATE TABLE bookings (
    booking_id INTEGER PRIMARY KEY,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests INTEGER NOT NULL CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Testing CHECK Constraints

INSERT INTO employees VALUES (1, 'Aru', 'Ngz', 18, 1000000);
INSERT INTO employees VALUES (2, 'Aruzhan', 'Ngzb', 19, 2000000);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1000, 800);
INSERT INTO products_catalog VALUES (2, 'Computer', 10000, 1200);

INSERT INTO bookings VALUES (1, '2025-10-10', '2025-10-15', 2);
INSERT INTO bookings VALUES (2, '2025-12-01', '2025-12-05', 4);

-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL
INSERT INTO customers VALUES (1, 'alice@example.com', '1234567890', '2025-10-14');
INSERT INTO customers VALUES (2, 'bob@example.com', NULL, '2025-10-13');

INSERT INTO inventory VALUES (1, 'Laptop', 10, 999.99, '2025-10-14 10:00:00');
INSERT INTO inventory VALUES (2, 'Mouse', 50, 19.99, '2025-10-14 11:00:00');

-- Task 3.1: Single Column UNIQUE
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users VALUES (1, 'alex', 'alex@gmail.com', NOW());
INSERT INTO users VALUES (2, 'maria', 'maria@gmail.com', NOW());

--Task 3.2: Multi-Column UNIQUE
DROP TABLE IF EXISTS course_enrollments;
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments VALUES (1, 1001, 'CS101', 'Fall 2025');
INSERT INTO course_enrollments VALUES (2, 1001, 'CS102', 'Fall 2025');
INSERT INTO course_enrollments VALUES (3, 1002, 'CS101', 'Fall 2025')

-- Task 3.3: Named UNIQUE Constraints

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

-- Task 4.1 — Single Column PRIMARY KEY
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1, 'Human Resources', 'New York');
INSERT INTO departments VALUES (2, 'Finance', 'London');
INSERT INTO departments VALUES (3, 'IT', 'Berlin');

-- Task 4.2 — Composite (составной) PRIMARY KEY
DROP TABLE IF EXISTS student_courses;

CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (101, 1, '2025-09-01', 'A');
INSERT INTO student_courses VALUES (101, 2, '2025-09-01', 'B');
INSERT INTO student_courses VALUES (102, 1, '2025-09-01', 'A');

--Part 5: FOREIGN KEY Constraints
DROP TABLE IF EXISTS employees_dept;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1, 'HR', 'New York');
INSERT INTO departments VALUES (2, 'Finance', 'London');
INSERT INTO departments VALUES (3, 'IT', 'Berlin');

CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Alice', 1, '2023-05-10');
INSERT INTO employees_dept VALUES (2, 'Bob', 2, '2022-11-01');

DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'George Orwell', 'UK');
INSERT INTO authors VALUES (2, 'J.K. Rowling', 'UK');
INSERT INTO publishers VALUES (1, 'Penguin', 'London');
INSERT INTO publishers VALUES (2, 'Bloomsbury', 'Oxford');
INSERT INTO books VALUES (1, '1984', 1, 1, 1949, '9780451524935');
INSERT INTO books VALUES (2, 'Harry Potter', 2, 2, 1997, '9780747532699');

-- Task 5.3
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products_fk;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Books');
INSERT INTO products_fk VALUES (1, 'Laptop', 1), (2, 'Novel', 2);
INSERT INTO orders VALUES (1, '2025-10-01'), (2, '2025-10-10');
INSERT INTO order_items VALUES (1, 1, 1, 2), (2, 2, 2, 1);

-- PART 6: E-COMMERCE SCHEMA

DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers (name, email, phone, registration_date) VALUES
('Alice Johnson', 'alice@example.com', '87001112233', '2025-10-01'),
('Bob Smith', 'bob@example.com', '87005556677', '2025-09-15'),
('Charlie Brown', 'charlie@example.com', '87009998877', '2025-08-20'),
('Diana Prince', 'diana@example.com', '87001234567', '2025-10-05'),
('Ethan Hunt', 'ethan@example.com', '87007778899', '2025-07-12');

INSERT INTO products (name, description, price, stock_quantity) VALUES
('Laptop', 'High-performance laptop', 1200.00, 15),
('Smartphone', 'Latest model smartphone', 800.00, 30),
('Headphones', 'Noise-cancelling headphones', 150.00, 50),
('Monitor', '27-inch 4K monitor', 300.00, 20),
('Mouse', 'Wireless ergonomic mouse', 50.00, 100);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2025-10-10', 1350.00, 'pending'),
(2, '2025-10-09', 800.00, 'processing'),
(3, '2025-10-08', 450.00, 'shipped'),
(4, '2025-10-07', 50.00, 'delivered'),
(5, '2025-10-06', 1200.00, 'cancelled');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1200.00),
(1, 5, 3, 50.00),
(2, 2, 1, 800.00),
(3, 3, 3, 150.00),
(4, 5, 1, 50.00);