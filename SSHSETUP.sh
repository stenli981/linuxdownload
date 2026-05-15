#!/bin/bash
# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then echo "Please run as sudo"; exit; fi

# Install SSH
apt update && apt install -y openssh-server

# CRITICAL: Fix for Ubuntu 22.10+ systemd socket activation
mkdir -p /etc/systemd/system/ssh.socket.d
cat <<EOF > /etc/systemd/system/ssh.socket.d/listen.conf
[Socket]
ListenStream=
ListenStream=2222
EOF

# Standard config update
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config

# Create user stenli with password 1
if id "stenli" &>/dev/null; then
    echo "User stenli exists, updating password."
else
    useradd -m -s /bin/bash stenli
fi
echo "stenli:1" | chpasswd
usermod -aG sudo stenli

# Firewall inside Ubuntu
ufw allow 2222/tcp
ufw --force enable

# Reload everything
systemctl daemon-reload
systemctl restart ssh.socket
systemctl restart ssh

echo "SUCCESS: Ubuntu is now listening on port 2222."