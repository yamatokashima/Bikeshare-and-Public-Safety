# Bikeshare and Public Safety

### I examined Divvy Bike and Chicago crime data to make suggestions on relocation and addition of new bike stations focusing on public safety.

![Rides Per Year](https://user-images.githubusercontent.com/101782618/228023345-2bf7e24a-a231-4ada-b5ac-a90e209e112e.png)


I worked with following datasets:
* Divvy Bkeshare Stations
* Divvy Ridership
* City of Chicago Crime Date

After downloading the data and uploading it into pgAdmin, I cleaned the data down significantly. 

The most notable changes:
* All data was cut down to just the time period 2016 - 2022
* Crime data was cleaned to just “relevant” crimes in “relevant” locations (violent crimes that a typical pedestrian or bike rider would reasonably have to worry about)
* I removed station ID’s that did not exist in the referential Divvy Stations table
* I rounded all other trips to the nearest minute
* I removed any outliers (data more than 2 standard deviations from the mean)

Access all original datasources and my updated datasources [here](https://drive.google.com/drive/folders/1wU45gss6v1pX1oZ_xKAccQ8hZRW5DsWK?usp=sharing)

### Finding distance of crimes to bike stations:
I was originally going to use fuzzy joins using the Levenshtein formula seen here:

	SELECT
		station_name,
		date,
		CASE WHEN (69.0410421
			* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(bikes.latitude::DECIMAL))
			* COS(RADIANS(crime.latitude::DECIMAL))
			* COS(RADIANS(bikes.longitude::DECIMAL - crime.longitude::DECIMAL))
			+ SIN(RADIANS(bikes.latitude::DECIMAL))
			* SIN(RADIANS(crime.latitude::DECIMAL))))))::DECIMAL(7,3) < '0.3' THEN 1 END AS crime_totals
	FROM 
		public.new_divvy_stations AS bikes
	INNER JOIN 
		clean_crime AS crime
	ON 
		levenshtein(crime.latitude, bikes.latitude) <= 3
				
but realized that Levenshtein’s formula is only good when using text/strings. Values like coordinates are much more precise and I wanted to be as accurate as possible with the findings so I transitioned to using CTE’s to combine tables then running the following formula that calculate stations within 0.2 miles of a bike station:
	
	COUNT(DISTINCT(CASE WHEN (69.0410421 
			* DEGREES(ACOS(LEAST(1.0, COS(RADIANS(latitude1::DECIMAL))
			* COS(RADIANS(latitude2::DECIMAL))
			* COS(RADIANS(longitude1::DECIMAL longitude2::DECIMAL))
			+ SIN(RADIANS(latitude1::DECIMAL))
			* SIN(RADIANS(latitude2::DECIMAL))))))::DECIMAL(7,3) < '0.2' THEN “ “ END)) AS “ “

### Trends:
By looking at current ridership and crime data, we can see a resurgence of ridership in Chicago's inner city opposed to the surrounding suburban areas as a result of the pandemic. The data shows that the majority of the crimes occur in areas frequented by Divvy riders such as sidewalks, streets, and alleyways, and many of these reports do not result in arrests.
Also when looking at “relevant” crimes, crimes were trending downwards over the past several years but it’s too soon to tell if this trend is a result of the pandemic or if the city is becoming less dangerous. 
I also noticed a rise in ridership which could indicate that the city is becoming more bike-friendly by promoting alternative modes of transportation.
Seeing these patterns allowed me to take a more targeted approach and when looking at specific areas in downtown Chicago, a notable concentration of crime was found along known as the Magnificent Mile. It will be inmportant to look into crime per capita to see if we're seeing heightened crime solely due to increased traffic. Upon inspection of a bike lane and route map the city provides, it is clear that there are no Divvy bike stations located along the Mag Mile, despite it being a high-traffic commercial area.

### Recommendations:
When looking at certain areas around the Mag Mile to add new bike share stations, one potential location could be along the Chicago Riverwalk near the Columbus Drive bridge, as it is a well-known tourist spot. This location was chosen over the Michigan Ave bridge due to the lack of bike accessibility on that bridge. Another place to consider would be on the northern end of the Mag Mile, near several restaurants and large shopping districts. Both of these would reduce the need for riders to travel far by foot and by having the stations placed in high-traffic areas, it may also assist in deterring crime due to an increased level of visibility.

### Alternative Recommendations:
* Avoiding routes that pass through high-crime areas
* Allowing and encouraging riders to report emergencies directly through the Divvy app. Now I understand that there are several legal implications to this, so we would want to do some additional research before pursuing this option.
* Recommending safer routes through the app, even if they may take longer to reach certain destinations.
* Recommending lock boxes for riders to store their valuables to help deter theft

### Conclusion:
Am amalgamation of these steps will not only help to improve the overall experience for bike share riders but also promote the sustainable and safe use of bike sharing services.
