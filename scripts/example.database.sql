-- Create databases
CREATE DATABASE api;
CREATE DATABASE metabase;

--Create users
CREATE USER 'api'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
CREATE USER 'metabase'@'%' IDENTIFIED WITH mysql_native_password BY 'password';

--Grant privileges
GRANT ALL PRIVILEGES ON api.* TO 'api'@'%';
GRANT ALL PRIVILEGES ON metabase.* TO 'metabase'@'%';

--Flush privileges
FLUSH PRIVILEGES;

-- Use the api database
USE api;

-- Create the jobs table
CREATE TABLE jobs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  job VARCHAR(255) NOT NULL
);

-- Create the department table
CREATE TABLE department (
  id INT AUTO_INCREMENT PRIMARY KEY,
  department VARCHAR(255) NOT NULL
);

-- Create the employees table
CREATE TABLE employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  datetime DATETIME NOT NULL,
  department_id INT NOT NULL,
  job_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES department (id),
  FOREIGN KEY (job_id) REFERENCES jobs (id)
);
