-- Convert schema '/perfwork/gitwork/PA/share/migrations/_source/deploy/2/001-auto.yml' to '/perfwork/gitwork/PA/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE vmstat DROP CONSTRAINT vmstat_timestamp;

;
CREATE INDEX vmstat_idx_host_fk on vmstat (host_fk);

;
ALTER TABLE vmstat ADD CONSTRAINT vmstat_host_fk_timestamp UNIQUE (host_fk, timestamp);

;
ALTER TABLE vmstat ADD CONSTRAINT vmstat_fk_host_fk FOREIGN KEY (host_fk)
  REFERENCES host (host_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;

COMMIT;

