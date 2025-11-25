#!/usr/bin/env python3
from prometheus_client import start_http_server, Gauge
import subprocess
import time
import psutil

# Metrics
tunnel_up = Gauge('sdwan_tunnel_up', 'IPsec tunnel status (1=up, 0=down)')
bandwidth_mbps = Gauge('sdwan_bandwidth_mbps', 'Bandwidth usage in Mbps')
cpu_percent = Gauge('sdwan_cpu_percent', 'CPU usage percent')
mem_percent = Gauge('sdwan_mem_percent', 'Memory usage percent')

def get_tunnel_status():
    try:
        result = subprocess.run(['ipsec', 'status'], capture_output=True, text=True)
        return 1 if 'ESTABLISHED' in result.stdout else 0
    except Exception:
        return 0

def get_bandwidth(interface='eth0'):
    net = psutil.net_io_counters(pernic=True).get(interface)
    if net:
        return (net.bytes_sent + net.bytes_recv) / 1024 / 1024  # MB
    return 0

if __name__ == '__main__':
    start_http_server(8000)  # Expose metrics on port 8000
    while True:
        tunnel_up.set(get_tunnel_status())
        bandwidth_mbps.set(get_bandwidth())
        cpu_percent.set(psutil.cpu_percent())
        mem_percent.set(psutil.virtual_memory().percent)
        time.sleep(10)