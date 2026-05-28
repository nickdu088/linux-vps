FROM alpine:latest

LABEL org.opencontainers.image.source="https://github.com/nickdu088/linux-vps"

# Set environment variables
ENV TZ=Asia/Shanghai \
    SSH_USER=debian \
    SSH_PASSWORD=debian!23

# Copy necessary scripts
COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot
COPY supervisord.conf /etc/supervisord.conf

# Install dependencies
RUN apk update && apk add --no-cache \
        tzdata \
        openssh \
        sudo \
        curl \
        ca-certificates \
        wget \
        vim \
        nano \
        nginx \
        net-tools \
        openssl \
        htop \
        supervisor \
        sqlite \
        python3 \
        py3-pip \
        bash \
        iputils \
        iproute2 \
        git \
        shadow \
        unzip \
        bind-tools \
    && \
    mkdir -p /var/run/sshd && \
    chmod +x /entrypoint.sh /usr/local/sbin/reboot && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]
