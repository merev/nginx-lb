#!/bin/bash

## Execute this script if the web server is NOT going to be behind LB.

echo "* Export Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

if [[ $VAR == "Red Hat" ]]; then

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

else

  echo "This is not RHEL-based distro. Skipping RHEL block."

fi

if [[ $VAR == 'Debian' ]]; then

  echo "* Change SSL config file and test ..."
  sed -i '24i\        return       301 https://$host$request_uri;\' /etc/nginx/sites-available/default
  sed -i "28,29s/# //" /etc/nginx/sites-available/default
  sed -i '30i\        ssl_certificate /etc/nginx/ca.crt;\' /etc/nginx/sites-available/default
  sed -i '31i\        ssl_certificate_key /etc/nginx/ca.key;\' /etc/nginx/sites-available/default
  nginx -t

  echo "* Restart the service ..."
  systemctl restart nginx && systemctl status nginx

  echo "* Test ..."
  curl -k https://localhost

#  echo "* Adjust the firewall settings ..."
#  ufw allow "Nginx HTTPS"

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi