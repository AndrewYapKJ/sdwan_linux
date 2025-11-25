#!/usr/bin/env python3
"""
OpenTelemetry Collector for SD-WAN Metrics
Collects IPsec, bandwidth, and system metrics, exports to console/OTLP.

Run: pip install opentelemetry-distro opentelemetry-exporter-otlp-proto-grpc
Then: python3 otel_collector.py
"""

from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import ConsoleMetricExporter, PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
import subprocess
import time
import psutil

# Set up OpenTelemetry
reader = PeriodicExportingMetricReader(
    exporters=[ConsoleMetricExporter(), OTLPMetricExporter(endpoint="http://localhost:4317", insecure=True)],
    export_interval_millis=10000  # Export every 10s
)
provider = MeterProvider(metric_readers=[reader])
metrics.set_meter_provider(provider)
meter = metrics.get_meter("sdwan-monitor")

# Define metrics
tunnel_up = meter.create_gauge("tunnel_up", description="IPsec tunnel status (1=up, 0=down)")
bandwidth_usage = meter.create_gauge("bandwidth_mbps", description="Current bandwidth usage")
cpu_usage = meter.create_gauge("cpu_percent", description="CPU usage percent")
memory_usage = meter.create_gauge("memory_percent", description="Memory usage percent")

def get_ipsec_status():
    try:
        result = subprocess.run(['ipsec', 'status'], capture_output=True, text=True)
        return 1 if "ESTABLISHED" in result.stdout else 0
    except Exception:
        return 0

def get_bandwidth(interface="eth0"):
    # Simplified: Use psutil or tc stats
    net_io = psutil.net_io_counters(pernic=True).get(interface)
    if net_io:
        return (net_io.bytes_sent + net_io.bytes_recv) / 1024 / 1024  # MB
    return 0

while True:
    tunnel_up.set(get_ipsec_status())
    bandwidth_usage.set(get_bandwidth())
    cpu_usage.set(psutil.cpu_percent())
    memory_usage.set(psutil.virtual_memory().percent)
    time.sleep(5)  # Update every 5s