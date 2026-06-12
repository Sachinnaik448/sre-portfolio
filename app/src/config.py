import os
from datetime import datetime

import boto3
from botocore.exceptions import ClientError


class Config:
    APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
    AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
    ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
    DEPLOY_TIME = os.getenv(
        "DEPLOY_TIME",
        datetime.utcnow().isoformat() + "Z",
    )
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")


def get_ssm_parameter(name: str, default=None):
    """
    Read a parameter from AWS Systems Manager Parameter Store.

    If unavailable (for example during local development),
    fall back to an environment variable or the provided default.
    """

    try:
        client = boto3.client(
            "ssm",
            region_name=Config.AWS_REGION,
        )

        response = client.get_parameter(
            Name=name,
            WithDecryption=True,
        )

        return response["Parameter"]["Value"]

    except ClientError:
        env_name = name.split("/")[-1].upper()
        return os.getenv(env_name, default)