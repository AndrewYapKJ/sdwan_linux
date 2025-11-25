#!/bin/bash

# Standalone Cloud Server Setup for SD-WAN Aggregator
# Run this on a fresh Ubuntu cloud instance (e.g., AWS EC2)
# Assumes public IP is set; adjust variables as needed.

# Variables (edit these)
PUBLIC_IP="3.1.23.200"  # Your instance's public IP
PSK="your_shared_secret_here"  # Same PSK for CPE

echo "Starting SD-WAN Aggregator Setup on Cloud Server..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y strongswan ufw git

# Configure UFW firewall
sudo ufw --force reset
sudo ufw allow ssh
sudo ufw allow 500/udp
sudo ufw allow 4500/udp
sudo ufw --force enable

# Generate self-signed certs (optional, for future use)
# sudo apt install -y strongswan-pki
# sudo ipsec pki --gen --type rsa --size 2048 --outform pem > serverKey.pem
# sudo ipsec pki --pub --in serverKey.pem --type rsa | sudo ipsec pki --issue --lifetime 3650 --cacert caCert.pem --cakey caKey.pem --dn "C=US, O=SDWAN, CN=$PUBLIC_IP" --san $PUBLIC_IP --flag serverAuth --outform pem > serverCert.pem
# sudo mv *.pem /etc/ipsec.d/

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
    rightsubnet=192.168.1.0/24
    rightid=%any
    rightsourceip=10.0.1.0/24
    auto=add
EOF

# Configure secrets
sudo tee /etc/ipsec.secrets > /dev/null <<EOF
%any : PSK "$PSK"
EOF

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# Start IPsec
sudo systemctl daemon-reload
sudo systemctl enable strongswan
sudo systemctl start strongswan

# Test connectivity
echo "Testing connectivity..."
ping -c 3 8.8.8.8  # Test internet
if [ $? -eq 0 ]; then
    echo "Internet connectivity: OK"
else
    echo "Internet connectivity: FAILED"
fi

# Check IPsec status
sudo ipsec status

echo "Setup complete! Public IP: $PUBLIC_IP"
echo "Security Rules Reminder:"
echo "- AWS Security Group: Allow SSH (22/TCP), UDP 500/4500 from 0.0.0.0/0"
echo "- Use PSK: $PSK on CPE"