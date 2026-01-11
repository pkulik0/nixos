#!/usr/bin/env bash
set -e

SERVER_ENDPOINT="kulik.sh:30050"
SERVER_PUBKEY="$(cat "$(dirname "$0")/../secrets/wireguard-pubkey.txt")"

[[ -z "$2" ]] && { echo "Usage: $0 <name> <ip>"; exit 1; }

PRIV=$(wg genkey)
PUB=$(echo "$PRIV" | wg pubkey)
PSK=$(wg genpsk)

cat > "$1.conf" <<EOF
[Interface]
PrivateKey = $PRIV
Address = $2/32
DNS = 10.100.0.1

[Peer]
PublicKey = $SERVER_PUBKEY
PresharedKey = $PSK
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

cat "$1.conf"
echo "
{ 
  publicKey = \"$PUB\";
  presharedKey = \"$PSK\";
  allowedIPs = [ \"$2/32\" ];
}
"
