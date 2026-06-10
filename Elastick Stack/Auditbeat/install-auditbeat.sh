   #!/bin/bash

   # Add Elastic GPG key
   curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

   # Add APT repository
   echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
     | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

   # Update and install Metricbeat
   sudo apt update
   sudo apt install -y apt-transport-https
   sudo apt install -y auditbeat=8.15.3
