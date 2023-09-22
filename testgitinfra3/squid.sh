#!/bin/bash
yum update -y
yum install squid -y
systemctl start squid
systemctl enable squid
echo "http_access allow all" > /etc/squid/squid.conf
echo "http_port 3128" >> /etc/squid/squid.conf
