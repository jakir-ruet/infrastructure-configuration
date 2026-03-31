-- 1️⃣ Create Database
CREATE DATABASE IF NOT EXISTS transactionsdb;

-- 2️⃣ Create User
CREATE USER IF NOT EXISTS 'jakir'@'localhost' IDENTIFIED BY 'Sql@054003';

-- 3️⃣ Grant Privileges
GRANT ALL PRIVILEGES ON transactionsdb.* TO 'jakir'@'localhost';
FLUSH PRIVILEGES;

-- 4️⃣ Use the database
USE transactionsdb;

-- 5️⃣ Create Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    amount DECIMAL(10,2) NOT NULL,
    description VARCHAR(255) NOT NULL
);

-- 6️⃣ Insert Sample Data
INSERT INTO transactions (amount, description) VALUES
(100.00, 'Groceries'),
(250.00, 'Electricity Bill'),
(150.00, 'Internet Bill'),
(500.00, 'Rent'),
(75.00, 'Transport'),
(200.00, 'Dining Out');
