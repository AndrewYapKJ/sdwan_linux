# Beginner-Friendly Setup: Prometheus & Grafana for SD-WAN Monitoring

This guide sets up Prometheus and Grafana on your aggregator for monitoring SD-WAN metrics. It's a Proof of Concept (POC) to visualize tunnel status, bandwidth, and system health.

## Prerequisites
- Ubuntu aggregator (from basic setup).
- Internet access.
- Basic terminal skills.

## Step 1: Install Prometheus and Grafana
Run these commands on the aggregator:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Prometheus
sudo apt install -y prometheus

# Install Grafana
sudo apt install -y grafana

# Install Node Exporter (for system metrics)
sudo apt install -y prometheus-node-exporter

# Start services
sudo systemctl enable prometheus grafana-server prometheus-node-exporter
sudo systemctl start prometheus grafana-server prometheus-node-exporter
```

- Prometheus: Runs on port 9090.
- Grafana: Runs on port 3000 (default user: admin, password: admin—change it!).

## Step 2: Configure Prometheus
Prometheus collects metrics. Edit its config to scrape system and custom SD-WAN data.

1. Open config: `sudo nano /etc/prometheus/prometheus.yml`
2. Add under `scrape_configs`:

```yaml
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']  # Node Exporter for CPU, memory, disk

  - job_name: 'sdwan'
    static_configs:
      - targets: ['localhost:8000']  # Custom metrics endpoint (see below)
    scrape_interval: 10s
```

3. Restart: `sudo systemctl restart prometheus`

## Step 3: Create Custom SD-WAN Metrics
We need metrics for IPsec and bandwidth. Use the provided exporter script.

1. Copy `sdwan_exporter.py` to `/usr/local/bin/` and make executable: `sudo chmod +x /usr/local/bin/sdwan_exporter.py`
2. Install Python libs: `pip3 install prometheus_client psutil`
3. Run: `sudo /usr/local/bin/sdwan_exporter.py &` (background)

## Step 4: Set Up Grafana Dashboard
1. Open browser: `http://aggregator-ip:3000` (login: admin/admin)
2. Add Prometheus data source:
   - Go to Configuration > Data Sources > Add.
   - Type: Prometheus, URL: `http://localhost:9090`, Save.
3. Create dashboard:
   - Dashboards > New Dashboard > Add Panel.
   - Query: `sdwan_tunnel_up` (tunnel status), `sdwan_bandwidth_mbps` (bandwidth), etc.
   - Add graphs for CPU/Memory from Node Exporter (e.g., `100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`).
4. Save dashboard as "SD-WAN Monitor".

## Suitable Metrics for This Project
- **SD-WAN Specific**:
  - `sdwan_tunnel_up`: 1 if IPsec tunnel is up.
  - `sdwan_bandwidth_mbps`: Current bandwidth usage.
- **System Metrics** (from Node Exporter):
  - CPU usage: `100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
  - Memory: `100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)`
  - Network: `rate(node_network_receive_bytes_total[5m])` (bytes/sec)
- **Alerts**: Set up in Grafana/Prometheus for tunnel down or high usage.

## Testing
- Check Prometheus: `http://aggregator-ip:9090` > Status > Targets (should show up).
- Grafana: View dashboard; simulate load (e.g., ping flood) to see metrics change.
- Stop: `sudo systemctl stop prometheus grafana-server`

This is beginner-friendly—start here for POC! If issues, check logs: `sudo journalctl -u prometheus`. For advanced, expand with more exporters.