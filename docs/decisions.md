# Architecture Decisions

## 2026-05-14 — Vehicle Command Protocol (VCP) proxy

**Decision**: Add tesla-http-proxy (from github.com/teslamotors/vehicle-command) as a Docker sidecar service.

**Why**: Tesla Fleet API deprecated the plain REST command endpoint (/api/1/vehicles/{id}/command/{cmd}) for third-party apps in Oct 2023. It now returns 403 "Tesla Vehicle Command Protocol required". Commands must be cryptographically signed with the app's EC private key using VCP.

**How**: The proxy runs inside Docker, listens on 0.0.0.0:4430 (HTTPS, self-signed cert). Backend sends commands to it with user Bearer token. Proxy wraps command in signed VCP envelope using the registered app private key (tesla-private-key.pem = the key served at /.well-known/appspecific/com.tesla.3p.public-key.pem).

**Trade-off**: Adds a Go build step (compiles vehicle-command from source) and a container. Considered building natively in Elixir — rejected as too complex (protocol is not documented, only the SDK is supported).

---

## 2026-05-14 — VIN instead of numeric vehicle_id for commands

**Decision**: Changed commands_controller to query vin (not eid) from the cars table and pass VIN to Api.run_command.

**Why**: tesla-http-proxy requires VIN in the URL path (/api/1/vehicles/{vin}/command/{cmd}). The numeric eid returned 404 when sent to the proxy.

---

## 2026-05-14 — env_file only in docker-compose (no environment: overrides for .env vars)

**Decision**: Remove all environment: entries that duplicate .env keys. Use env_file: .env exclusively for those vars. Keep only DATABASE_HOST=database (hardcoded, not in .env).

**Why**: docker-compose performs variable substitution on environment: values using the host shell. If DATABASE_USER is in .env but not exported in the host shell, environment: - DATABASE_USER=${DATABASE_USER} resolves to empty and OVERRIDES the env_file value, breaking the DB connection.

---

## 2026-05-14 — Double-dollar in .env for literal dollar signs

**Decision**: Write $$u in .env to represent the literal string $u in the client secret.

**Why**: docker-compose applies variable interpolation to env_file contents. The Tesla client secret contains $u which was being expanded to empty (u is unset). Using $$ produces a literal $ in the final value passed to the container.
