-- Step 1: Create the Database
CREATE DATABASE OrderDatabase;
USE OrderDatabase;

-- Step 2: Create Tables
CREATE TABLE SALESMAN (
    Salesman_id INT PRIMARY KEY,
    Name VARCHAR(100),
    City VARCHAR(50),
    Commission DECIMAL(5,2)
);

CREATE TABLE CUSTOMER (
    Customer_id INT PRIMARY KEY,
    Cust_Name VARCHAR(100),
    City VARCHAR(50),
    Grade INT,
    Salesman_id INT,
    FOREIGN KEY (Salesman_id) REFERENCES SALESMAN(Salesman_id) ON DELETE CASCADE
);

CREATE TABLE ORDERS (
    Ord_No INT PRIMARY KEY,
    Purchase_Amt DECIMAL(10,2),
    Ord_Date DATE,
    Customer_id INT,
    Salesman_id INT,
    FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(Customer_id) ON DELETE CASCADE,
    FOREIGN KEY (Salesman_id) REFERENCES SALESMAN(Salesman_id) ON DELETE CASCADE
);

-- Step 3: Insert Sample Data
INSERT INTO SALESMAN VALUES 
(1001, 'Amit', 'Bangalore', 0.15),
(1002, 'Rohit', 'Delhi', 0.12),
(1003, 'Priya', 'Mumbai', 0.10),
(1004, 'John', 'Bangalore', 0.18),
(1005, 'Ravi', 'Chennai', 0.14);

INSERT INTO CUSTOMER VALUES 
(2001, 'Akash', 'Bangalore', 2, 1001),
(2002, 'Suresh', 'Delhi', 3, 1002),
(2003, 'Neha', 'Mumbai', 4, 1003),
(2004, 'Kiran', 'Bangalore', 5, 1004),
(2005, 'Manoj', 'Chennai', 3, 1005);

INSERT INTO ORDERS VALUES 
(3001, 5000.00, '2024-02-15', 2001, 1001),
(3002, 7500.00, '2024-02-16', 2002, 1002),
(3003, 12000.00, '2024-02-17', 2003, 1003),
(3004, 8000.00, '2024-02-18', 2004, 1004),
(3005, 6500.00, '2024-02-19', 2005, 1005);

-- 1. Count customers with grades above Bangalore’s average
SELECT COUNT(*) AS High_Grade_Customers 
FROM CUSTOMER 
WHERE Grade > (SELECT AVG(Grade) FROM CUSTOMER WHERE City = 'Bangalore');

-- 2. Find salesmen who had more than one customer
SELECT S.Name, S.Salesman_id, COUNT(C.Customer_id) AS Total_Customers
FROM SALESMAN S
JOIN CUSTOMER C ON S.Salesman_id = C.Salesman_id
GROUP BY S.Salesman_id
HAVING COUNT(C.Customer_id) > 1;

-- 3. List all salesmen and indicate those who have and don’t have customers in their cities
(SELECT S.Name, S.City, 'Has Customer' AS Status 
FROM SALESMAN S 
JOIN CUSTOMER C ON S.City = C.City)
UNION
(SELECT S.Name, S.City, 'No Customer' AS Status 
FROM SALESMAN S 
WHERE S.City NOT IN (SELECT City FROM CUSTOMER));

-- 4. Create a view to find the salesman who has the customer with the highest order of a day
CREATE VIEW TopSalesman AS
SELECT O.Ord_Date, S.Name AS Salesman_Name, C.Cust_Name AS Customer_Name, O.Purchase_Amt
FROM ORDERS O
JOIN CUSTOMER C ON O.Customer_id = C.Customer_id
JOIN SALESMAN S ON O.Salesman_id = S.Salesman_id
WHERE O.Purchase_Amt = (SELECT MAX(Purchase_Amt) FROM ORDERS WHERE Ord_Date = O.Ord_Date);

-- 5. Delete salesman with ID 1000 and all his orders
DELETE FROM SALESMAN WHERE Salesman_id = 1000;
