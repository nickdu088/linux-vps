#!/usr/bin/env sh

# Create user if not exists
if ! id "$SSH_USER" >/dev/null 2>&1; then
    adduser -D -s /bin/sh "$SSH_USER"
    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
    addgroup "$SSH_USER" wheel
    echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SSH_USER
fi

sed -i 's/^#\s*\(AllowAgentForwarding\s\+yes\)/\1/' /etc/ssh/sshd_config
sed -i 's/^AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sed -i 's/^GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config
# Harden SSH: Disable root login
echo 'PermitRootLogin no' >> /etc/ssh/sshd_config

# Generate SSH host keys if missing
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
    
    # Generate supervisord.conf with rathole enabled
    cat > /etc/supervisord.conf << 'SUPERVISORD_CONFIG'
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/tmp/supervisord.pid
user=root

[program:sshd]
command=/usr/sbin/sshd -D
user=root
autorestart=true

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
user=root
autorestart=true

[program:rathole]
command=bash -c "RUST_LOG=debug /usr/local/bin/rathole /etc/rathole/config.toml"
user=root
autostart=true
autorestart=true
startsecs=5
startretries=3
SUPERVISORD_CONFIG
else
    # Generate supervisord.conf with nginx (without rathole)
    cat > /etc/supervisord.conf << 'SUPERVISORD_CONFIG'
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
SUPERVISORD_CONFIG
fi

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisord.conf
