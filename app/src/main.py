from flask import Flask, g, request

from config import Config

from metrics import (
    APP_INFO,
    CPU_USAGE,
    HTTP_REQUEST_DURATION,
    HTTP_REQUESTS_TOTAL,
    MEMORY_USAGE,
    update_system_metrics,
)

import json
import time
APP_START_TIME = time.time()
import uuid

from datetime import datetime, UTC

app = Flask(__name__)
APP_INFO.labels(
    version=Config.APP_VERSION,
    region=Config.AWS_REGION,
    environment=Config.ENVIRONMENT,
).set(1)


@app.before_request
def before_request():
    """
    Runs before every incoming request.
    """

    g.request_id = str(uuid.uuid4())

    g.start_time = time.time()


@app.after_request
def after_request(response):
    """
    Runs after every request.
    """

    duration_ms = round(
        (time.time() - g.start_time) * 1000,
        2,
    )

    response.headers["X-Request-ID"] = g.request_id

    log_data = {
        "timestamp": datetime.now(UTC).isoformat(),
        "level": "INFO",
        "method": request.method,
        "path": request.path,
        "status_code": response.status_code,
        "duration_ms": duration_ms,
        "request_id": g.request_id,
    }

    HTTP_REQUESTS_TOTAL.labels(
        method=request.method,
        endpoint=request.path,
        status_code=response.status_code,
    ).inc()

    HTTP_REQUEST_DURATION.labels(
        endpoint=request.path,
    ).observe(duration_ms / 1000)

    print(json.dumps(log_data))

    return response


@app.route("/")
def home():
    return f"""
    <html>
        <head>
            <title>AWS SRE Platform</title>
        </head>

        <body>
            <h1>AWS SRE Platform</h1>

            <hr>

            <p><strong>Status:</strong> Operational ✅</p>

            <p><strong>Version:</strong> {Config.APP_VERSION}</p>

            <p><strong>AWS Region:</strong> {Config.AWS_REGION}</p>

            <p><strong>Environment:</strong> {Config.ENVIRONMENT}</p>

            <p><strong>Deploy Time:</strong> {Config.DEPLOY_TIME}</p>

        </body>
    </html>
    """


@app.route("/health")
def health():
    uptime = round(
        time.time() - APP_START_TIME,
        2,
    )

    return {
        "status": "healthy",
        "service": "aws-sre-platform",
        "version": Config.APP_VERSION,
        "region": Config.AWS_REGION,
        "environment": Config.ENVIRONMENT,
        "deploy_time": Config.DEPLOY_TIME,
        "request_id": g.request_id,
        "timestamp": datetime.now(UTC).isoformat(),
        "uptime_seconds": uptime,
    }, 200


from prometheus_client import generate_latest
from flask import Response


@app.route("/metrics")
def metrics():
    update_system_metrics()

    return Response(
        generate_latest(),
        mimetype="text/plain",
    )


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
    )