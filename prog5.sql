-- Create the database
CREATE DATABASE CompanyDatabase;

-- Use the newly created database
USE CompanyDatabase;

-- Create Tables
CREATE TABLE EMPLOYEE (
    SSN VARCHAR(9) PRIMARY KEY, 
    Name VARCHAR(50), 
    Address VARCHAR(100), 
    Sex CHAR(1), 
    Salary DECIMAL(10,2), 
    SuperSSN VARCHAR(9), 
    DNo INT
);

CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY, 
    DName VARCHAR(50), 
    MgrSSN VARCHAR(9), 
    MgrStartDate DATE
);

CREATE TABLE DLOCATION (
    DNo INT, 
    DLoc VARCHAR(100), 
    PRIMARY KEY (DNo, DLoc), 
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY, 
    PName VARCHAR(50), 
    PLocation VARCHAR(100), 
    DNo INT, 
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

CREATE TABLE WORKS_ON (
    SSN VARCHAR(9), 
    PNo INT, 
    Hours DECIMAL(5,2), 
    PRIMARY KEY (SSN, PNo), 
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN), 
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)
);

-- Insert 5 sample tuples into each table

-- Insert into EMPLOYEE
INSERT INTO EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo) VALUES 
('123456789', 'John Scott', '123 Elm St', 'M', 500000, NULL, 1),
('234567890', 'Alice Brown', '456 Oak St', 'F', 700000, '123456789', 1),
('345678901', 'Bob Smith', '789 Pine St', 'M', 600000, '234567890', 2),
('456789012', 'Charlie Davis', '101 Maple St', 'M', 800000, '234567890', 2),
('567890123', 'David Clark', '202 Birch St', 'M', 650000, NULL, 3);

-- Insert into DEPARTMENT
INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) VALUES 
(1, 'Accounts', '123456789', '2021-01-01'),
(2, 'Engineering', '234567890', '2020-06-15'),
(3, 'Marketing', '345678901', '2022-05-20'),
(4, 'HR', '456789012', '2021-09-10'),
(5, 'IT', '567890123', '2023-02-05');

-- Insert into DLOCATION
INSERT INTO DLOCATION (DNo, DLoc) VALUES 
(1, 'New York'),
(2, 'San Francisco'),
(3, 'Los Angeles'),
(4, 'Chicago'),
(5, 'Dallas');

-- Insert into PROJECT
INSERT INTO PROJECT (PNo, PName, PLocation, DNo) VALUES 
(101, 'IoT', 'New York', 1),
(102, 'Cloud Computing', 'San Francisco', 2),
(103, 'AI Research', 'Los Angeles', 3),
(104, 'Blockchain', 'Chicago', 4),
(105, 'Data Science', 'Dallas', 5);

-- Insert into WORKS_ON
INSERT INTO WORKS_ON (SSN, PNo, Hours) VALUES 
('123456789', 101, 40),
('234567890', 102, 35),
('345678901', 103, 30),
('456789012', 104, 50),
('567890123', 105, 45);

-- Perform the Queries

-- 1. Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’
SELECT DISTINCT P.PNo
FROM PROJECT P
JOIN WORKS_ON W ON P.PNo = W.PNo
JOIN EMPLOYEE E ON W.SSN = E.SSN
WHERE E.Name LIKE '%Scott%' 
   OR P.DNo IN (
       SELECT DNo 
       FROM DEPARTMENT 
       WHERE MgrSSN IN (SELECT SSN FROM EMPLOYEE WHERE Name LIKE '%Scott%')
   );

-- 2. Show the resulting salaries if every employee working on the 'IoT' project is given a 10 percent raise.
SELECT E.Name, E.Salary * 1.10 AS NewSalary
FROM EMPLOYEE E
JOIN WORKS_ON W ON E.SSN = W.SSN
JOIN PROJECT P ON W.PNo = P.PNo
WHERE P.PName = 'IoT';

-- 3. Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the maximum salary, the minimum salary, and the average salary in this department.
SELECT 
    SUM(E.Salary) AS TotalSalary,
    MAX(E.Salary) AS MaxSalary,
    MIN(E.Salary) AS MinSalary,
    AVG(E.Salary) AS AvgSalary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
WHERE D.DName = 'Accounts';

-- 4. Retrieve the name of each employee who works on all the projects controlled by department number 5 (use NOT EXISTS operator).
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo
    FROM PROJECT P
    WHERE P.DNo = 5
    AND NOT EXISTS (
        SELECT W.PNo
        FROM WORKS_ON W
        WHERE W.SSN = E.SSN AND W.PNo = P.PNo
    )
);

-- 5. For each department that has more than five employees, retrieve the department number and the number of its employees who are making more than Rs.6,00,000.
SELECT D.DNo, COUNT(E.SSN) AS HighEarners
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.DNo = E.DNo
WHERE E.Salary > 600000
GROUP BY D.DNo
HAVING COUNT(E.SSN) > 5;
