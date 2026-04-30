---
title: Projects using Marites
---

Here are some projects that use **Marites** as a data source to enrich its functionality and that can be useful depending on your setup.

## [Marites ABRP](https://fetzu.github.io/Marites-abrp/)

A python script (also available as a lightweight docker image) that pushes car status data to [ABetterRoutePlanner](https://abetterrouteplanner.com) based on contents of Marites MQTT's topic.

LINK: [github.com/fetzu/Marites-abrp](https://github.com/fetzu/Marites-abrp)

## [MaritesAgile](https://github.com/MattJeanes/MaritesAgile)

A Marites integration for calculating cost of charges. This application will automatically update your cost for charge sessions in Marites within a specified geofence (usually home) using data from your smart electricity tariff.

The supported energy providers / tarriffs are either [Octopus Agile](https://octopus.energy/agile/), [Tibber](https://tibber.com/en/), [aWATTar](https://www.awattar.de/) or fixed pricing (manually specified).

LINK: [github.com/MattJeanes/MaritesAgile](https://github.com/MattJeanes/MaritesAgile)

## [MaritesApi](https://github.com/tobiasehlert/Maritesapi)

MaritesApi is a RESTful API to get data collected by self-hosted data logger Marites in JSON.

The application is written in Golang and data is received from both PostgreSQL and Mosquitto and presented in various endpoints.

LINK: [github.com/tobiasehlert/MaritesApi](https://github.com/tobiasehlert/Maritesapi)

## [Marites Custom Dashboards](https://github.com/jheredianet/Marites-CustomGrafanaDashboards)

Marites Custom Grafana Dashboards, including: Amortization Tracker, Battery Health, Browse Charges, Charging Costs Stats, Charging CurveStats, Continuous Trips, Current State, Database Information, DC Charging Curves By Carrier, Incomplete Data, Range Degradation, Mileage Stats, Speed Rates, Speed & Temperature, Tracking Drives and more.
Also, there are two dashboards (Current Charge & Drive View) that could be browsed on the car while driving or charging.

LINK: [github.com/jheredianet/Marites-CustomGrafanaDashboards](https://github.com/jheredianet/Marites-CustomGrafanaDashboards)

## [Marites Guru on Gurubase](https://gurubase.io/g/Marites)

Marites Guru is a Marites-focused AI to answer your questions. It primarily uses the Marites documentation and the Marites GitHub repository to generate responses.

LINK: [https://gurubase.io/g/Marites](https://gurubase.io/g/Marites)

## [Tesla Home Assistant Integration](https://github.com/alandtse/tesla)

The Tesla Home Assistant integration can use the data from the Marites MQTT integration to update car data in near-real time.

LINK: [github.com/alandtse/tesla](https://github.com/alandtse/tesla)

LINK: [Wiki How-To](https://github.com/alandtse/tesla/wiki/Marites-MQTT-Integration)

## [Marites Telegram Bot](https://github.com/JakobLichterfeld/Marites-Telegram-Bot)

This is a telegram bot written in Python to notify by Telegram message when a new SW update for your Tesla is available. It uses the MQTT topic which Marites offers.

LINK: [github.com/JakobLichterfeld/Marites-Telegram-Bot](https://github.com/JakobLichterfeld/Marites-Telegram-Bot)

## [CustomGrafanaDashboards](https://github.com/CarlosCuezva/dashboards-Grafana-Marites)

Collection of custom dashboards for Grafana.

LINK: [github.com/CarlosCuezva/dashboards-Grafana-Marites](https://github.com/CarlosCuezva/dashboards-Grafana-Marites)

## [Gaussmeter](https://github.com/gaussmeter/gaussmeter)

An LED illuminated acrylic Tesla Model 3. Its color and scale of light depend on the cars current state.

LINK: [github.com/gaussmeter/gaussmeter](https://github.com/gaussmeter/gaussmeter)

## [Home Assistant Addon](https://github.com/lildude/ha-addon-Marites)

An unofficial Home Assistant addon for Marites, with a PostgreSQL addon too. Works with the existing community Grafana and Mosquitto addons to provide a complete solution.

LINK: [github.com/lildude/ha-addon-Marites](https://github.com/lildude/ha-addon-Marites)

## [MateDroid](https://github.com/vide/matedroid)

MateDroid is a native Android app for viewing Tesla vehicle data from your self-hosted Marites instance. It uses the [Marites API](https://github.com/tobiasehlert/Maritesapi) project to retrieve the data and display it in a beautiful and clean way.

LINK: [https://github.com/vide/matedroid](https://github.com/vide/matedroid)

## [MMM-Marites](https://github.com/denverquane/MMM-Marites)

A [Magic Mirror](https://magicmirror.builders/) Module for Marites.

LINK: [github.com/denverquane/MMM-Marites](https://github.com/denverquane/MMM-Marites)

## [MyMarites](https://www.myMarites.com)

For those who do not wish to install their own instance, MyMarites provides a managed instance of Marites ready to use in one minute, with a security overlay (Authelia), 30-day backups, and the possibility of importing a backup to migrate easily.

For all [Marites](https://www.myMarites.com) users, MyMarites also provides for free a [Fleet API](https://app.myMarites.com/fleet) endpoint and a streaming server based on Tesla Telemetry events.

LINK: [MyMarites Website](https://www.myMarites.com)

LINK: [Follow this guide](/docs/configuration/api#myMarites-fleet-api) to use official Tesla APIs on your Marites.

## [Tesla-GeoGDO](https://github.com/brchri/tesla-geogdo) (previously [Tesla-YouQ](https://github.com/brchri/tesla-youq))

A lightweight app that will operate your smart garage door openers based on the location of your Tesla vehicles, automatically closing when you leave, and opening when you return. Supports multiple geofence types including circular, Marites, and polygonal. Supports multiple vehicles and various smart garage door openers.

LINK: [https://github.com/brchri/tesla-geogdo](https://github.com/brchri/tesla-geogdo)

## [Marites Achievements](https://github.com/crstian19/Marites-achievements)

A gamification add-on for Marites that analyzes your historical data to unlock achievements. It features a collection of badges based on driving milestones, charging habits, efficiency, and phantom drain, turning your ownership statistics into a fun progression system.

LINK: [github.com/crstian19/Marites-achievements](https://github.com/crstian19/Marites-achievements)
