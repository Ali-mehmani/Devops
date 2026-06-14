# Metricbeat 8.x – Installation & Configuration Guide (APT-based)

## Overview

This guide provides a professional, scalable setup for **Metricbeat 8.x** using the official Elastic APT repository on Ubuntu. Metricbeat collects system and service metrics and ships them to Elasticsearch or Logstash.

> **Tip for users in Iran:** Set public DNS and update your system before starting:
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
- Internet access (direct or via proxy)
- Elasticsearch or Logstash and optionally Kibana

---

## Step 1 – Install Metricbeat via APT

### Option 1: Install via `.deb`

1. Download metricbeat:

   ```bash
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-x.x.x-amd64.deb
   ```

2. Transfer it to your server and install:

   ```bash
  sudo dpkg -i metricbeat-x.x.x-amd64.deb
   ```


---
### Option 2: Install with APT `.sh

Instead of entering each command manually, create and run a shell script:

1. Create the install script:

   ```bash
   nano install-metricbeat.sh
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
   sudo apt install -y metricbeat=8.15.3
   ```

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`)

4. Make the script executable:

   ```bash
   chmod +x install-metricbeat.sh
   ```

5. Run the script:

   ```bash
   ./install-metricbeat.sh
   ```

---

## Step 2 – Enable and Configure Modules

Enable modules:

```bash
sudo metricbeat modules enable system
sudo metricbeat modules enable docker
sudo metricbeat modules enable nginx
```

Edit module configs if needed:

```bash
sudo nano /etc/metricbeat/modules.d/system.yml
```

---

## Step 3 – Configure `metricbeat.yml`

#### Open the config file:

```bash
sudo nano /etc/metricbeat/metricbeat.yml
```

#### Add or verify the following sections:

```yaml
  reload.enabled: true
  reload.period: 10s

setup.dashboards.enabled: true

setup.kibana:
  host: "http://localhost:5601"
```

### Output to Elasticsearch:

#### Option 1 – Using Username & Password

```yaml
output.elasticsearch:
  hosts: ["https://<elasticsearch_host>:9200"]
  username: "elastic"
  password: "your_password"
  ssl:
    certificate_authorities: ["/etc/metricbeat/certs/ca.crt"]
    verification_mode: none
    # if you dont have certificate use **ssl.verification_mode: none** insted ssl part
    
```

or
#### Option 2 – Using API Key (Recommended)

```yaml
output.elasticsearch:
  hosts: ["https://<elasticsearch_host>:9200"]
  api_key: "${ES_API_KEY}"
  ssl:
    certificate_authorities: ["/etc/metricbeat/certs/ca.crt"]
    verification_mode: none
    # if you dont have certificate use **ssl.verification_mode: none** insted ssl part
```

---

## Step 4 – ## Enable Modules (Optional)


```bash
sudo metricbeat modules enable system
sudo metricbeat modules list
```


---


> [!Attention] Before doing step 5
>If you use api key do this step


## Step 5 – Secure Setup with Keystore and API Key

1. Create a dedicated role in Kibana **Dev Tools**:

```json
POST /_security/role/metricbeat-user
{
  "cluster": ["monitor", "read_ilm"],
  "indices": [
    {
      "names": ["metricbeat-*"],
      "privileges": ["create", "write", "read"]
    }
  ]
}
```

2. Create a user and assign the role:

```json
POST /_security/user/metric
{
  "password": "<your_password>",
  "roles": ["metricbeat-user"],
  "full_name": "metric",
  "email": "metric@metric"
}
```

3. Generate an API key:

```json
POST /_security/api_key
{
  "name": "metric"
}
```

4. Store the `id:key` result safely.

5. Add it to Metricbeat keystore:

```bash
cd /usr/share/metricbeat/bin
sudo ./metricbeat keystore add ES_API_KEY -c /etc/metricbeat/metricbeat.yml --path.home /usr/share/metricbeat --path.data /var/lib/metricbeat
```

- Enter y and copy id:key    for example  Y11XFpcBlGV8EUOx9K5L:H2th2VVhSUCSfk6M-tp10g

---
## Step 6 – Secure Setup with Keystore and API Key


8. Test and apply setup:

```bash
cd /usr/share/metricbeat/bin
sudo ./metricbeat test config -c /etc/metricbeat/metricbeat.yml --path.home /usr/share/metricbeat --path.data /var/lib/metricbeat
sudo ./metricbeat test output -c /etc/metricbeat/metricbeat.yml --path.home /usr/share/metricbeat --path.data /var/lib/metricbeat
sudo ./metricbeat setup -c /etc/metricbeat/metricbeat.yml --path.home /usr/share/metricbeat --path.data /var/lib/metricbeat
```

9. Enable and start service:

```bash
sudo systemctl enable metricbeat
sudo systemctl start metricbeat
```

---


## Step 7 – Monitor and Troubleshoot

Check logs:

```bash
sudo journalctl -u metricbeat
sudo systemctl status metricbeat
```

---

## Best Practices
- Use `keystore` for storing credentials securely
- Monitor resource usage of Metricbeat itself
- Regularly review and update enabled modules
- Use HTTPS and authentication for all outputs

---

## Conclusion

Using APT to install Metricbeat provides a scalable and maintainable setup, ideal for production environments. With modules enabled and dashboards loaded, you are ready to start monitoring system and service metrics efficiently.