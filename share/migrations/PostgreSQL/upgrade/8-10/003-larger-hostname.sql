;
BEGIN;

;
ALTER TABLE host ALTER COLUMN name TYPE character varying(64);

;

COMMIT;

