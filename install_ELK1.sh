#!/bin/bash
#install packages
yum install -y deltarpm epel-release
yum -y update
yum -y install java tomcat tomcat-webapps tomcat-admin-webappsnginx gcc make gcc-c++ kernel-devel kernel-headers perl wget bzip2 tree man

#add logstashrepo && install logstash
echo "installing logstash"
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
touch /etc/yum.repos.d/logstash.repo

FILE="/etc/yum.repos.d/elastic.repo"
/bin/cat <<EOM >>$FILE
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

EOM

yum update
yum -y install logstash
yum -y install filebeat

logst="/etc/logstash/conf.d/tomcat_log.conf"
/bin/cat <<EOM >>$logst
input {
  file {
    path => "/var/log/tomcat/catalina.2019-07-08.log"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["192.168.0.52:9200"]
  }
  stdout { codec => rubydebug }
}

EOM

systemctl start logstash.service
systemctl start filebeat

#nginx conf
echo "installing nginx"
yum -y install nginx
yum clean all
sed -i '/^#\|^$/d' /etc/nginx/nginx.conf #dell commented strings
sed -i '/\[::\]:80 default_server/s/^/#/' /etc/nginx/nginx.conf #comment ipv6 string
sed -i '/location \/ {/a \\t proxy_pass http://localhost:8080/sample/;' /etc/nginx/nginx.conf #add proxypass
systemctl start nginx

#tomcat
echo "installing tomcat"
yum clean all
wget wget -P /usr/share/tomcat/webapps https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war #get, deploy warfile
chown -R tomcat:tomcat /usr/share/tomcat
systemctl start tomcat

#firewall
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

systemctl enable nginx
systemctl enable tomcat
systemctl enable logstash
systemctl enable filebeat
echo "DONE"
