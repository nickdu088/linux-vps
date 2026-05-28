FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/nickdu088/linux-vps"

# Set environment variables
ENV TZ=Asia/Shanghai \
    SSH_USER=debian \
    SSH_PASSWORD=debian!23

# prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Copy necessary scripts
COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot
COPY supervisord.conf /etc/supervisord.conf
COPY index.html /usr/share/nginx/html/index.html

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    openssh-server \
    sudo \
    curl \
    wget \
    ca-certificates \
    vim \
    nano \
    nginx \
    net-tools \
    openssl \
    htop \
    supervisor \
    sqlite3 \
    python3 \
    python3-pip \
    bash \
    iputils-ping \
    iproute2 \
    git \
    unzip \
    dnsutils \
    procps \
    && rm -rf /var/lib/apt/lists/*

# directories
RUN mkdir -p /var/run/sshd /usr/share/nginx/html
RUN chmod +x /entrypoint.sh /usr/local/sbin/reboot

# Install rathole
RUN curl -sSL https://github.com/rathole-org/rathole/releases/download/v0.5.0/rathole-x86_64-unknown-linux-gnu.zip -o /tmp/rathole.zip && \
    unzip -o /tmp/rathole.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/rathole && \
    rm /tmp/rathole.zip

EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]