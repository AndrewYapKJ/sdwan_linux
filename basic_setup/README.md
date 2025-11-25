# SD-WAN Linux Implementation

This project implements a Software-Defined Wide Area Network (SD-WAN) solution using Linux, with IPsec tunnels between a Service Orchestrator (SO)/Aggregator and Customer Premises Equipment (CPE).

## Components

- **Aggregator (SO)**: Central server that aggregates connections from multiple CPEs.
- **CPE**: Customer router that connects to the aggregator via IPsec tunnel and provides access to datacenter servers.

## Features

- IPsec tunnel using strongSwan (IKEv2 with PSK for both aggregator and CPE).
- CPE acting as router with NAT and routing.
- Bandwidth shaping (configurable 100Mbps/200Mbps).
- Virtual IP pool for CPEs (dynamic assignment from aggregator).
- Secure access to datacenter servers over internet (MPLS alternative).

## Setup

1. Edit `common/config.sh` with your network settings (IPs, subnets, pools).
2. On the aggregator machine, run `aggregator/setup.sh` (sets up IPsec server with certs and VIP pool).
3. On each CPE machine, run `cpe/setup.sh` (connects via IPsec, gets VIP from pool).
4. On CPE, configure bandwidth: `cpe/configure_bandwidth.sh 100` or `cpe/configure_bandwidth.sh 200`.
5. Ensure IPsec tunnel is up: `sudo ipsec status` (CPE gets a VIP from the pool).
6. Routes are set for datacenter access via tunnel.

## Notes

- This provides MPLS-like connectivity over IPsec without physical MPLS infrastructure.
- For multiple CPEs, each connects to the aggregator and gets a unique VIP.
- Update PSK in `/etc/ipsec.secrets` securely.
- In production, use certificates on CPEs too.

## Directories

- `aggregator/`: Scripts and configs for the aggregator.
- `cpe/`: Scripts and configs for the CPE.
- `common/`: Shared utilities and configurations.