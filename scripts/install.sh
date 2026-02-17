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

# Ensure TUN kernel module is loaded (required for OpenVPN)
echo "Checking for TUN kernel module..."
if lsmod | grep -qw '^tun'; then
  echo "TUN module already loaded."
else
  echo "TUN module not loaded; attempting to load it now."
  if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    else
      echo "ERROR: root or sudo is required to load the tun module and write to /etc/modules-load.d."
      echo "Please re-run the installer as root or install sudo and retry."
      exit 1
    fi
  else
    SUDO=""
  fi

  if $SUDO modprobe tun; then
    echo "Loaded tun module."
  else
    echo "ERROR: failed to load tun module with modprobe."
    exit 1
  fi

  echo "Making tun load at boot (/etc/modules-load.d/droneship-tun.conf)..."
  printf 'tun\n' | $SUDO tee /etc/modules-load.d/droneship-tun.conf >/dev/null
  echo "Wrote /etc/modules-load.d/droneship-tun.conf"
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
