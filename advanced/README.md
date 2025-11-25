# Advanced SD-WAN Features

This folder contains enhancements for production SD-WAN deployments.

## Planned Features

- High Availability (HA) with failover.
- Monitoring and logging (Prometheus/Grafana).
- Certificate management.
- **Dynamic Configuration via APIs**: RESTful APIs for remote management (e.g., add CPE, adjust bandwidth, monitor tunnels).
- Load balancing and redundancy.
- Security hardening.

## Dynamic Configuration via APIs

This allows centralized, programmatic control of the SD-WAN setup without manual edits.

### What It Means
- **APIs**: REST endpoints (e.g., `/api/cpe/add`, `/api/bandwidth/set`) to configure tunnels, bandwidth, and policies dynamically.
- **Use Cases**: Integrate with a controller app, automate deployments, or allow web UIs for management.
- **Benefits**: Zero-touch provisioning, real-time adjustments, easier scaling.

### Example Implementation
- Use Flask (Python) or Node.js to create a simple API server on the aggregator.
- Endpoints:
  - `POST /api/cpe/add`: Add a new CPE with IP/subnet.
  - `PUT /api/bandwidth/set`: Change bandwidth for a CPE.
  - `GET /api/status`: Get tunnel statuses.
- Secure with API keys or OAuth.

## Setup

- For monitoring POC: Follow `prometheus_grafana_setup.md` for beginner-friendly Prometheus/Grafana setup.
- For API example: Install Flask (`pip install flask`), then run `python3 api_server.py` on aggregator.
- For OpenTelemetry: Install packages (`pip install opentelemetry-distro opentelemetry-exporter-otlp-proto-grpc psutil`), run `python3 otel_collector.py`.
- For custom dashboard: Open `custom_dashboard.html` in a browser (serve via Flask for data).
- TBD - Add more scripts and configs here as needed.