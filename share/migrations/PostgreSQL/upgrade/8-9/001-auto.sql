-- Convert schema '/home/gmarler/gitwork/PA/share/migrations/_source/deploy/8/001-auto.yml' to '/home/gmarler/gitwork/PA/share/migrations/_source/deploy/9/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "fsoplatjson" (
  "fsoplatjson_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "interval_data" json NOT NULL,
  PRIMARY KEY ("fsoplatjson_id")
);
CREATE INDEX "fsoplatjson_idx_host_fk" on "fsoplatjson" ("host_fk");

;
CREATE TABLE "timeseriesgap" (
  "entity_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "value" bigint NOT NULL
);

;
ALTER TABLE "fsoplatjson" ADD CONSTRAINT "fsoplatjson_fk_host_fk" FOREIGN KEY ("host_fk")
  REFERENCES "host" ("host_id") DEFERRABLE;

;

COMMIT;

