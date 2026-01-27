#!/usr/bin/env bash
set -euo pipefail

REPO_RAW_BASE="https://raw.githubusercontent.com/myhELO/droneship/main"
COMPOSE_FILE="docker-compose.yml"

echo "======================================"
echo " myhELO Droneship Installer (Linux)"
echo "======================================"
echo

# Basic sanity checks
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is not installed."
  echo "Please install Docker before continuing."
  exit 1
fi

if [ ! -f "droneship_client.ovpn" ]; then
  echo "ERROR: droneship_client.ovpn not found."
  echo
  echo "Please copy your customer-specific VPN file into this directory:"
  echo "  $(pwd)/droneship_client.ovpn"
  exit 1
fi

echo "Downloading docker-compose.yml..."
curl -fsSL "${REPO_RAW_BASE}/docker-compose.yml" -o "${COMPOSE_FILE}"

echo
echo "Starting Droneship containers..."
docker compose up -d

echo
echo "Droneship startup initiated."
echo "Check status with:"
echo "  docker compose ps"
echo
echo "View logs with:"
echo "  docker logs -f myhelo-droneship-app"
