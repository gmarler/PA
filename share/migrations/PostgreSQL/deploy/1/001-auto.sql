-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Thu Nov 19 16:08:32 2015
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
