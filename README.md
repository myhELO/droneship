# myhELO Droneship Appliance (Docker)

## Overview

The **myhELO Droneship Appliance** is a secure, preconfigured interface engine used to exchange HL7 messages (ADT, SIU, ORM/ORU) and other healthcare-related data between customer environments and the myhELO platform.

The Droneship runs locally at the customer site and establishes a **minimal, outbound-only VPN connection** to myhELO's data center, eliminating the need for a traditional static 'site-to-site' IPSEC vpn.

This repository provides:
- A ready-to-use `docker-compose.yml`
- Simple install scripts for Linux and Windows
- Clear manual install instructions if scripts are not desired

Each customer is issued a **customer-specific OpenVPN client file** (`droneship_client.ovpn`) by myhELO.

---

## Who is this for?

This guide is intended for customer IT administrators or system integrators responsible for local interface infrastructure.

---

## High-Level Requirements (Read This First)

Before installing the Droneship, you must have:

### 1. A Base Operating System Host

As a best practice, the Droneship should run on a **dedicated device or a dedicated virtual machine**, separate from other production workloads.

Common deployment options include:

- **Linux VM or host** (recommended):
  - Ubuntu / Debian
  - RHEL / Rocky / Alma
  - openSUSE

- **Windows OS** (traditional Windows device or VM)
- **Windows Server** (2019 / 2022 recommended)

#### Windows Server Best Practice

Windows Server includes **Hyper-V**, which allows it to act as a virtualization host.

The most common deployment pattern is:
- Enable Hyper-V
- Create a small **Linux virtual machine**
- Install Docker Engine and Docker Compose inside the VM
- Run the Droneship containers inside the VM

Running Docker Desktop directly on Windows Server is supported, but typically reserved for single-purpose servers.

#### Microsoft Azure

In Azure environments, the recommended deployment is:
- Create a **Linux virtual machine**
- Install Docker Engine and Docker Compose
- Deploy the Droneship containers normally

Azure container orchestration platforms (AKS, Container Apps) are **not recommended**.

---

### Minimum System Requirements

- **10 GB free disk space**
- **2 GB RAM** (4 GB recommended)
- Reliable outbound internet access

---

### 2. Docker Installed

Docker **must** be installed before continuing.

Required components:
- Docker Engine
- Docker Compose v2 (`docker compose`)
- On Windows: Docker Desktop configured for **Linux containers**

#### Example Docker Installation (Linux)

**Ubuntu / Debian**
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://get.docker.com | sudo bash
```

**RHEL / Rocky / Alma**
```bash
sudo dnf install -y dnf-utils
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
```

**openSUSE**
```bash
sudo zypper install -y docker docker-compose
sudo systemctl enable --now docker
```

After installation, verify:
```bash
docker version
docker compose version
```

#### Example Docker Installation (Windows)

If running Docker directly on Windows, install Docker Desktop following the instructions provided by Docker.

https://docs.docker.com/desktop/setup/install/windows-install/

---

### 3. Static IP address (local, not public)
The device running the docker containers should have an assigned or static set IP Address.  This address does not need to be publicly accessible.

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

The application container waits for the database container to become healthy before starting services.

Docker uses **bridge networking** by default, with an isolated internal network for the Droneship containers. Inbound access is provided via explicit port mappings.

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
curl -fsSL https://raw.githubusercontent.com/myhELO/droneship/main/scripts/install.sh | bash
```

#### Windows PowerShell (one command)
```powershell
iwr -useb https://raw.githubusercontent.com/myhELO/droneship/main/scripts/install.ps1 | iex
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

If successful, you will see the containers running and a **READY** message in the application logs indicating successful startup.

---

## What to Expect on First Startup

On the first run, Docker will download the Droneship images, create a network and volume, and initialize the database. This may take **1–3 minutes**, depending on internet speed and disk performance.

### Example output
```bash
docker compose up -d
```

```text
[+] up 38/38
 ✔ Image myhelo/myhelo-droneship-db  Pulled        24.0s
 ✔ Image myhelo/myhelo-droneship-app Pulled        55.5s
 ✔ Network docker_default            Created        0.1s
 ✔ Volume docker_myhelo_storage      Created        0.0s
 ✔ Container myhelo-droneship-db     Healthy       18.9s
 ✔ Container myhelo-droneship-app    Created        0.1s
```

Once the containers are running, you can view application logs:

```bash
docker logs myhelo-droneship-app
```

You should see output similar to:

```text
INFO supervisord started with pid 1
INFO spawned: 'apache'
INFO spawned: 'chimera'
INFO spawned: 'droneship_status'
INFO spawned: 'openvpn'
INFO spawned: 'sshd'
INFO success: apache entered RUNNING state
INFO success: openvpn entered RUNNING state
INFO success: chimera entered RUNNING state

======================================

   myhELO Droneship is READY ✅

======================================
```

When you see **“Droneship is READY”**, the appliance is fully operational.

### If startup takes longer than expected

- Database initialization on first run may take extra time, especially on Windows.
- You can monitor database logs with:
```bash
docker logs myhelo-droneship-db
```

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

The myhELO Droneship appliance requires no dedicated port mappings unless messages will be sent to the Droneship via dedicated socket connections (eg: ORM result HL7 messages). The following TCP ports are pre-configured and exposed by default, but are not listening by default.

- **7879**
- **7880**
- **7881**
- **7882**

If the any system on the local network will be sending messages to the Droneship via TCP/IP socket connection, these ports must be allowed on:
- The host firewall
- Any upstream firewall or security group

---

## Troubleshooting

### Database startup takes a long time
On first run, MySQL initialization may take several minutes, especially on slower devices.

Do not change the environment variables within the docker-compose.yml file as these are used during initial setup of the container.

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

## Security considerations

The myhELO Droneship appliance configuration was designed to limit security liabilities.  

- The two containers run on an isolated docker network, ensuring that the database and appliance aren't listening or accessible to any local devices.  
- The separate database container is only accessible to the application container via the private docker network created at startup.
- The application container exposes no default service ports (http, ssh, etc) to the local network at any time.
- The 4 available socket listener ports (7879-7882) are not enabled until myhELO support works with the customer to do so.
- The customer is recommended to ensure that the host OS is also firewalled appropriately.  
  - For internet access, the Droneship only needs outbound access to udp port 1194 (to mothership.myhelo.com)
  - For local network access, the Droneship only needs outbound IP access to the devices it will send data to and inbound traffic to the Droneship host will need to be opened on the local host firewall.

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
