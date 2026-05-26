# Marit.es Backend

This repository contains the open-source vehicle monitoring engine powering [Marit.es](https://marit.es) — a Tesla vehicle monitoring and management app.

## Based on TeslaMate

This codebase is a fork of **[TeslaMate](https://github.com/teslamate-org/teslamate)** by the TeslaMate contributors, licensed under the [GNU Affero General Public License v3.0 (AGPL-3.0)](https://www.gnu.org/licenses/agpl-3.0.html).

All credit for the core vehicle data collection, MQTT integration, Postgres storage, and Grafana dashboards belongs to the TeslaMate project and its contributors.

## What this repo is

Per the AGPL-3.0 requirements, the modified engine source code used by the Marit.es SaaS service is published here. This covers:

- Vehicle data polling via the Tesla Fleet API
- Drive, charge, and sentry event recording (Postgres)
- MQTT publishing of vehicle state
- Phoenix LiveView web UI (sign-in, vehicle management)
- Grafana dashboard definitions

The proprietary Marit.es application layer (REST API service, Android/iOS apps, billing) is **not** included here.

## License

GNU Affero General Public License v3.0 — see [LICENSE](LICENSE).

Original work: © TeslaMate contributors  
Modifications: © Marit.es contributors
