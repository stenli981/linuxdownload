#!/bin/bash

# Update and install SSH
apt update
apt install -y openssh-server

# Configure SSH to use port 2222
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
systemctl restart ssh

# Create user 'stenli' with password '1' and sudo access
useradd -m -s /bin/bash stenli
echo "stenli:1" | chpasswd
usermod -aG sudo stenli

# Configure Firewall (UFW)
ufw allow 2222/tcp
ufw reload