#!/bin/bash

# Bandwidth Configuration Script for CPE
# Usage: ./configure_bandwidth.sh <rate_mbps>

source ../common/config.sh

RATE_MBPS=$1

if [ -z "$RATE_MBPS" ]; then
    echo "Usage: $0 <rate_mbps> (e.g., 100 or 200)"
    exit 1
fi

echo "Configuring bandwidth to ${RATE_MBPS}Mbps on $WAN_INTERFACE"

/usr/local/bin/bandwidth_shape.sh $WAN_INTERFACE $RATE_MBPS

echo "Bandwidth configured."