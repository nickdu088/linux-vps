#!/usr/bin/env sh

# Create user if not exists
# Create user if not exists
if ! id "$SSH_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$SSH_USER"

    # set password
    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

    # sudo group
    usermod -aG sudo "$SSH_USER"

    # sudo rules
    echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SSH_USER
    chmod 0440 /etc/sudoers.d/$SSH_USER

    # ensure home directory exists (explicit safety)
    mkdir -p /home/$SSH_USER
    chown -R $SSH_USER:$SSH_USER /home/$SSH_USER

    # force correct shell (important for SSH login stability)
    usermod -s /bin/bash $SSH_USER
fi

# SSH config tweaks
sed -i 's/^#\?AllowAgentForwarding.*/AllowAgentForwarding yes/' /etc/ssh/sshd_config
sed -i 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sed -i 's/^GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config

# Ensure root login disabled
grep -q "^PermitRootLogin" /etc/ssh/sshd_config \
    && sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    || echo "PermitRootLogin no" >> /etc/ssh/sshd_config

echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "PermitTTY yes" >> /etc/ssh/sshd_config
echo "PrintLastLog yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
ssh-keygen -A

# Configure rathole if environment variables are set
if [ -n "$RATHOLE_SERVICE_NAME" ] && [ -n "$RATHOLE_REMOTE_ADDR" ] && [ -n "$RATHOLE_TOKEN" ]; then

    mkdir -p /etc/rathole

    cat > /etc/rathole/config.toml << EOF
[client]
remote_addr = "$RATHOLE_REMOTE_ADDR"

[client.services.$RATHOLE_SERVICE_NAME]
token = "$RATHOLE_TOKEN"
local_addr = "127.0.0.1:22"
EOF

    cat > /etc/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/tmp/supervisord.pid

[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true

[program:rathole]
command=/usr/local/bin/rathole /etc/rathole/config.toml
autorestart=true
EOF

else
    cat > /etc/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/tmp/supervisord.pid

[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true
EOF
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf