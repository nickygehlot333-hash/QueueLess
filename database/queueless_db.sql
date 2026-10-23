
CREATE DATABASE IF NOT EXISTS queueless_db;

USE queueless_db;

-- 1. Store student and staff accounts
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('STUDENT', 'STAFF', 'ADMIN') NOT NULL
);

-- 2. Store departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_code VARCHAR(5) NOT NULL UNIQUE,
    department_name VARCHAR(100) NOT NULL
);

INSERT INTO departments (department_code, department_name)
VALUES
('AC', 'Accounts'),
('EX', 'Examination Cell'),
('AD', 'Administration'),
('SC', 'Scholarship'),
('CE', 'Certificate Section'),
('HO', 'Hostel Office');

-- 3. Store queue tokens
CREATE TABLE tokens (
    token_id INT PRIMARY KEY AUTO_INCREMENT,
    token_number VARCHAR(20) NOT NULL,
    student_id INT NOT NULL,
    department_id INT NOT NULL,
    status ENUM(
        'WAITING',
        'CALLED',
        'SERVING',
        'COMPLETED',
        'CANCELLED',
        'SKIPPED'
    ) NOT NULL DEFAULT 'WAITING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(user_id),
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- 4. Store token status changes
CREATE TABLE token_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    token_id INT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (token_id) REFERENCES tokens(token_id)
);
