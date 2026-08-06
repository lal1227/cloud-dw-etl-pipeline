-- Snowflake stage, file format, and COPY INTO definitions for the sales ETL pipeline.

CREATE OR REPLACE FILE FORMAT sales_csv_format
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

CREATE OR REPLACE STAGE sales_raw_stage
  URL = 's3://my-data-warehouse-raw-bucket/sales/raw/'
  FILE_FORMAT = sales_csv_format;

CREATE TABLE IF NOT EXISTS staging.sales_raw (
    order_id NUMBER,
    order_date DATE,
    region STRING,
    product STRING,
    quantity NUMBER,
    unit_price NUMBER(10, 2)
);

COPY INTO staging.sales_raw
FROM @sales_raw_stage
FILE_FORMAT = (FORMAT_NAME = sales_csv_format);
