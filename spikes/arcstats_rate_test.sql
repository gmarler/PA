SELECT ((hits - prev_hits) / ( (snaptime::float - prev_snaptime::float) / 1000000000.0 ))::bigint AS hit_rate_per_sec
FROM
  (SELECT snaptime, hits,
          lag(hits) OVER (ORDER BY snaptime ASC) as prev_hits,
          lag(snaptime) OVER (ORDER BY snaptime ASC) as prev_snaptime
   FROM
     arcstat
   ORDER BY
     snaptime ASC) as w1
WHERE
  (hits - prev_hits) > 0 AND
  (snaptime - prev_snaptime) > 0
  ;






