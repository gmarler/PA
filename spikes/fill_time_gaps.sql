-- SELECT timestamp, kernel_bytes FROM memstat WHERE
--   (
--     (DATE(timestamp AT TIME ZONE 'America/New_York') = '2016-04-27')
--     AND
--     ((timestamp AT TIME ZONE 'America/New_York')::time > '17:10:00')
--     AND
--     (host_fk = 7)
--   )
--   ORDER by timestamp ASC
--   ;
--
-- WITH filled_timestamps AS (
--   SELECT time, 0 AS empty_data FROM
--       generate_series('2016-04-27 17:10:00'::timestamptz AT TIME ZONE 'America/New_York',
--                       '2016-04-27 17:30:00'::timestamptz AT TIME ZONE 'America/New_York',
--                       '1 min')
--         AS time
-- ),
-- kbytes AS (
--   SELECT timestamp, kernel_bytes FROM memstat WHERE
--   (
--     (DATE(timestamp AT TIME ZONE 'America/New_York') = '2016-04-27')
--     AND
--     ((timestamp AT TIME ZONE 'America/New_York')::time > '17:10:00')
--     AND
--     (host_fk = 7)
--   )
--   GROUP BY host_fk, timestamp, kernel_bytes
-- )
-- SELECT filled_timestamps.time,
--        coalesce(kbytes.kernel_bytes, filled_timestamps.empty_data) AS kernel_bytes
--   FROM filled_timestamps
--     LEFT OUTER JOIN kbytes ON kbytes.timestamp = filled_timestamps.time
--   ORDER BY filled_timestamps.time;

DROP SCHEMA tmp CASCADE;
CREATE SCHEMA tmp ;
SET search_path = tmp;

DROP TABLE IF EXISTS data_table CASCADE;

CREATE TABLE data_table (
  entity_fk   INTEGER,
  timestamp   timestamptz,
  value       BIGINT
);

INSERT INTO data_table(entity_fk, timestamp, value) VALUES
 ( 7,  '2016-04-05 13:00:00',           1)
,( 7,  '2016-04-05 13:00:32',           2)
,( 7,  '2016-04-05 13:01:14',           3)
,( 7,  '2016-04-05 13:01:54',           4)
,( 7,  '2016-04-05 13:02:49',           5)
,( 7,  '2016-04-05 13:03:39',           6)
,( 7,  '2016-04-05 13:23:00',           7)
,( 7,  '2016-04-05 13:23:48',           8)
,( 7,  '2016-04-05 13:25:04',           9)
             ;

SELECT entity_fk, timestamp AT TIME ZONE 'America/New_York', value FROM data_table;

WITH
ts_after_midnight AS (
  SELECT timestamp FROM data_table
  WHERE data_table.entity_fk = 7 AND
        timestamp >= '2016-04-05 00:00:00'::timestamptz AT TIME ZONE 'America/New_York'
  ORDER BY data_table.timestamp ASC
  LIMIT 1
),
-- null_ts_after midnight
null_ts_after_midnight AS (
  SELECT entity_fk,
         (ts_after_midnight.timestamp - interval '1 second') AS timestamp,
         'NaN' AS value
  FROM ts_after_midnight
  LEFT JOIN data_table
  ON entity_fk = 7
  LIMIT 1
),
ts_before_midnight AS (
  SELECT timestamp FROM data_table
  WHERE data_table.entity_fk = 7 AND
        timestamp <= '2016-04-05 23:59:59'::timestamptz AT TIME ZONE 'America/New_York'
  ORDER BY data_table.timestamp DESC
  LIMIT 1
),
-- null_ts_before midnight
null_ts_before_midnight AS (
  SELECT entity_fk,
         (ts_before_midnight.timestamp + interval '1 second') AS timestamp,
         'NaN' AS value
  FROM ts_before_midnight
  LEFT JOIN data_table
  ON entity_fk = 7
  LIMIT 1
),
real_ts AS (
  SELECT entity_fk, timestamp, value
  FROM data_table
  WHERE data_table.entity_fk = 7
)
SELECT entity_fk, timestamp AT TIME ZONE 'America/New_York', value
  FROM null_ts_after_midnight
  JOIN real_ts
  ON null_ts_after_midnight.entity_fk = real_ts.entity_fk
  ;

-- SELECT entity_fk, timestamp, value, ntile(5) OVER (ORDER BY timestamp ASC)
-- FROM data_table;
SELECT entity_fk, timestamp AT TIME ZONE 'America/New_York', value FROM data_table
  ORDER BY timestamp ASC
  LIMIT 1;
