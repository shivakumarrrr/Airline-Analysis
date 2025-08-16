-- Creating flights table with the data type as varchar for all the columns to prevent the loading issues and after loading changed the data types to their respective data types...

CREATE TABLE flights (
    year VARCHAR(10),
    month VARCHAR(10),
    day VARCHAR(10),
    day_of_week VARCHAR(10),
    airline VARCHAR(10),
    flight_number VARCHAR(10),
    tail_number VARCHAR(20),
    origin_airport VARCHAR(10),
    destination_airport VARCHAR(10),
    scheduled_departure VARCHAR(10),
    departure_time VARCHAR(10),
    departure_delay VARCHAR(10),
    taxi_out VARCHAR(10),
    wheels_off VARCHAR(10),
    scheduled_time VARCHAR(10),
    elapsed_time VARCHAR(10),
    air_time VARCHAR(10),
    distance VARCHAR(10),
    wheels_on VARCHAR(10),
    taxi_in VARCHAR(10),
    scheduled_arrival VARCHAR(10),
    arrival_time VARCHAR(10),
    arrival_delay VARCHAR(10),
    diverted VARCHAR(10),
    cancelled VARCHAR(10),
    cancellation_reason VARCHAR(10),
    air_system_delay VARCHAR(10),
    security_delay VARCHAR(10),
    airline_delay VARCHAR(10),
    late_aircraft_delay VARCHAR(10),
    weather_delay VARCHAR(10)
);

-- Loading CSV files into data base:
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/flights.csv'
INTO TABLE flights
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Handling missing values in airports table:

UPDATE airports SET longitude = NULL WHERE longitude = '';

UPDATE airports SET latitude = NULL WHERE latitude = '';

-- Year, Month, Day, Day_of_Week
-- Updating null values in flights table and changing their data types:

UPDATE flights SET year = NULL WHERE year = '';
ALTER TABLE flights MODIFY COLUMN year SMALLINT;

UPDATE flights SET month = NULL WHERE month = '';
ALTER TABLE flights MODIFY COLUMN month TINYINT;

UPDATE flights SET day = NULL WHERE day = '';
ALTER TABLE flights MODIFY COLUMN day TINYINT;

UPDATE flights SET day_of_week = NULL WHERE day_of_week = '';
ALTER TABLE flights MODIFY COLUMN day_of_week TINYINT;

UPDATE flights SET airline = NULL WHERE airline = '';
ALTER TABLE flights MODIFY COLUMN airline CHAR(2);


-- Flight Info
UPDATE flights SET flight_number = NULL WHERE flight_number = '';
ALTER TABLE flights MODIFY COLUMN flight_number INT;

-- Tail number
UPDATE flights SET tail_number = NULL WHERE tail_number = '';
ALTER TABLE flights MODIFY COLUMN tail_number VARCHAR(10);

-- Airports (3-char codes)
UPDATE flights SET origin_airport = NULL WHERE origin_airport = '';
ALTER TABLE flights MODIFY COLUMN origin_airport VARCHAR(10);

UPDATE flights SET destination_airport = NULL WHERE destination_airport = '';
ALTER TABLE flights MODIFY COLUMN destination_airport VARCHAR(10);


-- Delays & Durations
UPDATE flights SET departure_delay = NULL WHERE departure_delay = '';
ALTER TABLE flights MODIFY COLUMN departure_delay INT;

UPDATE flights SET arrival_delay = NULL WHERE arrival_delay = '';
ALTER TABLE flights MODIFY COLUMN arrival_delay INT;

UPDATE flights SET taxi_out = NULL WHERE taxi_out = '';
ALTER TABLE flights MODIFY COLUMN taxi_out INT;

UPDATE flights SET taxi_in = NULL WHERE taxi_in = '';
ALTER TABLE flights MODIFY COLUMN taxi_in INT;

UPDATE flights SET air_system_delay = NULL WHERE air_system_delay = '';
ALTER TABLE flights MODIFY COLUMN air_system_delay INT;

UPDATE flights SET security_delay = NULL WHERE security_delay = '';
ALTER TABLE flights MODIFY COLUMN security_delay INT;

UPDATE flights SET airline_delay = NULL WHERE airline_delay = '';
ALTER TABLE flights MODIFY COLUMN airline_delay INT;

UPDATE flights SET late_aircraft_delay = NULL WHERE late_aircraft_delay = '';
ALTER TABLE flights MODIFY COLUMN late_aircraft_delay INT;

UPDATE flights SET weather_delay = NULL WHERE weather_delay = '';
ALTER TABLE flights MODIFY COLUMN weather_delay INT;

UPDATE flights SET elapsed_time = NULL WHERE elapsed_time = '';
ALTER TABLE flights MODIFY COLUMN elapsed_time INT;

UPDATE flights SET scheduled_time = NULL WHERE scheduled_time = '';
ALTER TABLE flights MODIFY COLUMN scheduled_time INT;

UPDATE flights SET air_time = NULL WHERE air_time = '';
ALTER TABLE flights MODIFY COLUMN air_time INT;

UPDATE flights SET distance = NULL WHERE distance = '';
ALTER TABLE flights MODIFY COLUMN distance INT;


-- Cancelled / Diverted (Flags)
UPDATE flights SET cancelled = NULL WHERE cancelled = '';
ALTER TABLE flights MODIFY COLUMN cancelled TINYINT(1);

UPDATE flights SET diverted = NULL WHERE diverted = '';
ALTER TABLE flights MODIFY COLUMN diverted TINYINT(1);


-- Cancellation Reason (keep as 1-char code)
UPDATE flights SET cancellation_reason = NULL WHERE cancellation_reason = '';
ALTER TABLE flights MODIFY COLUMN cancellation_reason CHAR(1);


-- Time Fields (Keep as CHAR(4) for now - will clean/convert later)
UPDATE flights SET scheduled_departure = NULL WHERE scheduled_departure = '';
ALTER TABLE flights MODIFY COLUMN scheduled_departure CHAR(4);

UPDATE flights SET departure_time = NULL WHERE departure_time = '';
ALTER TABLE flights MODIFY COLUMN departure_time CHAR(4);

UPDATE flights SET wheels_off = NULL WHERE wheels_off = '';
ALTER TABLE flights MODIFY COLUMN wheels_off CHAR(4);

UPDATE flights SET wheels_on = NULL WHERE wheels_on = '';
ALTER TABLE flights MODIFY COLUMN wheels_on CHAR(4);

UPDATE flights SET scheduled_arrival = NULL WHERE scheduled_arrival = '';
ALTER TABLE flights MODIFY COLUMN scheduled_arrival CHAR(4);

UPDATE flights SET arrival_time = NULL WHERE arrival_time = '';
ALTER TABLE flights MODIFY COLUMN arrival_time CHAR(4);


-- Handle invalid 2400 (set to midnight)
UPDATE flights
SET scheduled_departure = '0000'
WHERE scheduled_departure = '2400';

-- Pad short times to 4-digit HHMM
UPDATE flights
SET scheduled_departure = LPAD(scheduled_departure, 4, '0')
WHERE scheduled_departure IS NOT NULL AND CHAR_LENGTH(scheduled_departure) < 4;

-- Create a New DATE TIME Column:

ALTER TABLE flights ADD COLUMN scheduled_departure_dt DATETIME;

--Combine Date + Time into DATETIME

UPDATE flights
SET scheduled_departure_dt = STR_TO_DATE(
  CONCAT(year, '-', LPAD(month,2,'0'), '-', LPAD(day,2,'0'), ' ', scheduled_departure),
  '%Y-%m-%d %H%i'
)
WHERE scheduled_departure IS NOT NULL;

-- FOR Remaining Columns:

1.
ALTER TABLE flights ADD COLUMN arrival_time_dt DATETIME;

UPDATE flights
SET arrival_time = '0000' WHERE arrival_time = '2400';
UPDATE flights SET arrival_time = LPAD(arrival_time, 4, '0') WHERE CHAR_LENGTH(arrival_time) < 4 AND arrival_time IS NOT NULL;


UPDATE flights
SET arrival_time_dt = STR_TO_DATE(
  CONCAT(year, '-', LPAD(month,2,'0'), '-', LPAD(day,2,'0'), ' ', arrival_time),
  '%Y-%m-%d %H%i'
)
WHERE arrival_time IS NOT NULL;

2.
ALTER TABLE flights ADD COLUMN departure_time_dt DATETIME;

UPDATE flights
SET departure_time = '0000' WHERE departure_time = '2400';
UPDATE flights SET departure_time = LPAD(departure_time, 4, '0') WHERE CHAR_LENGTH(departure_time) < 4 AND departure_time IS NOT NULL;


UPDATE flights
SET departure_time_dt = STR_TO_DATE(
  CONCAT(year, '-', LPAD(month,2,'0'), '-', LPAD(day,2,'0'), ' ', departure_time),
  '%Y-%m-%d %H%i'
)
WHERE departure_time IS NOT NULL;

3.
ALTER TABLE flights ADD COLUMN wheels_off_dt DATETIME;

UPDATE flights
SET wheels_off = '0000' WHERE wheels_off = '2400';
UPDATE flights SET wheels_off = LPAD(wheels_off, 4, '0') WHERE CHAR_LENGTH(wheels_off) < 4 AND wheels_off IS NOT NULL;


UPDATE flights
SET wheels_off_dt = STR_TO_DATE(
  CONCAT(year, '-', LPAD(month,2,'0'), '-', LPAD(day,2,'0'), ' ', wheels_off),
  '%Y-%m-%d %H%i'
)
WHERE wheels_off IS NOT NULL;

4.
ALTER TABLE flights ADD COLUMN scheduled_arrival_dt DATETIME;

UPDATE flights
SET scheduled_arrival = '0000' WHERE scheduled_arrival = '2400';
UPDATE flights SET scheduled_arrival = LPAD(scheduled_arrival, 4, '0') WHERE CHAR_LENGTH(scheduled_arrival) < 4 AND scheduled_arrival IS NOT NULL;


UPDATE flights
SET scheduled_arrival_dt = STR_TO_DATE(
  CONCAT(year, '-', LPAD(month,2,'0'), '-', LPAD(day,2,'0'), ' ', scheduled_arrival),
  '%Y-%m-%d %H%i'
)
WHERE scheduled_arrival IS NOT NULL;

5.
ALTER TABLE flights ADD COLUMN wheels_on_dt DATETIME;

UPDATE flights
SET wheels_on = '0000' WHERE wheels_on = '2400';
UPDATE flights SET wheels_on = LPAD(wheels_on, 4, '0') WHERE CHAR_LENGTH(wheels_on) < 4 AND wheels_on IS NOT NULL;


UPDATE flights
SET wheels_on_dt = STR_TO_DATE(
  CONCAT(year, '-', LPAD(month,2,'0'), '-', LPAD(day,2,'0'), ' ', wheels_on),
  '%Y-%m-%d %H%i'
)
WHERE wheels_on IS NOT NULL;

-- Descriptive CANCELLATION_REASON_DESC Column

| Code | Meaning          |
| ---- | ---------------- |
| A    | Airline/Carrier  |
| B    | Weather          |
| C    | NAS (Air System) |
| D    | Security         |
| NULL | Not Cancelled    |

-- Add the column
ALTER TABLE flights ADD COLUMN cancellation_reason_desc VARCHAR(50);

-- Fill the description
UPDATE flights
SET cancellation_reason_desc = CASE cancellation_reason
    WHEN 'A' THEN 'Airline/Carrier'
    WHEN 'B' THEN 'Weather'
    WHEN 'C' THEN 'NAS (Air System)'
    WHEN 'D' THEN 'Security'
    ELSE 'Not Cancelled'
END;
SELECT cancellation_reason_desc
FROM flights
LIMIT 200;

-- Create a FLIGHT_DATE Column

ALTER TABLE flights ADD COLUMN flight_date DATE;


UPDATE flights
SET flight_date = STR_TO_DATE(
    CONCAT(year, '-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
    '%Y-%m-%d'
);

-- Integrating all tables into a single table

CREATE TABLE flights_analytics AS
SELECT
    -- Date fields
    f.year,
    f.month,
    f.day,
    f.day_of_week,
    f.flight_date,
    
    -- Airline info
    f.airline,
    al.airline AS airline_name,
    
    -- Flight details
    f.flight_number,
    f.tail_number,
    
    -- Origin airport details
    f.origin_airport,
    ao.airport AS origin_airport_name,
    ao.city AS origin_city,
    ao.state AS origin_state,
    ao.country AS origin_country,
    ao.latitude AS origin_latitude,
    ao.longitude AS origin_longitude,
    
    -- Destination airport details
    f.destination_airport,
    ad.airport AS destination_airport_name,
    ad.city AS destination_city,
    ad.state AS destination_state,
    ad.country AS destination_country,
    ad.latitude AS destination_latitude,
    ad.longitude AS destination_longitude,
    
    -- Flight timings
    f.scheduled_departure_dt,
    f.departure_time_dt,
    f.wheels_off_dt,
    f.arrival_time_dt,
    
    -- Delays
    f.departure_delay,
    f.arrival_delay,
    f.air_system_delay,
    f.security_delay,
    f.airline_delay,
    f.late_aircraft_delay,
    f.weather_delay,
    
    -- Flags & distance
    f.cancelled,
    f.diverted,
    f.cancellation_reason,

    -- Descriptive cancellation reason
    CASE f.cancellation_reason
        WHEN 'A' THEN 'Airline/Carrier'
        WHEN 'B' THEN 'Weather'
        WHEN 'C' THEN 'NAS (Air System)'
        WHEN 'D' THEN 'Security'
        ELSE 'Not Cancelled'
    END AS cancellation_reason_desc,

    f.distance
FROM flights f
LEFT JOIN (
    SELECT iata_code, MAX(airline) AS airline
    FROM airlines
    GROUP BY iata_code
) al ON f.airline = al.iata_code
LEFT JOIN (
    SELECT iata_code,
           MAX(airport) AS airport,
           MAX(city) AS city,
           MAX(state) AS state,
           MAX(country) AS country,
           MAX(latitude) AS latitude,
           MAX(longitude) AS longitude
    FROM airports
    GROUP BY iata_code
) ao ON f.origin_airport = ao.iata_code
LEFT JOIN (
    SELECT iata_code,
           MAX(airport) AS airport,
           MAX(city) AS city,
           MAX(state) AS state,
           MAX(country) AS country,
           MAX(latitude) AS latitude,
           MAX(longitude) AS longitude
    FROM airports
    GROUP BY iata_code
) ad ON f.destination_airport = ad.iata_code;

-- Exploratory Data Analysis (EDA) & KPI Definition (SQL)
-- Total flights, cancelled, diverted:

SELECT 
    COUNT(*) AS total_flights,
    SUM(cancelled) AS total_cancelled,
    SUM(diverted) AS total_diverted
FROM flights_analytics;

-- Cancellation counts by reason:
SELECT 
    cancellation_reason_desc,
    COUNT(*) AS cancelled_flights
FROM flights_analytics
WHERE cancelled = 1
GROUP BY cancellation_reason_desc
ORDER BY cancelled_flights DESC;

-- Basic Statistics for Departure and Arrival Delays:
-- Average, Min, Max:
SELECT 
    AVG(departure_delay) AS avg_dep_delay,
    MIN(departure_delay) AS min_dep_delay,
    MAX(departure_delay) AS max_dep_delay,
    AVG(arrival_delay) AS avg_arr_delay,
    MIN(arrival_delay) AS min_arr_delay,
    MAX(arrival_delay) AS max_arr_delay
FROM flights_analytics
WHERE cancelled = 0; 

-- Median (requires a workaround since MySQL has no direct median):

SELECT @mid := FLOOR(COUNT(*)/2)
FROM flights_analytics
WHERE cancelled = 0;

-- Fetch the median departure delay
SELECT departure_delay AS median_dep_delay
FROM flights_analytics
WHERE cancelled = 0
ORDER BY departure_delay
LIMIT 1 OFFSET @mid;

-- Distribution of Delay Types:
-- Aggregate distribution (sum by type):
SELECT
    SUM(airline_delay) AS total_airline_delay,
    SUM(weather_delay) AS total_weather_delay,
    SUM(air_system_delay) AS total_nas_delay,
    SUM(security_delay) AS total_security_delay,
    SUM(late_aircraft_delay) AS total_late_aircraft_delay
FROM flights_analytics
WHERE cancelled = 0;

-- Average per flight:
SELECT
    AVG(airline_delay) AS avg_airline_delay,
    AVG(weather_delay) AS avg_weather_delay,
    AVG(air_system_delay) AS avg_nas_delay,
    AVG(security_delay) AS avg_security_delay,
    AVG(late_aircraft_delay) AS avg_late_aircraft_delay
FROM flights_analytics
WHERE cancelled = 0;

-- Key Performance Indicators (KPIs) relevant to the project objectives:
-- On-Time Performance (OTP) Rate:
SELECT 
    ROUND(100 * SUM(CASE WHEN arrival_delay <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS otp_rate_percent
FROM flights_analytics
WHERE cancelled = 0;

-- Average Arrival & Departure Delay (in Minutes):
SELECT 
    ROUND(AVG(arrival_delay), 2) AS avg_arrival_delay,
    ROUND(AVG(departure_delay), 2) AS avg_departure_delay
FROM flights_analytics
WHERE cancelled = 0;

-- Cancellation Rate:
SELECT 
    ROUND(100 * SUM(cancelled) / COUNT(*), 2) AS cancellation_rate_percent
FROM flights_analytics;

-- Percentage Contribution of Each Delay Type:
SELECT 
    ROUND(100 * SUM(airline_delay) / SUM(airline_delay + weather_delay + air_system_delay + security_delay + late_aircraft_delay), 2) AS airline_pct,
    ROUND(100 * SUM(weather_delay) / SUM(airline_delay + weather_delay + air_system_delay + security_delay + late_aircraft_delay), 2) AS weather_pct,
    ROUND(100 * SUM(air_system_delay) / SUM(airline_delay + weather_delay + air_system_delay + security_delay + late_aircraft_delay), 2) AS nas_pct,
    ROUND(100 * SUM(security_delay) / SUM(airline_delay + weather_delay + air_system_delay + security_delay + late_aircraft_delay), 2) AS security_pct,
    ROUND(100 * SUM(late_aircraft_delay) / SUM(airline_delay + weather_delay + air_system_delay + security_delay + late_aircraft_delay), 2) AS late_aircraft_pct
FROM flights_analytics
WHERE cancelled = 0;

-- Initial aggregations to understand how these KPIs vary by:
-- KPIs by Airline:
SELECT
    airline_name,
    COUNT(*) AS total_flights,
    ROUND(100 * SUM(CASE WHEN arrival_delay <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS otp_rate_percent,
    ROUND(AVG(arrival_delay), 2) AS avg_arrival_delay,
    ROUND(AVG(departure_delay), 2) AS avg_departure_delay,
    ROUND(100 * SUM(cancelled) / COUNT(*), 2) AS cancellation_rate_percent
FROM flights_analytics
GROUP BY airline_name
ORDER BY otp_rate_percent DESC;

-- KPIs by Origin and Destination Airports:
-- Origin:
SELECT
    origin_airport_name,
    origin_city,
    COUNT(*) AS total_departures,
    ROUND(AVG(departure_delay), 2) AS avg_dep_delay,
    ROUND(100 * SUM(cancelled) / COUNT(*), 2) AS cancellation_rate_percent
FROM flights_analytics
GROUP BY origin_airport_name, origin_city
ORDER BY avg_dep_delay DESC
LIMIT 20;

-- Destination:
SELECT
    destination_airport_name,
    destination_city,
    COUNT(*) AS total_arrivals,
    ROUND(AVG(arrival_delay), 2) AS avg_arr_delay,
    ROUND(100 * SUM(cancelled) / COUNT(*), 2) AS cancellation_rate_percent
FROM flights_analytics
GROUP BY destination_airport_name, destination_city
ORDER BY avg_arr_delay DESC
LIMIT 20;

-- KPIs by Month:
SELECT
    MONTH(flight_date) AS month,
    COUNT(*) AS total_flights,
    ROUND(100 * SUM(CASE WHEN arrival_delay <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS otp_rate_percent,
    ROUND(AVG(arrival_delay), 2) AS avg_arrival_delay,
    ROUND(AVG(departure_delay), 2) AS avg_departure_delay,
    ROUND(100 * SUM(cancelled) / COUNT(*), 2) AS cancellation_rate_percent
FROM flights_analytics
GROUP BY MONTH(flight_date)
ORDER BY month;

-- KPIs by Day of Week:
SELECT
    day_of_week,
    COUNT(*) AS total_flights,
    ROUND(100 * SUM(CASE WHEN arrival_delay <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS otp_rate_percent,
    ROUND(AVG(arrival_delay), 2) AS avg_arrival_delay,
    ROUND(AVG(departure_delay), 2) AS avg_departure_delay,
    ROUND(100 * SUM(cancelled) / COUNT(*), 2) AS cancellation_rate_percent
FROM flights_analytics
GROUP BY day_of_week
ORDER BY day_of_week;

-- KPIs by Time of Day:
-- Creating dep_hour Column First;
ALTER TABLE flights_analytics ADD COLUMN dep_hour TINYINT;

UPDATE flights_analytics
SET dep_hour = HOUR(scheduled_departure_dt);

-- Grouping by time blocks (e.g., every 4 hours):
SELECT
    CONCAT(FLOOR(dep_hour/4)*4, '-', FLOOR(dep_hour/4)*4+3) AS time_block,
    COUNT(*) AS total_flights,
    ROUND(100 * SUM(CASE WHEN arrival_delay <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS otp_rate_percent,
    ROUND(AVG(arrival_delay), 2) AS avg_arrival_delay,
    ROUND(AVG(departure_delay), 2) AS avg_departure_delay
FROM flights_analytics
GROUP BY CONCAT(FLOOR(dep_hour/4)*4, '-', FLOOR(dep_hour/4)*4+3)
ORDER BY MIN(dep_hour);




