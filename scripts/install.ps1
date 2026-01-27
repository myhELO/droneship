$ErrorActionPreference = "Stop"

$RepoRawBase = "https://raw.githubusercontent.com/myhELO/dronship/main"
$TargetDir = $env:TARGET_DIR
if ([string]::IsNullOrWhiteSpace($TargetDir)) { $TargetDir = "myhelo-droneship" }

Write-Host "== myhELO Droneship Installer (Windows) =="
Write-Host "Target directory: $TargetDir"
Write-Host ""

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Set-Location $TargetDir

function Download-File($Url, $OutFile) {
  Invoke-WebRequest -Uri $Url -UseBasicParsing -OutFile $OutFile
}

Write-Host "Downloading docker-compose.yml ..."
Download-File "$RepoRawBase/docker-compose.yml" "docker-compose.yml"

Write-Host "Downloading .env.example ..."
Download-File "$RepoRawBase/.env.example" ".env.example"

if (-not (Test-Path ".env")) {
  Copy-Item ".env.example" ".env"
  Write-Host "Created .env from .env.example"
}

Write-Host ""
if (-not (Test-Path "droneship_client.ovpn")) {
  Write-Host "IMPORTANT: droneship_client.ovpn is missing."
  Write-Host "Place the customer-specific OpenVPN file here:"
  Write-Host "  $((Get-Location).Path)\droneship_client.ovpn"
  Write-Host ""
  Write-Host "Then run:"
  Write-Host "  docker compose up -d"
  exit 0
}

Write-Host "Starting containers..."
docker compose up -d

Write-Host ""
Write-Host "Done."
Write-Host "Check status:"
Write-Host "  docker compose ps"
Write-Host ""
Write-Host "App logs:"
Write-Host "  docker logs -f myhelo-droneship-app"
