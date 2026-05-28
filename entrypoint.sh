#!/usr/bin/env sh

echo "========== Entrypoint startup =========="
echo "[*] Environment check:"
echo "    RATHOLE_SERVICE_NAME=$RATHOLE_SERVICE_NAME"
echo "    RATHOLE_REMOTE_ADDR=$RATHOLE_REMOTE_ADDR"
echo "    RATHOLE_TOKEN=${RATHOLE_TOKEN:+*REDACTED*}"

# Create user if not exists
if ! id "$SSH_USER" >/dev/null 2>&1; then
    echo "[*] Creating user: $SSH_USER"

    useradd -m -s /bin/bash "$SSH_USER"

    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

    usermod -aG sudo "$SSH_USER"

    echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SSH_USER
    chmod 0440 /etc/sudoers.d/$SSH_USER
fi

# SSH config tweaks
sed -i 's/^#\?AllowAgentForwarding.*/AllowAgentForwarding yes/' /etc/ssh/sshd_config
sed -i 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sed -i 's/^GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config

# Ensure root login disabled
grep -q "^PermitRootLogin" /etc/ssh/sshd_config \
    && sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    || echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# Generate SSH host keys
ssh-keygen -A

# Configure rathole if environment variables are set
if [ -n "$RATHOLE_SERVICE_NAME" ] && [ -n "$RATHOLE_REMOTE_ADDR" ] && [ -n "$RATHOLE_TOKEN" ]; then
    echo "[*] Configuring rathole client..."
    echo "    Service: $RATHOLE_SERVICE_NAME"
    echo "    Remote: $RATHOLE_REMOTE_ADDR"

    mkdir -p /etc/rathole

    cat > /etc/rathole/config.toml << EOF
[client]
remote_addr = "$RATHOLE_REMOTE_ADDR"

[client.services.$RATHOLE_SERVICE_NAME]
token = "$RATHOLE_TOKEN"
local_addr = "127.0.0.1:22"
EOF

    echo "[*] Rathole config created:"
    cat /etc/rathole/config.toml

    echo "[*] Testing rathole binary..."
    /usr/local/bin/rathole --version || echo "[!] Rathole binary not available"

    cat > /etc/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/tmp/supervisord.pid
user=root

[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true

[program:rathole]
command=/usr/local/bin/rathole /etc/rathole/config.toml
autorestart=true
startsecs=5
startretries=3
EOF

else
    cat > /etc/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/tmp/supervisord.pid
user=root

[program:sshd]
command=/usr/sbin/sshd -D
autorestart=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autorestart=true
EOF
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf