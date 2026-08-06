# Cloud Data Warehouse ETL Pipeline

A cloud-oriented ETL pipeline that ingests raw sales data into Amazon S3, loads it into a cloud data warehouse (Redshift or Snowflake), and transforms it using PL/SQL-style stored procedures. DevOps tooling (Docker and a GitHub Actions workflow) packages and validates the pipeline on every push.

## Architecture

📥 `ingestion/s3_ingestion.py` uploads raw CSV extracts to an S3 bucket using boto3, organized by ingestion date, and can also download objects back for local inspection.

🏗️ `sql/redshift_schema.sql` defines the staging and warehouse table DDL for Amazon Redshift, including a COPY command that loads directly from S3 into the staging table.

❄️ `sql/snowflake_load.sql` defines an equivalent Snowflake stage, file format, and COPY INTO statement for warehouses running on Snowflake instead of Redshift.

🧮 `plsql/transform_procedures.sql` contains PL/SQL-style stored procedures that transform and upsert staged rows into the final warehouse fact table, handling deduplication and null-safe aggregation.

🐳 `docker/Dockerfile` containerizes the Python ingestion component so it can run consistently in any environment.

⚙️ `.github/workflows/ci.yml` is a GitHub Actions workflow that installs dependencies, lints the Python code, and validates the SQL files on every push, representing the DevOps layer of the pipeline.

## Tech Stack

- Python and boto3 for S3 ingestion
- Amazon S3 as the raw data landing zone
- Amazon Redshift and Snowflake SQL for warehouse loading (COPY / COPY INTO)
- PL/SQL-style stored procedures for in-warehouse transformation
- Docker for containerized execution
- GitHub Actions for continuous integration

## How It Works

Raw sales extracts are uploaded to S3 under a date-partitioned prefix. A COPY (Redshift) or COPY INTO (Snowflake) statement loads the raw files from S3 into a staging table in the warehouse. Stored procedures then clean, deduplicate, and aggregate the staged rows into a final fact table used for reporting. The GitHub Actions workflow validates the Python and SQL on every push so issues are caught before deployment.

## Running Locally

This is a portfolio/demo project; no real AWS, Redshift, or Snowflake credentials are included. To try it out, set your own bucket name and warehouse connection details in `config/pipeline_config.yaml`, install dependencies from `requirements.txt`, and run `python ingestion/s3_ingestion.py` to see the upload logic. The SQL files can be run against a real Redshift or Snowflake instance once connection details are configured.
