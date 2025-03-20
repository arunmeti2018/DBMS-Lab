CREATE DATABASE COLDB;
USE COLDB;

CREATE TABLE STUDENT(
USN VARCHAR (10) PRIMARY KEY,
SNAME VARCHAR (25), 
ADDRESS VARCHAR (25), 
PHONE varchar(20), 
GENDER CHAR (1)); 

CREATE TABLE SEMSEC( 
SSID VARCHAR (5) PRIMARY KEY, 
SEM INT, 
SEC CHAR (1)); 
 
CREATE TABLE CLASS( 
USN VARCHAR (10), 
SSID VARCHAR (5),
PRIMARY KEY (USN, SSID), 
FOREIGN KEY (USN) REFERENCES STUDENT (USN), 
FOREIGN KEY (SSID) REFERENCES SEMSEC (SSID)); 

CREATE TABLE SUBJECT ( 
SUBCODE VARCHAR (8), 
TITLE VARCHAR (20), 
SEM INT, 
CREDITS INT, 
PRIMARY KEY (SUBCODE)); 
 
CREATE TABLE IAMARKS ( 
USN VARCHAR (10), 
SUBCODE VARCHAR (8), 
SSID VARCHAR(5), 
TEST1 INT, 
TEST2 INT, 
TEST3 INT, 
FINALIA INT, 
PRIMARY KEY (USN, SUBCODE, SSID), 
FOREIGN KEY (USN) REFERENCES STUDENT (USN), 
FOREIGN KEY (SUBCODE) REFERENCES SUBJECT (SUBCODE), 
FOREIGN KEY (SSID) REFERENCES SEMSEC (SSID)); 

USE COLDB;

-- Insert records into STUDENT table
INSERT INTO STUDENT (USN, SNAME, ADDRESS, PHONE, GENDER) 
VALUES 
('1CS19CS001', 'John Doe', '123 Main St', '9876543210', 'M'),
('1CS19CS002', 'Alice Smith', '456 Elm St', '8765432109', 'F'),
('1CS19CS003', 'Bob Johnson', '789 Oak St', '7654321098', 'M'),
('1CS19CS004', 'Eve White', '321 Pine St', '6543210987', 'F'),
('1CS19CS005', 'Charlie Brown', '654 Maple St', '5432109876', 'M');

-- Insert records into SEMSEC table
INSERT INTO SEMSEC (SSID, SEM, SEC) 
VALUES 
('S101', 1, 'A'),
('S102', 1, 'B'),
('S103', 2, 'C'),
('S104', 2, 'B'),
('S105', 4, 'A');

-- Insert records into CLASS table
INSERT INTO CLASS (USN, SSID) 
VALUES 
('1CS19CS001', 'S101'),
('1CS19CS002', 'S102'),
('1CS19CS003', 'S103'),
('1CS19CS004', 'S104'),
('1CS19CS005', 'S105');

-- Insert records into SUBJECT table
INSERT INTO SUBJECT (SUBCODE, TITLE, SEM, CREDITS) 
VALUES 
('CS101', 'Introduction to Programming', 1, 3),
('CS102', 'Data Structures', 2, 4),
('CS103', 'Database Systems', 3, 3),
('CS104', 'Operating Systems', 1, 3),
('CS105', 'Computer Networks', 4, 3);

-- Insert records into IAMARKS table
INSERT INTO IAMARKS (USN, SUBCODE, SSID, TEST1, TEST2, TEST3, FINALIA) 
VALUES 
('1CS19CS001', 'CS101', 'S101', 85, 90, 80, 88),
('1CS19CS002', 'CS102', 'S102', 78, 85, 88, 92),
('1CS19CS003', 'CS103', 'S103', 88, 89, 91, 94),
('1CS19CS004', 'CS104', 'S104', 72, 80, 77, 85),
('1CS19CS005', 'CS105', 'S105', 90, 92, 86, 90);



-- 1. List all student details studying in the fourth semester 'C' section
SELECT S.* 
FROM STUDENT S
JOIN CLASS C ON S.USN = C.USN
JOIN SEMSEC SS ON C.SSID = SS.SSID
WHERE SS.Sem = 4 AND SS.Sec = 'A';

-- 2. Compute the total number of male and female students in each semester and section
SELECT SS.Sem, SS.Sec, 
       SUM(CASE WHEN S.Gender = 'M' THEN 1 ELSE 0 END) AS Male_Students,
       SUM(CASE WHEN S.Gender = 'F' THEN 1 ELSE 0 END) AS Female_Students
FROM STUDENT S
JOIN CLASS C ON S.USN = C.USN
JOIN SEMSEC SS ON C.SSID = SS.SSID
GROUP BY SS.Sem, SS.Sec;

-- 3. Create a view of Test1 marks of student USN ‘1BI15CS101’ in all subjects
CREATE VIEW Test1_Marks AS
SELECT I.Subcode, S.Title, I.Test1
FROM IAMARKS I
JOIN SUBJECT S ON I.Subcode = S.Subcode
WHERE I.USN = '1CS19CS001';

-- 4. Calculate the FinalIA (average of the best two test marks) and update the IAMARKS table
SET SQL_SAFE_UPDATES = 0;
UPDATE IAMARKS 
SET FinalIA = (SELECT (Test1 + Test2 + Test3 - LEAST(Test1, Test2, Test3)) / 3);
SET SQL_SAFE_UPDATES = 1;

-- 5. Categorize students based on the FinalIA score in 8th semester A, B, and C section
SELECT S.USN, S.SName, SS.Sem, SS.Sec, I.FinalIA,
       CASE 
           WHEN I.FinalIA BETWEEN 50 AND 70 THEN 'Outstanding'
           WHEN I.FinalIA BETWEEN 40 AND 50 THEN 'Average'
           ELSE 'Weak'
       END AS CAT
FROM STUDENT S
JOIN CLASS C ON S.USN = C.USN
JOIN SEMSEC SS ON C.SSID = SS.SSID
JOIN IAMARKS I ON S.USN = I.USN
WHERE SS.Sem = 4 AND SS.Sec IN ('A', 'B', 'C');
