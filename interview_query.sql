-- Notes:
-- `tianhong_west.ride_data` contains yellow taxi trip records for 2023 (currently available until Sep 2023)
-- `tianhong_west.location_lookup` contains taxi zone look up data
-- there are some data issues (e.g., pick up time not in 2023), so as an initial explore, filter on the pick time is used in all queries
-- pickup time is used to attribute rides to a date and time slot instead of drop off time

--2.1
SELECT COUNT(*) FROM tianhong_west.ride_data DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01';

--2.2
SELECT DATE_TRUNC(tpep_pickup_datetime, MONTH) AS month, COUNT(*) AS count
FROM tianhong_west.ride_data 
WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01'
GROUP BY 1 ORDER BY 2 LIMIT 1;

SELECT DATE_TRUNC(tpep_pickup_datetime, MONTH) AS month, COUNT(*) AS count
FROM tianhong_west.ride_data 
WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01'
GROUP BY 1 ORDER BY 2 DESC LIMIT 1;

--2.3
WITH reveue_per_month AS (
  SELECT DATE_TRUNC(tpep_pickup_datetime, MONTH) AS month, SUM(fare_amount) AS revenue 
  FROM tianhong_west.ride_data 
  WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01'
  GROUP BY 1
)
SELECT month, revenue, 'month with most revenue' AS metric FROM reveue_per_month QUALIFY RANK() OVER (ORDER BY revenue DESC) = 1
UNION ALL 
SELECT month, revenue, 'month with least revenue' AS metric FROM reveue_per_month QUALIFY RANK() OVER (ORDER BY revenue) = 1

--2.4
SELECT AVG(tip_amount) FROM tianhong_west.ride_data WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01';

--2.5
SELECT DATE_TRUNC(tpep_pickup_datetime, MONTH) AS month, AVG(tip_amount) / SUM(fare_amount) AS tip_pct
FROM tianhong_west.ride_data 
WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01'
GROUP BY 1 ORDER BY 2 DESC LIMIT 1;

--2.6 
-- for plotting
SELECT TIME(tpep_pickup_datetime) AS time_of_day, COUNT(*) AS count
FROM tianhong_west.ride_data 
WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01'
GROUP BY 1;

--2.7
SELECT lkup1.zone AS pickup_zone, lkup2.zone AS dropoff_zone, COUNT(*) AS count
FROM tianhong_west.ride_data ride
  LEFT JOIN tianhong_west.location_lookup lkup1
    ON ride.PULocationID = lkup1.LocationID
  LEFT JOIN tianhong_west.location_lookup lkup2
    ON ride.DOLocationID = lkup2.LocationID
WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01'
GROUP BY 1,2 ORDER BY 2 DESC LIMIT 1;

--2.8
-- for plotting
SELECT PULocationID, DOLocationID, COUNT(*) AS count
FROM tianhong_west.ride_data 
WHERE DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01'
GROUP BY 1,2;

--2.9
-- Result shows significant small percent of trip with tip when trip is really short (less than 1 mile)
SELECT ROUND(trip_distance, 1) AS dist, COUNTIF(tip_amount > 0) / COUNT(*) AS trip_with_tip_pct
FROM tianhong_west.ride_data
WHERE (DATE_TRUNC(tpep_pickup_datetime, MONTH) BETWEEN '2023-01-01' AND '2023-09-01')
  AND trip_distance > 0 AND trip_distance < 50 
GROUP BY 1 ORDER BY 1;
