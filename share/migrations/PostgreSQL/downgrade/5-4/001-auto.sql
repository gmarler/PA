-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/5/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE arcstat ADD COLUMN data_freed bigint NOT NULL;

;

COMMIT;

