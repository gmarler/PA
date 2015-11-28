-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/3/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE vmstat DROP CONSTRAINT vmstat_host_fk_timestamp;

;
ALTER TABLE vmstat DROP CONSTRAINT vmstat_fk_host_fk;

;
DROP INDEX vmstat_idx_host_fk;

;
ALTER TABLE vmstat ADD CONSTRAINT vmstat_timestamp UNIQUE (timestamp);

;

COMMIT;

