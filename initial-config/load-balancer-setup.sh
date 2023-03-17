#!/bin/bash

echo "* Export Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

##################################################
################ RHEL commands ###################
##################################################

if [[ $VAR == "Red Hat" ]]; then

  echo "* Prepare the config files ..."
  cp /vagrant/vagrant/load-balancer/lb-setup.conf /etc/nginx/nginx.conf
  nginx -t

  echo "* Restart the service ..."
  systemctl restart nginx && systemctl status nginx
  
  echo "* Adjust SELinux boolean ..."
  setsebool -P httpd_can_network_connect on

else

  echo "This is not RHEL-based distro. Skipping RHEL block."

fi

##################################################
##################################################
##################################################



##################################################
############### Debian commands ##################
##################################################

if [[ $VAR == 'Debian' ]]; then

  echo "* Create custom index file ..."
  echo "Custom index.html Web Page Reverse Proxy" | tee /var/www/html/index.html
  
  echo "* Enable the proxy module ..."
  a2enmod proxy
  a2enmod proxy_http
  
  echo "* Copy the files to the appropriate folders ..."
  cp /vagrant/vagrant/reverse-proxy/deb-proxy-setup.conf /etc/apache2/conf-available/reverse-proxy.conf
  
  echo "* Enable the config and test ..."
  a2enconf reverse-proxy
  apachectl configtest
  
  echo "* Restart the service ..."
  systemctl restart apache2 && systemctl status apache2

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi

##################################################
##################################################
##################################################