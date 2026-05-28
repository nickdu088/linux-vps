# Debian

This project provides a custom Docker image based on Alpine Linux, designed to simulate a minimal VPS environment. It includes an SSH server enabled by default, allowing users to interact with the container just like a typical remote server. This setup is ideal for testing, development, or training purposes where a lightweight and easily reproducible virtual server is needed.

# Usage

```
docker run -d \
  --name debian \
  -p 2222:22 \
  -e SSH_USER=debian \
  -e SSH_PASSWORD='debian!23' \
  ghcr.io/nickdu088/linux-vps:latest
```

Thanks https://github.com/vevc/ubuntu to give me a idea!
