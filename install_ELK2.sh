#!/usr/bin/env bash
yum install -y deltarpm epel-release
yum -y update
yum -y install java-1.8.0-openjdk-devel wget bzip2 tree man

#add elasticksearch repo && install elasticksearch
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
touch /etc/yum.repos.d/elasticsearch.repo

FILE="/etc/yum.repos.d/elastic.repo"
/bin/cat <<EOM >>$FILE
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

EOM



yum update
yum -y install elasticsearch
el_conf="/etc/elasticsearch/elasticsearch.yml"
/bin/cat <<EOM >>$el_conf
network.host: 192.168.0.52
http.port: 9200
discovery.type: single-node
EOM

systemctl daemon-reload
systemctl enable elasticsearch.service

systemctl start elasticsearch.service

yum -y install kibana
kib_conf="/etc/kibana/kibana.yml"
/bin/cat <<EOM >>$kib_conf
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: "http://192.168.0.52:9200"
EOM

systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service
#systemctl stop kibana.service

#checks
#curl -X GET "localhost:9200/"
#journalctl -u elasticsearch

#firewall
#sudo firewall-cmd --new-zone=elasticsearch --permanent
#sudo firewall-cmd --reload
#sudo firewall-cmd --zone=elasticsearch --add-source=192.168.0.1/24 --permanent
#sudo firewall-cmd --zone=elasticsearch --add-port=9200/tcp --permanent
#sudo firewall-cmd --reload

#config
#sed -i 's/network.host:/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml
systemctl restart elasticsearch
