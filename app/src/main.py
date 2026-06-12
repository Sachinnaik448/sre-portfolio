from flask import Flask

from config import Config

app = Flask(__name__)


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