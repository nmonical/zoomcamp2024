CREATE MATERIALIZED VIEW latest_pickup_time AS
    WITH t AS (
        SELECT MAX(tpep_pickup_datetime) AS latest_pickup_time
        FROM trip_data
    )
    SELECT taxi_zone.Zone as taxi_zone, latest_pickup_time
    FROM t,
            trip_data
    JOIN taxi_zone
        ON trip_data.PULocationID = taxi_zone.location_id
    WHERE trip_data.tpep_pickup_datetime = t.latest_pickup_time;

DROP MATERIALIZED VIEW pickup_time;
CREATE MATERIALIZED VIEW pickup_time AS
    SELECT taxi_zone.Zone as taxi_zone, trip_data.tpep_pickup_datetime as pickup
    FROM taxi_zone
    JOIN trip_data
    ON taxi_zone.location_id=trip_data.PULocationID;

CREATE MATERIALIZED VIEW time_bet_zones AS
  SELECT taxi_zone_pu.Zone AS pu_taxi_zone,
         taxi_zone_do.Zone AS do_taxi_zone,
         MAX(tpep_dropoff_datetime - tpep_pickup_datetime) AS high,
         MIN(tpep_dropoff_datetime - tpep_pickup_datetime) AS low,
         AVG(tpep_dropoff_datetime - tpep_pickup_datetime) AS mid,
         COUNT(*)
  FROM trip_data
  JOIN taxi_zone taxi_zone_pu ON trip_data.PULocationID = taxi_zone_pu.location_id
  JOIN taxi_zone taxi_zone_do ON trip_data.DOLocationID = taxi_zone_do.location_id
  GROUP BY taxi_zone_pu.Zone, taxi_zone_do.Zone;

SELECT * FROM time_bet_zones
ORDER BY mid DESC
LIMIT 5;

DROP MATERIALIZED VIEW time_bet_zones;

CREATE MATERIALIZED VIEW time_bet_zones AS
  SELECT taxi_zone_pu.Zone AS pu_taxi_zone,
         taxi_zone_do.Zone AS do_taxi_zone,
         MAX(tpep_dropoff_datetime - tpep_pickup_datetime) AS high,
         MIN(tpep_dropoff_datetime - tpep_pickup_datetime) AS low,
         AVG(tpep_dropoff_datetime - tpep_pickup_datetime) AS mid,
         COUNT(*)
  FROM trip_data
  JOIN taxi_zone taxi_zone_pu ON trip_data.PULocationID = taxi_zone_pu.location_id
  JOIN taxi_zone taxi_zone_do ON trip_data.DOLocationID = taxi_zone_do.location_id
  GROUP BY taxi_zone_pu.Zone, taxi_zone_do.Zone;

SELECT * FROM time_bet_zones
ORDER BY mid DESC
LIMIT 5;

SELECT taxi_zone, COUNT(*)
FROM latest_pickup_time
WHERE latest_pickup_time BETWEEN latest_pickup_time AND (latest_pickup_time - 17)
GROUP BY taxi_zone
ORDER BY COUNT(*)
LIMIT 5;

WITH last_pickup AS (SELECT max(latest_pickup_time) max FROM latest_pickup_time) 
SELECT taxi_zone, COUNT(*) FROM pickup_time, last_pickup 
WHERE pickup BETWEEN max - interval '17 hours' AND max
GROUP BY taxi_zone
ORDER BY COUNT(*) DESC
LIMIT 5
