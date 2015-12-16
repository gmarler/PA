-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Dec 15 17:59:34 2015
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
-- Table: arcstat
--
CREATE TABLE "arcstat" (
  "arcstat_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "snaptime" bigint NOT NULL,
  "buf_size" bigint NOT NULL,
  "c" bigint NOT NULL,
  "c_max" bigint NOT NULL,
  "c_min" bigint NOT NULL,
  "data_size" bigint NOT NULL,
  "deleted" bigint NOT NULL,
  "demand_data_hits" bigint NOT NULL,
  "demand_data_misses" bigint NOT NULL,
  "demand_metadata_hits" bigint NOT NULL,
  "demand_metadata_misses" bigint NOT NULL,
  "evict_mfu" bigint NOT NULL,
  "evict_mru" bigint NOT NULL,
  "hits" bigint NOT NULL,
  "l2_hits" bigint NOT NULL,
  "l2_misses" bigint NOT NULL,
  "l2_persistence_hits" bigint NOT NULL,
  "l2_read_bytes" bigint NOT NULL,
  "l2_rw_clash" bigint NOT NULL,
  "l2_size" bigint NOT NULL,
  "memory_throttle_count" bigint NOT NULL,
  "meta_limit" bigint NOT NULL,
  "meta_max" bigint NOT NULL,
  "meta_used" bigint NOT NULL,
  "mfu_ghost_hits" bigint NOT NULL,
  "mfu_hits" bigint NOT NULL,
  "misses" bigint NOT NULL,
  "mru_ghost_hits" bigint NOT NULL,
  "mru_hits" bigint NOT NULL,
  "mutex_miss" bigint NOT NULL,
  "other_size" bigint NOT NULL,
  "p" bigint NOT NULL,
  "prefetch_behind_prefetch" bigint NOT NULL,
  "prefetch_data_hits" bigint NOT NULL,
  "prefetch_data_misses" bigint NOT NULL,
  "prefetch_joins" bigint NOT NULL,
  "prefetch_meta_size" bigint NOT NULL,
  "prefetch_metadata_hits" bigint NOT NULL,
  "prefetch_metadata_misses" bigint NOT NULL,
  "prefetch_reads" bigint NOT NULL,
  "prefetch_size" bigint NOT NULL,
  "size" bigint NOT NULL,
  PRIMARY KEY ("arcstat_id")
);
CREATE INDEX "arcstat_idx_host_fk" on "arcstat" ("host_fk");

;
--
-- Table: fsoplat
--
CREATE TABLE "fsoplat" (
  "fsoplat_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "fsop" character varying(12) NOT NULL,
  "fstype" character varying(8) NOT NULL,
  "latrange" int8range NOT NULL,
  "count" integer NOT NULL,
  PRIMARY KEY ("fsoplat_id")
);
CREATE INDEX "fsoplat_idx_host_fk" on "fsoplat" ("host_fk");

;
--
-- Table: vmstat
--
CREATE TABLE "vmstat" (
  "vmstat_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "freemem" bigint NOT NULL,
  PRIMARY KEY ("vmstat_id")
);
CREATE INDEX "vmstat_idx_host_fk" on "vmstat" ("host_fk");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "arcstat" ADD CONSTRAINT "arcstat_fk_host_fk" FOREIGN KEY ("host_fk")
  REFERENCES "host" ("host_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "fsoplat" ADD CONSTRAINT "fsoplat_fk_host_fk" FOREIGN KEY ("host_fk")
  REFERENCES "host" ("host_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "vmstat" ADD CONSTRAINT "vmstat_fk_host_fk" FOREIGN KEY ("host_fk")
  REFERENCES "host" ("host_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
