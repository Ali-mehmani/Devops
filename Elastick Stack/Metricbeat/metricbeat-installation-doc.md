
# Metricbeat Installation & Configuration Guide (Elastic 8.x)

## Overview

This guide provides a clean and production-ready setup for Metricbeat 8.x on Ubuntu. It covers installation, secure configuration using API Keys, dashboard setup, and best practices.

> **Tip:** If you're installing from inside Iran, configure public DNS servers and update your system before proceeding:

```bash
sudo nano /etc/systemd/resolved.conf
# Set DNS=8.8.8.8 1.1.1.1
sudo systemctl restart systemd-resolved
sudo resolvectl status

sudo apt update && sudo apt upgrade -y
```

---

## Step 1 – Prepare Installation Script

Create an install script:

```bash
nano install-metricbeat.sh
```

Paste the following into the file:

```bash
#!/bin/bash

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo apt-get install -y metricbeat=8.15.3
```

Then run:

```bash
chmod +x install-metricbeat.sh
sudo ./install-metricbeat.sh
```

---

## Step 2 – Enable & Start Metricbeat

```bash
sudo systemctl enable metricbeat
sudo systemctl start metricbeat
```

---

## Step 3 – Configure `metricbeat.yml`

Open the config file:

```bash
sudo nano /etc/metricbeat/metricbeat.yml
```

Add or verify the following sections:

```yaml
metricbeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: true
  reload.period: 10s

setup.dashboards.enabled: false

setup.kibana:
  host: "http://localhost:5601"

output.elasticsearch:
  hosts: ["https://your-es-host:9200"]
  username: "elastic"
  password: "yourpassword"
  ssl.verification_mode: none
```

> 🟡 Use `username/password` for the **initial setup**. You can switch to API Key authentication later.

---

## Step 4 – Enable Modules

```bash
sudo metricbeat modules enable system
sudo metricbeat modules list
```

---

## Step 5 – Test Connection

```bash
cd /usr/share/metricbeat
sudo ./metricbeat test config -c /etc/metricbeat/metricbeat.yml --path.home /usr/share/metricbeat --path.data /var/lib/metricbeat
sudo ./metricbeat test output -c /etc/metricbeat/metricbeat.yml --path.home /usr/share/metricbeat --path.data /var/lib/metricbeat
```

---

## Step 6 – Setup Dashboards (first time only)

```bash
sudo ./metricbeat setup -c /etc/metricbeat/metricbeat.yml --path.home /usr/share/metricbeat --path.data /var/lib/metricbeat
```

---

## Step 7 – Switch to API Key (after initial setup)

1. Create a role (`metricbeat-user`) in Kibana.
2. Create a user `metric` with that role.
3. Generate an API key in Dev Tools:

```json
POST /_security/api_key/grant
{
  "grant_type": "password",
  "username": "metric",
  "password": "YourMetricPassword",
  "api_key": {
    "name": "metric"
  }
}
```

4. Copy the result (id:key), then:

```bash
cd /usr/share/metricbeat
sudo ./metricbeat keystore add ES_API_KEY
# Paste the id:key value
```

5. Edit `metricbeat.yml`:

```yaml
output.elasticsearch:
  hosts: ["https://your-es-host:9200"]
  api_key: "${ES_API_KEY}"
  ssl.verification_mode: none
```

6. Restart service:

```bash
sudo systemctl restart metricbeat
```

---

## Step 8 – Monitor Logs

```bash
sudo journalctl -u metricbeat -f
sudo tail -f /var/log/metricbeat/metricbeat.log
```

---

## Step 9 – For Other Servers

Just install and configure `metricbeat.yml`, then:

```bash
cd /usr/share/metricbeat
sudo ./metricbeat keystore add ES_API_KEY
# Paste the same id:key
sudo systemctl start metricbeat
```
