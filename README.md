# cloud-dw-etl-pipeline

ETL pipeline for loading sales data into a cloud warehouse - S3 for landing raw files, then Redshift or Snowflake for the actual warehouse, with a Docker + GitHub Actions setup so it's not just scripts sitting around.

## Layout

- `ingestion/s3_ingestion.py` - uploads raw CSVs to S3, partitioned by date
- `sql/redshift_schema.sql` - staging/fact tables + COPY from S3 (Redshift version)
- `sql/snowflake_load.sql` - same idea but for Snowflake (stage + COPY INTO)
- `plsql/transform_procedures.sql` - dedupe + upsert into the fact table
- `docker/Dockerfile` - containerizes the ingestion script
- `.github/workflows/ci.yml` - basic CI, installs deps and checks the SQL files exist

## Why both Redshift and Snowflake

Wanted to show I can work with either since job postings are split pretty evenly between the two. Same staging table shape either way, just different load syntax.

## Running it

No real AWS/warehouse creds in here - it's a demo. Fill in `config/pipeline_config.yaml` with your own bucket/warehouse details, then `pip install -r requirements.txt` and run the ingestion script. SQL files are meant to be run against an actual Redshift/Snowflake instance once you've got one.
