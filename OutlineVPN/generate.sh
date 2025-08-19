#!/bin/sh
set -e

STATE_DIR=${SB_STATE_DIR:-/opt/outline/persisted-state}
CERT_FILE="${STATE_DIR}/shadowbox-selfsigned.crt"
KEY_FILE="${STATE_DIR}/shadowbox-selfsigned.key"
PROMETHEUS_DIR="${STATE_DIR}/prometheus/data"

if [ ! -d "${STATE_DIR}" ]; then
  echo "Creating state directory..."
  mkdir -p "${STATE_DIR}"
  chmod 700 "${STATE_DIR}"
else
  echo "State directory exists, skipping creation."
fi

if [ ! -f "${CERT_FILE}" ] || [ ! -f "${KEY_FILE}" ]; then
  echo "Generating new self-signed certificate..."
  openssl req -x509 -nodes -days 36500 -newkey rsa:4096 \
    -subj "/CN=outline-server" \
    -keyout "${KEY_FILE}" -out "${CERT_FILE}"
else
  echo "Certificate already exists, skipping generation."
fi

ACCESS_CONFIG="${STATE_DIR}/access.txt"

apiUrl="https://localhost:${SB_API_PORT}/${SB_API_PREFIX}"
certSha256=$(openssl x509 -in "${CERT_FILE}" -noout -sha256 -fingerprint | \
    sed 's/^.*=//' | tr -d ':')

echo "apiUrl:${apiUrl}" > "$ACCESS_CONFIG"
echo "certSha256:${certSha256}" >> "$ACCESS_CONFIG"

echo "{\"apiUrl\":\"$apiUrl\",\"certSha256\":\"$certSha256\"}"

if [ ! -d "${PROMETHEUS_DIR}" ]; then
  echo "Creating Prometheus data directory..."
  mkdir -p "${PROMETHEUS_DIR}"
  chown -R 1000:1000 "${STATE_DIR}/prometheus"
else
  echo "Prometheus data directory exists, skipping creation."
fi

echo "Done."