#!/bin/bash

## Execute this script if the web server is NOT going to be behind LB.

echo "* Export Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

##################################################
################ RHEL commands ###################
##################################################

if [[ $VAR == "Red Hat" ]]; then

################## NGINX Settings ##################

  echo "* Change SSL config file and test ..."
  sed -i "60,87s/#//" /etc/nginx/nginx.conf
  sed -i "64s/_;/`hostname`;/" /etc/nginx/nginx.conf
  sed -i "67s%nginx/server%tls/certs/ca%" /etc/nginx/nginx.conf
  sed -i "68s%nginx/private/server%tls/private/ca%" /etc/nginx/nginx.conf
  nginx -t
  
  echo "* Configure automatic redirect and test ..."
  sed -i '41i\        return       301 https://$host$request_uri;\' /etc/nginx/nginx.conf
  nginx -t
  
  echo "* Restart the service ..."
  systemctl restart nginx && systemctl status nginx
  
  echo "* Adjust the firewall settings ..."
  firewall-cmd --add-service https --permanent
  firewall-cmd --reload

#######################################################

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

################## NGINX Settings ##################

#  echo "* Change SSL config file and test..."
#  sed -i "85s/localhost/ca/" /etc/httpd/conf.d/ssl.conf
#  sed -i "93s/localhost/ca/" /etc/httpd/conf.d/ssl.conf
#  apachectl configtest

  echo "* Enable SSL modules ..."
  a2enmod ssl
  a2enmod rewrite
  
  echo "* Activate SSL ..."
  cp /vagrant/vagrant/ssl-config/deb-ssl-activate.conf /etc/apache2/sites-available/000-default-ssl.conf
  
  echo "* Configure automatic redirect ..."
  cp /vagrant/vagrant/ssl-config/deb-ssl-redirect.conf /etc/apache2/sites-available/000-default.conf
  
  echo "* Enable the SSL version of the site ..."
  a2ensite 000-default-ssl.conf
  apachectl configtest
  
  echo "* Restart the service ..."
  systemctl restart apache2 && systemctl status apache2

#######################################################

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi

##################################################
##################################################
##################################################
