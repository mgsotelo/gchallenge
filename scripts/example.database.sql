-- Drop databases if they exist
DROP DATABASE IF EXISTS api;
DROP DATABASE IF EXISTS metabase;

-- Create databases
CREATE DATABASE api;
CREATE DATABASE metabase;

-- Create users
CREATE USER 'api'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
CREATE USER 'metabase'@'%' IDENTIFIED WITH mysql_native_password BY 'password';

-- Grant privileges
GRANT ALL PRIVILEGES ON api.* TO 'api'@'%';
GRANT ALL PRIVILEGES ON metabase.* TO 'metabase'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Use the api database (Note: MySQL does not support 'USE' in scripts, so we need to change the default database separately.)
USE api;

-- Drop tables if they exist in the api database
DROP TABLE IF EXISTS `api`.`jobs`;
DROP TABLE IF EXISTS `api`.`department`;
DROP TABLE IF EXISTS `api`.`employees`;

-- Create the jobs table in the api database
CREATE TABLE `api`.`jobs` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  job VARCHAR(255) NOT NULL
);

-- Create the department table in the api database
CREATE TABLE `api`.`department` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  department VARCHAR(255) NOT NULL
);

-- Create the employees table in the api database
CREATE TABLE `api`.`employees` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  datetime DATETIME NOT NULL,
  department_id INT NOT NULL,
  job_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES `api`.`department` (id),
  FOREIGN KEY (job_id) REFERENCES `api`.`jobs` (id)
);
