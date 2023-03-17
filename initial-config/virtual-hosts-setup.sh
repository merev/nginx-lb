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
  
  echo "* Add new record in the hosts file ..."
  echo "$(hostname -i | cut -d " " -f 2)     www.$(hostname).lab      www" | tee -a /etc/hosts
  
  echo "* Check the connection ..."
  curl http://localhost
  curl http://localhost:8080
  curl http://www.$(hostname).lab

else
 
  echo "This is not RHEL-based distro. Skipping RHEL block."
 
fi

##################################################

############### Debian commands ##################

if [[ $VAR == 'Debian' ]]; then

  echo "* Prepare the config files ..."
  cp /vagrant/vagrant/virtual-hosts/deb-vhost-port.conf /etc/nginx/sites-available/vhost-port.conf
  cp /vagrant/vagrant/virtual-hosts/deb-vhost-name.conf /etc/nginx/sites-available/vhost-name.conf
  sed -i "3s/demo/`hostname`/" /etc/nginx/sites-available/vhost-name.conf
  
  echo "* Create needed folders ..."
  mkdir /var/www/vhost-{name,port}
  
  echo "* Create two new indexes files ..."
  echo "<h1>Cutom index.html page for vhost by port from $(hostname)</h1>" | tee /var/www/vhost-port/index.html
  echo "<h1>Cutom index.html page for vhost by name from $(hostname)</h1>" | tee /var/www/vhost-name/index.html
  
  echo "* Enable the two sites and test ..."
  ln -s /etc/nginx/sites-available/vhost-port.conf /etc/nginx/sites-enabled/
  ln -s /etc/nginx/sites-available/vhost-name.conf /etc/nginx/sites-enabled/
  nginx -t
  
  echo "* Restart the service ..."
  systemctl restart nginx
  
  echo "* Add new record in the hosts file ..."
  echo "$(hostname -i | cut -d " " -f 2)     www.$(hostname).lab      www" | tee -a /etc/hosts
  
  echo "* Check the connection ..."
  curl http://localhost
  curl http://localhost:8080
  curl http://www.$(hostname).lab

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi

##################################################