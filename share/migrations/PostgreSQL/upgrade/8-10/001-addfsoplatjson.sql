;
BEGIN;

;
CREATE TABLE "fsoplatjson" (
  "fsoplatjson_id" serial NOT NULL,
  "host_fk" integer NOT NULL,
  "timestamp" timestamptz NOT NULL,
  "interval_data" jsonb NOT NULL,
  PRIMARY KEY ("fsoplatjson_id")
);
CREATE INDEX "fsoplatjson_idx_host_fk" on "fsoplatjson" ("host_fk");

;
ALTER TABLE "fsoplatjson" ADD CONSTRAINT "fsoplatjson_fk_host_fk" FOREIGN KEY ("host_fk")
  REFERENCES "host" ("host_id") DEFERRABLE;

;
COMMIT;
