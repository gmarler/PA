-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/6/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/7/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "memstat" (
  "memstat_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "free_cachelist_bytes" bigint NOT NULL,
  "free_cachelist_page_count" integer NOT NULL,
  "free_cachelist_pct_of_total" smallint NOT NULL,
  "defdump_prealloc_bytes" bigint NOT NULL,
  "defdump_prealloc_page_count" integer NOT NULL,
  "defdump_prealloc_pct_of_total" smallint NOT NULL,
  "exec_and_libs_bytes" bigint NOT NULL,
  "exec_and_libs_page_count" integer NOT NULL,
  "exec_and_libs_pct_of_total" smallint NOT NULL,
  "free_freelist_bytes" bigint NOT NULL,
  "free_freelist_page_count" integer NOT NULL,
  "free_freelist_pct_of_total" smallint NOT NULL,
  "zfs_file_data_bytes" bigint NOT NULL,
  "zfs_file_data_page_count" integer NOT NULL,
  "zfs_file_data_pct_of_total" smallint NOT NULL,
  "anon_bytes" bigint NOT NULL,
  "anon_page_count" integer NOT NULL,
  "anon_pct_of_total" smallint NOT NULL,
  "page_cache_bytes" bigint NOT NULL,
  "page_cache_page_count" integer NOT NULL,
  "page_cache_pct_of_total" smallint NOT NULL,
  "zfs_metadata_bytes" bigint NOT NULL,
  "zfs_metadata_page_count" integer NOT NULL,
  "zfs_metadata_pct_of_total" smallint NOT NULL,
  "kernel_bytes" bigint NOT NULL,
  "kernel_page_count" integer NOT NULL,
  "kernel_pct_of_total" smallint NOT NULL,
  "total_bytes" bigint NOT NULL,
  "total_page_count" integer NOT NULL,
  "total_pct_of_total" smallint NOT NULL,
  PRIMARY KEY ("memstat_id")
);
CREATE INDEX "memstat_idx_host_fk" on "memstat" ("host_fk");

;
ALTER TABLE "memstat" ADD CONSTRAINT "memstat_fk_host_fk" FOREIGN KEY ("host_fk")
  REFERENCES "host" ("host_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE vmstat ADD COLUMN swap bigint NOT NULL;

;
ALTER TABLE vmstat ADD COLUMN sr integer NOT NULL;

;
ALTER TABLE vmstat ADD COLUMN w integer NOT NULL;

;

COMMIT;

