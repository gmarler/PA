-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Nov 24 16:45:38 2015
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
  CONSTRAINT "vmstat_host_fk_timestamp" UNIQUE ("host_fk", "timestamp")
);
CREATE INDEX "vmstat_idx_host_fk" on "vmstat" ("host_fk");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "vmstat" ADD CONSTRAINT "vmstat_fk_host_fk" FOREIGN KEY ("host_fk")
  REFERENCES "host" ("host_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
