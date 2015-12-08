DROP TABLE rate;

CREATE TABLE rate(
  -- id       bigserial,
  snaptime bigint,
  hits     bigint
  -- PRIMARY KEY( id )
);


INSERT INTO rate ( hits, snaptime )
       VALUES (50588538, 7650606632271230);
INSERT INTO rate ( hits, snaptime )
       VALUES (50588904, 7650607634514240);
INSERT INTO rate ( hits, snaptime )
       VALUES (50588955, 7650608636493120);
INSERT INTO rate ( hits, snaptime )
       VALUES (50588959, 7650609639240740);
INSERT INTO rate ( hits, snaptime )
       VALUES (50589175, 7650610641724880);
INSERT INTO rate ( hits, snaptime )
       VALUES (50589251, 7650611643101720);
INSERT INTO rate ( hits, snaptime )
       VALUES (50589288, 7650612645459620);

SELECT prev_snaptime, snaptime, prev_hits, hits,
       (hits - prev_hits) AS hit_diff,
       ((snaptime - prev_snaptime) ) AS snaptime_diff,
       ((hits - prev_hits) / ((snaptime - prev_snaptime) / 1000000000)) AS rate_per_sec
FROM
  (SELECT snaptime, hits,
          lag(hits) OVER (ORDER BY snaptime ASC) as prev_hits,
          lag(snaptime) OVER (ORDER BY snaptime ASC) as prev_snaptime
   FROM
     rate
   ORDER BY
     snaptime ASC) as w1;






