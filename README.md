# myhELO Droneship Appliance (Docker)

## Overview

The **myhELO Droneship Appliance** is a secure, preconfigured interface engine for organizations that need to send/receive HL7 messages (ADT, SIU, ORM/ORU) and/or support file-based exchange methods (e.g., SFTP, DICOM workflows), without requiring direct inbound VPN access to the myhELO data center.

This repository provides:
- A production-ready `docker-compose.yml`
- Simple install scripts for Linux and Windows
- Operational commands (start/stop/logs/reset)

> **Important:** Each customer receives a **customer-specific** OpenVPN client configuration file:  
> `droneship_client.ovpn`

---

## Architecture

This deployment runs two containers:

- **db** (`myhelo/myhelo-droneship-db`)
  - MySQL database
  - Persistent storage via Docker volume (`myhelo_storage`)
- **app** (`myhelo/myhelo-droneship-app`)
  - Chimera + Apache/PHP + OpenVPN client
  - Supervisor-managed services
  - Publishes inbound ports for HL7/socket traffic

Docker Compose is configured so the **app waits for db** to become healthy before starting.

---

## Requirements

### Docker
- Docker Engine
- Docker Compose v2 (`docker compose ...`)
- **Linux containers** (Docker Desktop on Windows must be set to Linux containers)

### OpenVPN
- A customer-specific file named `droneship_client.ovpn`
- This file must be placed next to `docker-compose.yml`

### Ports / Firewall
The Droneship app publishes the following TCP ports by default:

- `7879`
- `7880`
- `7881`
- `7882`

These ports must be allowed on:
- The Docker host firewall
- Any upstream firewall or security group

> Docker uses **bridge networking** by default. Inbound access is provided via the published `ports:` mappings in Docker Compose.

---

## Quick Install (Recommended)

### Linux (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/myhELO/dronship/main/scripts/install.sh | bash
```

### Windows PowerShell (one-liner)

```powershell
iwr -useb https://raw.githubusercontent.com/myhELO/dronship/main/scripts/install.ps1 | iex
```

The installer will:
- Create a `myhelo-droneship` directory
- Download `docker-compose.yml` and `.env.example`
- Prompt you to place `droneship_client.ovpn`
- Start the containers

---

## Manual Install

1. Create a working directory:
```bash
mkdir myhelo-droneship
cd myhelo-droneship
```

2. Copy into this directory:
- `docker-compose.yml`
- `droneship_client.ovpn` (provided by myhELO)

3. Start the stack:
```bash
docker compose up -d
```

4. Verify:
```bash
docker compose ps
docker logs myhelo-droneship-app --tail 200
docker logs myhelo-droneship-db  --tail 200
```

If successful, you should see:
- `myhelo-droneship-db` running and healthy
- `myhelo-droneship-app` running
- A **READY** message in the app logs once Apache and Chimera are up

---

## Common Operations

### View running containers
```bash
docker compose ps
```

### Tail logs
```bash
docker logs -f myhelo-droneship-app
docker logs -f myhelo-droneship-db
```

### Restart
```bash
docker compose restart
```

### Stop
```bash
docker compose down
```

### Stop and wipe all persistent data (FULL RESET)
⚠️ This permanently deletes the database volume.

```bash
docker compose down --volumes
```

---

## Upgrades

To pull updated images and restart:

```bash
docker compose pull
docker compose up -d
```

---

## Troubleshooting

### App does not start because DB is unhealthy
On first run, MySQL initialization may take several minutes (especially on Windows Docker Desktop).

Check database logs:
```bash
docker logs myhelo-droneship-db --tail 200
```

### OpenVPN connection issues
If the OpenVPN file is missing or invalid, the VPN process will fail.

Verify the file exists:
- `./droneship_client.ovpn`

Then check logs:
```bash
docker logs myhelo-droneship-app --tail 200
```

---

## Support

When contacting support, please provide:
- Output of `docker compose ps`
- Output of `docker logs myhelo-droneship-app --tail 200`
- Output of `docker logs myhelo-droneship-db --tail 200`

Docker images are published at:
https://hub.docker.com/u/myhelo