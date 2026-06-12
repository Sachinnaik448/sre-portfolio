from prometheus_client import Counter, Gauge, Histogram
import psutil


HTTP_REQUESTS_TOTAL = Counter(
    "http_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status_code"],
)

HTTP_REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["endpoint"],
    buckets=(
        0.005,
        0.01,
        0.025,
        0.05,
        0.1,
        0.25,
        0.5,
        1.0,
        2.5,
    ),
)

APP_INFO = Gauge(
    "app_info",
    "Application information",
    ["version", "region", "environment"],
)

MEMORY_USAGE = Gauge(
    "memory_usage_bytes",
    "Current memory usage in bytes",
)

CPU_USAGE = Gauge(
    "cpu_usage_percent",
    "Current CPU usage percentage",
)


def update_system_metrics():
    """
    Update CPU and memory metrics.
    """

    MEMORY_USAGE.set(psutil.virtual_memory().used)

    CPU_USAGE.set(psutil.cpu_percent(interval=0))