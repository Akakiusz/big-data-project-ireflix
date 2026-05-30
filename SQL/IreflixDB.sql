-- ============================================================
-- Ireflix Database - Big Data CA1 Assignment (test version)
-- ============================================================

-- Create the command to work on the new version of Irexlix database
DROP DATABASE IF EXISTS Ireflix;
CREATE DATABASE Ireflix;
USE Ireflix;

-- Users table - for storing login info
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    userName VARCHAR(35) NOT NULL,
    firstName VARCHAR(35) NOT NULL,
    surName VARCHAR(35) NOT NULL,
    password VARCHAR(15) NOT NULL
);
-- Actors table (no duplicated surnames)
CREATE TABLE Actors (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    actorFirstName VARCHAR(35) NOT NULL,
    actorSurName VARCHAR(35) NOT NULL UNIQUE,
    nationality VARCHAR(50)
);
-- Directors table (no duplicated surnames)
CREATE TABLE Directors (
    director_id INT PRIMARY KEY AUTO_INCREMENT,
    directorFirstName VARCHAR(35) NOT NULL,
    directorSurName VARCHAR(35) NOT NULL UNIQUE,
    nationality VARCHAR(50)
);  
-- Movies table - this is the main table
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    movieName VARCHAR(35) NOT NULL,
    genre VARCHAR(20),
    releaseYear YEAR,
    duration INT NOT NULL CHECK (duration <=180),
    rating DECIMAL(2, 1) CHECK (rating BETWEEN 1 AND 5),
    actorFirstName VARCHAR(35) NOT NULL,
    actorSurName VARCHAR(35) NOT NULL,
    actor_id INT, FOREIGN KEY (actor_id) REFERENCES Actors(actor_id),
    director_id INT, FOREIGN KEY (director_id) REFERENCES Directors(director_id)
);
-- Series table -
CREATE TABLE Series (
    series_id INT PRIMARY KEY AUTO_INCREMENT,
    seriesName VARCHAR(35) NOT NULL,
    genre VARCHAR(20),
    releaseYear YEAR,
    actorFirstName VARCHAR(35) NOT NULL,
    actorSurName VARCHAR(35) NOT NULL,
    actor_id INT, FOREIGN KEY (actor_id) REFERENCES Actors(actor_id),
    rating DECIMAL(2, 1) CHECK (rating BETWEEN 1 AND 5),
    numberOfSeasons INT,
    director_id INT, FOREIGN KEY (director_id) REFERENCES Directors(director_id)
);
-- UserMovies - tracks which users watched which movies 
CREATE TABLE UserMovies (
    user_id INT, FOREIGN KEY (user_id) REFERENCES Users(user_id),
    movie_id INT, FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    genre VARCHAR(20),
    activity_id INT PRIMARY KEY AUTO_INCREMENT
);  
-- UserSeries - same lagic as UserMovies
CREATE TABLE UserSeries (
    user_id INT, FOREIGN KEY (user_id) REFERENCES Users(user_id),
    series_id INT, FOREIGN KEY (series_id) REFERENCES Series(series_id),
    genre VARCHAR(20),
    activity_id INT PRIMARY KEY AUTO_INCREMENT
);

-- ============================================================
-- VERIFICATION QUERIES - check if everything is correct
-- ============================================================
DESCRIBE Users;
DESCRIBE Actors;
DESCRIBE Directors;
DESCRIBE Movies;
DESCRIBE Series;
DESCRIBE UserMovies;
DESCRIBE UserSeries;

-- ============================================================
-- VERIFICATION QUERIES - check imported data
-- ============================================================
SELECT * FROM Users
LIMIT 15;

USE Ireflix;
SELECT COUNT(*) FROM Users;
SELECT COUNT(*) FROM Actors;
SELECT COUNT(*) FROM Directors;
SELECT COUNT(*) FROM Movies;
SELECT COUNT(*) FROM Series;
SELECT COUNT(*) FROM UserMovies;
SELECT COUNT(*) FROM UserSeries;

-- ============================================================
-- TESTS - INSERT SAMPLES FOR WELL-KNOWN ACTORS 
-- ============================================================
SELECT * FROM Actors;
SELECT actorSurName FROM Movies;

-- There is no well-known actor for me but we can add few (5) into our data
INSERT INTO Actors
(actorFirstName, actorSurName, nationality)
VALUES
('Tom', 'Hanks','American'),
('Leonardo', 'DiCaprio','American'),
('Robert','Downey','American'),
('Cillian','Murphy','Irish'),
('Keanu','Reeves','Canadian');

SELECT * FROM Actors
WHERE actorSurName=('Hanks') OR actorSurName=('Murphy');

-- We can add a bit random data to create better analysis and practice adding data
-- First check actor ID for Tom Hanks 
SELECT actor_id, actorSurName
FROM Actors
WHERE actorSurName IN
('Hanks','DiCaprio','Downey','Murphy','Reeves');

INSERT INTO Movies
(movieName, genre, releaseYear, duration, rating, actorFirstName, actorSurName, actor_id, director_id)
VALUES
('Forrest Gump','Drama',1996,142,4.9,'Tom','Hanks',101,1),
('Cast Away', 'Drama',2003,143,4.8,'Tom','Hanks',101,2),
('Saving Private Ryan','War',1999, 144,4.9,'Tom','Hanks',101,3);

-- Second insert data for actor Leonardo DiCaprio 
-- Genre consistency checking
SELECT Genre FROM Movies;

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

-- Third insert data for actor Cillian Murphy
INSERT INTO Movies
(movieName, genre,  releaseYear, duration, rating, actorFirstName, actorSurName, actor_id, director_id)
VALUES
('Oppenheimer','Drama',2021,120,4.9,'Cillian','Murphy',104,2),
('Red Eye','Thriller',2015,82,4.4,'Cillian','Murphy',104,3);

-- Fourth insert data for actor Keanu Reeves
INSERT INTO Movies
(movieName, genre, releaseYear, duration, rating, actorFirstName, actorSurName, actor_id, director_id)
VALUES
('John Wick','Action',2004,99,4.7,'Keanu','Reeves',105,1),
('The Matrix','Sci-Fi',1997,106,4.9,'Keanu','Reeves',105,2),
('Constantine','Thriller',2000,109,4.5,'Keanu','Reeves',105,3);

-- Now we can check hard worked actors (and use GROUP BY, ORDER BY)
SELECT actorSurName,
COUNT(*) AS moviesNumber
FROM Movies
GROUP BY actorSurName;

SELECT actorSurName,
COUNT(*) AS moviesNumber
FROM Movies
GROUP BY actorSurName
ORDER BY moviesNumber DESC;

-- We can check all movies with specific rating (and use WHERE)
SELECT movieName,genre,rating
FROM Movies
WHERE rating >3.8 AND rating >=4.5;

-- We can check if any movie is longer than required 180 minutes
SELECT COUNT(*) AS Duration_Limit FROM Movies WHERE duration > 180;

-- Check JOIN command from 2 tables with common PK/FK element
SELECT movies.movie_id,  movies.actorSurName, actors.actorSurName,  movies.movieName
FROM Movies
LEFT JOIN Actors ON movies.actor_id = actors.actor_id
LIMIT 10;

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

SELECT genre,  COUNT(*) AS totalMovies
FROM Movies
GROUP BY genre;

-- ============================================================
-- TYPE OF MOVIES ANALYSIS 
-- ============================================================
SELECT genre, COUNT(*) AS MoviesTOTAL
FROM Movies
GROUP BY genre
HAVING COUNT(*) >120;