-- NETFLIX PROJECT

CREATE TABLE NETFLIX(
show_id VARCHAR(5),
movie_type varchar(10),	title varchar(120),	
director varchar(250),	
casts varchar(1000),
country varchar(150),
date_added	varchar(50),
release_year int,	
rating varchar(10),
duration varchar(20),
listed_in varchar(100),
description varchar(250)
)
select * from netflix

-- 1. Count of TV shows and Movies in the Data set ?
select movie_type,count(show_id) as content_count from netflix group by movie_type

-- 2.Year Wise count of Movies and Tv Shows that added in the Data Set?

SELECT 
    movie_type,
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_year,
    COUNT(show_id) AS total_added,
    round((COUNT(show_id) * 100.0) / 
    (SELECT COUNT(show_id) FROM netflix WHERE movie_type = n.movie_type),2) AS percentage_of_total_type
FROM netflix n
WHERE EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) IS NOT NULL
GROUP BY 1,2
ORDER BY 
    CASE 
        WHEN movie_type = 'Movie' THEN 1
        WHEN movie_type = 'TV Show' THEN 2
        ELSE 3
    END,
    2 DESC;

--3. Most popular Genre Combination for both movies and TV Shows [TOP 10)]?

SELECT listed_in, COUNT(show_id) AS total_count FROM netflix
where listed_in like '%,%'
GROUP BY 1
ORDER BY 2 DESC limit 10

--4. Top 5 Invidual Genre for each type in the Data Set?

WITH genre_counts AS (
  SELECT 
    movie_type, 
    TRIM(UNNEST(string_to_array(listed_in, ','))) AS genre,
    COUNT(show_id) AS genre_count
  FROM netflix
  GROUP BY movie_type, genre
),
ranked_genres AS (
  SELECT 
    movie_type, 
    genre, 
    genre_count,
    ROW_NUMBER() OVER (PARTITION BY movie_type ORDER BY genre_count DESC) AS rank
  FROM genre_counts
)
SELECT 
  movie_type, 
  genre, 
  genre_count
FROM ranked_genres
WHERE rank <= 5
ORDER BY movie_type, rank;

-- 5. Count the no of content items in each genre?
WITH genre_counts AS (
  SELECT 
    movie_type, 
    TRIM(UNNEST(string_to_array(listed_in, ','))) AS genre,
    COUNT(show_id) AS genre_count
  FROM netflix
  GROUP BY movie_type, genre
),
ranked_genres AS (
  SELECT 
    movie_type, 
    genre, 
    genre_count,
    ROW_NUMBER() OVER (PARTITION BY movie_type ORDER BY genre_count DESC) AS rank
  FROM genre_counts
)
SELECT 
  movie_type, 
  genre, 
  genre_count
FROM ranked_genres
WHERE rank <= 5
ORDER BY movie_type, rank;

--6.top 10 countries with max content and which genre they preferred?

WITH GenreCounts AS (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
        COUNT(*) AS watch_count
    FROM netflix
    GROUP BY country, genre
),
RankedGenres AS (
    SELECT 
        country, genre, watch_count,
        Rank() OVER (PARTITION BY country ORDER BY watch_count DESC) AS rank
    FROM GenreCounts
)
SELECT country, genre, watch_count
FROM RankedGenres
WHERE rank = 1
ORDER BY watch_count DESC
LIMIT 10;


--7. Maximum added Genre in each year in the data set?

with year_genre_count as(
select extract( year from to_date(date_added,'month dd,yyyy')) as year,trim(unnest(string_to_array(listed_in,','))) as genre,count(*) as genre_count from netflix group by year , genre ),

content_rank as (
select year,genre,genre_count,row_number() over(partition by year order  by genre_count desc) as rank from year_genre_count
)

select year , genre,genre_count from content_rank where rank =1 and year is not null order by year desc



--8. top 10 Countries with the maximum content in the netflix?

create view country_content as(
select count(show_id) as content_count,movie_type, TRIM(unnest(string_to_array(country, ','))) AS country from netflix group by movie_type,country )

create view rank_content as(
select content_count,movie_type,country,row_number() over (partition by movie_type order by content_count desc ) as rank from country_content
)

select country,movie_type,content_count from rank_content where rank <= 5 

--9. Top 10 countries which produce on combinations ?
select country, count(show_id) as combination_count from netflix
where country like '%,%' 
group by country
order by combination_count desc limit 10

--10. Top Rated Content?

create view rating as(
select count(show_id) as rating_count,movie_type,rating from netflix group by rating,movie_type 
)
 create view rating_rank as(
select rating_count,movie_type,rating ,row_number() over(partition by movie_type order by rating_count desc) as rank from rating
 )
 
select movie_type,rating,rating_count from rating_rank where rank <= 5


--11. top 5 longest Movies and TV serials?

with longest_movie as(
select movie_type,trim(split_part(duration,' ',1))::numeric as time,duration from netflix group by movie_type,time,duration ),

 rank_movie as (
select movie_type,time,duration,row_number() over(partition by movie_type order by time desc) as rank from longest_movie
 )
 
select movie_type,duration from rank_movie where rank <=5


--12. Top 10 countries which produce on combinations ?
select country, count(show_id) as combination_count from netflix
where country like '%,%' 
group by country
order by combination_count desc limit 10


--13.top 10 Directors with more number of movies in the Data Set?

select unnest(string_to_array(director,',')) as director , count(show_id) as content_count from netflix group by 1 order by 2 desc limit 10

--14. Top 10 casts with more number of movies in the Data Set?

select  trim(unnest(string_to_array(casts,','))) as casts,count(casts) as content_count from netflix group by 1 order by 2 desc limit 10

































































































































