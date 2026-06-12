# ---------- Stage 1: Builder ----------
FROM python:3.12-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ---------- Stage 2: Runtime ----------
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r appuser && \
    useradd -r -g appuser -u 1001 appuser

COPY --from=builder /install /usr/local

COPY src/ .

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
CMD curl -f http://localhost:5000/health || exit 1

ARG DEPLOY_TIME

ENV DEPLOY_TIME=${DEPLOY_TIME}

CMD [
    "gunicorn",
    "--bind",
    "0.0.0.0:5000",
    "--workers",
    "2",
    "--threads",
    "2",
    "--timeout",
    "30",
    "--access-logfile",
    "-",
    "--error-logfile",
    "-",
    "--log-level",
    "info",
    "main:app"
]