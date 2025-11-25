#!/bin/bash

# CPE Setup Script
# This script sets up the CPE for SD-WAN with IPsec tunnel to aggregator

echo "Setting up CPE..."

# Source common config
source ../common/config.sh

# Update system
sudo apt update 
sudo apt upgrade -y

# Install strongSwan and traffic control tools
sudo apt install -y strongswan iproute2

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

conn aggregator-tunnel
    left=%defaultroute
    leftsubnet=$CPE_SUBNET
    right=$AGGREGATOR_IP
    rightsubnet=0.0.0.0/0
    auto=start
EOF

# Configure secrets (pre-shared key)
sudo tee /etc/ipsec.secrets > /dev/null <<EOF
$AGGREGATOR_IP : PSK "your_shared_secret_here"
EOF

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo tee -a /etc/sysctl.conf > /dev/null <<'EOF'
net.ipv4.ip_forward=1
EOF

# Set up NAT
sudo iptables -t nat -A POSTROUTING -o $WAN_INTERFACE -j MASQUERADE
sudo iptables -A FORWARD -i $LAN_INTERFACE -o $WAN_INTERFACE -j ACCEPT
sudo iptables -A FORWARD -i $WAN_INTERFACE -o $LAN_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Save iptables rules
sudo apt install -y iptables-persistent
sudo netfilter-persistent save

# Bandwidth shaping script
sudo tee /usr/local/bin/bandwidth_shape.sh > /dev/null <<'EOF'
#!/bin/bash
# Bandwidth shaping for CPE
# Usage: ./bandwidth_shape.sh <interface> <rate_mbps>

INTERFACE=$1
RATE_MBPS=$2
BURST=$((RATE_MBPS * 125))  # Burst in kbps

sudo tc qdisc del dev $INTERFACE root 2>/dev/null
sudo tc qdisc add dev $INTERFACE root handle 1: htb default 10
sudo tc class add dev $INTERFACE parent 1: classid 1:1 htb rate ${RATE_MBPS}mbit burst ${BURST}kbit
sudo tc class add dev $INTERFACE parent 1:1 classid 1:10 htb rate ${RATE_MBPS}mbit burst ${BURST}kbit
EOF

sudo chmod +x /usr/local/bin/bandwidth_shape.sh

# Set up firewall
sudo ufw allow 500/udp
sudo ufw allow 4500/udp
sudo ufw --force enable

# Start IPsec
sudo systemctl enable strongswan
sudo systemctl start strongswan

# Note: After tunnel is established, add route to datacenter
# sudo ip route add $DATACENTER_SUBNET dev <tunnel_interface>  # e.g., ipsec0

echo "CPE setup complete. Run bandwidth_shape.sh to configure bandwidth."