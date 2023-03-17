#!/bin/bash

echo "* Exporting Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

############### RHEL commands ##################

if [[ $VAR == "Red Hat" ]]; then

  echo "* Prepare the config files ..."
  cp /vagrant/vagrant/virtual-hosts/vhost-port.conf /etc/nginx/conf.d/vhost-port.conf
  cp /vagrant/vagrant/virtual-hosts/vhost-name.conf /etc/nginx/conf.d/vhost-name.conf
  sed -i "3s/demo/`hostname`/" /etc/nginx/conf.d/vhost-name.conf
  
  echo "* Create needed folders ..."
  mkdir /usr/share/nginx/vhost-{name,port}
  
  echo "* Create two new indexes files ..."
  echo "<h1>Cutom index.html page for vhost by port from $(hostname)</h1>" | tee /usr/share/nginx/vhost-port/index.html
  echo "<h1>Cutom index.html page for vhost by name from $(hostname)</h1>" | tee /usr/share/nginx/vhost-name/index.html
  
  echo "* Test config ..."
  nginx -t
  
  echo "* Restart the service ..."
  systemctl restart nginx
  
  echo "* Adjust the firewall settings ..."
  firewall-cmd --add-port 8080/tcp --permanent
  firewall-cmd --reload
  
  echo "* Create custom index file ..."
  echo "$(hostname -i | cut -d " " -f 2)     www.$(hostname).lab      www" | tee -a /etc/hosts
  
  echo "* Check the connection ..."
  curl localhost
  curl localhost:8080
  curl www.$(hostname).lab

else
 
  echo "This is not RHEL-based distro. Skipping RHEL block."
 
fi
##################################################
############### Debian commands ##################
if [[ $VAR == 'Debian' ]]; then

  echo "* Prepare the config files ..."
  cp /vagrant/vagrant/virtual-hosts/deb-main.conf /etc/apache2/sites-available/001-main.conf
  cp /vagrant/vagrant/virtual-hosts/deb-vhost-port.conf /etc/apache2/sites-available/002-vhost-port.conf
  cp /vagrant/vagrant/virtual-hosts/deb-vhost-name.conf /etc/apache2/sites-available/003-vhost-name.conf
  
  echo "* Create needed folders ..."
  mkdir /var/www/vhost-{name,port}
  
  echo "* Create two new indexes files ..."
  echo '<h1>Cutom index.html page for vhost by port</h1>' | tee /var/www/vhost-port/index.html
  echo '<h1>Cutom index.html page for vhost by name</h1>' | tee /var/www/vhost-name/index.html
  
  echo "* Enable virtual hosts ..."
  a2ensite 001-main.conf
  a2ensite 002-vhost-port.conf
  a2ensite 003-vhost-name.conf
  
  echo "* Test config ..."
  apachectl configtest
  
  echo "* Restart the service ..."
  systemctl restart apache2
  
  echo "* Create custom index file ..."
  echo '192.168.100.163     www.demo2.lab      www' | tee -a /etc/hosts
  
  echo "* Change the ownership and permissions of the directory ..."
  curl localhost
  curl localhost:8080
  curl www.demo2.lab

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi

##################################################