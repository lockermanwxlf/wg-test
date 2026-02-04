#!/usr/bin/env bash

export WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go
export WG_THREADS=4

if [ ! -e /etc/wireguard/publickey ]; then
    echo "Generating WireGuard keypair..."
    mkdir -p /etc/wireguard
    (umask 077 && wg genkey > /etc/wireguard/privatekey)
    wg pubkey < /etc/wireguard/privatekey > /etc/wireguard/publickey
fi

PRIV_KEY=$(cat /etc/wireguard/privatekey 2>/dev/null)
echo "Writing WireGuard configuration..."
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 172.16.0.1/12
ListenPort = $WG_PORT
PrivateKey = $PRIV_KEY
MTU = 1280
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

echo "Starting WireGuard interface..."
wg-quick down wg0 2>/dev/null || true
wg-quick up wg0

echo "Starting wstunnel..."
wstunnel server --restrict-to localhost:$WG_PORT wss://0.0.0.0:$WG_PORT &
WSTUNNEL_PID=$!

trap "kill $WSTUNNEL_PID; wg-quick down wg0" SIGINT SIGTERM EXIT

wait