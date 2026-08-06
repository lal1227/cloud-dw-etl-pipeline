-- Redshift staging and warehouse table definitions for the sales ETL pipeline.

CREATE TABLE IF NOT EXISTS staging.sales_raw (
    order_id BIGINT,
    order_date DATE,
    region VARCHAR(50),
    product VARCHAR(100),
    quantity INTEGER,
    unit_price DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS warehouse.sales_fact (
    order_id BIGINT PRIMARY KEY,
    order_date DATE NOT NULL,
    region VARCHAR(50) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_revenue DECIMAL(12, 2) NOT NULL
);

COPY staging.sales_raw
FROM 's3://my-data-warehouse-raw-bucket/sales/raw/'
IAM_ROLE 'arn:aws:iam::123456789012:role/RedshiftLoadRole'
FORMAT AS CSV
IGNOREHEADER 1;
