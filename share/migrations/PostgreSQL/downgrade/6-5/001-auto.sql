-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/6/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/5/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE arcstat DROP COLUMN snaptime;

;

COMMIT;

