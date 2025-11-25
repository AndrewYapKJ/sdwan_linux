#!/usr/bin/env python3
"""
Simple SD-WAN API for Dynamic Configuration
Run on aggregator: python3 api_server.py
Endpoints:
- GET /status: Get IPsec tunnel status
- POST /cpe/add: Add a new CPE (JSON: {"ip": "1.2.3.4", "subnet": "192.168.1.0/24"})
- PUT /bandwidth/set: Set bandwidth (JSON: {"interface": "eth0", "rate": 100})

Install: pip install flask
Secure: Add auth, HTTPS in production.
"""

from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route('/status', methods=['GET'])
def get_status():
    try:
        result = subprocess.run(['sudo', 'ipsec', 'status'], capture_output=True, text=True)
        return jsonify({"status": "success", "output": result.stdout})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)})

@app.route('/cpe/add', methods=['POST'])
def add_cpe():
    data = request.json
    ip = data.get('ip')
    subnet = data.get('subnet')
    if not ip or not subnet:
        return jsonify({"status": "error", "message": "Missing ip or subnet"})

    # Example: Update ipsec.conf dynamically (simplified)
    config_line = f"conn cpe-{ip}\n    right={ip}\n    rightsubnet={subnet}\n"
    with open('/etc/ipsec.conf', 'a') as f:
        f.write(config_line)
    subprocess.run(['sudo', 'ipsec', 'reload'])
    return jsonify({"status": "success", "message": f"CPE {ip} added"})

@app.route('/bandwidth/set', methods=['PUT'])
def set_bandwidth():
    data = request.json
    interface = data.get('interface')
    rate = data.get('rate')
    if not interface or not rate:
        return jsonify({"status": "error", "message": "Missing interface or rate"})

    # Call bandwidth script
    subprocess.run(['sudo', '/usr/local/bin/bandwidth_shape.sh', interface, str(rate)])
    return jsonify({"status": "success", "message": f"Bandwidth set to {rate}Mbps on {interface}"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)