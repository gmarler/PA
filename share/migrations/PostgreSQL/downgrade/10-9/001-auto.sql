-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/10/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/8/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE host ALTER COLUMN name TYPE character varying(32);

;

COMMIT;

