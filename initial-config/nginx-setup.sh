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

  echo "* Install Apache ..."
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

  echo "* Install Apache and php ..."
  apt install -y apache2 php

#  echo "* Turn off the default web page ..."
#  sed -i 's/^/#/g' /etc/httpd/conf.d/welcome.conf

#  echo "* Change config file and test..."
#  sed -i "89s/localhost/`hostname`/" /etc/httpd/conf/httpd.conf
#  sed -i "98s/#//" /etc/httpd/conf/httpd.conf
#  sed -i "98s/www.example.com/`hostname`/" /etc/httpd/conf/httpd.conf
#  sed -i '147s/Indexes //' /etc/httpd/conf/httpd.conf
#  sed -i '167s/index.html/index.php index.html/' /etc/httpd/conf/httpd.conf
#  apachectl configtest

  echo "* Start and enable the service ..."
  systemctl enable --now apache2
  systemctl status apache2

  echo "* Create custom index file ..."
  echo "Custom index.html Web Page" | tee /var/www/html/index.html

  echo "* Test ..."
  curl localhost

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi

##################################################