-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/7/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/6/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE vmstat DROP COLUMN swap;

;
ALTER TABLE vmstat DROP COLUMN sr;

;
ALTER TABLE vmstat DROP COLUMN w;

;
DROP TABLE memstat CASCADE;

;

COMMIT;

