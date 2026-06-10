


## Table of Contents



1. [Introduction](#introduction)

2. [Set hostname per node](#hostname)

3. [Set local DNS if required](#DNS)

4. [ELK Clustering](#ELK)
 
5. [Install Kibana](#Kibana)

6. [Install logstash](#logstash)





---

## Introduction<a name ="introduction"></a>

The **ELK Stack** is a powerful trio of open-source tools—**Elasticsearch**, **Logstash**, and **Kibana**—designed for efficient data ingestion, storage, analysis, and visualization.

And in This Document i want to cluster with 5node.

###### 1. **Elasticsearch**:

  A highly scalable search and analytics engine that stores and indexes large volumes of data, enabling fast and complex queries.


###### 2 **Logstash**: 
   A data processing pipeline that ingests, transforms, and forwards data from various sources to Elasticsearch, supporting numerous input and output plugins.


###### 3. **Kibana**: 
 A visualization layer that provides intuitive dashboards and real-time insights, allowing users to explore and present data through charts, graphs, and maps

<br>
<br>
<br>
<br>
<br><br>
<br>



 > [!attention] 
> If You Have DNS Server in your network ,Ignore this step 
> Else this step is first step


 ## Set hostname per node<a name ="hostname"></a>

For node install elasticserch Example1:

```
sudo hostnamectl set-hostname ELK-Cluster-node1
```

For node install logstash Example2:

```
sudo hostnamectl set-hostname ELK-Cluster-logstash
```

For node install kibana Example2:

```
sudo hostnamectl set-hostname ELK-Cluster-kibana
```

## Set local DNS if required<a name ="DNS"></a>

 Edit this file:
```
sudo nano /etc/hosts
```
Add all ip addresses and hostname :


``` 
127.0.0.1 localhost	
127.0.1.1 ELK-Cluster-node1
# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
192.168.10.10 ELK-Cluster-node1
192.168.10.11 ELK-Cluster-node2
192.168.10.12 ELK-Cluster-node3
192.168.10.13 ELK-Cluster-node4
192.168.10.14 ELK-Cluster-kibana
192.168.10.15 ELK-Cluster-logstash
```



## ELK Clustering(3 nodes for elasticsearch extendable for n nodes):<a name ="ELK"></a>



###### 1)   Create a user for elasticsearch:

```
	sudo useradd elasticsearch -m -s /bin/bash
	sudo passwd elasticsearch
	sudo adduser elasticsearch sudo
	su -l elasticsearch
```


   ###### 2) Set DNS :

```
sudo nano /etc/systemd/resolved.conf
#Set Dns (for example)
Dns=10.202.10.202
sudo systemctl restart systemd-resolved
#check  DNS
```

###### 3) Install Java 17 in ubuntu 22.04:

```
	 java --version
	 sudo apt update
	 sudo apt-cache search openjdk
	 sudo apt install openjdk-17-jdk
	 sudo apt install openjdk-17-jre
```


###### 4) Set environment for JAVA_HOME:

```
	java -version  &&  javac -version
	sudo update-alternatives --config java
	sudo nano /etc/environment
	JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
	source /etc/environment
	echo $JAVA_HOME
```


###### 5)  Install Elasticsearch:

```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.17.2-amd64.deb
```

```
sudo dpkg -i elasticsearch-X.X.X-amd64.deb
```


 ###### 6 ) Cracked ELasticsearch:
 
> [!attention] If you have the crack file on `/home/ubuntu`use the command below, otherwise load the crack file firs

 ```
 sudo scp /path/to/x-pack-core-X.X.X.jar /usr/share/elasticsearch/modules/x-pack-core/
 ```
 
> [!NOTE] Tip
> X.X.X Version of elasticsearch
> I install 8.17.2


###### 7) Edit configuration file:

```
sudo nano /etc/elasticsearch/elasticsearch.yml
```
  
**Change those parameters below:**

```
cluster.name: ELK-Cluster
node.name:ELK-Cluster-node1  #(hostname)
network.host: 192.168.10.10 #(ip address or domain name server)
path.data: #(it's better change)
path.logs: #(it's better change)
cluster.initial_master_nodes: ["ELK-Cluster-node1"]
http.port: 9200
transport.host: 0.0.0.0
ingest.geoip.downloader.enabled: false
```


###### 8) Start ELasticsearch:

```
	sudo systemctl daemon-reload
	sudo systemctl enable elasticsearch.service
	sudo systemctl start elasticsearch.service
	sudo systemctl status elasticsearch.service
```


###### 9)  Change password **elastic** user (root/admin user): [Optional]

```
	cd /usr/share/elasticsearch/bin
	sudo ./elasticsearch-reset-password -i -u elastic
```


###  Add node/nodes to cluster

###### 10) in node master generate token

```
	cd /usr/share/elasticsearch/bin
	./elasticsearch-create-enrollment-token -s node	
```


> [!attention] Permission
> if dont generat password us this command : 
> sudo chown -R elasticsearch:elasticsearch /etc/elasticsearch
sudo chmod -R 750 /etc/elasticsearch



###### 11) in node 2 install elasticsearch from **step 1-8**

> [!attention] Do not start elasticsearch on this step.

> [!attention] Verify New Permissions
> ls -ld /etc/elasticsearch
> You should now see:   drwxrws--- *  elasticsearch elasticsearch  **** **** **** ****

###### 12) in node 2 add this node to cluster

```
	cd /usr/share/elasticsearch/bin
	./elasticsearch-reconfigure-node --enrollment-token (token generated previous step copy here)
```

> Again verify persmiision if you dont cant generate
###### 13) Edit configuration file:

```
sudo nano /etc/elasticsearch/elasticsearch.yml
```

###### 14) Change those parameters below:

```
cluster.name: ELK-Cluster
node.name: ELK-Cluster-node2 #(hostname)
network.host: 192.168.10.11 #(ip address or domain name server)
path.data: #(it's better change)
path.logs: #(it's better change)
http.port: 9200
discovery.seed_hosts: ["192.168.10.10:9300"]
transport.host: 0.0.0.0
ingest.geoip.downloader.enabled: false
```


###### 15) Start Elastisearch in node2:

```
	sudo systemctl daemon-reload
	sudo systemctl enable elasticsearch.service
	sudo systemctl start elasticsearch.service
	sudo systemctl status elasticsearch.service
```



###### 16) Check add node 2 in cluster:

```
curl -k -u elastic:Password https://ELK-Cluster-node1:9200/_cluster/health?pretty
```


> [!NOTE] Tip
> Output command above:
> {
  "cluster_name" : "ELK-Cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 4,
  "number_of_data_nodes" : 4,
  "active_primary_shards" : 93,
  "active_shards" : 186,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

###### 17)  Check all nodes available and get some information about them:

```
curl -k -u  elastic:Password https://ELK-Cluster-node1:9200/_cat/nodes?pretty
```

> [!NOTE] Tip
> Output command above:
> 192.168.10.10   - ELK-Cluster-node4
192.168.10.11      * ELK-Cluster-node1
192.168.10.12      - ELK-Cluster-node2
192.168.10.13     - ELK-Cluster-node3

###### 18) in all nodes  edit configuration elasticsearch:

```
 discovery.seed_hosts: ["192.168.50.28:9300", "192.168.50.29:9300" , "192.168.50.30:9300"]
```

###### 19) in each server restart elasticsearch :

```
sudo systemctl restart elasticsearch.service
```

## Install Kibana <a name ="Kibana"></a>



###### 1) Create a user for kibana:

```
sudo useradd kibana -m -s /bin/bash
sudo passwd kibana
sudo adduser kibana sudo
su -l kibana
```



###### 2) Install **Java 17** and Set environment for JAVA_HOME in ubuntu 22.04 same as step 2 and 3 in previous section

###### 3)  Install kibana:

```
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.17.2-amd64.deb
```


```
sudo dpkg -i kibana-X.X.X-amd64.deb
```


###### 4) Start Kibana in node:

```
sudo systemctl daemon-reload
sudo systemctl enable kibana.service
sudo systemctl start kibana.service
sudo systemctl status kibana.service
```


###### 5) Edit configuration file:

```
sudo nano /etc/kibana/kibana.yml
```

> Go to master node , /usr/share/elasticsearch and copy :
> sudo bin/elasticsearch-reset-password -u kibana_system

###### 6)  Change those parameters below:

```
	server.port: 5601
	server.host: "0.0.0.0"
	server.publicBaseUrl: "https://ELK-Cluster-node7:5601/"
	server.name: "ELK-Cluster-kibana"
	elasticsearch.hosts:
	  - "https://ELK-Cluster-node1:9200"
	  - "https://ELK-Cluster-node2:9200"
	  - "https://ELK-Cluster-node3:9200"
	  - "https://ELK-Cluster-node4:9200"
	elasticsearch.username: "kibana_system"
    elasticsearch.password: "Password"

```


> [!NOTE] SSL
> if  you dont have ssl or used self sign add:
> **elasticsearch.ssl.verificationMode: none**

###### 7) Restart kibana.service

```
	sudo systemctl restart kibana.service
	sudo systemctl status kibana.service
```


## Install logstash<a name ="logstash"></a>


###### 1) Create a user for logstash:

```
	 sudo useradd logstash -m -s /bin/bash
	 sudo passwd logstash
	 sudo adduser logstash sudo
	 su -l logstash
```



###### 2) Install **Java 17** and Set environment for JAVA_HOME in ubuntu 22.04 same as step 2 and 3 in previous section



###### 3)  Install logstash:

```
wget https://artifacts.elastic.co/downloads/logstash/logstash-8.15.3-amd64.deb
```

``` 
sudo dpkg -i logstash-X.X.X-amd64.deb 
```


###### 4) Start logstash in node:

```
sudo systemctl daemon-reload
sudo systemctl enable logstash.service
sudo systemctl start logstash.service
sudo systemctl status logstash.service
```



#### How to Remove Elasticsearch(If You need it)

```
sudo systemctl stop elasticsearch
sudo apt-get remove --purge elasticsearch
sudo apt-get autoremove
sudo rm -rf /var/lib/elasticsearch
sudo rm /etc/systemd/system/elasticsearch.service
sudo rm /etc/init.d/elasticsearch
sudo apt-get clean
sudo systemctl daemon-reload
```