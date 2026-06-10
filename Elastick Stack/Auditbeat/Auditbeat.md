# Auditbeat 8.x – Installation & Configuration Guide

## Overview


This guide provides a clean and production-ready setup for **Auditbeat 8.x** on Ubuntu. It covers audit data collection, secure output to Elasticsearch or Logstash, dashboard setup in Kibana, and recommended best practices for system auditing.


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
- Internet access or offline `.deb` file for Auditbeat 8.x

---

## Step 1 – Install Auditbeat 8.x

### Option 1: Install via `.deb`

1. Download Auditbeat:

   ```bash
curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-x.x.x-amd64.deb 
   ```

2. Transfer it to your server and install:

   ```bash
sudo dpkg -i auditbeat-x.x.x-amd64.deb
   ```


---
### Option 2: Install with APT `.sh
Instead of entering each command manually, create and run a shell script:

1. Create the install script:

   ```bash
   nano install-auditbeat.sh
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
   sudo apt install -y Auditbeat=8.15.3
   ```

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`)

4. Make the script executable:

   ```bash
   chmod +x install-Auditbeat.sh
   ```

5. Run the script:

   ```bash
   ./install-auditbeat.sh
   ```



---

## Step 2 – Configure `auditbeat.yml`

#### Open the config file:

```bash
sudo nano /etc/auditbeat/auditbeat.yml
```

#### Add or verify the following sections:

```yaml
state.period: 2m
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
    # if you dont have certificate use ssl.verification_mode: none insted ssl part
```

#### Option 2 – Using API Key (Recommended)

```yaml
output.elasticsearch:
  hosts: ["https://<elasticsearch_host>:9200"]
  api_key: "${ES_API_KEY}"
   ssl:
    certificate_authorities: ["/etc/auditbeat/certs/ca.crt"]
    verification_mode: none
    # if you dont have certificate use ssl.verif++ication_mode: none insted ssl part
```

---

## Step 3 – Enable and Configure Modules(optional)

Enable default modules:

```bash
sudo auditbeat modules enable auditd
sudo auditbeat modules list
```

---

## Step 4 – Secure Setup with Keystore and API Key

1. Create a role in Kibana **Dev Tools:**

```json
POST /_security/role/auditbeat-user
{
  "cluster": ["monitor", "read_ilm"],
  "indices": [
    {
      "names": ["auditbeat-*"],
      "privileges": ["create", "write", "read"]
    }
  ]
}
```

2. Create a user and assign the role:

```json
POST /_security/user/audit
{
  "password": "<your_password>",
  "roles": ["auditbeat-user"],
  "full_name": "audit",
  "email": "audit@audit"
}
```

3. Generate an API key:

```json
POST /_security/api_key
{
  "name": "audit"
}
```

4. Store the `id:key` result safely.

5. Add it to Auditbeat keystore:

```bash
cd /usr/share/auditbeat/bin
sudo ./auditbeat keystore add ES_API_KEY -c /etc/auditbeat/auditbeat.yml --path.home /usr/share/auditbeat --path.data /var/lib/auditbeat
```

---

## Step 5 – Test & Apply Setup

```bash
cd /usr/share/auditbeat/bin
sudo ./auditbeat test config -c /etc/auditbeat/auditbeat.yml --path.home /usr/share/auditbeat --path.data /var/lib/auditbeat
sudo ./auditbeat test output -c /etc/auditbeat/auditbeat.yml --path.home /usr/share/auditbeat --path.data /var/lib/auditbeat
sudo ./auditbeat setup -c /etc/auditbeat/auditbeat.yml --path.home /usr/share/auditbeat --path.data /var/lib/auditbeat
```

---

## Step 6 – Enable and Start Service

```bash
sudo systemctl enable auditbeat
sudo systemctl start auditbeat
```

---

## Step 7 – Monitor and Troubleshoot

```bash
sudo journalctl -u auditbeat
sudo systemctl status auditbeat
```

---

## Best Practices
- Use keystore for storing secrets
- Regularly review active modules
- Monitor auditd kernel rules
- Secure all communication with TLS

---

## Conclusion

Using APT to install Auditbeat provides a clean, reproducible, and scalable deployment. With proper modules and dashboards, you can achieve efficient audit logging and file integrity monitoring across your systems.
