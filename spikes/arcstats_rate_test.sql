SELECT prev_timestamp, timestamp, prev_hits, hits,
       (hits - prev_hits) AS hit_diff,
       ((timestamp - prev_timestamp) ) AS timestamp_diff,
       ((hits - prev_hits) / ((timestamp - prev_timestamp) / 1000000000)) AS rate_per_sec
FROM
  (SELECT timestamp, hits,
          lag(hits) OVER (ORDER BY timestamp ASC) as prev_hits,
          lag(timestamp) OVER (ORDER BY timestamp ASC) as prev_timestamp
   FROM
     rate
   ORDER BY
     timestamp ASC) as w1;






