# marites-backend

Vehicle monitoring engine powering [Marit.es](https://marit.es) — a self-hosted Tesla vehicle monitoring platform.

This is a fork of [TeslaMate](https://github.com/adriankumpf/teslamate) (AGPL v3), modified to serve as the data collection and telemetry engine for the Marit.es platform. The proprietary API layer (Tesla OAuth, mobile REST API, push notifications) is maintained separately and is not included here.

## What's here

- Elixir/Phoenix backend engine
- Tesla Fleet Telemetry consumer (MQTT)
- Postgres data models (drives, charges, positions, sentry events)
- Fleet telemetry registration and proto decoding
- Web UI (TeslaMate-derived, lightly modified)

## What's not here

The proprietary `marites-api` service (Tesla OAuth, JWT auth, mobile REST API, FCM push notifications) is not open source and is not included in this repository.

## Relationship to TeslaMate

This project is a fork of [TeslaMate](https://github.com/adriankumpf/teslamate) by Adrian Kumpf, licensed under AGPL v3. Significant modifications have been made including fleet telemetry integration, service architecture changes, and branding. Per AGPL v3 requirements, all modifications to the TeslaMate-derived code are published here.

## License

GNU Affero General Public License v3.0 — see [LICENSE](LICENSE).

The original TeslaMate project is © Adrian Kumpf and contributors.
Modifications are © Marit.es contributors.
