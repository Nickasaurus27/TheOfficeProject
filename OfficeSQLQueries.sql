--Creating tables/importing the data
CREATE TABLE IF NOT EXISTS the_office_imdb (
season SMALLINT,
episode_number SMALLINT,
title VARCHAR(100),
original_air_date DATE,
imdb_rating NUMERIC,
total_votes INT,
description VARCHAR(500)
);

CREATE TABLE IF NOT EXISTS the_office_episodes (
season SMALLINT,
episode_num_in_season SMALLINT,
episode_num_overall SMALLINT, 
title VARCHAR(50), 
directed_by VARCHAR(50),
written_by VARCHAR(100),
original_air_date DATE,
prod_code INT,
us_viewers NUMERIC
);

SELECT *
FROM the_office_episodes
LIMIT 5;

/* us_viewers had some float values with more than 10 decimal places 
Also wanted to convert these to integers from numeric */
UPDATE the_office_episodes
SET us_viewers = ROUND(us_viewers,0);

ALTER TABLE the_office_episodes
ALTER COLUMN us_viewers TYPE BIGINT;

SELECT *
FROM the_office_imdb
LIMIT 5;

SELECT *
FROM the_office_episodes
LIMIT 5;

/* With the data now uploaded, I had some exploratory questions about one of my favourite shows. 
Nothing fancy, and I could've sunk more time into this but I wanted to answer some questions with SQL. */


-- #1) How many total episodes are there? How many per each season? 

-- 201 episodes in total
SELECT COUNT(title) num_of_episodes
FROM the_office_episodes;

-- Number of episodes per season
SELECT season, COUNT(*) num_of_episodes
FROM the_office_episodes
GROUP BY 1
ORDER BY 1 ASC;


-- #2) Who were all of the writers on the show? How many episodes did they write?

/* Mindy Kaling (Kelly), Paul Lieberstein (Toby) and BJ Novak (Ryan) wrote the most episodes in the show */
SELECT DISTINCT written_by writers, COUNT(*) num_of_episodes
FROM the_office_episodes
GROUP BY 1
ORDER BY 2 DESC;

/* There are episodes that include more than one writer; I want to include a column that counts the # of writers */
SELECT DISTINCT written_by writers, 
LENGTH(written_by) - LENGTH(REPLACE(written_by, '&','')) + 1 num_of_writers
FROM the_office_episodes;

/*- There's one record in the data that uses 'and' instead of the ampersand
	- Updating this record to include '&' symbol */
UPDATE the_office_episodes
SET written_by = 'Ricky Gervais & Stephen Merchant & Greg Daniels'
WHERE written_by = 'Ricky Gervais & Stephen Merchant and Greg Daniels'

-- The updated worked perfectly! 
SELECT DISTINCT written_by writers, 
LENGTH(written_by) - LENGTH(REPLACE(written_by, '&','')) + 1 num_of_writers
FROM the_office_episodes
ORDER BY num_of_writers DESC;


-- #3) What was the average rating for all of the 9 seasons? How did each episode compare to its season's average rating? 
SELECT *
FROM the_office_imdb
LIMIT 10;

/* Let's first grab the average rating for each season 
	-  Seasons 2-5 (my favourites) had the highest average ratings throughout the show's runtime */
SELECT season, ROUND(AVG(imdb_rating),2) avg_season_rating
FROM the_office_imdb 
GROUP BY 1
ORDER BY 1 ASC;

/* Now that we know each season's average rating, let's find out how each episode in each season
fared against their respective season's average rating. */
SELECT season, episode_number, title, imdb_rating, 
AVG(imdb_rating) OVER(PARTITION BY season) avg_season_rating
FROM the_office_imdb;

/* Was trying to get the 'avg_season_rating' column to only display up to 2 decimal points since I can't 
perform ROUND() it on an OVER() function.
Didn't work like I'd hoped but it's still easy to read/work with
	- Now we have a table that shows how each episode compares to it's season's average rating 
	- Going to create a new View out of this */
CREATE VIEW seasons_and_eps_ratings AS (
WITH season_ratings AS (
	SELECT season, ROUND(AVG(imdb_rating),2) avg_season_rating
FROM the_office_imdb 
GROUP BY 1
ORDER BY 1 ASC)

SELECT a.season, episode_number, title, imdb_rating, 
AVG(b.avg_season_rating) OVER(PARTITION BY a.season) avg_season_rating,
imdb_rating - avg_season_rating diff_from_season_avg,
CASE 
	WHEN imdb_rating - avg_season_rating > 0 THEN 'Higher than average!'
	WHEN imdb_rating - avg_season_rating < 0 THEN 'Lower than average :('
	END AS higher_or_lower
FROM the_office_imdb a
JOIN season_ratings b ON a.season = b.season);

-- #4) How many episodes in each season were higher or lower than the average season rating?

/* Using the View we created from the last question above */

SELECT *
FROM seasons_and_eps_ratings
LIMIT 5;

/* Interesting that S2, one of the highest rated seasons, had more 'below average' episodes than 'above average' ones 
	- This might tell us that the avg season rating was heavily influenced by several standout episodes 

S8 has the lowest avg_season_rating yet has double the amount of 'above average' episodes
	- Those below average episodes must've really brought down the avg season rating */ 
SELECT season, ROUND(AVG(avg_season_rating),2) avg_season_rating,
SUM(CASE 
	WHEN diff_from_season_avg > 0 THEN 1 ELSE 0
	END) above_avg_ep, 
SUM(CASE 
	WHEN diff_from_season_avg < 0 THEN 1 ELSE 0
	END) below_avg_ep
FROM seasons_and_eps_ratings
GROUP BY 1
ORDER BY 1;


-- #5) Which directors of the show garnered the highest avg imdb ratings and us_viewers in the show? 

/* Now I'm going to join the data into a new View */
CREATE VIEW the_office_combined AS (
SELECT a.season, episode_num_in_season, episode_num_overall, a.title, 
directed_by, written_by, a.original_air_date, us_viewers, 
imdb_rating, total_votes
FROM the_office_episodes a
INNER JOIN the_office_imdb b ON 
	a.title = b.title
ORDER BY episode_num_overall);

SELECT *
FROM the_office_combined 
LIMIT 5;

/* It looks like Steve Carell has the highest avg imdb rating overall for the episdoes he directed
	- However he only directed 3 (seemingly well-received) episodes while directors like Paul Feig and Ken Kwapis directed 
		more than 5 times the episodes, and had a relatively close rating to Carell */
SELECT directed_by, ROUND(AVG(imdb_rating),2) avg_imdb_rating,
	ROUND(AVG(us_viewers)) avg_us_viewers, COUNT(*) episodes_directed
	FROM the_office_combined
	GROUP BY 1
	ORDER BY 2 DESC
	
/* Next, I wanted to categorize each director by their avg imdb rating. 
	- Any director with an imdb rating over 8 was considered 'Great'
	- A rating between 7 and 8 was considered 'Good'
	- Anything below that was considered 'Decent' (no bad eps in The Office, yes I'm biased) */
WITH director_info AS 
	(SELECT directed_by, ROUND(AVG(imdb_rating),2) avg_imdb_rating,
	ROUND(AVG(us_viewers)) avg_us_viewers, COUNT(*) episodes_directed
	FROM the_office_combined
	GROUP BY 1
	ORDER BY 2 DESC), 
director_rating AS 
	(SELECT directed_by, avg_imdb_rating, 
	CASE 
		WHEN avg_imdb_rating >= 8 THEN 'Great Director'
		WHEN avg_imdb_rating BETWEEN 7 AND 8 THEN 'Good Director'
		WHEN avg_imdb_rating < 7 THEN 'Decent Director'
		END director_standing
	FROM director_info)
	
SELECT director_standing, COUNT(*) num_of_directors
FROM director_rating num_of_directors
GROUP BY 1
ORDER BY 2 DESC;


--CONCLUSION
/* There's a LOT that I can do with this data, and I aim to return to it at some point. 
My next step would be to take some of these queries and export them to visualize in Tableau. 
I will update this file with 'Visualization' queries when that time comes. */
