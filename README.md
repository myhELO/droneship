# myhELO Droneship Appliance (Docker)

## Overview

The **myhELO Droneship Appliance** is a secure, preconfigured interface engine used to exchange HL7 messages (ADT, SIU, ORM/ORU) and other healthcare-related data between customer environments and the myhELO platform.

The Droneship runs locally at the customer site and establishes a **minimal VPN connection** to myhELO's data center, eliminating the need for a traditional static 'site-to-site' IPSEC vpn.

This repository provides:
- A ready-to-use `docker-compose.yml`
- Simple install scripts for Linux and Windows
- Clear manual install instructions if scripts are not desired

Each customer is issued a **customer-specific OpenVPN client file** (`droneship_client.ovpn`) by myhELO.

---

## High-Level Requirements (Read This First)

Before installing the Droneship, you must have:

### 1. A Base Operating System
One of the following, connected to the internet:

- **Windows Server** (2019 / 2022 recommended)
- **Windows OS** (Traditional windows device), such as:
  - NUC device w Windows 11
  - Repurposed device running Windows
- **Linux VM or host**, such as:
  - Ubuntu
  - Debian
  - openSUSE
  - RHEL / Rocky / Alma

Minimum system requirements:
- **10 GB free disk space**
- **2 GB RAM** (4 GB recommended)
- Reliable outbound internet access

> The Droneship may run on a physical server or a virtual instance.

### 2. Docker Installed
Docker **must** be installed before continuing.

- Docker Engine
- Docker Compose v2 (`docker compose ...`)
- On Windows: Docker Desktop configured for **Linux containers**

### 3. Static IP address
The device running the docker containers should have an assigned or static set IP Address.

---

## What You Need From myhELO

You will receive:
- `droneship_client.ovpn` (customer-specific VPN configuration)

Before installing, create a working folder on your system and copy this file into it.

Example folder name:
```
myhelo-droneship
```

Place the file here:
```
myhelo-droneship/droneship_client.ovpn
```

---

## Architecture

The Droneship runs as two Docker containers:

- **Database container**
  - MySQL
  - Persistent storage via Docker volume
- **Application container**
  - Chimera engine
  - Apache / PHP
  - OpenVPN client
  - Supervisor-managed services

The application container waits for the database to be fully ready before starting.

Docker uses **bridge networking** by default. Inbound access is provided via explicit port mappings.

---

## Quick Install (Recommended)

### Step 1: Create a working directory
Create a folder and copy your VPN file into it:

**Linux**
```bash
mkdir myhelo-droneship
cp droneship_client.ovpn myhelo-droneship/
cd myhelo-droneship
```

**Windows (PowerShell)**
```powershell
mkdir myhelo-droneship
copy droneship_client.ovpn myhelo-droneship\
cd myhelo-droneship
```

---

### Step 2: Run the installer

#### Linux (one command)
```bash
curl -fsSL https://raw.githubusercontent.com/myhELO/dronship/main/scripts/install.sh | bash
```

#### Windows PowerShell (one command)
```powershell
iwr -useb https://raw.githubusercontent.com/myhELO/dronship/main/scripts/install.ps1 | iex
```

The installer will:
- Download `docker-compose.yml`
- Start the Droneship containers

---

## Manual Install (No Scripts)

If you prefer not to use the installer scripts:

1. Download `docker-compose.yml` from this repository.
2. Place it into your working directory:
   ```
   myhelo-droneship/
     docker-compose.yml
     droneship_client.ovpn
   ```

3. Start the Droneship:
```bash
docker compose up -d
```

4. Verify:
```bash
docker compose ps
docker logs myhelo-droneship-app --tail 200
```

If successful, you will see the containers running and a **READY** message in the application logs.

---

## Common Operations

### Check status
```bash
docker compose ps -a
```

### View logs
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

### Full reset (deletes database)
⚠️ This permanently deletes stored data.

```bash
docker compose down --volumes
```

---

## Upgrades

To upgrade to newer images:

```bash
docker compose down  #if services are already running
docker compose pull
docker compose up -d
```

---

## Optional: Network Ports

The myhELO droneship appliance requires no dedicated port mappings unless messages will be sent to the droneship via dedicated socket connections (eg: ORM result HL7 messages). The following TCP ports are pre-configured and exposed by default, but are not listening by default.

- **7879**
- **7880**
- **7881**
- **7882**

If the any system on the local network will be sending messages to the droneship via TCP/IP socket sconnection, these ports must be allowed on:
- The host firewall
- Any upstream firewall or security group

---

## Troubleshooting

### Database startup takes a long time
On first run, MySQL initialization may take several minutes, especially on slower devices.

Check logs:
```bash
docker logs myhelo-droneship-db --tail 200
```

### VPN does not connect
Ensure:
- `droneship_client.ovpn` exists in the working directory
- The file was not modified

Check logs:
```bash
docker logs myhelo-droneship-app --tail 200
```

---

## Support

When contacting myhELO support, please provide:
- Output of `docker compose ps`
- Application logs:
  ```bash
  docker logs myhelo-droneship-app --tail 200
  ```
- Database logs:
  ```bash
  docker logs myhelo-droneship-db --tail 200
  ```

Docker images are published at:
https://hub.docker.com/u/myhelo
