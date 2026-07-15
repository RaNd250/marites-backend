import React from "react";
import Layout from "@theme/Layout";

const C = {
  bg: "#0a0a0f",
  card: "#111113",
  purple: "#7c3aed",
  red: "#e31937",
  green: "#4ade80",
  text: "#e5e7eb",
  muted: "#9ca3af",
  dim: "#6b7280",
};

const Section = ({ id, title, children }) => (
  <section id={id} style={{ marginBottom: 30 }}>
    <h2 style={{ color: "#fff", fontSize: 20, fontWeight: 800, margin: "0 0 14px", letterSpacing: "-0.3px" }}>
      {title}
    </h2>
    <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>{children}</div>
  </section>
);

const QA = ({ q, children }) => (
  <div className="m-qa" style={{ background: C.card, borderRadius: 12, padding: "16px 18px" }}>
    <div style={{ color: "#fff", fontWeight: 700, fontSize: 14, marginBottom: 7 }}>{q}</div>
    <div style={{ color: C.muted, fontSize: 13.5, lineHeight: 1.65 }}>{children}</div>
  </div>
);

const Pill = ({ color, children }) => (
  <span style={{
    display: "inline-block", background: color + "22", color,
    border: "1px solid " + color + "55", borderRadius: 6,
    padding: "1px 8px", fontSize: 12, fontWeight: 600, margin: "0 4px 4px 0",
  }}>{children}</span>
);

const LangSwitch = () => (
  <div style={{ display: "flex", gap: 6, alignItems: "center", fontSize: 12, fontWeight: 700, flexShrink: 0 }}>
    <span style={{ color: "#fff" }}>EN</span>
    <span style={{ color: "#374151" }}>|</span>
    <a href="/el/faq/" lang="el" hrefLang="el" style={{ color: "#6b7280", textDecoration: "none" }} onClick={() => { try { localStorage.setItem("marites_lang_choice", "el"); } catch {} }}>ΕΛ</a>
  </div>
);

export default function Faq() {
  return (
    <Layout
      title="FAQ & Manual"
      description="How marit.es works: Tesla sentry monitoring, notifications, vehicle status, commands, privacy and troubleshooting across the Core and Lite Android apps and the marit.es Web dashboard."
      noFooter
    >
      <style>{`
        .navbar { display: none !important; }
        .main-wrapper { padding-top: 0 !important; }
        .m-wrap { max-width: 860px; margin: 0 auto; width: 100%; padding: 0 20px; }
        .m-head {
          display: flex; align-items: center; justify-content: space-between;
          padding: 14px 20px; gap: 16px; max-width: 860px; margin: 0 auto; width: 100%;
        }
        .m-toc { display: flex; flex-wrap: wrap; gap: 8px; margin: 0 0 28px; }
        .m-toc a {
          color: ${C.muted}; font-size: 12.5px; text-decoration: none;
          background: ${C.card}; border: 1px solid rgba(255,255,255,0.06);
          border-radius: 999px; padding: 5px 12px;
        }
        .m-toc a:hover { color: #fff; border-color: ${C.purple}; }
        .m-qa a { color: ${C.purple}; text-decoration: none; }
        .m-qa a:hover { text-decoration: underline; }
        @media (max-width: 600px) {
          .m-head { padding: 12px 16px; }
          .m-hide-sm { display: none; }
        }
      `}</style>

      <main style={{ background: C.bg, minHeight: "100vh", color: C.text }}>
        {/* Header */}
        <header className="m-head">
          <a href="/" style={{ display: "flex", alignItems: "center", gap: 10, textDecoration: "none" }}>
            <img src="/img/logo.png" alt="marit.es" style={{ width: 32, height: 32, borderRadius: 6 }} />
            <span style={{ color: "#fff", fontWeight: 800, fontSize: 16, letterSpacing: "-0.3px" }}>
              mari<span style={{ color: C.red }}>t.es</span>
            </span>
          </a>
          <LangSwitch />
        </header>

        <div className="m-wrap">
          {/* Title */}
          <div style={{ padding: "18px 0 6px" }}>
            <h1 style={{ color: "#fff", fontSize: 30, fontWeight: 900, margin: "0 0 8px", letterSpacing: "-0.5px" }}>
              FAQ &amp; Manual
            </h1>
            <p style={{ color: C.dim, fontSize: 14, lineHeight: 1.6, margin: 0 }}>
              Everything about what marit.es does, how it works, and how to get the most out of the
              Core and Lite Android apps and the marit.es Web dashboard.
            </p>
          </div>

          {/* Name origin */}
          <p style={{
            color: C.muted, fontSize: 13.5, lineHeight: 1.65, margin: "0 0 22px",
            background: C.card, borderRadius: 12, padding: "14px 18px",
          }}>
            <b style={{ color: "#fff" }}>Why Marit.es?</b> Because your Tesla is the biggest gossip
            around. Inspired by the slang <b>&ldquo;Marites&rdquo;</b>, the app brings you every
            Sentry event, charging update and trip — so you never miss what your car has to say.
          </p>

          {/* TOC */}
          <nav className="m-toc" style={{ marginTop: 22 }}>
            <a href="#what">What is it</a>
            <a href="#how">How it works</a>
            <a href="#editions">Core, Lite &amp; Web</a>
            <a href="#web">Web version</a>
            <a href="#subscription">Subscription</a>
            <a href="#status">Vehicle status</a>
            <a href="#history">Drives &amp; charging</a>
            <a href="#insights">Battery &amp; cost insights</a>
            <a href="#units">Units &amp; formats</a>
            <a href="#export">Exporting data</a>
            <a href="#sentry">Sentry &amp; alarms</a>
            <a href="#notifications">Notifications</a>
            <a href="#commands">Commands</a>
            <a href="#pairing">Virtual key</a>
            <a href="#account">Sign-in</a>
            <a href="#privacy">Privacy</a>
            <a href="#trouble">Troubleshooting</a>
          </nav>

          <Section id="what" title="What is marit.es?">
            <QA q="In one sentence?">
              marit.es watches your Tesla in real time — Sentry activity, drives, charging and
              battery — and lets you control the car and get instant alerts when something happens.
              It's available as <b>Android apps</b> (Core and Lite) and as a <b>web dashboard</b> at
              <a href="https://app.marit.es" target="_blank" rel="noopener noreferrer"> app.marit.es</a>.
            </QA>
            <QA q="What can it do?">
              Live vehicle status and location, drive history with maps, charge history and stats,
              battery monitoring, Sentry mode control with alerts, scheduled Sentry, automatic alarm
              response (honk &amp; flash), and remote commands like honk, flash and more — all from your phone.
            </QA>
            <QA q="Which cars are supported?">
              Any Tesla supported by Tesla's official Fleet API (Model 3, Y, S and X). You sign in with
              your own Tesla account; marit.es never asks for your Tesla password.
            </QA>
          </Section>

          <Section id="how" title="How it works">
            <QA q="Where does the data come from?">
              marit.es uses Tesla's official <b>Fleet API</b> and <b>Fleet Telemetry</b>. Your car streams
              live data (battery, location, Sentry state, charging, speed) directly to the marit.es
              backend over an encrypted connection, and the app reads it from there. There is no
              unofficial scraping and no third-party data broker.
            </QA>
            <QA q="Is it real time?">
              Yes — while the car is awake it streams telemetry continuously, so status and Sentry
              alerts arrive within seconds. When the car goes to sleep it stops streaming (to protect the
              12&nbsp;V battery); the app then shows the last known status until the car wakes again.
            </QA>
            <QA q="Do I need to leave anything running on my phone?">
              No. The monitoring happens on the backend, not on your phone. You can close the app and
              still receive push notifications. The app is just the window into your data.
            </QA>
            <QA q="Why does it sometimes show slightly old data?">
              If the car is asleep or out of coverage it isn't streaming. The timestamp under the status
              (&ldquo;Updated …&rdquo;) tells you how fresh the reading is.
            </QA>
          </Section>

          <Section id="editions" title="Core, Lite &amp; Web">
            <QA q="What's the difference?">
              <div style={{ marginBottom: 8 }}>
                <Pill color={C.purple}>Core</Pill> — the full Android experience: multiple vehicles, full
                drive &amp; charge history, statistics, remote commands, scheduled Sentry and automatic
                alarm response. Subscription-based.
              </div>
              <div style={{ marginBottom: 8 }}>
                <Pill color={C.green}>Lite</Pill> — free Android app. One vehicle, 7-day history, live
                battery &amp; status, Sentry ON/OFF and Sentry push alerts. No stats or commands.
              </div>
              <div>
                <Pill color={C.red}>Web</Pill> — the same full experience as Core, in any browser at
                app.marit.es. Drives, charges, stats, Sentry (log, schedule, alarm response), commands and
                data export. Alerts arrive on <b>Telegram</b> instead of phone push. Subscription with a
                7-day free trial. See <a href="#web">Web version</a>.
              </div>
            </QA>
            <QA q="Can I use them together?">
              Yes — it's one account everywhere. A Core (or web) subscription unlocks both the Core app
              and the web dashboard; sign in with the same Tesla account and your vehicles, history and
              settings follow you. Lite keeps working as a lightweight viewer. On Lite you can pick which
              one vehicle you monitor, and change that choice once every 7 days.
            </QA>
          </Section>

          <Section id="web" title="The web version (marit.es Web)">
            <QA q="Is there a version without installing an app?">
              Yes — <a href="https://app.marit.es" target="_blank" rel="noopener noreferrer">app.marit.es</a> is
              a full web dashboard that runs in any modern browser on iPhone, Mac, Windows or Android.
              Nothing to install. It's a subscription with a <b>7-day free trial</b> (see
              <a href="#subscription"> Subscription</a>).
            </QA>
            <QA q="What can I do on the web?">
              Almost everything Core does:
              <div style={{ marginTop: 8, display: "flex", flexDirection: "column", gap: 5 }}>
                <div>📊 <b>Dashboard</b> — live status, battery and a live map of the car.</div>
                <div>📍 <b>Drives</b> — full history with route maps.</div>
                <div>⚡ <b>Charges</b> — every session with energy, duration and cost.</div>
                <div>📈 <b>Stats</b> — battery health and phantom-drain analysis.</div>
                <div>🛡 <b>Sentry</b> — event log with location maps, Sentry on/off, a weekly schedule and automatic alarm response (honk, flash, Boombox).</div>
                <div>🔑 <b>Commands</b> — Sentry on/off, honk, flash and Boombox.</div>
                <div>💾 <b>Export</b> — download drives and charges as CSV, Excel or PDF (web only).</div>
              </div>
            </QA>
            <QA q="How are alerts delivered on the web?">
              Through <b>Telegram</b>. A browser can't reliably push alerts the way a phone does, so the
              web version sends Sentry alerts — with a map pin of the car — to Telegram. Open
              <b> Settings &rarr; Telegram notifications &rarr; Connect Telegram</b> and tap <b>Start</b> in
              our bot <b>@MaritesAppBot</b>. More under <a href="#notifications">Notifications</a>.
            </QA>
            <QA q="How do I sign in on the web?">
              Two ways. (1) <b>Log in with Tesla</b> on <a href="https://app.marit.es" target="_blank" rel="noopener noreferrer">app.marit.es</a> —
              the same secure Tesla sign-in, no password shared with us. (2) <b>Pair from the app</b>: in the
              Core app open <b>Settings &rarr; Pair a browser</b> to get a QR (or short code), then scan or
              enter it on the new browser — it signs that device in without a Tesla login. Sessions stay
              logged in for weeks.
            </QA>
            <QA q="Do commands need anything special on the web?">
              Same as on the phone — Tesla's <a href="#pairing">virtual key</a> must be paired to your car
              before honk, flash or Sentry commands work. Viewing your data needs no key.
            </QA>
          </Section>

          <Section id="subscription" title="Subscription &amp; billing">
            <QA q="What does the subscription cost?">
              <b>&euro;4.99 / month</b> with a <b>7-day free trial</b>. You aren't charged during the trial
              and can cancel any time before it ends at no cost.
            </QA>
            <QA q="How do I subscribe?">
              Sign in at <a href="https://app.marit.es" target="_blank" rel="noopener noreferrer">app.marit.es</a> and
              follow the <b>Subscribe</b> prompt, or subscribe to <b>Core</b> on Google Play. Web payments are
              handled securely by <b>Stripe</b> — marit.es never sees your card details.
            </QA>
            <QA q="How do I cancel or change my plan?">
              On the web, open <b>Settings &rarr; Subscription &rarr; Manage billing</b> to reach the Stripe
              billing portal, where you can cancel, update your card or download invoices. Cancelling keeps
              access until the end of the period you've already paid for. (Play subscriptions are managed in
              Google Play.)
            </QA>
            <QA q="I already pay through Google Play — do I get the web too?">
              Yes. A Core subscription unlocks the web dashboard as well — just log in at app.marit.es with
              the same Tesla account. No second payment.
            </QA>
          </Section>

          <Section id="status" title="Vehicle status — what the labels mean">
            <QA q="What do the status labels mean?">
              The status next to the dot reflects what the car is actually doing right now:
              <div style={{ marginTop: 8, display: "flex", flexDirection: "column", gap: 5 }}>
                <div><b style={{ color: C.green }}>Online – Idle</b> — awake and parked, nothing happening.</div>
                <div><b style={{ color: C.green }}>Online – Driving</b> — currently in motion.</div>
                <div><b style={{ color: C.green }}>Online – Charging</b> — actively drawing power from a charger.</div>
                <div><b style={{ color: C.green }}>Online – Plugged in</b> — cable connected but <i>not</i> currently charging (full, scheduled, or paused).</div>
                <div><b style={{ color: C.muted }}>Asleep</b> — the car is sleeping to save battery; data is paused.</div>
                <div><b style={{ color: C.muted }}>Offline</b> — no connection to the car right now.</div>
              </div>
            </QA>
            <QA q="Why is &ldquo;Plugged in&rdquo; different from &ldquo;Charging&rdquo;?">
              Because they're genuinely different states. A Tesla can be plugged in for hours while
              already full or waiting for a scheduled start — it isn't charging then. marit.es shows
              <b> Charging</b> only while power is actually flowing, and <b>Plugged in</b> the rest of the
              time the cable is connected.
            </QA>
          </Section>

          <Section id="history" title="Drives &amp; charging history">
            <QA q="Does it log my drives?">
              Yes. Every drive is recorded automatically with its date, distance, duration and
              top speed, and you can open a drive to see its route on a map. No setup needed —
              just drive, and it appears under <b>Drives</b>.
            </QA>
            <QA q="Does it log charging?">
              Yes. Each charging session is recorded with start/end time, duration, the battery
              level before and after, and the energy added (kWh) once your car reports it. See them
              under <b>Charges</b>.
            </QA>
            <QA q="Why is a brand-new drive or charge not there yet?">
              Records are written when the session ends (you park, or the charge stops). Give it a
              minute after you finish and pull to refresh.
            </QA>
          </Section>

          <Section id="insights" title="Battery health, charging cost &amp; phantom drain">
            <QA q="What does Battery Health show?">
              Under <b>Stats</b>, Battery Health estimates how much of your battery capacity you've
              kept over time. It normalises range for charge level (so it isn't fooled by a low
              battery) and shows a percentage retained plus a trend line. It needs a few weeks of
              data to be meaningful.
            </QA>
            <QA q="How do I see what charging costs me?">
              In <b>Settings → Charging Tariff</b>, enter your electricity price per kWh and your
              currency. Each charge then shows its cost (energy × price) under <b>Charges</b>.
            </QA>
            <QA q="I'm on a day/night electricity plan — can it handle that?">
              Yes. In the same Charging Tariff settings, add a <b>night / off-peak price</b> and the
              hours it applies (it can wrap past midnight). Each session's cost is split between the
              day and night rates by how much of the charge happened in the night window.
            </QA>
            <QA q="What is Phantom Drain?">
              It's the battery your car loses while parked (not driving, not charging). Under
              <b>Stats</b>, Phantom Drain shows an average %/day, a daily trend, and your worst
              parking spot — all worked out from your parked data, nothing to enable.
            </QA>
          </Section>

          <Section id="units" title="Units &amp; formats">
            <QA q="Can I choose km vs miles, °C vs °F, and the time/date format?">
              Yes, in <b>Settings</b>. Keep <b>Auto (match car)</b> to follow your car's own
              settings, or turn Auto off and pick units (metric/imperial), 12 or 24-hour time, and
              the date format (DD/MM, MM/DD or YYYY-MM-DD) independently.
            </QA>
            <QA q="What about the Lite app?">
              Lite always follows your car's units automatically, to keep it simple.
            </QA>
          </Section>

          <Section id="export" title="Exporting your data (web)">
            <QA q="Can I download my drives and charges?">
              Yes, from the web dashboard at <a href="https://app.marit.es" target="_blank" rel="noopener noreferrer">app.marit.es</a>.
              On the <b>Drives</b> and <b>Charges</b> pages there's an export bar: choose a date
              range, a sort order, and download as <b>CSV</b>, <b>Excel</b> or <b>PDF</b>.
            </QA>
          </Section>

          <Section id="sentry" title="Sentry &amp; alarms">
            <QA q="How does Sentry monitoring work?">
              When your car reports a Sentry event, marit.es detects it from the live telemetry and sends
              you a push notification immediately — no need to have the app open.
            </QA>
            <QA q="What kinds of Sentry events are there?">
              Tesla reports two levels of activity: <b>Aware</b> (motion or a person detected nearby) and
              <b>Panic</b> (the alarm is actually sounding). marit.es alerts you on both. To avoid spam in
              busy areas, repeated &ldquo;Aware&rdquo; events are rate-limited, while a real alarm always
              comes through instantly.
            </QA>
            <QA q="Can I turn Sentry on or off?">
              Yes — both Core and Lite have a single Sentry toggle on the home screen, and the web has the
              same control on the Dashboard and Sentry pages. Core and the web can also schedule Sentry on a
              weekly timetable and respond automatically to an alarm (honk, flash and Boombox).
            </QA>
            <QA q="Does it record where and when?">
              Yes. Core and the web both log each Sentry alarm with its time and location (shown on a map),
              so you can review what happened later.
            </QA>
            <QA q="Why didn't I get an alert while the car was asleep?">
              Sentry detection relies on the car streaming telemetry. A sleeping car streams nothing, so
              brief events that happen and end entirely while asleep can be missed. This is a limitation of
              Tesla's telemetry that affects every app of this kind, not a marit.es bug.
            </QA>
          </Section>

          <Section id="notifications" title="Notifications">
            <QA q="What push notifications will I actually receive?">
              marit.es is deliberately quiet. There are only two kinds of push:
              <div style={{ marginTop: 8, display: "flex", flexDirection: "column", gap: 5 }}>
                <div>🛡 <b>Sentry alert</b> — when your car detects activity or its alarm sounds.</div>
                <div>🔑 <b>Reconnect needed</b> — when the app needs you to sign in with Tesla again so alerts keep working.</div>
              </div>
            </QA>
            <QA q="Will it nag me about arming/disarming or every drive and charge?">
              No. We removed routine arm/disarm, drive and charge notifications — those just create noise.
              You get the Sentry alert and the reconnect prompt, nothing else. (Lite may show one gentle
              reminder to open the app if it hasn't seen you in a while.)
            </QA>
            <QA q="How are notifications organised on Android?">
              Under the app's notification settings you'll see <b>Sentry Alerts</b> (high priority) and
              <b>Account &amp; alerts</b> (the reconnect prompt and reminders). You can fine-tune or mute
              each category from Android settings.
            </QA>
            <QA q="Can I get my alerts on Telegram?">
              Yes. In the Core app open <b>Settings &rarr; Notifications &rarr; Connect Telegram</b>, or on
              the web open <b>Settings &rarr; Telegram notifications &rarr; Connect Telegram</b>. Either opens
              our bot <b>@MaritesAppBot</b> &mdash; tap <b>Start</b> and your account is linked. No Tesla
              login or password is involved; it just hands the bot a one-time code. On the web, Telegram is
              how you receive Sentry alerts (a browser has no reliable push).
            </QA>
            <QA q="Phone notifications, Telegram, or both?">
              Your choice. The same Notifications screen has independent <b>Push</b> and <b>Telegram</b>
              switches &mdash; turn on either or both. Telegram mirrors exactly what you'd get on your
              phone: if you snooze a Sentry alert or mute an alert type, Telegram goes quiet too.
            </QA>
            <QA q="What does a Telegram alert look like?">
              You get the alert message followed by a <b>map pin of your car's location</b>, so you can
              see where it is and tap through for directions. Great for keeping an eye on the car from a
              computer or any device with Telegram.
            </QA>
            <QA q="How do I unlink Telegram?">
              In the same <b>Settings &rarr; Notifications</b> card, tap <b>Unlink</b>. The bot stops
              messaging you immediately. You can re-connect any time.
            </QA>
          </Section>

          <Section id="commands" title="Commands (Core &amp; Web)">
            <QA q="What commands can I send?">
              Honk the horn, flash the lights, control Sentry (on/off), Boombox, and other supported
              vehicle commands — straight from the Core home screen or the web Dashboard. A paired
              <a href="#pairing"> virtual key</a> is required.
            </QA>
            <QA q="A command said &ldquo;car not found&rdquo; — why?">
              That usually means the vehicle isn't linked to the account you're using, or the virtual key
              isn't paired yet. If two people share cars, each command is routed through the owner who has
              an active Tesla session for that car. See <a href="#pairing">Virtual key</a> below.
            </QA>
          </Section>

          <Section id="pairing" title="Virtual key pairing">
            <QA q="What is the virtual key and why do I need it?">
              Tesla requires a &ldquo;virtual key&rdquo; before any app can send commands (honk, flash,
              Sentry, etc.) to your car. Viewing data doesn't need it, but commands do.
            </QA>
            <QA q="How do I add it?">
              In the app, tap the &ldquo;Add virtual key&rdquo; prompt (or open
              <a href="https://tesla.com/_ak/app.marit.es" target="_blank" rel="noopener noreferrer"> tesla.com/_ak/app.marit.es</a>)
              and approve in the Tesla app. You do <b>not</b> need physical NFC card access — pairing is done
              in software through the Tesla app.
            </QA>
            <QA q="I paired it but still get the prompt.">
              Give it a moment and reopen marit.es; the pairing status refreshes automatically once Tesla
              confirms it. If it persists, re-open the pairing link above and confirm the approval went through.
            </QA>
          </Section>

          <Section id="account" title="Signing in &amp; staying logged in">
            <QA q="Do I give marit.es my Tesla password?">
              Never. You log in on Tesla's own page via OAuth; marit.es only receives a token to read your
              data and send the commands you allow. You can revoke access any time in your Tesla account.
            </QA>
            <QA q="Why was I asked to sign in with Tesla again?">
              Tesla tokens expire and occasionally Tesla invalidates a session (e.g. after an account
              change). When that happens marit.es sends a <b>Reconnect needed</b> notification so your alerts
              don't silently stop. Signing back in takes a few seconds.
            </QA>
            <QA q="It used to ask very often — is that fixed?">
              Yes. Earlier builds could prompt too frequently; the session handling was reworked so you stay
              logged in far longer. Make sure you're on the latest version from Google Play.
            </QA>
          </Section>

          <Section id="privacy" title="Privacy &amp; data">
            <QA q="Who can see my data?">
              Only you. Your vehicle data is tied to your account and used solely to power the app's
              features. See the <a href="/privacy/">Privacy Policy</a> for full detail.
            </QA>
            <QA q="Can I delete my data?">
              Yes — contact <a href="mailto:admin@marit.es">admin@marit.es</a> and you can also revoke
              marit.es from your Tesla account to stop all data flow immediately.
            </QA>
          </Section>

          <Section id="trouble" title="Troubleshooting">
            <QA q="I'm not getting Sentry notifications.">
              Check that (1) you're signed in (no &ldquo;Reconnect needed&rdquo; prompt), (2) the
              <b> Sentry Alerts</b> notification category is enabled in Android settings, (3) battery
              optimization isn't blocking the app, and (4) the car is awake/streaming when the event happens.
            </QA>
            <QA q="I'm on the web and not getting alerts.">
              The web sends alerts over Telegram, so check that (1) Telegram is linked in
              <b> Settings &rarr; Telegram notifications</b> and the <b>Send to Telegram</b> switch is on,
              (2) you started a chat with <b>@MaritesAppBot</b>, and (3) the car was awake/streaming when the
              event happened. Sentry alerts on the web don't use browser pop-ups.
            </QA>
            <QA q="The status looks stale.">
              The car is probably asleep or offline. Check the &ldquo;Updated …&rdquo; timestamp; data
              resumes automatically when the car wakes.
            </QA>
            <QA q="Commands don't work.">
              Confirm the <a href="#pairing">virtual key</a> is paired and that the vehicle belongs to (or is
              shared with) your account.
            </QA>
            <QA q="Still stuck?">
              Email <a href="mailto:admin@marit.es">admin@marit.es</a> with your account email and what you're seeing.
            </QA>
          </Section>
        </div>

        {/* Footer */}
        <footer style={{
          padding: "20px 24px 40px", textAlign: "center",
          display: "flex", gap: 20, justifyContent: "center", flexWrap: "wrap",
          borderTop: "1px solid rgba(255,255,255,0.05)", marginTop: 20,
        }}>
          <a href="/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Home</a>
          <a href="/changelog/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Changelog</a>
          <a href="/privacy/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Privacy Policy</a>
          <a href="/terms/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Terms of Service</a>
          <a href="mailto:admin@marit.es" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Contact</a>
        </footer>
      </main>
    </Layout>
  );
}
