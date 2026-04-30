---
title: Docker install
sidebar_label: Docker
---

This document provides the necessary steps for installation of Marites on any system that runs Docker. You run NixOS? We got you covered, see [NixOS install](nixos.md).

This setup is recommended only if you are running Marites **on your home network**, as otherwise your Tesla API tokens might be at risk.
If you intend to access Marites from the Internet, the recommended way is to use a secure connection (such as a VPN, Cloudflare Tunnel, Tailscale, Zero Tier and a reverse proxy for portless access) for secured access to your Marites instance outside your home network.
Alternatively, you can use a reverse proxy (such as Traefik, Apache2 or Caddy) with appropriate hardening to secure your Marites instance before expose it to the internet, check out the [advanced guides with Traefik](../advanced_guides/traefik.md) for an example how to use Traefik with Marites. Or you can use the [advanced guides with Apache](../advanced_guides/apache.md) to set up Marites with Apache2, TLS and HTTP Basic Auth.

## Requirements

- Docker _(if you are new to Docker, see [Installing Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/linux/))_
- A Machine that's always on, so Marites can continually fetch data
- At least 1 GB of RAM on the machine for the installation to succeed. It is recommended to have at least 2 GB of RAM for optimal operation.
- External internet access, to talk to tesla.com

## Instructions

1. Create a file called `docker-compose.yml` with the following content:

   ```yml title="docker-compose.yml"
   services:
     Marites:
       image: Marites/Marites:latest
       restart: always
       environment:
         - ENCRYPTION_KEY=secretkey #replace with a secure key to encrypt your Tesla API tokens
         - DATABASE_USER=Marites
         - DATABASE_PASS=password #insert your secure database password!
         - DATABASE_NAME=Marites
         - DATABASE_HOST=database
         - MQTT_HOST=mosquitto
       ports:
         - 4000:4000
       volumes:
         - ./import:/opt/app/import
       cap_drop:
         - all

     database:
       image: postgres:18-trixie
       restart: always
       environment:
         - POSTGRES_USER=Marites
         - POSTGRES_PASSWORD=password #insert your secure database password!
         - POSTGRES_DB=Marites
       volumes:
         - Marites-db:/var/lib/postgresql

     grafana:
       image: Marites/grafana:latest
       restart: always
       environment:
         - DATABASE_USER=Marites
         - DATABASE_PASS=password #insert your secure database password!
         - DATABASE_NAME=Marites
         - DATABASE_HOST=database
       ports:
         - 3000:3000
       volumes:
         - Marites-grafana-data:/var/lib/grafana

     mosquitto:
       image: eclipse-mosquitto:2
       restart: always
       command: mosquitto -c /mosquitto-no-auth.conf
       # ports:
       #   - 1883:1883
       volumes:
         - mosquitto-conf:/mosquitto/config
         - mosquitto-data:/mosquitto/data

   volumes:
     Marites-db:
     Marites-grafana-data:
     mosquitto-conf:
     mosquitto-data:
   ```

2. **Choose a secure encryption key** that will be used to encrypt your Tesla API tokens (insert as `ENCRYPTION_KEY`).
3. **Choose your secure database password** and insert it at every occurrence of `DATABASE_PASS` and `POSTGRES_PASSWORD`
4. Start the docker containers with `docker compose up`. To run the containers in the background add the `-d` flag:

   ```bash
   docker compose up -d
   ```

### MCU2 upgraded car

If you have a MCU2 upgraded car, you can replace `image: Marites/Marites:latest` with `image: ghcr.io/Marites-org/Marites:pr-4453` to get the latest version of Marites that supports MCU2 upgraded cars (improved sleeping behavior for MCU2 upgraded cars).

## Usage

1. Open the web interface [http://your-ip-address:4000](http://localhost:4000)
2. Sign in with your Tesla Account
3. The Grafana dashboards are available at [http://your-ip-address:3000](http://localhost:3000). Log in with the default user `admin` (initial password `admin`) and enter a secure password.

## Update

To update the running Marites configuration to the latest version, follow: [Upgrading to a new version](../upgrading.mdx)
