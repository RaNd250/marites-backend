# Current Tasks & Work Log

## 2026-05-14 — Tesla Fleet API Vehicle Commands

### Problem
Vehicle commands (honk, sentry, flash) were silently doing nothing. Root causes found and fixed:

### Root Cause Chain

1. **Billing threshold exceeded** — excessive REST polling 05/01-05/03 triggered account_disabled: EXCEEDED_LIMIT on all Fleet API calls. Tesla updated limits.
2. **Partner registration never completed** — POST /api/1/partner_accounts had never been called. Done. Account ID: a2b261fa-68e9-4a94-8f19-0092d26e7b81, domain: app.marit.es.
3. **Token refresh stripped vehicle_cmds scope** — tesla_api/auth/refresh.ex only requested openid email offline_access, dropping vehicle_cmds on every refresh. Fixed to include full scope.
4. **Wrong 403 mapping** — all 403 responses mapped to command_unauthorized (virtual key dialog). Fixed: account disabled prefix -> :account_disabled, "key" in msg -> :command_unauthorized, else -> :missing_scope.
5. **VCP required** — Tesla Fleet API deprecated plain REST commands. Now requires Vehicle Command Protocol (VCP). Added tesla-http-proxy Docker service that signs commands with app private key.
6. **Commands used numeric eid, proxy needs VIN** — changed commands path to use VIN from cars table.
7. **docker-compose environment: overriding env_file** — dollar-sign{VAR} in environment: section resolves from host shell (empty), overriding env_file values. Fixed by removing redundant environment: entries.
8. **Client secret dollar-sign expansion** — ta-secret.o+sK$u^YJD^RVNDd was losing the $u via compose interpolation. Fixed with $$u in .env.

### Files Changed (backend — RaNd250/TeslaMi)
- lib/tesla_api/auth/refresh.ex — full OAuth scope on token refresh
- lib/tesla_api/vehicle.ex — TESLA_CMD_HOST for commands, VIN param, account_disabled pattern
- lib/marites_web/controllers/api/v1/commands_controller.ex — select VIN, differentiate 403 cases
- lib/marites/http.ex — Finch pool for proxy with TLS verify_none
- lib/marites/vehicles/vehicle.ex — account_disabled state handling
- docker-compose.yml — added tesla-proxy service, fixed env_file usage
- tesla-proxy/Dockerfile — builds tesla-http-proxy from teslamotors/vehicle-command repo

### Files Changed (Android)
- Added MissingScopeException, differentiated 403 handling in repository
- Added missingScopeError state and "Command Permission Required" dialog
- Main app: v0.1.0.9 (versionCode 9) — released
- Lite app: v1.0.1 (versionCode 2) — released

### What Still Needs to Happen
- Virtual key must be paired per vehicle: open https://tesla.com/_ak/app.marit.es in Tesla app, approve, NFC tap on car card reader
- Verify end-to-end: honk/flash/sentry work after pairing
- Temperature fields in /api/v1/vehicles/status (inside_temp, outside_temp) — not yet added
