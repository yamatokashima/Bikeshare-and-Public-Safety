-- Table creations

-- Importing monthly tables
CREATE TABLE divvyrides (
    ride_id text primary key,
    rideable_type text NOT NULL,
    started_at timestamp,
    ended_at timestamp,
	start_station_name text,
	start_station_id int,
	end_station_name text,
	end_station_id int,
	start_lat numeric,
	start_lng numeric,
	end_lat numeric,
	end_lng numeric,
	member_casual text
	);

-- Combining yearly tables (2020-2022)

CREATE TABLE divvbikes_2020_2021_2022 AS
	SELECT *
	FROM public.divvybikes_2020
	UNION
	SELECT *
    FROM public.divvybikes_2021
    UNION
    SELECT *
    FROM public.divvybikes_2022

-- New table for crimes 2016-2022

CREATE TABLE 
	chiacgo_crimes_new AS
		SELECT 
			*
		FROM 
			public.chiacgo_crimes
		WHERE 
			date_part('year',date) > 2016
			AND date_part('year',date) < 2022

-- Created new table using crime data in Chicago

create table clean_crime as
select
	id,
	case_number,
	date,
	block,
	primary_type,
	description,
	location_description,
	arrest,
	round(latitude::decimal, 8) as latitude,
	round(longitude::decimal, 8) as longitude
	from chicago_crimes
	where latitude IS NOT NULL
	AND longitude IS NOT NULL
	AND date_part('year', "date") >= 2016
	AND LOWER(primary_type) IN('assault','battery','crim sexual assault','criminal sexual assault','homicide','human trafficking','intimidation','kidnapping','obscenity','offense involving children','public indecency','public peace violation','robbery','sex offense','stalking')
	AND lower(location_description) in('street', 'sidewalk', 'other', 'parking lot/garage(non.resid.)', 'alley', 'grocery food store', 'gas station', 'parking lot / garage (non residential)', 'cta train', 'convenience store',
										'other (specify)', 'cta bus', 'cta platform', 'cta station', 'cta bus stop', 'government building/property', 'medical/dental office', 'other commercial transportation', 'police facility / vehicle parking lot',
										'cta garage / other property', 'government building / property', 'vehicle - other ride share service (e.g., uber, lyft)', 'vehicle - commercial', 'other railroad prop / tain depot',
										'cta parking lot / garage / other property', 'federal building', 'parking lot', 'cta "l" train', 'cta property', 'cta "l" platform', 'cta subway station', 'police facility')




2016-2019


-- Connor's code to concat start and end of trips
with t1 as
(
SELECT CONCAT (a.start_station_id,
REPLACE (to_char (a.start_time, 'HH24:MI'),':',''))::numeric,
a.start_station_id,
to_char(a.start_time, 'HH24:MI') start_time_hr, COUNT (a.start_time) bikes_outflow_cnt, b.latitude, b.longitude,
b.name
FROM public.divvybikes_2019 a
JOIN public.divvy_stations b
ON a.start_station_id = b.id
GROUP BY 2, 3, b.latitude, b.longitude, b.name 
ORDER BY 2,3),
t2 AS (
SELECT CONCAT (a.end_station_id, REPLACE (to_char(a.end_time, 'HH24:MI'),':',''))::numeric, a.end_station_id,
to_char(a.end_time, 'HH24:MI') end_time_hr, COUNT (a.end_time) bikes_inflow_cnt, b.name, b.latitude,
b.longitude, b.docks
FROM public.divvybikes_2019 a
JOIN public.divvy_stations b
ON a.end_station_id = b.id
GROUP BY 1, 2, 3, 5, b.name, b.docks, b.latitude, b.longitude ORDER BY 2,3)
SELECT t1.*, t2.* 
FROM t1
FULL JOIN t2 
USING (CONCAT);

-- M/F Ratio by Year
SELECT "2016_Male","2016_Female","2017_Male","2017_Female","2018_Male","2018_Female","2019_Male","2019_Female"
FROM (SELECT COUNT(gender) AS "2016_Male",
(SELECT COUNT(gender) FROM public.divvybikes_2016 WHERE lower(gender) LIKE 'f%') AS "2016_Female"
FROM public.divvybikes_2016
WHERE LOWER(gender) LIKE 'm%') AS "2016",
(SELECT COUNT(gender) AS "2017_Male",
(SELECT COUNT(gender) FROM public.divvybikes_2017 WHERE lower(gender) LIKE 'f%') AS "2017_Female"
FROM public.divvybikes_2017) "2017",
(SELECT COUNT(gender) AS "2018_Male",
(SELECT COUNT(gender) FROM public.divvybikes_2018 WHERE LOWER(gender) LIKE 'f%') AS "2018_Female"
FROM public.divvybikes_2018
WHERE lower(gender) LIKE 'm%') AS "2018",
(SELECT COUNT(gender) AS "2019_Male",
(SELECT COUNT(gender) FROM public.divvybikes_2019 WHERE LOWER(gender) LIKE 'f%') AS "2019_Female"
FROM public.divvybikes_2019
WHERE LOWER(gender) ILIKE 'm%') AS "2019"
GROUP BY 1,2,3,4,5,6,7,8;

-- 2016
-- Number of trips by gender
SELECT gender, COUNT(trip_id) num_of_trips
FROM public.divvybikes_2016
GROUP BY gender;

-- Number of trips by birthyear
SELECT birthyear, COUNT(trip_id) num_of_trips
FROM public.divvybikes_2016
WHERE 1 IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- Number of trips by user type
SELECT user_type, COUNT(trip_id) num_of_trips
FROM public.divvybikes_2016
GROUP BY user_type;

-- Avg duration based on user type
SELECT user_type, AVG(end_time - start_time) AS avg_duration
FROM divvybikes_2016
GROUP BY user_type;

-- Quantity of trips based on start station with long and lat
SELECT six.start_station_id,COUNT(six.trip_id) count_of_trips,d.longitude,d.latitude
FROM divvybikes_2016 six
LEFT JOIN divvy_stations d
ON d.id = six.start_station_id
GROUP BY start_station_id, d.longitude, d.latitude
ORDER BY count_of_trips DESC;

-- Quantity of trips based on end station with long and lat
SELECT six.end_station_id,COUNT(six.trip_id) count_of_trips,d.longitude,d.latitude
FROM divvybikes_2016 six
LEFT JOIN divvy_stations d
ON d.id = six.end_station_id
GROUP BY end_station_id, d.longitude, d.latitude
ORDER BY count_of_trips DESC;

-- Quantity of trips based on start and end station
WITH t1 as(SELECT six.start_station_id,COUNT(six.trip_id) count_of_trips,d.longitude,d.latitude
FROM divvybikes_2016 six
LEFT JOIN divvy_stations d
ON d.id = six.start_station_id
GROUP BY start_station_id, d.longitude, d.latitude
ORDER BY count_of_trips DESC),
t2 as(SELECT six.end_station_id,COUNT(six.trip_id) count_of_trips,d.longitude,d.latitude
FROM divvybikes_2016 six
LEFT JOIN divvy_stations d
ON d.id = six.end_station_id
GROUP BY end_station_id, d.longitude, d.latitude
ORDER BY count_of_trips DESC)
SELECT t1.*,t2.*
FROM t1
FULL JOIN t2
USING(count_of_trips)
ORDER BY t2.count_of_trips DESC, t1.count_of_trips DESC;

-- Most Popular Routes with count
SELECT 
  ds.name AS start_station_name, 
  ds2.name AS end_station_name, 
  COUNT(*)
FROM divvybikes_2016 b
JOIN divvy_stations ds ON ds.id = b.start_station_id
JOIN divvy_stations ds2 ON ds2.id = b.end_station_id
GROUP BY 1,2
ORDER BY COUNT desc;

-- Same as above but with station id's
SELECT start_station_id,end_station_id,COUNT(*)
FROM divvybikes_2016
GROUP BY 1,2
ORDER BY COUNT desc;

-- Count of each age
SELECT (2023 - birthyear::int) AS age, COUNT((2023 - birthyear::int))
FROM divvybikes_2016
WHERE birthyear > 1940
GROUP BY AGE
ORDER BY AGE,COUNT;

-- Count of trips per quarter
SELECT CASE
		WHEN EXTRACT(MONTH FROM start_time) IN(1,2,3)
		THEN 'Q1'
		WHEN EXTRACT(MONTH FROM start_time) IN(4,5,6)
		THEN 'Q2'
		WHEN EXTRACT(MONTH FROM start_time) IN(7,8,9)
		THEN 'Q3'
		ELSE 'Q4'
		END AS quarters,
COUNT(trip_id)
FROM divvybikes_2016
GROUP BY quarters;

-- Count of trips by day of week
SELECT TO_CHAR(DATE_TRUNC('day',start_time),'ID') AS day_of_week, COUNT(trip_id)
FROM divvybikes_2016
GROUP BY day_of_week;

-- Count of trips by day of week
SELECT TO_CHAR(DATE_TRUNC('hour',start_time),'HH') AS time_of_day, COUNT(trip_id)
FROM divvybikes_2016
GROUP BY time_of_day;

-- Trip durations 
SELECT end_time - start_time AS trip_duration, COUNT (end_time - start_time) AS num_of_trips
FROM public.divvybikes_2016
GROUP BY trip_duration
ORDER BY num_of_trips DESC;

-- Trip count with distance 
SELECT 
  ds.name AS start_station_name, 
  ds2.name AS end_station_name, 
  COUNT(*),
  (69.0410421 * DEGREES(ACOS(LEAST(1.0, COS(RADIANS(ds.latitude))
     			    * COS(RADIANS(ds2.latitude))
     			    * COS(RADIANS(ds.longitude - ds2.longitude))
    			    + SIN(RADIANS(ds.latitude))
     			    * SIN(RADIANS(ds2.latitude))))))::decimal(7,3) as distance -- Courtesy of Evan 
FROM divvybikes_2016 b
JOIN divvy_stations ds ON ds.id = b.start_station_id
JOIN divvy_stations ds2 ON ds2.id = b.end_station_id
GROUP BY 1,2,4
ORDER BY COUNT DESC
LIMIT 1000;




2020-2022
-- average duration based on member type 2020-2022
SELECT 
	member_casual, 
	AVG(ended_at - started_at) AS avg_duration
FROM 
	public.divvybikes_2020_2022
GROUP BY 
	member_casual;

-- Count of rides by year and quarter, pivoted
SELECT
	quarters,
	COUNT(CASE WHEN EXTRACT(YEAR FROM started_at) = 2020 THEN 1 END) AS "2020",
	COUNT(CASE WHEN EXTRACT(YEAR FROM started_at) = 2021 THEN 1 END) AS "2021",
	COUNT(CASE WHEN EXTRACT(YEAR FROM started_at) = 2022 THEN 1 END) AS "2022"
FROM (
	SELECT started_at,EXTRACT(YEAR FROM started_at) AS YEAR,
		CASE
			WHEN EXTRACT(MONTH FROM started_at) IN(1,2,3) THEN 'Q1'
			WHEN EXTRACT(MONTH FROM started_at) IN(4,5,6) THEN 'Q2'
			WHEN EXTRACT(MONTH FROM started_at) IN(7,8,9) THEN 'Q3'
			ELSE 'Q4'
		END AS quarters
	FROM divvybikes_2020_2022
) q
GROUP BY quarters;


-- Count of trips by day of week
SELECT 
	TO_CHAR(DATE_TRUNC('day',started_at),'ID') AS day_of_week, 
	COUNT(ride_id)
FROM 
	divvybikes_2020_2022
GROUP BY 
	day_of_week;

-- Trip durations 
SELECT 
	ended_at - started_at AS trip_duration,
	COUNT(ended_at - started_at) AS num_of_trips
FROM 
	public.divvybikes_2020_2022
GROUP BY 
	trip_duration
ORDER BY 
	num_of_trips DESC;

-- Trip count with distance 
SELECT 
  start_station_name, 
  end_station_name, 
  COUNT(b.ride_id) AS num_rides,
  (69.0410421 * DEGREES(ACOS(LEAST(1.0, COS(RADIANS(b.start_lat))
     			    * COS(RADIANS(b.end_lat))
     			    * COS(RADIANS(b.start_lng - b.end_lng))
    			    + SIN(RADIANS(b.start_lat))
     			    * SIN(RADIANS(b.end_lat))))))::decimal(7,3) AS distance
FROM 
	divvybikes_2020_2022 b
WHERE
	start_station_name IS NOT NULL
	AND end_station_name IS NOT NULL
GROUP BY 
	1,2,4
ORDER BY 
	num_rides DESC;





Crimes Report
-- Count of crimes by primary type
SELECT
	DISTINCT(primary_type)
FROM 
	clean_crime
GROUP BY 
	primary_type

-- Count of crimes year over year
SELECT
	date_part('year',date) AS "year",
	COUNT(id) AS count_of_crimes
FROM 
	public.clean_crime
GROUP BY 
	date_part('year',date);

-- Count of relevant vs non-relevant crimes by year
SELECT 
	sub.year,
	COUNT(CASE WHEN sub.crime_type = 'non-relevant' THEN 1 END) AS non_relevant,
	COUNT(CASE WHEN sub.crime_type = 'relevant' THEN 1 END) AS relevant
	FROM
		(SELECT 
			DATE_PART('year', "date") AS "year",
			(CASE 
				WHEN LOWER(primary_type) IN('arson','burglary','concealed carry license violation','criminal damage','criminal trespass','deceptive practice','gambling','interference with public officer','liquor law violation','narcotics','non - criminal','non-criminal','non-criminal(subject specified)','other narcotic violation','other offense','prostitution','ritualism','weapons violation')
					THEN 'non-relevant' 
				WHEN LOWER(primary_type) IN('assault','battery','crim sexual assault','criminal sexual assault','homicide','human trafficking','intimidation','kidnapping','obscenity','offense involving children','public indecency','public peace violation','robbery','sex offense','stalking')
					THEN 'relevant'
				WHEN (description) ILIKE '%bike%' OR description NOT ILIKE 'from building' OR description NOT ILIKE 'retail theft'
					THEN 'relevant'
				ELSE 'non-relevant' END) AS "crime_type"
			FROM public.clean_crime
			) sub
	GROUP BY 1
	ORDER BY 1;

-- total crimes by quarter
SELECT
	quarters,
	COUNT(CASE WHEN EXTRACT(YEAR from date) = 2020 THEN 1 END) as "2020",
	COUNT(CASE WHEN EXTRACT(YEAR from date) = 2021 THEN 1 END) as "2021",
	COUNT(CASE WHEN EXTRACT(YEAR from date) = 2022 THEN 1 END) as "2022"
FROM (
	SELECT date,EXTRACT(YEAR FROM date) as year,
		CASE
			WHEN EXTRACT(MONTH FROM date) IN(1,2,3) THEN 'Q1'
			WHEN EXTRACT(MONTH FROM date) IN(4,5,6) THEN 'Q2'
			WHEN EXTRACT(MONTH FROM date) IN(7,8,9) THEN 'Q3'
			ELSE 'Q4'
		END AS quarters
	FROM public.clean_crime
) q
GROUP BY quarters;

-- Number of crimes within 0.3 miles of stations
SELECT
	supersub.*
	FROM (
		SELECT
		sub.station_name,
		COALESCE(SUM(CASE WHEN date_year = 2016 THEN crime_totals END),'0') AS "2016",
		COALESCE(SUM(CASE WHEN date_year = 2017 THEN crime_totals END),'0') AS "2017",
		COALESCE(SUM(CASE WHEN date_year = 2018 THEN crime_totals END),'0') AS "2018",
		COALESCE(SUM(CASE WHEN date_year = 2019 THEN crime_totals END),'0') AS "2019",
		COALESCE(SUM(CASE WHEN date_year = 2020 THEN crime_totals END),'0') AS "2020",
		COALESCE(SUM(CASE WHEN date_year = 2021 THEN crime_totals END),'0') AS "2021",
		COALESCE(SUM(CASE WHEN date_year = 2022 THEN crime_totals END),'0') AS "2022",
		SUM(crime_totals) AS total
		FROM (
			SELECT
				station_name,
				date_part('year',date) AS date_year,
				CASE WHEN (69.0410421
					* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(bikes.latitude::DECIMAL))
					* COS(RADIANS(crime.latitude::DECIMAL))
					* COS(RADIANS(bikes.longitude::DECIMAL - crime.longitude::DECIMAL))
					+ SIN(RADIANS(bikes.latitude::DECIMAL))
					* SIN(RADIANS(crime.latitude::DECIMAL))))))::DECIMAL(7,3) < '0.3' THEN 1 END AS crime_totals
				FROM public.new_divvy_stations bikes
				INNER JOIN clean_crime crime
				ON levenshtein(crime.latitude, bikes.latitude) <= 3
			) AS sub
			GROUP BY 1
		) AS supersub
	WHERE supersub.total > '0'
	ORDER BY 9 DESC;

--Relative crimes by distance to stations and quarter
SELECT
	supersub.*
	FROM (
		SELECT
		sub.station_name,
		COALESCE(SUM(CASE WHEN date_month IN(1,2,3) THEN crime_totals END),'0') AS "Q1",
		COALESCE(SUM(CASE WHEN date_month IN(4,5,6) THEN crime_totals END),'0') AS "Q2",
		COALESCE(SUM(CASE WHEN date_month IN(7,8,9) THEN crime_totals END),'0') AS "Q3",
		COALESCE(SUM(CASE WHEN date_month IN(10,11,12) THEN crime_totals END),'0') AS "Q4",
		SUM(crime_totals) AS total
		FROM (
			SELECT
				station_name,
				date_part('month',date) AS date_month,
				CASE WHEN (69.0410421
					* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(bikes.latitude::DECIMAL))
					* COS(RADIANS(crime.latitude::DECIMAL))
					* COS(RADIANS(bikes.longitude::DECIMAL - crime.longitude::DECIMAL))
					+ SIN(RADIANS(bikes.latitude::DECIMAL))
					* SIN(RADIANS(crime.latitude::DECIMAL))))))::DECIMAL(7,3) < '0.3' THEN 1 END AS crime_totals
				FROM public.new_divvy_stations bikes
				INNER JOIN clean_crime crime
				ON levenshtein(crime.latitude, bikes.latitude) <= 3
			) AS sub
			GROUP BY 1
		) AS supersub
	WHERE supersub.total > '0'
	ORDER BY 6 DESC;

---Crimes by week
SELECT
	supersub.*
	FROM (
		SELECT
		sub.station_name,
		COALESCE(SUM(CASE WHEN EXTRACT(dow FROM sub.date) = 1 THEN crime_totals END), '0')::numeric AS "Sunday",
		COALESCE(SUM(CASE WHEN EXTRACT(dow FROM sub.date) = 2 THEN crime_totals END), '0')::numeric AS "Monday",
		COALESCE(SUM(CASE WHEN EXTRACT(dow FROM sub.date) = 3 THEN crime_totals END), '0')::numeric AS "Tuesday",
		COALESCE(SUM(CASE WHEN EXTRACT(dow FROM sub.date) = 4 THEN crime_totals END), '0')::numeric AS "Wednesday",
		COALESCE(SUM(CASE WHEN EXTRACT(dow FROM sub.date) = 5 THEN crime_totals END), '0')::numeric AS "Thursday",
		COALESCE(SUM(CASE WHEN EXTRACT(dow FROM sub.date) = 6 THEN crime_totals END), '0')::numeric AS "Friday",
		COALESCE(SUM(CASE WHEN EXTRACT(dow FROM sub.date) = 7 THEN crime_totals END), '0')::numeric AS "Saturday",
		SUM(crime_totals) AS total
		FROM (
			SELECT
				station_name,
				date,
				CASE WHEN (69.0410421
					* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(bikes.latitude::DECIMAL))
					* COS(RADIANS(crime.latitude::DECIMAL))
					* COS(RADIANS(bikes.longitude::DECIMAL - crime.longitude::DECIMAL))
					+ SIN(RADIANS(bikes.latitude::DECIMAL))
					* SIN(RADIANS(crime.latitude::DECIMAL))))))::DECIMAL(7,3) < '0.3' THEN 1 END AS crime_totals
				FROM public.new_divvy_stations bikes
				INNER JOIN clean_crime crime
				ON levenshtein(crime.latitude, bikes.latitude) <= 3
			) AS sub
			GROUP BY 1
		) AS supersub
	WHERE supersub.total > '0'
	ORDER BY 9 DESC;

-- Avg distances between bike stations
WITH t1 AS(
	SELECT 
		a.station_name AS from_station_name,
		b.station_name AS to_station_name,
		(69.0410421 
			* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(a.latitude::DECIMAL))
			* COS(RADIANS(b.latitude::DECIMAL))
			* COS(RADIANS(a.longitude::DECIMAL - b.longitude::DECIMAL))
			+ SIN(RADIANS(a.latitude::DECIMAL))
			* SIN(RADIANS(b.latitude::DECIMAL))))))::DECIMAL(7,3) AS distance
		FROM new_divvy_stations a
		JOIN new_divvy_stations b ON a.station_name != b.station_name
	)
	SELECT 
		'total' AS from_station_name,
		'' AS to_station_name,
		AVG(t1.distance)::decimal(4,3)
		FROM t1
		WHERE t1.distance < 
			(SELECT 
				(2* STDDEV(t1.distance)) 
				+ PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY t1.distance)
				FROM t1)				  
	UNION ALL
	SELECT 
		t1.*
		FROM t1
		WHERE t1.distance < 
			(SELECT 
			(2* STDDEV(t1.distance)) 
			+ PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY t1.distance)
			FROM t1);

--- Crimes by time of day:	
SELECT
	supersub.*
	FROM (
		SELECT
		sub.station_name,
		COALESCE(SUM(CASE WHEN sub.date_hour = 1 THEN crime_totals END), '0')::numeric AS "1:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 2 THEN crime_totals END), '0')::numeric AS "2:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 3 THEN crime_totals END), '0')::numeric AS "3:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 4 THEN crime_totals END), '0')::numeric AS "4:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 5 THEN crime_totals END), '0')::numeric AS "5:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 6 THEN crime_totals END), '0')::numeric AS "6:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 7 THEN crime_totals END), '0')::numeric AS "7:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 8 THEN crime_totals END), '0')::numeric AS "8:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 9 THEN crime_totals END), '0')::numeric AS "9:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 10 THEN crime_totals END), '0')::numeric AS "10:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 11 THEN crime_totals END), '0')::numeric AS "11:00 AM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 12 THEN crime_totals END), '0')::numeric AS "12:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 13 THEN crime_totals END), '0')::numeric AS "1:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 14 THEN crime_totals END), '0')::numeric AS "2:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 15 THEN crime_totals END), '0')::numeric AS "3:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 16 THEN crime_totals END), '0')::numeric AS "4:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 17 THEN crime_totals END), '0')::numeric AS "5:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 18 THEN crime_totals END), '0')::numeric AS "6:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 19 THEN crime_totals END), '0')::numeric AS "7:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 20 THEN crime_totals END), '0')::numeric AS "8:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 21 THEN crime_totals END), '0')::numeric AS "9:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 22 THEN crime_totals END), '0')::numeric AS "10:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 23 THEN crime_totals END), '0')::numeric AS "11:00 PM",
		COALESCE(SUM(CASE WHEN sub.date_hour = 24 THEN crime_totals END), '0')::numeric AS "12:00 AM",
		SUM(crime_totals) AS total
		FROM (
			SELECT
				station_name,
				date_part('hour',date) AS date_hour,
				CASE WHEN (69.0410421
					* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(bikes.latitude::DECIMAL))
					* COS(RADIANS(crime.latitude::DECIMAL))
					* COS(RADIANS(bikes.longitude::DECIMAL - crime.longitude::DECIMAL))
					+ SIN(RADIANS(bikes.latitude::DECIMAL))
					* SIN(RADIANS(crime.latitude::DECIMAL))))))::DECIMAL(7,3) < '0.3' THEN 1 END AS crime_totals
				FROM public.new_divvy_stations bikes
				INNER JOIN clean_crime crime
				ON levenshtein(crime.latitude, bikes.latitude) <= 3
			) AS sub
			GROUP BY 1
		) AS supersub
	WHERE supersub.total > '0'
	ORDER BY 26 DESC;

--- Crimes North of City Center
Select count(id)
FROM clean_crime
WHERE latitude::numeric > 41.879999

--- Crimes South of City Center
Select count(id)
FROM clean_crime
WHERE latitude::numeric < 41.879999


