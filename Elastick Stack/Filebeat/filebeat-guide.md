# Filebeat 8.x – Installation & Configuration Guide

## Overview

This guide provides a clean and production-ready setup for **Filebeat 8.x** on Ubuntu. It covers log collection, output to Elasticsearch or Logstash, dashboard setup, and best practices.

 **Tip for users in Iran:** Set public DNS and update your system before starting:
>
> ```bash
> sudo nano /etc/systemd/resolved.conf
> # Add or edit the following:
> DNS=10.202.10.202 
> 
> sudo systemctl restart systemd-resolved
> sudo resolvectl status
> sudo apt update && sudo apt upgrade -y
> ```

---

## Prerequisites

- Ubuntu 20.04 or newer  
- Sudo/root access  
- Elasticsearch or Logstash (and optionally Kibana) available  
- Internet access or offline `.deb` file for Filebeat 8.x

---

## Step 1 – Install Filebeat 8.x

### Option 1: Install via `.deb`

1. Download Filebeat:

   ```bash
   curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.X.X-amd64.deb
   ```

2. Transfer it to your server and install:

   ```bash
   sudo dpkg -i filebeat-8.X.X-amd64.deb
   ```


---
### Option 2: Install with APT `.sh
Instead of entering each command manually, create and run a shell script:

1. Create the install script:

   ```bash
   nano install-filebeat.sh
   ```

2. Paste the following content:

   ```bash
   #!/bin/bash

   # Add Elastic GPG key
   curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

   # Add APT repository
   echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
     | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

   # Update and install Metricbeat
   sudo apt update
   sudo apt install -y apt-transport-https
   sudo apt install -y filebeat=8.15.3
   ```

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`)

4. Make the script executable:

   ```bash
   chmod +x install-filebeat.sh
   ```

5. Run the script:

   ```bash
   ./install-filebeat.sh
   ```

---

## Step 2 – Configure Filebeat

Open the config file:

```bash
sudo nano /etc/filebeat/filebeat.yml
```

### 🔹 Enable Log Input

```yaml
filebeat.inputs:
  - type: filestream
    enabled: true
    paths:
      - /var/log/*.log
```

### 🔹 Enable Config Reloading

```yaml
  reload.enabled: true
  reload.period: 10s
```

### 🔹 Output to Elasticsearch

```yaml
output.elasticsearch:
  hosts: ["https://<elasticsearch_host>:9200"]
  username: "elastic"
  password: "your_password"
  ssl.verification_mode: none
```

### 🔹 Output to Logstash (alternative)

```yaml
output.logstash:
  hosts: ["<logstash_host>:5044"]
```

### 🔹 Kibana Setup (for dashboards)

```yaml
setup.kibana:
  host: "http://<kibana_host>:5601"
```

### 🔹 Load Dashboards

```bash
sudo filebeat setup --dashboards
```

---

## Step 3 – Start Filebeat

```bash
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

---

## Step 4 – Test & Monitor

### Validate configuration:

```bash
filebeat test config
filebeat test output
```

### View logs:

```bash
sudo journalctl -u filebeat
sudo tail -f /var/log/filebeat/filebeat.log
```

---

## Best Practices

- Use TLS & authentication  
- Use keystore for secrets:

  ```bash
  sudo filebeat keystore create
  sudo filebeat keystore add ELASTICSEARCH_PASSWORD
  ```

- Rotate logs at source  
- Use external config inputs  
- Monitor dropped events

---

## Conclusion

You're now ready to run Filebeat 8.x in production with a clean, secure configuration.


1. cd /usr/share/filebeat/bin
2. ./filebeat test config -c /etc/filebeat/filebeat.yml --path.home /usr/share/filebeat/ --path.data /var/lib/filebeat/
