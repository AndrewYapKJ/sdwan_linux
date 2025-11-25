# Common configurations for SD-WAN

# Bandwidth limits (in Mbps)
BANDWIDTH_100=100
BANDWIDTH_200=200

# Interfaces (examples)
WAN_INTERFACE=eth0
LAN_INTERFACE=eth1

# IPsec settings
AGGREGATOR_IP=192.168.0.1  # Example IP
CPE_SUBNET=192.168.1.0/24
DATACENTER_SUBNET=10.0.0.0/8  # Example datacenter subnet

# IP Pools
CPE_VIP_POOL=10.0.1.0/24  # Virtual IP pool for CPEs