# SD-WAN Linux Setup Guide for Beginners

## What is This?

This is a simple setup to create a secure network connection between two computers (or devices) over the internet. One computer is the "main hub" (called the Aggregator), and the other is the "branch office" (called the CPE). The CPE acts like a router, letting devices behind it access servers in a datacenter, with speed limits you can set (like 100 Mbps or 200 Mbps).

It's like building a private tunnel on the internet, without needing expensive special hardware. It replaces old systems that used MPLS (a type of network tech).

## What You Need

- Two Linux computers (like Ubuntu). One for the Aggregator, one for the CPE.
- Internet connection on both.
- Basic knowledge of typing commands in a terminal (we'll guide you).
- Root access (sudo) on both computers.

## Quick Explanation

- **Aggregator**: The central server that all branch offices connect to. It gives out "virtual" IP addresses to CPEs.
- **CPE**: Customer device at the branch. It connects to the Aggregator and shares its local network.
- **IPsec Tunnel**: A secure, encrypted connection between them using a shared password (PSK).
- **Bandwidth**: How fast data can flow (we limit it to control costs/speed).

## Step-by-Step Setup

### Step 1: Download and Prepare

1. Copy the files from this project to both computers.
2. Open a terminal on each computer.
3. Go to the project folder: `cd /path/to/sdwan_linux` (replace with your actual path).

### Step 2: Edit Settings

1. Open `common/config.sh` in a text editor (like Notepad or nano).
2. Change these lines to match your setup:
   - `AGGREGATOR_IP`: The real IP address of the Aggregator computer (find it with `ip addr show`).
   - `WAN_INTERFACE`: The internet-facing network card (usually `eth0` or `enp0s3`).
   - `LAN_INTERFACE`: The local network card on CPE (usually `eth1`).
   - `CPE_SUBNET`: The local network behind CPE (e.g., 192.168.1.0/24).
   - `DATACENTER_SUBNET`: The network of the datacenter servers (e.g., 10.0.0.0/8).
   - `CPE_VIP_POOL`: A range of IPs for CPEs (e.g., 10.0.1.0/24).
3. Save the file.

### Step 3: Set Up the Aggregator

1. On the Aggregator computer, run: `./aggregator/setup.sh`
2. It will ask for your password (sudo). Type it.
3. Wait for it to finish. It installs software and sets up the secure server.

### Step 4: Set Up the CPE

1. On the CPE computer, run: `./cpe/setup.sh`
2. It will ask for your password. Type it.
3. Wait for it to finish. It connects to the Aggregator and sets up routing.

### Step 5: Set Speed Limit on CPE

1. On the CPE computer, run: `./cpe/configure_bandwidth.sh 100` (for 100 Mbps) or `./cpe/configure_bandwidth.sh 200` (for 200 Mbps).
2. This limits how fast data goes through the internet connection.

## How to Use

- Once set up, devices behind the CPE can access the datacenter servers as if they were on the same network.
- Check if it's working: On CPE, run `sudo ipsec status`. You should see "ESTABLISHED".
- To change speed: Run the bandwidth script again with a new number.

## Troubleshooting

- **Setup fails?** Make sure you have internet and sudo access. Try `sudo apt update` first.
- **Can't connect?** Check IPs in `config.sh`. Firewall might block—run `sudo ufw disable` temporarily to test.
- **No internet on CPE?** Check `ip route show`. The tunnel should add routes.
- **Slow speed?** Bandwidth limit is working. Change with the script.
- **Errors?** Look at logs: `sudo journalctl -u strongswan` or `sudo ipsec statusall`.

## Next Steps

This is basic. For real use, add security (like certificates) and monitoring. Read the main README for advanced tips.

Want to test? Check `TESTING_GUIDE.md` for using Parallels and a cloud server.

If stuck, ask for help or check online for "strongSwan IPsec tutorial".