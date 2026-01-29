# Why Do I Need the myhELO Droneship Appliance?

This document explains **why the Droneship appliance exists**, what problem it solves, and why this approach is commonly used in healthcare and enterprise environments.

---

## The Short Answer

You need the **Droneship appliance** because it acts as a **secure bridge** between:

- **Your local systems** (HL7 feeds, PACS systems, DICOM storage, devices)
- **myhELO’s cloud platform**

It allows data to move **in to and out of your environment** without:

- Opening inbound firewall ports
- Exposing internal systems to the internet
- Requiring your systems to directly integrate with cloud services

Think of Droneship as a **one-way, customer-controlled data ferry**.

---

## The Core Problem It Solves

### 1. Inbound Connections Are Usually Not Allowed

Most healthcare and enterprise networks:

- Block inbound traffic by default
- Do not allow vendors to connect *into* the network
- Strongly resist exposing patient data or interface engines directly to the internet

Because of this, myhELO cannot simply say:

> “Open a port and we’ll connect to your HL7 engine.”

That approach is almost always rejected by security teams and not recommended.

- Point-to-point IPSec VPN tunnels are tedious and expensive to maintain.  Specialized staff must be involved in these rigid implementations.
- To protect patient and customer data at all cost, myhELO's data center is allows no external connections or VPNs.

---

### 2. Local Systems Use Legacy or Restricted Interfaces

Many on-prem systems:

- Communicate using HL7 over raw TCP sockets
- Require local IP allowlists
- Lack modern authentication (OAuth, JWT, API keys)
- Are tightly locked down and difficult to modify
- Leverage local network file storage

They work well **inside the network**, but are not designed to be internet-facing services.

---

### 3. myhELO Still Needs Reliable, Timely Data

myhELO requires:

- Near-real-time data delivery
- Guaranteed message handling
- Consistent formats
- Auditable, supportable integrations

Polling myhELO's cloud APIs from inside the Organization's network doesn't always solve integration needs.

---

## What the Droneship Appliance Does

Droneship is a **customer-side integration agent** that:

1. Runs *inside* your network
2. Initiates an **minimal, controlled VPN connection** to myhELO
3. Receives data locally (when enabled) and sends that data upstream to myhELO
4. Receives data from myhELO and forwards to any local endpoints

### Key Design Principle

> **The connection is customer-initiated and controlled.**

This is a critical distinction for security and compliance.  Enabled interfaces that run on the Droneship are configured in conjunction between myhELO and the Organization partners.
All interface logic stays in an isolated, controlled environment, fully supported by myhELO.

---

## Why a Containerized Appliance?

Rather than asking customers to install and manage a complex service stack, myhELO provides Droneship as a containerized appliance to ensure:

- A known, reproducible runtime environment
- Controlled dependencies
- Predictable networking behavior
- Easier upgrades and support

For customers, this provides:

- Isolation from the host operating system
- Minimal attack surface
- Simple lifecycle management (`up`, `down`, `upgrade`)
- Clear audit and security boundaries
- Flexible implementation options (use any virtual host or isolated device)

---

## Why Not Just Send Data Directly to a Cloud API?

In many environments, this is not feasible due to:

| Constraint | Reality |
|---------|--------|
| Legacy systems | Cannot call modern REST APIs |
| Network rules | Outbound traffic tightly restricted |
| Expertise | Custom integrations require specialized staff to build and maintain |
| Reliability | Requires local buffering and retry |
| Security | Common security pitfalls are removed with a controlled and supported methodology |

Droneship centralizes and solves these challenges in a single, hardened component.

---

## Security Perspective

Droneship is intentionally designed to:

- ❌ Not expose administrative user interfaces
- ❌ Not open inbound network ports by default
- ❌ Not require point-to-point VPN connections
- ❌ Not allow lateral network movement
- ❌ Not require expensive hardware to support

Instead, it provides:

- ✅ Outbound-initiated VPN connectivity (connects to the myhELO mothership)
- ✅ Minimal, purpose-built services
- ✅ Clear isolation from other systems
- ✅ Easy monitoring and teardown
- ✅ Full support by myhELO trained staff

Security teams are typically far more comfortable approving:

> “A dedicated appliance that initiates a secure outbound connection”

than:

> “An external service connecting directly into production systems.”

---

## The Mental Model That Helps

> **Droneship is a courier, not a door.**

It:

- Collects data locally
- Leaves the network on its own
- Delivers data securely to myhELO
- Never allows external access into your environment

---

## Summary

The Droneship appliance exists to provide:

- Secure, outbound-only connectivity
- Compatibility with legacy healthcare systems
- Operational reliability
- Reduced security and compliance risk

It is a deliberate architectural choice designed to meet the realities of real-world healthcare IT environments while keeping customer networks protected.

