#!/bin/bash

echo "* Export Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

if [[ $VAR == "Red Hat" ]]; then

  echo "* Prepare the config files ..."
  cp /vagrant/vagrant/load-balancer/lb-setup.conf /etc/nginx/nginx.conf
  nginx -t

  echo "* Restart the service ..."
  systemctl restart nginx && systemctl status nginx

else

  echo "This is not RHEL-based distro. Skipping RHEL block."

fi


if [[ $VAR == 'Debian' ]]; then
  
  echo "* Prepare the config files ..."
  cp /vagrant/vagrant/load-balancer/deb-lb-setup.conf /etc/nginx/sites-enabled/default
  
  echo "* Restart the service ..."
  systemctl restart nginx && systemctl status nginx

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi