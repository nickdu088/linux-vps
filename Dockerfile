FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/nickdu088/linux-vps"

ENV TZ=Asia/Shanghai \
    SSH_USER=debian \
    SSH_PASSWORD=debian!23 \
    DEBIAN_FRONTEND=noninteractive

# BuildKit variables
ARG TARGETARCH
ARG RATHOLE_VERSION=0.5.0

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

# Required dirs
RUN mkdir -p /var/run/sshd /usr/share/nginx/html && \
    chmod +x /entrypoint.sh /usr/local/sbin/reboot

# Download correct rathole binary based on architecture
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) \
            RATHOLE_FILE="rathole-x86_64-unknown-linux-gnu.zip" ;; \
        arm64) \
            RATHOLE_FILE="rathole-aarch64-unknown-linux-musl.zip" ;; \
        *) \
            echo "Unsupported arch: ${TARGETARCH}"; \
            exit 1 ;; \
    esac; \
    curl -fsSL \
      "https://github.com/rathole-org/rathole/releases/download/v${RATHOLE_VERSION}/${RATHOLE_FILE}" \
      -o /tmp/rathole.zip; \
    unzip -o /tmp/rathole.zip -d /usr/local/bin; \
    chmod +x /usr/local/bin/rathole; \
    rm -f /tmp/rathole.zip; \
    /usr/local/bin/rathole --version

EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]