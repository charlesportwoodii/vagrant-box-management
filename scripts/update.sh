#!/bin/bash

# Upgrade box
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y

# Clean up APT
apt-get clean -y
apt-get autoclean -y
find /var/lib/apt -type f | xargs rm -f

# Zero free space to aid in disk compression
dd if=/dev/zero of=/empty bs=1M
rm -rf /empty

# Reset default SSH key
wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O .ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
chown -R vagrant:vagrant .ssh

# Wipe log files
cat /dev/null > /var/log/nginx/access.log
cat /dev/null > /var/log/nginx/error.log

# Wipe history
unset HISTFILE
rm -rf /root/.bash_history
rm -rf /home/vagrant/.bash_history
