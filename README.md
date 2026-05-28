# Debian

This project provides a custom Docker image based on Alpine Linux, designed to simulate a minimal VPS environment. It includes an SSH server enabled by default, allowing users to interact with the container just like a typical remote server. This setup is ideal for testing, development, or training purposes where a lightweight and easily reproducible virtual server is needed.

# Usage

```
docker run -d \
  --name debian \
  -p 2222:22 \
  -e SSH_USER=debian \
  -e SSH_PASSWORD='debian!23' \
  -e RATHOLE_REMOTE_ADDR=127.0.0.1:12345 \
  -e RATHOLE_TOKEN="secret_token" \
  -e RATHOLE_SERVICE_NAME=service_name
  ghcr.io/nickdu088/linux-vps:latest
```

Thanks https://github.com/vevc/ubuntu to give me a idea!
