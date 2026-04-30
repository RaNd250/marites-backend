---
title: Manual install - FreeBSD (no support)
sidebar_label: Manual - FreeBSD (no support)
---

This document provides the necessary steps for installation of Marites in a FreeBSD jail. The **recommended and most straightforward installation approach is through the use of [Docker](../docker.md)**, however this walkthrough provides the necessary steps for manual installation in a FreeBSD 13.0 environment.
It assumes that pre-requisites are met and only basic instructions are provided and should also work in FreeBSD before 13.0.

## Requirements

Click on the following items to view detailed installation steps.

<details>
  <summary>bash & jq</summary>

```bash
pkg install bash jq
bash
```

For simplicity reasons, follow the rest of the tutorial in bash rather the csh.

</details>

<details>
  <summary>git</summary>

```bash
pkg install git
```

</details>

<details>
  <summary>Erlang (v26+)</summary>

```bash
pkg install erlang
```

</details>

<details>
  <summary>Elixir (v1.17+)</summary>

```bash
pkg install elixir
```

</details>

<details>
  <summary>Postgres (v16.7+, v17.3+ or v18.0+)</summary>

```bash
pkg install postgresql18-server
pkg install postgresql18-contrib
echo postgres_enable="yes" >> /etc/rc.conf
```

</details>

<details>
  <summary>Initialize the database</summary>

```bash
service postgresql initdb
```

</details>

<details>
  <summary>Grafana (v12.3.0+)</summary>

```bash
pkg install grafana
echo grafana_enable="yes" >> /etc/rc.conf
```

</details>

<details>
  <summary>An MQTT Broker (e.g. Mosquitto)</summary>

```bash
pkg install mosquitto
echo mosquitto_enable="yes" >> /etc/rc.conf
```

</details>

<details>
  <summary>Node.js (v22+)</summary>

```bash
pkg install node22
pkg install npm-node22
```

</details>

## Clone Marites git repository

The following command will clone the source files for the Marites project. This should be run in an appropriate directory within which you would like to install Marites. You should also record this path and provide them to the startup scripts proposed at the end of this guide.

```bash
cd /usr/local/src

git clone https://github.com/Marites-org/Marites.git
cd Marites

git checkout $(git describe --tags `git rev-list --tags --max-count=1`) # Checkout the latest stable version
```

## Create PostgreSQL database

The following commands will create a database called `Marites` on the PostgreSQL database server, and a user called `Marites`. When creating the `Marites` user, you will be prompted to enter a password for the user interactively. This password should be recorded and provided as an environment variable in the startup script at the end of this guide. Use 'su - postgres' if unable to enter psql console from current user.

```console
psql
postgres=# create database Marites;
postgres=# create user Marites with encrypted password 'your_secure_password_here';
postgres=# grant all privileges on database Marites to Marites;
postgres=# ALTER USER Marites WITH SUPERUSER;
postgres=# \q
```

_Note: The superuser privileges can be revoked after running the initial database migrations._

## Compile Elixir Project

```bash
mix local.hex --force; mix local.rebar --force

mix deps.get --only prod
npm install --prefix ./assets && npm run deploy --prefix ./assets

export MIX_ENV=prod
mix do phx.digest, release --overwrite
```

## Starting Marites at boot time

### Create FreeBSD service definition _/usr/local/etc/rc.d/Marites_

```console
#!/bin/sh
# PROVIDE: Marites
# REQUIRE: DAEMON
# KEYWORD: Marites,tesla

. /etc/rc.subr

name=Marites
rcvar=Marites_enable

load_rc_config $name

user=Marites
group=Marites

#
# DO NOT CHANGE THESE DEFAULT VALUES HERE
# SET THEM IN THE /etc/rc.conf FILE
#
Marites_enable=${Marites_enable-"NO"}
pidfile=${Marites_pidfile-"/var/run/${name}.pid"}

Marites_enable_mqtt=${Marites_enable_mqtt-"FALSE"}
Marites_db_port=${Marites_db_port-"5432"}

HTTP_BINDING_ADDRESS="0.0.0.0"; export HTTP_BINDING_ADDRESS
HOME="/usr/local/src/Marites"; export HOME
PORT=${Marites_port-"4000"}; export PORT
TZ=${Marites_timezone-"Europe/Berlin"}; export TZ
LANG=${Marites_locale-"en_US.UTF-8"}; export LANG
LC_CTYPE=${Marites_locale-"en_US.UTF-8"}; export LC_TYPE
DATABASE_NAME=${Marites_db-"Marites"}; export DATABASE_NAME
DATABASE_HOST=${Marites_db_host-"localhost"}; export DATABASE_HOST
DATABASE_USER=${Marites_db_user-"Marites"}; export DATABASE_USER
DATABASE_PASS=${Marites_db_pass}; export DATABASE_PASS
ENCRYPTION_KEY=${Marites_encryption_key}; export ENCRYPTION_KEY
DISABLE_MQTT=${Marites_mqtt_enable-"FALSE"}; export DISABLE_MQTT
MQTT_HOST=${Marites_mqtt_host-"localhost"}; export MQTT_HOST
# Uncomment if you need these
#MQTT_USERNAME=${Marites_mqtt_user-"Marites"}; export MQTT_USERNAME
#MQTT_PASSWORD=${Marites_mqtt_pass-"mqttpassword"}; export MQTT_PASSWORD
VIRTUAL_HOST=${Marites_virtual_host-"Marites.example.com"}; export VIRTUAL_HOST

COMMAND=${Marites_command-"${HOME}/_build/prod/rel/Marites/bin/Marites"}

Marites_start()
{
  ${COMMAND} eval "Marites.Release.migrate"
  ${COMMAND} daemon
}

start_cmd="${name}_start"
stop_cmd="${COMMAND} stop"
status_cmd="${COMMAND} pid"

run_rc_command "$1"
```

### Update _/etc/rc.conf_

```bash
echo Marites_enable="YES" >> /etc/rc.conf
echo Marites_db_host="localhost"  >> /etc/rc.conf
echo Marites_db_port="5432"  >> /etc/rc.conf
echo Marites_db_pass="<super secret>" >> /etc/rc.conf
echo Marites_encryption_key="<super secret encryption key>" >> /etc/rc.conf
echo Marites_disable_mqtt="true" >> /etc/rc.conf
echo Marites_timezone="<TZ Database>" >> /etc/rc.conf #i.e. Europe/Berlin, America/Los_Angeles
```

### Start service

```bash
chmod +x /usr/local/etc/rc.d/Marites
service Marites start
```

## Import Grafana Dashboards

1. Visit [localhost:3000](http://localhost:3000) and log in (don't forget to start the service: service grafana start). The default credentials are: `admin:admin`.

2. Create a data source with the name "Marites":

   ```grafana
   Type: PostgreSQL
   Default: YES
   Name: Marites
   Host: localhost
   Database: Marites
   User: Marites  Password: your_secure_password_here
   SSL-Mode: disable
   Version: 10
   ```

3. [Manually import](https://grafana.com/docs/reference/export_import/#importing-a-dashboard) the dashboard [files](https://github.com/Marites-org/Marites/tree/main/grafana/dashboards) or use the `dashboards.sh` script. First create a "Service Account" called `Marites` under Grafana's Administration > User and access menu. Then create an API token for this service account (in place of `<mytoken>` below) and run the script:

   ```bash
   $ env GRAFANA_API_TOKEN=<mytoken> ./grafana/dashboards.sh restore

   URL:                    http://localhost:3000
   GRAFANA_API_TOKEN:      mytoken
   DASHBOARDS_DIRECTORY:   ./grafana/dashboards
   GRAFANA_ORG_NAMESPACE:  default

   RESTORED locations.json into Grafana folder 'Marites' ...
   RESTORED drive-stats.json into Grafana folder 'Marites' ...
   ...
   ```

   :::tip
   To point to a different Grafana instance use the URL variable:

   ```bash
   env URL=https://mygrafana.example.net GRAFANA_API_TOKEN=<mytoken> ./grafana/dashboards.sh restore
   ```

   :::
