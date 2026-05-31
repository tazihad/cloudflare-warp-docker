# Cloudflare WARP Container

A lightweight containerized setup for running Cloudflare WARP using Podman. This allows you to route traffic through Cloudflare's WARP service via local SOCKS5 and HTTP proxies.

This image is hosted on Docker Hub: [tazihad/cloudflare-warp](https://hub.docker.com/repository/docker/tazihad/cloudflare-warp)

---

## Deployment Guide

Choose one of the deployment methods below depending on whether you have a premium license key or are using the free tier.

### Option 1: Standard Run (Free Tier)

Use this command to run the container using the standard, free Cloudflare WARP tier:

```bash
podman run -d \
  --name cloudflare-warp \
  -p 127.0.0.1:50000:1080 \
  -p 127.0.0.1:51000:8080 \
  --restart unless-stopped \
  docker.io/tazihad/cloudflare-warp:latest
```

### Option 2: Run with WARP+ License Key

If you have a WARP+ or Cloudflare for Teams license key, pass it using the -e LICENSE_KEY environment variable:
```bash
podman run -d \
  --name cloudflare-warp \
  -p 127.0.0.1:50000:1080 \
  -p 127.0.0.1:51000:8080 \
  -e LICENSE_KEY="your_actual_license_key_here" \
  --restart unless-stopped \
  docker.io/tazihad/cloudflare-warp:latest
```

Connect with proxy:
```bash
http: 127.0.0.1:50000
socks5: 127.0.0.1:51000
```

### Docker Compose Configuration

```yml
services:
  warp:
    image: tazihad/cloudflare-warp:latest # Or ghcr.io/tazihad/cloudflare-warp:latest
    container_name: cloudflare-warp
    restart: unless-stopped
    ports:
      - "1080:1080" # SOCKS5 Proxy Port
    environment:
      - WARP_SLEEP=2 # Optional: wait time before connection
    cap_add:
      - NET_ADMIN # Required for WARP networking
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv4.conf.all.src_valid_mark=1
```

verify
```sh
curl -x socks5h://localhost:1080 https://www.cloudflare.com/cdn-cgi/trace
```
