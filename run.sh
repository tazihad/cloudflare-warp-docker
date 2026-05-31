#!/bin/bash

# Ensure the runtime socket directory exists and is accessible
mkdir -p /run/cloudflare-warp /var/log/warp
chmod 777 /run/cloudflare-warp

# Start the daemon
warp-svc > /var/log/warp/log &

# Wait up to 5 seconds for the socket file, otherwise break out to prevent an infinite hang
for i in {1..50}; do
	[ -S /run/cloudflare-warp/warp_service.sock ] && break
	sleep 0.1
done

(
	while ! warp-cli --accept-tos registration new; do
		sleep 1
		>&2 echo "Awaiting warp-svc become online..."
	done

	warp-cli --accept-tos mode proxy
	warp-cli --accept-tos proxy port 40000

	if [ -n "$LICENSE_KEY" ]; then
		warp-cli --accept-tos registration license "$LICENSE_KEY"
	fi

	warp-cli --accept-tos connect
) && \
/usr/bin/v2ray run -config /etc/v2ray/v2f-config.json
