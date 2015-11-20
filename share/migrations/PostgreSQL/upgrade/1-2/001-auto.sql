-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/1/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "vmstat" (
  "vmstat_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "freemem" bigint NOT NULL,
  PRIMARY KEY ("vmstat_id"),
  CONSTRAINT "vmstat_timestamp" UNIQUE ("timestamp")
);

;

COMMIT;

