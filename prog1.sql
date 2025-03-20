-- Create Database
CREATE DATABASE IF NOT EXISTS LibraryDatabase;
USE LibraryDatabase;

-- Create Tables
CREATE TABLE BOOK (
    Book_id INT PRIMARY KEY,
    Title VARCHAR(255),
    Publisher_Name VARCHAR(100),
    Pub_Year INT
);

CREATE TABLE BOOK_AUTHORS (
    Book_id INT,
    Author_Name VARCHAR(100),
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id) ON DELETE CASCADE
);

CREATE TABLE PUBLISHER (
    Name VARCHAR(100) PRIMARY KEY,
    Address VARCHAR(255),
    Phone VARCHAR(20)
);

CREATE TABLE BOOK_COPIES (
    Book_id INT,
    Branch_id INT,
    No_of_Copies INT,
    PRIMARY KEY (Book_id, Branch_id),
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id) ON DELETE CASCADE
);

CREATE TABLE BOOK_LENDING (
    Book_id INT,
    Branch_id INT,
    Card_No INT,
    Date_Out DATE,
    Due_Date DATE,
    FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id) ON DELETE CASCADE
);

CREATE TABLE LIBRARY_BRANCH (
    Branch_id INT PRIMARY KEY,
    Branch_Name VARCHAR(100),
    Address VARCHAR(255)
);

-- Insert Data
INSERT INTO BOOK VALUES
(1, 'The Great Gatsby', 'Scribner', 1925),
(2, 'To Kill a Mockingbird', 'J.B. Lippincott & Co.', 1960),
(3, '1984', 'Secker & Warburg', 1949),
(4, 'Moby-Dick', 'Harper & Brothers', 1851),
(5, 'Pride and Prejudice', 'T. Egerton', 1813);

INSERT INTO BOOK_AUTHORS VALUES
(1, 'F. Scott Fitzgerald'),
(2, 'Harper Lee'),
(3, 'George Orwell'),
(4, 'Herman Melville'),
(5, 'Jane Austen');

INSERT INTO PUBLISHER VALUES
('Scribner', 'New York, USA', '1234567890'),
('J.B. Lippincott & Co.', 'Philadelphia, USA', '0987654321'),
('Secker & Warburg', 'London, UK', '1112223334'),
('Harper & Brothers', 'New York, USA', '5556667778'),
('T. Egerton', 'London, UK', '9998887776');

INSERT INTO LIBRARY_BRANCH VALUES
(1, 'Central Library', 'Main St, City Center'),
(2, 'East Branch', 'East Ave, Suburb'),
(3, 'West Branch', 'West Rd, Downtown'),
(4, 'North Branch', 'North St, Uptown'),
(5, 'South Branch', 'South Blvd, Old Town');

INSERT INTO BOOK_COPIES VALUES
(1, 1, 5),
(2, 2, 3),
(3, 3, 4),
(4, 4, 2),
(5, 5, 6);

INSERT INTO BOOK_LENDING VALUES
(1, 1, 101, '2023-01-10', '2023-01-20'),
(2, 2, 102, '2023-02-15', '2023-02-25'),
(3, 3, 103, '2023-03-20', '2023-03-30'),
(4, 4, 104, '2023-04-05', '2023-04-15'),
(5, 5, 105, '2023-05-12', '2023-05-22');

-- Queries
-- 1. Retrieve details of all books
SELECT B.Book_id, B.Title, B.Publisher_Name, P.Address, GROUP_CONCAT(A.Author_Name) AS Authors, 
       SUM(C.No_of_Copies) AS Total_Copies
FROM BOOK B
JOIN PUBLISHER P ON B.Publisher_Name = P.Name
JOIN BOOK_AUTHORS A ON B.Book_id = A.Book_id
JOIN BOOK_COPIES C ON B.Book_id = C.Book_id
GROUP BY B.Book_id;

-- 2. Borrowers who borrowed more than 3 books between Jan 2017 - Jun 2017
SELECT Card_No, COUNT(Book_id) AS Books_Borrowed
FROM BOOK_LENDING
WHERE Date_Out BETWEEN '2017-01-01' AND '2017-06-30'
GROUP BY Card_No
HAVING COUNT(Book_id) > 3;

-- 3. Delete a book and update references
DELETE FROM BOOK WHERE Book_id = 3;

-- 4. Partition the BOOK table by publication year
ALTER TABLE BOOK PARTITION BY RANGE (Pub_Year) (
    PARTITION p1 VALUES LESS THAN (1900),
    PARTITION p2 VALUES LESS THAN (1950),
    PARTITION p3 VALUES LESS THAN (2000),
    PARTITION p4 VALUES LESS THAN MAXVALUE
);

-- Check partitioned data
SELECT * FROM BOOK PARTITION (p3);

-- 5. Create a view of available books
CREATE VIEW Available_Books AS
SELECT B.Book_id, B.Title, SUM(C.No_of_Copies) AS Total_Copies
FROM BOOK B
JOIN BOOK_COPIES C ON B.Book_id = C.Book_id
GROUP BY B.Book_id;

SELECT * FROM Available_Books;
