-- 1. Create Database
CREATE DATABASE MovieDatabase;
USE MovieDatabase;

-- 2. Create Tables

-- ACTOR Table
CREATE TABLE ACTOR (
    Act_id INT PRIMARY KEY AUTO_INCREMENT,
    Act_Name VARCHAR(100) NOT NULL,
    Act_Gender VARCHAR(10) NOT NULL
);

-- DIRECTOR Table
CREATE TABLE DIRECTOR (
    Dir_id INT PRIMARY KEY AUTO_INCREMENT,
    Dir_Name VARCHAR(100) NOT NULL,
    Dir_Phone VARCHAR(15)
);

-- MOVIES Table
CREATE TABLE MOVIES (
    Mov_id INT PRIMARY KEY AUTO_INCREMENT,
    Mov_Title VARCHAR(200) NOT NULL,
    Mov_Year INT NOT NULL,
    Mov_Lang VARCHAR(50),
    Dir_id INT,
    FOREIGN KEY (Dir_id) REFERENCES DIRECTOR(Dir_id) ON DELETE CASCADE
);

-- MOVIE_CAST Table
CREATE TABLE MOVIE_CAST (
    Act_id INT,
    Mov_id INT,
    Role VARCHAR(100),
    PRIMARY KEY (Act_id, Mov_id),
    FOREIGN KEY (Act_id) REFERENCES ACTOR(Act_id) ON DELETE CASCADE,
    FOREIGN KEY (Mov_id) REFERENCES MOVIES(Mov_id) ON DELETE CASCADE
);

-- RATING Table
CREATE TABLE RATING (
    Mov_id INT,
    Rev_Stars INT CHECK (Rev_Stars BETWEEN 1 AND 5),
    PRIMARY KEY (Mov_id),
    FOREIGN KEY (Mov_id) REFERENCES MOVIES(Mov_id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Insert into ACTOR
INSERT INTO ACTOR (Act_Name, Act_Gender) VALUES
('Leonardo DiCaprio', 'Male'),
('Scarlett Johansson', 'Female'),
('Robert Downey Jr.', 'Male'),
('Meryl Streep', 'Female'),
('Tom Hanks', 'Male');

-- Insert into DIRECTOR
INSERT INTO DIRECTOR (Dir_Name, Dir_Phone) VALUES
('Alfred Hitchcock', '1234567890'),
('Steven Spielberg', '2345678901'),
('Christopher Nolan', '3456789012'),
('Martin Scorsese', '4567890123'),
('Quentin Tarantino', '5678901234');

-- Insert into MOVIES
INSERT INTO MOVIES (Mov_Title, Mov_Year, Mov_Lang, Dir_id) VALUES
('Psycho', 1960, 'English', 1),
('Jaws', 1975, 'English', 2),
('Inception', 2010, 'English', 3),
('The Irishman', 2019, 'English', 4),
('Pulp Fiction', 1994, 'English', 5);

-- Insert into MOVIE_CAST
INSERT INTO MOVIE_CAST (Act_id, Mov_id, Role) VALUES
(1, 3, 'Dom Cobb'),
(2, 5, 'Mia Wallace'),
(3, 2, 'Matt Hooper'),
(4, 4, 'Peggy Sheeran'),
(5, 1, 'Norman Bates');

-- Insert into RATING
INSERT INTO RATING (Mov_id, Rev_Stars) VALUES
(1, 5),
(2, 4),
(3, 5),
(4, 3),
(5, 4);

-- 4. Queries

-- 1. List the titles of all movies directed by ‘Hitchcock’.
SELECT Mov_Title 
FROM MOVIES 
JOIN DIRECTOR ON MOVIES.Dir_id = DIRECTOR.Dir_id
WHERE Dir_Name = 'Alfred Hitchcock';

-- 2. Find the movie names where one or more actors acted in two or more movies.
SELECT MOVIES.Mov_Title 
FROM MOVIES
JOIN MOVIE_CAST ON MOVIES.Mov_id = MOVIE_CAST.Mov_id
WHERE Act_id IN (
    SELECT Act_id FROM MOVIE_CAST GROUP BY Act_id HAVING COUNT(DISTINCT Mov_id) >= 2
);

-- 3. List all actors who acted in a movie before 2000 and also in a movie after 2015 (use JOIN operation).
SELECT DISTINCT ACTOR.Act_Name 
FROM ACTOR
JOIN MOVIE_CAST ON ACTOR.Act_id = MOVIE_CAST.Act_id
JOIN MOVIES M1 ON MOVIE_CAST.Mov_id = M1.Mov_id
JOIN MOVIES M2 ON MOVIE_CAST.Mov_id = M2.Mov_id
WHERE M1.Mov_Year < 2000 AND M2.Mov_Year > 2015;

-- 4. Find the title of movies and number of stars for each movie that has at least one rating 
-- and find the highest number of stars that movie received. Sort the result by movie title.
SELECT MOVIES.Mov_Title, RATING.Rev_Stars
FROM MOVIES
JOIN RATING ON MOVIES.Mov_id = RATING.Mov_id
ORDER BY MOVIES.Mov_Title;

-- 5. Update rating of all movies directed by ‘Steven Spielberg’ to 5.
SET SQL_SAFE_UPDATES = 0;
UPDATE RATING
JOIN MOVIES ON RATING.Mov_id = MOVIES.Mov_id
JOIN DIRECTOR ON MOVIES.Dir_id = DIRECTOR.Dir_id
SET RATING.Rev_Stars = 5
WHERE DIRECTOR.Dir_Name = 'Steven Spielberg';
SET SQL_SAFE_UPDATES = 1;

