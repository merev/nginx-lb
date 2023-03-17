#!/bin/bash

echo "* Add hosts ..."
echo "192.168.100.161 nginx-srv1" >> /etc/hosts
echo "192.168.100.162 nginx-srv2" >> /etc/hosts
echo "192.168.100.163 nginx-lb" >> /etc/hosts
echo "192.168.100.164 nginx-single" >> /etc/hosts

echo "* Add nameserver ..."
echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf