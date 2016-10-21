;
BEGIN;

;
CREATE TABLE "timeseriesgap" (
  "entity_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "value" bigint NOT NULL
);

;

COMMIT;
