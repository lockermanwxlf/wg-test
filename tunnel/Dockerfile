FROM debian:trixie-slim

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    bash wireguard-tools wireguard-go iproute2 iptables iputils-ping

COPY --from=ghcr.io/erebe/wstunnel /home/app/wstunnel /bin/wstunnel
WORKDIR /app
COPY . .
CMD [ "bash", "entrypoint.bash" ]