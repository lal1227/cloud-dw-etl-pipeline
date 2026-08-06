"""
S3 ingestion utility for the cloud data warehouse ETL pipeline.

Uploads local raw data extracts to an S3 bucket under a date-partitioned
prefix, and provides a helper to download objects back for inspection.
"""

import os
from datetime import date

import boto3

BUCKET_NAME = "my-data-warehouse-raw-bucket"
RAW_DATA_DIR = "data/raw"
S3_PREFIX = "sales/raw"


def build_s3_client():
    return boto3.client("s3")


def build_object_key(filename, ingestion_date=None):
    ingestion_date = ingestion_date or date.today().isoformat()
    return f"{S3_PREFIX}/{ingestion_date}/{filename}"


def upload_file(s3_client, local_path, bucket=BUCKET_NAME):
    filename = os.path.basename(local_path)
    key = build_object_key(filename)
    s3_client.upload_file(local_path, bucket, key)
    print(f"Uploaded {local_path} to s3://{bucket}/{key}")
    return key


def upload_directory(s3_client, directory=RAW_DATA_DIR, bucket=BUCKET_NAME):
    uploaded_keys = []
    for filename in os.listdir(directory):
        local_path = os.path.join(directory, filename)
        if os.path.isfile(local_path):
            uploaded_keys.append(upload_file(s3_client, local_path, bucket))
    return uploaded_keys


def download_object(s3_client, key, destination_path, bucket=BUCKET_NAME):
    s3_client.download_file(bucket, key, destination_path)
    print(f"Downloaded s3://{bucket}/{key} to {destination_path}")


if __name__ == "__main__":
    client = build_s3_client()
    upload_directory(client)
