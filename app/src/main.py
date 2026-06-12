from flask import Flask, g, request

from config import Config

import json
import time
import uuid

from datetime import datetime

app = Flask(__name__)


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
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "level": "INFO",
        "method": request.method,
        "path": request.path,
        "status_code": response.status_code,
        "duration_ms": duration_ms,
        "request_id": g.request_id,
    }

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
    return {
        "status": "healthy",
        "version": Config.APP_VERSION,
        "region": Config.AWS_REGION,
        "environment": Config.ENVIRONMENT,
    }, 200


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
    )