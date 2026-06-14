#!/bin/bash

# Add Elastic GPG key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Add APT repository
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

# Install transport package and update APT
sudo apt-get update
sudo apt-get install -y apt-transport-https

# Install specific version of Metricbeat
sudo apt-get install -y metricbeat=8.15.3

