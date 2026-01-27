$ErrorActionPreference = "Stop"

$RepoRawBase = "https://raw.githubusercontent.com/myhELO/droneship/main"
$ComposeFile = "docker-compose.yml"

Write-Host "======================================"
Write-Host " myhELO Droneship Installer (Windows)"
Write-Host "======================================"
Write-Host ""

# Sanity checks
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "ERROR: Docker is not installed."
  Write-Host "Please install Docker Desktop before continuing."
  exit 1
}

if (-not (Test-Path "droneship_client.ovpn")) {
  Write-Host "ERROR: droneship_client.ovpn not found."
  Write-Host ""
  Write-Host "Please copy your customer-specific VPN file into this directory:"
  Write-Host "  $((Get-Location).Path)\droneship_client.ovpn"
  exit 1
}

Write-Host "Downloading docker-compose.yml..."
Invoke-WebRequest `
  -Uri "$RepoRawBase/docker-compose.yml" `
  -UseBasicParsing `
  -OutFile $ComposeFile

Write-Host ""
Write-Host "Starting Droneship containers..."
docker compose up -d

Write-Host ""
Write-Host "Droneship startup initiated."
Write-Host "Check status with:"
Write-Host "  docker compose ps"
Write-Host ""
Write-Host "View logs with:"
Write-Host "  docker logs -f myhelo-droneship-app"
