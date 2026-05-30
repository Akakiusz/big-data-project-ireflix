
-- ============================================================
-- SECTION 1: DATABASE SETUP
-- Create the command to work on the new version of Irexlix database
-- DROP ensures we start clean on every re-run
-- ============================================================
-DROP DATABASE IF EXISTS Ireflix; -- this command is locked for safety reasons - to avoid accidental deletion of the database
-CREATE DATABASE Ireflix;
USE Ireflix;

-- ============================================================
-- SECTION 2: TABLE CREATION
-- Create tables with appropriate data types, constraints, and relationships
-- Users table - for storing login info
-- Password is stored as VARCHAR(15) for simplicity, but in real applications, it should be hashed and salted for security
-- Primary key (PK) is user_id, auto-incremented for unique identification
-- ALTER TABLE command is used to add releaseYear column to Movies and Series tables after initial creation to avoid issues with CSV import and to maintain data integrity
-- ============================================================

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    userName VARCHAR(35) NOT NULL,
    firstName VARCHAR(35) NOT NULL,
    surName VARCHAR(35) NOT NULL,
    password VARCHAR(15) NOT NULL
);

-- TABLE: Actors (no duplicated surnames)
CREATE TABLE Actors (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    actorFirstName VARCHAR(35) NOT NULL,
    actorSurName VARCHAR(35) NOT NULL UNIQUE,
    nationality VARCHAR(50)
);
-- TABLE: Directors (no duplicated surnames)
CREATE TABLE Directors (
    director_id INT PRIMARY KEY AUTO_INCREMENT,
    directorFirstName VARCHAR(35) NOT NULL,
    directorSurName VARCHAR(35) NOT NULL UNIQUE,
    nationality VARCHAR(50)
);  
-- TABLE: Movies - this is the main table
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    movieName VARCHAR(35) NOT NULL,
    genre VARCHAR(20),
    duration INT NOT NULL CHECK (duration <=180),
    rating DECIMAL(2, 1) CHECK (rating BETWEEN 1 AND 5),
    actorFirstName VARCHAR(35) NOT NULL,
    actorSurName VARCHAR(35) NOT NULL,
    actor_id INT, FOREIGN KEY (actor_id) REFERENCES Actors(actor_id),
    director_id INT, FOREIGN KEY (director_id) REFERENCES Directors(director_id)
);

ALTER TABLE Movies ADD COLUMN releaseYear INT; -- Adding releaseYear column to Movies table after initial creation (to avoid issues with CSV import and to maintain data integrity)

-- TABLE: Series - similar structure to Movies
CREATE TABLE Series (
    series_id INT PRIMARY KEY AUTO_INCREMENT,
    seriesName VARCHAR(35) NOT NULL,
    genre VARCHAR(20),
    actorFirstName VARCHAR(35) NOT NULL,
    actorSurName VARCHAR(35) NOT NULL,
    actor_id INT, FOREIGN KEY (actor_id) REFERENCES Actors(actor_id),
    rating DECIMAL(2, 1) CHECK (rating BETWEEN 1 AND 5),
    numberOfSeasons INT,
    director_id INT, FOREIGN KEY (director_id) REFERENCES Directors(director_id)
);

ALTER TABLE Series ADD COLUMN releaseYear INT; -- Adding releaseYear column to Series table after initial creation (to avoid issues with CSV import and to maintain data integrity)


-- TABLE: UserMovies - tracks which users watched which movies 
CREATE TABLE UserMovies (
    user_id INT, FOREIGN KEY (user_id) REFERENCES Users(user_id),
    movie_id INT, FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    genre VARCHAR(20),
    activity_id INT PRIMARY KEY AUTO_INCREMENT
);  
-- TABLE: UserSeries - same logic as UserMovies
CREATE TABLE UserSeries (
    user_id INT, FOREIGN KEY (user_id) REFERENCES Users(user_id),
    series_id INT, FOREIGN KEY (series_id) REFERENCES Series(series_id),
    genre VARCHAR(20),
    activity_id INT PRIMARY KEY AUTO_INCREMENT
);

-- ============================================================
-- SECTION 3: STRUCTURE VERIFICATION
-- DESCRIBE command to check if tables are created correctly with all specified columns, data types, and constraints
-- ============================================================
DESCRIBE Users;
DESCRIBE Actors;
DESCRIBE Directors;
DESCRIBE Movies;
DESCRIBE Series;
DESCRIBE UserMovies;
DESCRIBE UserSeries;

-- ============================================================
-- SECTION 4: DATA VERIFICATION
-- SELECT and Count () queries to check if tables are not empty and contain expected number of records (after CSV import)
-- ============================================================
SELECT * FROM Users
LIMIT 15;

USE Ireflix; -- Ensure we are using the correct database for counting records
SELECT COUNT(*) FROM Users;
SELECT COUNT(*) FROM Actors;
SELECT COUNT(*) FROM Directors;
SELECT COUNT(*) FROM Movies;
SELECT COUNT(*) FROM Series;
SELECT COUNT(*) FROM UserMovies;
SELECT COUNT(*) FROM UserSeries;

-- ============================================================
-- SECTION 5: INSERTING ADDITIONAL DATA (for analysis purposes)
-- Adding new actors and movies to have more data for analysis and practice of INSERT command
-- ============================================================

SELECT * FROM Actors; -- Check existing actors to avoid duplicates and maintain data integrity
SELECT actorSurName FROM Movies; -- Check existing actor surnames in Movies to maintain consistency with Actors table and avoid orphan records

-- There are well-known actor imported but we can add few (5) into our data
INSERT INTO Actors
(actorFirstName, actorSurName, nationality)
VALUES
('Tom', 'Hanks','American'),
('Leonardo', 'DiCaprio','American'),
('Robert','Downey','American'),
('Cillian','Murphy','Irish'),
('Keanu','Reeves','Canadian');

SELECT * FROM Actors
WHERE actorSurName=('Hanks') OR actorSurName=('Murphy'); -- Quick check if new actors are added correctly

-- Check if we can find all new actors with IN operator (and avoid duplicates) 
SELECT actor_id, actorSurName
FROM Actors
WHERE actorSurName IN
('Hanks','DiCaprio','Downey','Murphy','Reeves');

-- INSERT movies for Tom Hanks
INSERT INTO Movies
(movieName, genre, releaseYear, duration, rating, actorFirstName, actorSurName, actor_id, director_id)
VALUES
('Forrest Gump','Drama',1996,142,4.9,'Tom','Hanks',101,1),
('Cast Away', 'Drama',2003,143,4.8,'Tom','Hanks',101,2),
('Saving Private Ryan','War',1999, 144,4.9,'Tom','Hanks',101,3);


-- Genre check - to maintain consistency and avoid typos in genre names (and to check if we can use existing
SELECT Genre FROM Movies;

-- INSERT movies for Leonardo DiCaprio 
INSERT INTO Movies
(movieName, genre, releaseYear, duration, rating, actorFirstName, actorSurName, actor_id, director_id)
VALUES
('Titanic','Romance',1987,134,4.7,'Leonardo','DiCaprio',102,1),
('Inception','Sci-Fi',2000,148,4.9,'Leonardo', 'DiCaprio',102,2),
('The Revenant','Drama',2012,156,4.6, 'Leonardo','DiCaprio',102,3),
('Shutter Island','Thriller',2009,138,4.7,'Leonardo','DiCaprio',102,1),
('The Wolf of Wall Street','Comedy',2023,180,4.8, 'Leonardo','DiCaprio',102,2);

-- Quick insert verification
SELECT * FROM Movies
WHERE actorSurName=('DiCaprio');
SELECT * FROM Movies
WHERE actorSurName=('Hanks');

-- INSERT movies for Cillian Murphy
INSERT INTO Movies
(movieName, genre,  releaseYear, duration, rating, actorFirstName, actorSurName, actor_id, director_id)
VALUES
('Oppenheimer','Drama',2021,120,4.9,'Cillian','Murphy',104,2),
('Red Eye','Thriller',2015,82,4.4,'Cillian','Murphy',104,3);

-- INSERT movies for Keanu Reeves
INSERT INTO Movies
(movieName, genre, releaseYear, duration, rating, actorFirstName, actorSurName, actor_id, director_id)
VALUES
('John Wick','Action',2004,99,4.7,'Keanu','Reeves',105,1),
('The Matrix','Sci-Fi',1997,106,4.9,'Keanu','Reeves',105,2),
('Constantine','Thriller',2000,109,4.5,'Keanu','Reeves',105,3);


-- =============================================================
-- SECTION 6: DATA ANALYSIS
-- Using SELECT, WHERE, GROUP BY, ORDER BY, JOIN commands to analyze the data and answer specific questions about actors, movies, genres, ratings, etc.
-- Finding the most hard-working actors (with the most movies) and best-rated movies (with rating above 4.5)
-- =============================================================

-- Now we can check hard worked actors (and use GROUP BY, ORDER BY) 
-- Actor Ronan played in 93 movies
-- Actor Hanks played in 3 movies (after our insert)

SELECT actorSurName,
COUNT(*) AS moviesNumber
FROM Movies
GROUP BY actorSurName;

SELECT actorSurName,
COUNT(*) AS moviesNumber
FROM Movies
GROUP BY actorSurName
ORDER BY moviesNumber DESC;

-- We can check all movies/series with specific rating (and use WHERE)
SELECT movieName,genre,rating
FROM Movies
WHERE rating >3.8 AND rating <=4.5;

SELECT seriesName,genre,rating
FROM Series
WHERE rating >= 3.9 AND rating <4.4;

-- We can check if any movie is longer than required 180 minutes
SELECT COUNT(*) AS Duration_Limit FROM Movies WHERE duration > 180;

-- Check JOIN command from 2 tables with common PK/FK element
SELECT movies.movie_id,  movies.actorSurName, actors.actorSurName,  movies.movieName
FROM Movies
LEFT JOIN Actors ON movies.actor_id = actors.actor_id
LIMIT 10;

-- Check best rated movies (TOP 5)
SELECT movieName, rating, genre, releaseYear
FROM Movies
ORDER BY rating DESC
LIMIT 5;

-- ============================================================
-- WELL-KNOWN ACTOR ANALYSIS (TOP 5 - based on number of movies)
-- ============================================================
SELECT actorSurName, COUNT(*) AS MoviesNumber
FROM Movies 
GROUP BY actorSurName
ORDER BY MoviesNumber DESC
LIMIT 5;

-- ============================================================
-- ACTORS IN MOVIES(only) ANALYSIS 
-- ============================================================
SELECT actorSurName
FROM Movies
WHERE actor_id NOT IN ( SELECT actor_id
FROM Series
);
-- Actors only in movies (without duplicates)
SELECT DISTINCT actorSurName AS MovieActor
FROM Movies
WHERE actor_id NOT IN ( SELECT actor_id
FROM Series
);

-- WHERE usege
SELECT movieName, genre, rating AS NetflixScore
FROM Movies 
WHERE rating >=4.5 AND rating <4.9;

-- GROUP BY (most popular genre)
SELECT genre,  COUNT(*) AS totalMovies
FROM Movies
GROUP BY genre;

-- ============================================================
-- TYPE OF MOVIES ANALYSIS 
-- ============================================================
SELECT genre, COUNT(*) AS MoviesTOTAL
FROM Movies
GROUP BY genre 
HAVING COUNT(*) >140;

-- All Maryl Streep movies
SELECT movieName, genre, rating, releaseYear
FROM Movies
WHERE actorSurName = 'Streep'
ORDER BY releaseYear DESC;

-- ============================================================
-- JOIN check
-- ============================================================
SELECT movies.movieName, actors.actorSurName, actors.nationality
FROM Movies 
JOIN Actors  ON movies.actorSurName = actors.actorSurName
LIMIT 12;

-- ============================================================
-- Because we have already RELEASE_YEAR column we can add another column for REVENUE
-- ============================================================
DESCRIBE Movies;
ALTER TABLE Movies
ADD COLUMN revenue INT;

-- ============================================================
-- APPENDIX - AI generated Revenue -- switch of/on safety mode 
-- UPDATE command to fill in the revenue column with AI generated values based on movie rating (for demonstration purposes only, not real revenue data)
-- ============================================================
SET SQL_SAFE_UPDATES = 0;
UPDATE Movies
SET revenue = ROUND(rating * 50000000)
WHERE revenue IS NULL OR revenue = 0;
SET SQL_SAFE_UPDATES = 1;

-- Check and verify
SELECT movieName, revenue FROM Movies;

