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
if [ -n "$RATHOLE_REMOTE_ADDR" ] && [ -n "$RATHOLE_TOKEN" ]; then
    mkdir -p /etc/rathole
    cat > /etc/rathole/config.toml << EOF
[client]
remote_addr = "$RATHOLE_REMOTE_ADDR"
token = "$RATHOLE_TOKEN"

[client.services.sshd]
local_addr = "127.0.0.1:22"
EOF
    
    # Generate supervisord.conf with rathole enabled
    cat > /etc/supervisord.conf << 'SUPERVISORD_CONFIG'
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
stderr_logfile=/var/log/nginx.err.log
stdout_logfile=/var/log/nginx.out.log

[program:rathole]
command=/usr/local/bin/rathole /etc/rathole/config.toml
autostart=true
autorestart=true
stderr_logfile=/var/log/rathole.err.log
stdout_logfile=/var/log/rathole.out.log
SUPERVISORD_CONFIG
else
    # Generate supervisord.conf with nginx (without rathole)
    cat > /etc/supervisord.conf << 'SUPERVISORD_CONFIG'
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
stderr_logfile=/var/log/nginx.err.log
stdout_logfile=/var/log/nginx.out.log
SUPERVISORD_CONFIG
fi

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisord.conf
