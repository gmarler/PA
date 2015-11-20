-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Thu Nov 19 18:18:56 2015
-- 
;
--
-- Table: host
--
CREATE TABLE "host" (
  "host_id" serial NOT NULL,
  "name" character varying(32) NOT NULL,
  "time_zone" character varying(64) NOT NULL,
  PRIMARY KEY ("host_id")
);

;
--
-- Table: vmstat
--
CREATE TABLE "vmstat" (
  "vmstat_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "freemem" bigint NOT NULL,
  PRIMARY KEY ("vmstat_id"),
  CONSTRAINT "vmstat_timestamp" UNIQUE ("timestamp")
);

;
