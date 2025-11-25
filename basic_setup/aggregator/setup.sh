#!/bin/bash

# Aggregator Setup Script
# This script sets up the aggregator (SO) for SD-WAN with IPsec

# Source common config
source ../common/config.sh

# Update system
sudo apt update && sudo apt upgrade -y

# Install strongSwan
sudo apt install -y strongswan

# Configure IPsec
sudo cp /etc/ipsec.conf /etc/ipsec.conf.backup
sudo tee /etc/ipsec.conf > /dev/null <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn %default
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    keyexchange=ikev2
    authby=secret

conn cpe-tunnel
    left=%defaultroute
    leftsubnet=0.0.0.0/0
    right=%any
    rightsubnet=192.168.1.0/24  # CPE subnet
    rightid=%any
    rightsourceip=$CPE_VIP_POOL  # Pool for CPE virtual IPs
    auto=add
EOF

# Configure secrets
sudo tee /etc/ipsec.secrets > /dev/null <<EOF
%any : PSK "your_shared_secret_here"
EOF

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo tee -a /etc/sysctl.conf > /dev/null <<'EOF'
net.ipv4.ip_forward=1
EOF

# Set up firewall rules (using ufw)
sudo ufw allow 500/udp
sudo ufw allow 4500/udp
sudo ufw --force enable

# Start IPsec
sudo systemctl daemon-reload
sudo systemctl enable strongswan
sudo systemctl start strongswan

echo "Aggregator setup complete."