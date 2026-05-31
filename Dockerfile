FROM docker.io/debian:trixie-slim AS v2fly
WORKDIR /v2fly
RUN set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl unzip && \
	curl -fsSL -O https://github.com/v2fly/v2ray-core/releases/download/v5.49.0/v2ray-linux-64.zip && \
	mkdir -p ./build && \
	unzip v2ray-linux-64.zip -d ./build

FROM docker.io/debian:trixie-slim AS cf2fly
ENV DEBIAN_FRONTEND noninteractive
ARG VERSION
LABEL \
	org.opencontainers.image.authors="tazihad <tazihad@gmail.com>" \
	org.opencontainers.image.warp-version=$VERSION

WORKDIR /tmp

# Download the standalone package directly and use apt-get to auto-resolve system dependencies
RUN set -x && \
	apt-get update && \
	apt-get install -y --no-install-recommends libcap2-bin curl ca-certificates && \
	curl -fsSL -O "https://pkg.cloudflareclient.com/pool/trixie/main/c/cloudflare-warp/cloudflare-warp_${VERSION}.0_amd64.deb" || \
	curl -fsSL -O "https://pkg.cloudflareclient.com/pool/bookworm/main/c/cloudflare-warp/cloudflare-warp_${VERSION}.0_amd64.deb" && \
	dpkg -i "cloudflare-warp_${VERSION}.0_amd64.deb" || apt-get install -f -y && \
	# Purge unnecessary curl and clean up caching structures
	apt-get purge -y curl && \
	apt-get autoremove -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy V2Ray application assets from the builder stage
COPY --from=v2fly /v2fly/build/v2ray /usr/bin/
COPY --from=v2fly /v2fly/build/geosite.dat /v2fly/build/geoip.dat /usr/local/share/v2ray/

# Inject runtime configurations and setup environment
COPY run.sh /
COPY v2f-config.json /etc/v2ray/
RUN chmod +x /run.sh && \
	mkdir -p /var/log/warp

CMD [ "/run.sh" ]
