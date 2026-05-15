#!/bin/bash

# 1. Install SSH
apt update && apt install -y openssh-server

# 2. Fix the "Socket" issue (Common in new Ubuntu versions)
# This ensures the system listens on 2222 instead of the default 22
mkdir -p /etc/systemd/system/ssh.socket.d
cat <<EOF > /etc/systemd/system/ssh.socket.d/listen.conf
[Socket]
ListenStream=
ListenStream=2222
EOF

# 3. Update sshd_config for consistency
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config

# 4. Create user 'stenli' (password '1' is a bold choice, but here you go!)
useradd -m -s /bin/bash stenli
echo "stenli:1" | chpasswd
usermod -aG sudo stenli

# 5. Configure Ubuntu Firewall
ufw allow 2222/tcp
ufw --force enable

# 6. Apply all changes
systemctl daemon-reload
systemctl restart ssh.socket
systemctl restart ssh

echo "Setup complete. Port 2222 is active for user stenli."