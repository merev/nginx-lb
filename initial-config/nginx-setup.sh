#!/bin/bash

echo "* Exporting Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

############### RHEL commands ##################

if [[ $VAR == "Red Hat" ]]; then

  echo "* Install prerequisites ..."
  dnf install -y nano curl tree

  echo "* Install NGINX ..."
  dnf install -y nginx

  echo "* Install PHP ..."
  dnf module install -y php

  echo "* Change the default web page ..."
  echo "<h1>Hello from $(hostname)</h1>" | sudo tee /usr/share/nginx/html/index.html

  echo "* Change config file and test..."
  sed -i "41s/_;/`hostname`;/" /etc/nginx/nginx.conf
  nginx -t

  echo "* Start and enable the service ..."
  systemctl enable --now nginx
  systemctl status nginx

  echo "* Adjust the firewall settings ..."
  firewall-cmd --add-service http --permanent
  firewall-cmd --reload

  echo "* Change the ownership and permissions of the directory ..."
  curl http://localhost

else

  echo "This is not RHEL-based distro. Skipping RHEL block."

fi

##################################################

############### Debian commands ##################

if [[ $VAR == 'Debian' ]]; then

  echo "This is Debian-based distro. Executing command block with Dbian commands"

  echo "* Install prerequisites ..."
  apt update && apt install -y nano curl tree

  echo "* Install NGINX and PHP ..."
  apt install -y nginx php php-fpm

  echo "* Change config for the default site and test ..."
  sed -i "46s/_;/`hostname`;/" /etc/nginx/sites-available/default
  nginx -t

  echo "* Change config for the default site and test ..."
  sed -i "44s/index /index index.php /" /etc/nginx/sites-available/default
  sed -i "56,60s/#//" /etc/nginx/sites-available/default
  sed -i "63s/#//" /etc/nginx/sites-available/default
  nginx -t

  echo "* Change the main index web page ..."
  echo "<h1>Hello from $(hostname)</h1>" | tee /var/www/html/index.html

  echo "* Restart and enable the service ..."
  systemctl enable nginx
  systemctl restart nginx

#  echo "* Adjust the firewall settings ..."
#  ufw allow "Nginx Full"

  echo "* Test ..."
  curl http://localhost

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi

##################################################