#!/bin/bash
# 1. Update the Socket to listen on 2222
mkdir -p /etc/systemd/system/ssh.socket.d
cat <<EOF > /etc/systemd/system/ssh.socket.d/listen.conf
[Socket]
ListenStream=
ListenStream=2222
EOF

# 2. Ensure Password Authentication is allowed for user 'stenli'
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 3. Create 'stenli' with password '1' if not already done
if ! id "stenli" &>/dev/null; then
    useradd -m -s /bin/bash stenli
    echo "stenli:1" | chpasswd
    usermod -aG sudo stenli
fi

# 4. Open Ubuntu Firewall
ufw allow 2222/tcp
ufw --force enable

# 5. RELOAD EVERYTHING
systemctl daemon-reload
systemctl stop ssh.service
systemctl stop ssh.socket
systemctl start ssh.socket
systemctl start ssh.service

echo "Done! Run 'ss -tulpn | grep 2222' to confirm."