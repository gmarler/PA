-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/4/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE vmstat ADD CONSTRAINT vmstat_host_fk_timestamp UNIQUE (host_fk, timestamp);

;
DROP TABLE arcstat CASCADE;

;
DROP TABLE fsoplat CASCADE;

;

COMMIT;

