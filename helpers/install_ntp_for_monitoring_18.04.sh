#!/bin/sh
# this is a helper for installing the ntp client on ubuntu 18.04
# needed for determinentptimesource.sh and ntp.conf
timedatectl set-ntp no
apt-install ntp
echo "add line server 192.168.10.2 right before pool definitions!"
joe /etc/ntp.conf
service ntp restart
ntpq -p

