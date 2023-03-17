#!/bin/bash

################## Create self-signed certificate ##################

echo "* Install the necessary packages ..."
dnf install -y mod_ssl openssl

echo "* Generate the private key ..."
openssl genrsa -out ca.key 2048

echo "* Create a certificate signing request (CSR) ..."
openssl req -new -subj "/C=BG/ST=Plovidv/L=Plovidv/O=merev/OU=merev/CN=merev/emailAddress=dummy@mail.test" -key ca.key -out ca.csr

echo "* Generate the self-signed certificate ..."
openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt

echo "* Show the result ..."
openssl x509 -text -in ca.crt

####################################################################

echo "* Export Distro version in env var and print its value ..."
VAR=`cat /proc/version | grep -o 'Red Hat\|Debian' | head -n 1`
echo "$VAR"

if [[ $VAR == "Red Hat" ]]; then
  
  echo "* Copy the files to the appropriate folders ..."
  cp ca.crt /etc/pki/tls/certs/ca.crt
  cp ca.key /etc/pki/tls/private/ca.key
  cp ca.csr /etc/pki/tls/private/ca.csr

else

  echo "This is not RHEL-based distro. Skipping RHEL block."

fi


if [[ $VAR == 'Debian' ]]; then

  echo "* Copy the files to the appropriate folders ..."
  cp ca.crt /etc/nginx/ca.crt
  cp ca.key /etc/nginx/ca.key
  cp ca.csr /etc/nginx/ca.csr

else

  echo "This is not Debian-based distro. Skipping Debian block."

fi