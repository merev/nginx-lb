#!/bin/bash

## Execute this script if the web server is going to be behind LB.

echo "* Export Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

if [[ $VAR == "Red Hat" ]]; then

  echo "* Prepare the lb config on the target host ..."
  sed -i '43i\        set_real_ip_from  192.168.100.0/24;\' /etc/nginx/nginx.conf
  sed -i '44i\        real_ip_header      X-Forwarded-For;\' /etc/nginx/nginx.conf
  nginx -t
  
  echo "* Restart the service ..."
  systemctl restart nginx && systemctl status nginx

else

  echo "This is not RHEL-based distro. Skipping RHEL block."

fi

if [[ $VAR == 'Debian' ]]; then

  echo "* Prepare the lb config on the target host ..."
  sed -i '42i\        set_real_ip_from  192.168.100.0/24;\' /etc/nginx/sites-enabled/default
  sed -i '43i\        real_ip_header      X-Forwarded-For;\' /etc/nginx/sites-enabled/default
  nginx -t

  echo "* Restart the service ..."
  systemctl restart nginx && systemctl status nginx

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi