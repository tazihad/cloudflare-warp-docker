FROM docker.io/debian:trixie-slim AS v2fly
WORKDIR /v2fly
RUN set -x && \
	apt-get update && \
	apt-get install -y ca-certificates curl unzip && \
	curl -fsSL -O https://github.com/v2fly/v2ray-core/releases/download/v5.49.0/v2ray-linux-64.zip && \
	mkdir -p ./build && \
	unzip v2ray-linux-64.zip -d ./build

FROM docker.io/debian:trixie-slim AS cf
ARG VERSION
ENV DEDEBIAN_FRONTEND noninteractive
WORKDIR /
RUN set -x && \
	apt-get update && \
	apt-get install -y gnupg ca-certificates libcap2-bin curl && \
	mkdir -p /usr/share/keyrings && \
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ trixie main" > /etc/apt/sources.list.d/cloudflare-client.list && \
	apt-get update && \
	apt-get install cloudflare-warp=$VERSION -y && \
	apt-get autoremove -y && \
	apt-get clean -y &&\
	rm -rf /var/lib/apt-get/lists/*

FROM cf AS cf2fly
ENV DEBIAN_FRONTEND noninteractive
ARG VERSION
LABEL \
	org.opencontainers.image.authors="tazihad <tazihad@gmail.com>" \
	org.opencontainers.image.warp-version=$VERSION

COPY run.sh /
COPY --from=v2fly /v2fly/build/v2ray /usr/bin/
COPY --from=v2fly /v2fly/build/geosite.dat /v2fly/build/geoip.dat /usr/local/share/v2ray/
COPY v2f-config.json /etc/v2ray/
RUN chmod +x /run.sh && \
	mkdir -p /var/log/warp
CMD [ "/run.sh" ]
