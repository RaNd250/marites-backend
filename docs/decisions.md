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

---

## 2026-05-16 — Core vs Lite polling mode via PubSub

**Decision**: Vehicle GenStateMachine subscribes to `"fcm_tokens/changed/#{user_id}"` PubSub topic and switches between `:full` (60 s idle) and `:sentry_only` (120 s idle, vehicle_state endpoint only) based on whether any Core FCM tokens are registered for that user.

**Why**: Lite users don't need drive/charge/climate data. Reducing polling frequency and endpoint scope cuts Tesla API call volume roughly in half for Lite-only users, reducing operating cost and Tesla rate-limit exposure.

**Trade-off**: If a user has both Core and Lite apps installed, the vehicle polls in `:full` mode (driven by Core). This is correct — Core shows all data.

---

## 2026-05-16 — FCM edition gating in Pusher (not TokenStore)

**Decision**: Edition filtering happens in `FCM.Pusher.push_events/4` using the `@core_only_events` list, not in `TokenStore`. Sentry events query tokens with `edition: nil` (all), drive/charge query with `edition: "core"`.

**Why**: Keeps token storage simple (just stores what was registered). Pusher owns the business rule of which events reach which editions — that's a notification concern, not a storage concern.

---

## 2026-05-16 — Exponential backoff capped at 600 s for sleeping vehicles

**Decision**: Asleep/offline vehicles double their poll interval on each cycle (30→60→120→240→480→600 s) up to a 10-minute cap (`@max_asleep_interval 600`). Fleet telemetry events reset to `:start` immediately.

**Why**: Polling a sleeping Tesla wakes it, consuming battery. Without backoff the old code polled at a fixed 30 s, generating ~120 wake-ups/hour. With backoff + fleet telemetry, REST polls drop to ~6/hour when asleep. The 10-minute cap ensures we notice a car waking up within a reasonable time if fleet telemetry is not flowing.

---

## 2026-05-16 — FCM push priority: high unconditionally

**Decision**: All FCM pushes include `"android": {"priority": "high"}` regardless of event type.

**Why**: Without high priority, Android batches FCM delivery during Doze mode (potentially hours of delay). All Marites notifications are time-sensitive (sentry alarm, drive start). The overhead of high-priority FCM (slight battery impact) is acceptable for this use case.

---

## 2026-05-16 — Anti-false-positive deduplication in Pusher state (not DB)

**Decision**: Deduplication timestamps (`last_push_at`) are stored in `FCM.Pusher` GenServer state keyed by `{car_id, event}`. Not persisted to the database.

**Why**: Deduplication is a runtime concern — it only needs to suppress rapid repeats within a session. If the server restarts, the worst outcome is one extra notification per event type. Using in-process state avoids a DB write on every push event and keeps the hot path fast.

**Per-user threshold**: Users can configure their own dedup window (1–3600 s) via `PATCH /api/v1/notifications` (the existing `threshold` column, previously unused). The Pusher reads it via `Settings.get_delivery_with_threshold/2`.

---

## 2026-05-16 — VCP public key served from env var (not filesystem)

**Decision**: `VcpKeyController` reads the PEM from `TESLA_VCP_PUBLIC_KEY` env var rather than a file path.

**Why**: In a Docker/Cloudflare Tunnel deployment, injecting a file requires volume mounts. An env var is simpler to configure (especially in Coolify/Portainer stacks) and consistent with how other secrets (Firebase SA JSON, client secret) are already handled.

---

## 2026-05-16 — Lite APK: R8 full mode + ABI splits, no WorkManager

**Decision**: Lite release build enables R8 full mode (`android.enableR8.fullMode=true`), `minifyEnabled true`, `shrinkResources true`, and per-ABI splits (arm64-v8a, armeabi-v7a, x86_64). No WorkManager or foreground service for FCM keep-alive.

**Why FCM keep-alive not needed**: Android guarantees FCM high-priority message delivery even in Doze mode without a foreground service — the high-priority flag (set on the backend) is the correct mechanism. WorkManager adds ~300 KB and complexity with no benefit given the backend change.

**Why ABI splits**: The Lite app has no JNI code; ABI splits are purely for reducing download size. Each ABI APK is ~1–2 MB smaller than a fat APK. Target: < 5 MB per ABI on Play Store.
