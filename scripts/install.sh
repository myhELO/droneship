#!/usr/bin/env bash
set -euo pipefail

REPO_RAW_BASE="https://raw.githubusercontent.com/myhELO/dronship/main"
TARGET_DIR="${TARGET_DIR:-myhelo-droneship}"

echo "== myhELO Droneship Installer (Linux) =="
echo "Target directory: ${TARGET_DIR}"
echo

mkdir -p "${TARGET_DIR}"
cd "${TARGET_DIR}"

download() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$out"
  else
    echo "ERROR: curl or wget is required."
    exit 1
  fi
}

echo "Downloading docker-compose.yml ..."
download "${REPO_RAW_BASE}/docker-compose.yml" "docker-compose.yml"

echo "Downloading .env.example ..."
download "${REPO_RAW_BASE}/.env.example" ".env.example"

if [ ! -f ".env" ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

echo
if [ ! -f "droneship_client.ovpn" ]; then
  echo "IMPORTANT: droneship_client.ovpn is missing."
  echo "Place the customer-specific OpenVPN file here:"
  echo "  $(pwd)/droneship_client.ovpn"
  echo
  echo "Then run:"
  echo "  docker compose up -d"
  exit 0
fi

echo "Starting containers..."
docker compose up -d

echo
echo "Done."
echo "Check status:"
echo "  docker compose ps"
echo
echo "App logs:"
echo "  docker logs -f myhelo-droneship-app"
