# Testing Basic SD-WAN Setup with Parallels and Cloud Server

This guide helps you test the basic SD-WAN setup using Parallels Desktop on macOS (for CPE) and a cloud server (for Aggregator).

## Prerequisites
- macOS with Parallels Desktop installed.
- A cloud account (e.g., AWS, DigitalOcean, or GCP) for a Linux server.
- Basic knowledge of cloud consoles and VM setup.

## Step 1: Set Up Cloud Server (Aggregator)
1. **Launch an EC2 Instance** (or similar on other clouds):
   - Go to AWS Console > EC2 > Launch Instance.
   - AMI: Ubuntu 22.04 LTS (free tier).
   - Instance Type: t2.micro (free tier).
   - Key Pair: Create/download a key (e.g., `vyos-demo-key.pem`).
   - Security Group: Allow SSH (22/TCP from 0.0.0.0/0), IPsec (500/UDP and 4500/UDP from 0.0.0.0/0 or your IP). HTTP optional.
   - Launch and note the Public IP (e.g., 18.141.25.25).

   - `ssh -i ~/.ssh/vyos-demo-key.pem ubuntu@13.214.177.4`
   - If permission denied: `chmod 400 ~/.ssh/vyos-demo-key.pem`

3. **Initial Setup on Server**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y git  # For cloning repo
   ```

4. **Clone and Set Up Project**:
   ```bash
   git clone https://github.com/your-repo/sdwan_linux.git  # Replace with your repo URL
   cd sdwan_linux/basic_setup
   ```

5. **Run Standalone Setup**:
   ```bash
   ./cloud_setup.sh
   ```
   - Edit the script first: Set `PUBLIC_IP` and `PSK` to match your setup.

6. **Verify**:
   - `sudo ipsec status` (should show listening).
   - Ping from local: `ping 3.1.23.200` (if ICMP allowed).

## Step 2: Set Up Parallels VM (CPE)
1. In Parallels, create a new VM:
   - OS: Ubuntu 22.04 LTS.
   - Network: Bridged (to get internet access) or Shared (NAT).
   - Allocate 2GB RAM, 20GB disk.

2. Boot the VM and install Parallels Tools if prompted.

3. In the VM, clone/upload the project to `~/sdwan_linux/basic_setup/`.

4. Edit `common/config.sh`:
   - `AGGREGATOR_IP`: Cloud server's public IP.
   - `WAN_INTERFACE`: Check with `ip link` (e.g., `enp0s5`).
   - `LAN_INTERFACE`: If you add a second NIC, or use loopback for testing.

5. Run setup: `./cpe/setup.sh`

6. Configure bandwidth: `./cpe/configure_bandwidth.sh 100`

7. Verify tunnel: `sudo ipsec status` (should show ESTABLISHED).

## Step 3: Test Connectivity
- From CPE VM: Ping datacenter subnet (if set up on aggregator).
- Add a test server on aggregator side and access from CPE.
- Check logs: `sudo journalctl -u strongswan`

## Option 2: CPE on Cloud Server (Cloud-to-Cloud)
If both Aggregator and CPE are cloud instances (easier for testing without local VM).

1. **Launch Two EC2 Instances**:
   - **Aggregator**: Ubuntu 22.04, security group as above. Note Public IP (e.g., 13.214.177.4).
   - **CPE**: Ubuntu 22.04, same security group. Note Public IP (e.g., 54.123.45.67).

2. **Set Up Aggregator**:
   - SSH to aggregator: `ssh -i key.pem ubuntu@13.214.177.4`
   - Clone repo, run `./cloud_setup.sh` (edit `PUBLIC_IP` and `PSK`).

3. **Set Up CPE**:
   - SSH to CPE: `ssh -i key.pem ubuntu@54.123.45.67`
   - Clone repo: `git clone https://github.com/your-repo/sdwan_linux.git && cd sdwan_linux/basic_setup`
   - Edit `common/config.sh`: Set `AGGREGATOR_IP=13.214.177.4`, `PSK=same as aggregator`.
   - Run `./cpe/setup.sh`

4. **Test Tunnel**:
   - On CPE: `sudo ipsec status` (should show ESTABLISHED).
   - On Aggregator: `sudo ipsec status` (should show 1 association).
   - Ping across tunnel: From CPE, ping aggregator's private IP or test route.

## Notes
- This simulates real SD-WAN: CPE connects over internet to cloud aggregator.
- For full test, add a datacenter VM behind aggregator.
- Secure: Use strong PSK; in production, use certs.