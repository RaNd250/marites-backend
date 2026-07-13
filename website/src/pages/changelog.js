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

const Pill = ({ color, children }) => (
  <span style={{
    display: "inline-block", background: color + "22", color,
    border: "1px solid " + color + "55", borderRadius: 6,
    padding: "1px 9px", fontSize: 12, fontWeight: 700,
  }}>{children}</span>
);

const LangSwitch = () => (
  <div style={{ display: "flex", gap: 6, alignItems: "center", fontSize: 12, fontWeight: 700, flexShrink: 0 }}>
    <span style={{ color: "#fff" }}>EN</span>
    <span style={{ color: "#374151" }}>|</span>
    <a href="/el/changelog/" lang="el" hrefLang="el" style={{ color: "#6b7280", textDecoration: "none" }}>ΕΛ</a>
  </div>
);

const Section = ({ id, color, title, children }) => (
  <section id={id} style={{ marginBottom: 34 }}>
    <h2 style={{ color: "#fff", fontSize: 20, fontWeight: 800, margin: "0 0 14px", letterSpacing: "-0.3px" }}>
      <span style={{ color }}>&#9679;</span> {title}
    </h2>
    <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>{children}</div>
  </section>
);

const Rel = ({ version, date, color, children }) => (
  <div style={{ background: C.card, borderRadius: 12, padding: "16px 18px" }}>
    <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 10 }}>
      {version ? <Pill color={color}>{version}</Pill> : null}
      <span style={{ color: C.dim, fontSize: 12.5 }}>{date}</span>
    </div>
    <ul style={{ margin: 0, paddingLeft: 18, color: C.muted, fontSize: 13.5, lineHeight: 1.7 }}>
      {children}
    </ul>
  </div>
);

export default function Changelog() {
  return (
    <Layout
      title="Changelog"
      description="What's new in marit.es: the latest features and fixes for the Core and Lite Android apps and the web dashboard."
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
        @media (max-width: 600px) { .m-head { padding: 12px 16px; } }
      `}</style>

      <main style={{ background: C.bg, minHeight: "100vh", color: C.text }}>
        <header className="m-head">
          <a href="/" style={{ display: "flex", alignItems: "center", gap: 10, textDecoration: "none" }}>
            <img src="/img/logo.png" alt="marit.es" style={{ width: 32, height: 32, borderRadius: 6 }} />
            <span style={{ color: "#fff", fontWeight: 800, fontSize: 16, letterSpacing: "-0.3px" }}>
              mari<span style={{ color: C.red }}>t.es</span>
            </span>
          </a>
          <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
            <LangSwitch />
            <a href="https://app.marit.es" target="_blank" rel="noopener noreferrer"
              style={{ background: C.red, color: "#fff", fontWeight: 700, padding: "8px 18px",
                borderRadius: 6, textDecoration: "none", fontSize: 13, whiteSpace: "nowrap" }}>
              Open App &#8594;
            </a>
          </div>
        </header>

        <div className="m-wrap">
          <div style={{ padding: "18px 0 6px" }}>
            <h1 style={{ color: "#fff", fontSize: 30, fontWeight: 900, margin: "0 0 8px", letterSpacing: "-0.5px" }}>
              What&#8217;s new
            </h1>
            <p style={{ color: C.dim, fontSize: 14, lineHeight: 1.6, margin: 0 }}>
              The latest features and fixes across the Core and Lite Android apps and the web dashboard.
              Always update from Google Play to get the newest version.
            </p>
          </div>

          <nav className="m-toc" style={{ marginTop: 22 }}>
            <a href="#core">Core app</a>
            <a href="#lite">Lite app</a>
            <a href="#web">Web dashboard</a>
          </nav>

          <Section id="core" color={C.purple} title="Core app (Android)">
            <Rel version="0.1.94" date="July 2026" color={C.purple}>
              <li><b>Sentry alerts now name your car.</b> &ldquo;Alarm Triggered&rdquo; alerts show which vehicle triggered it instead of a generic &ldquo;Your Tesla&rdquo;.</li>
              <li><b>Timestamps in your car&#8217;s own timezone.</b> Sentry, drive and charge times are now shown in the timezone where the car actually is, not your phone&#8217;s.</li>
              <li><b>Per-car alarm response.</b> Honk/flash-on-alarm settings are now set separately for each vehicle instead of applying to all your cars at once.</li>
              <li><b>Bigger, animated battery bar.</b> The battery bar is thicker and pulses with a small lightning-bolt icon while charging.</li>
              <li><b>Better fit on smaller phones.</b> The UI now scales down cleanly on narrow screens instead of appearing oversized.</li>
              <li><b>16&nbsp;KB memory page size support</b>, required for newer Android devices.</li>
            </Rel>
            <Rel version="0.1.85" date="June 2026" color={C.purple}>
              <li><b>Cancelling Tesla sign-in no longer leaves a blank screen.</b> If you start the Tesla login and back out, the app now returns to the welcome screen so you can try again.</li>
            </Rel>
            <Rel version="0.1.84" date="June 2026" color={C.purple}>
              <li><b>Telegram alerts.</b> Get your Sentry alerts on Telegram too. Open <b>Settings &rarr; Notifications &rarr; Connect Telegram</b>, tap Start in the bot, and you&#8217;re linked &mdash; no Tesla login needed. Choose <b>phone notifications, Telegram, or both</b>.</li>
              <li><b>Alerts now show the car&#8217;s location.</b> Each Telegram alert is followed by a map pin of where your car is &mdash; tap it to open directions.</li>
            </Rel>
            <Rel version="0.1.83" date="June 2026" color={C.purple}>
              <li><b>Energy used per trip.</b> Drives now show how many kWh each trip used, estimated from your own charging history.</li>
              <li><b>Stats marked Beta.</b> The estimated figures in Stats are labelled Beta &mdash; they&#8217;re still being fine-tuned.</li>
              <li><b>Flexible charging tariff.</b> The off-peak &ldquo;night&rdquo; rate is now a <b>reduced</b> rate you can apply to up to three time windows a day.</li>
              <li><b>Refreshed logo</b> across the app.</li>
              <li><b>No more double alerts.</b> If you have both Core and Lite installed, a Sentry alert no longer arrives twice.</li>
            </Rel>
            <Rel version="0.1.73" date="June 2026" color={C.purple}>
              <li><b>More accurate trips &amp; charging.</b> Fixed recording so distances, charging sessions and battery figures line up correctly.</li>
              <li><b>Fewer &ldquo;Unknown&rdquo; dates</b> on drives and charges.</li>
              <li><b>Smoother tabs.</b> Swiping between screens no longer tears or jumps.</li>
            </Rel>
            <Rel version="0.1.70" date="June 2026" color={C.purple}>
              <li><b>Driving-style trip maps.</b> Drive routes are coloured by hard acceleration and braking.</li>
              <li><b>Settings scrolls fully</b> on smaller phones, so nothing is cut off.</li>
            </Rel>
            <Rel version="0.1.71" date="June 2026" color={C.purple}>
              <li><b>Predicted range.</b> A new Stats card estimates how far you can really go right now, learned from your own driving in different temperatures &mdash; not just the car&#8217;s rated number.</li>
            </Rel>
            <Rel version="0.1.69" date="June 2026" color={C.purple}>
              <li><b>Pair a browser.</b> Sign in to the web dashboard without Tesla &mdash; open <b>Settings &rarr; Pair a browser</b> and scan the QR (or type the code) on your computer.</li>
            </Rel>
            <Rel version="0.1.68" date="June 2026" color={C.purple}>
              <li><b>Phantom drain.</b> A new Stats section shows how much battery you lose while parked, day by day and by location.</li>
            </Rel>
            <Rel version="0.1.67" date="June 2026" color={C.purple}>
              <li><b>Day &amp; night charging rates.</b> Set an optional off-peak / night price and the hours it applies; each charge&#8217;s cost is split between day and night automatically.</li>
            </Rel>
            <Rel version="0.1.66" date="June 2026" color={C.purple}>
              <li><b>Units &amp; date format, your way.</b> Keep <b>Auto</b> to follow your car, or set units (metric/imperial), 12/24-hour time and date format (DD/MM, MM/DD or ISO) independently.</li>
            </Rel>
            <Rel version="0.1.65" date="June 2026" color={C.purple}>
              <li><b>Charging cost.</b> Set your electricity price and currency in Settings, and every charge now shows what it cost.</li>
            </Rel>
            <Rel version="0.1.64" date="June 2026" color={C.purple}>
              <li><b>Battery health.</b> A new Stats section shows how much battery capacity you&#8217;ve kept over time and your range trend.</li>
            </Rel>
            <Rel version="0.1.63" date="June 2026" color={C.purple}>
              <li><b>Trips &amp; charging are back.</b> Your drives and charging sessions are recorded and shown again, with distance, duration and battery added.</li>
              <li><b>Safer delete.</b> Swipe a drive, charge or Sentry event to reveal a Delete button, then tap to confirm &mdash; no more accidental deletes.</li>
              <li><b>Bulk actions.</b> Select and delete several drives at once.</li>
              <li><b>No login flash.</b> The app no longer briefly shows the &ldquo;Login with Tesla&rdquo; screen when you&#8217;re already signed in.</li>
            </Rel>
            <Rel version="0.1.62" date="June 2026" color={C.purple}>
              <li><b>Units, your way.</b> Choose Auto (follow your car), Metric or Imperial, plus 12 or 24-hour time, in Settings.</li>
            </Rel>
            <Rel version="0.1.61" date="June 2026" color={C.purple}>
              <li><b>No more blank temperatures.</b> Inside/outside temperature now keeps the last known value with an &ldquo;x min ago&rdquo; label when the car is asleep.</li>
            </Rel>
            <Rel version="0.1.60" date="June 2026" color={C.purple}>
              <li><b>More secure sign-in.</b> Reworked Tesla login with a one-time code and verified app links.</li>
              <li><b>Stay logged in longer.</b> Session handling reworked so you&#8217;re asked to reconnect far less often.</li>
            </Rel>
          </Section>

          <Section id="lite" color={C.green} title="Lite app (Android)">
            <Rel version="0.1.58" date="July 2026" color={C.green}>
              <li><b>Ad moved above the fold.</b> The banner ad now sits right under the Sentry toggle, so it&#8217;s always visible without scrolling.</li>
              <li><b>Open-source licenses moved</b> into the Settings dialog, under a new About section.</li>
              <li><b>One account, one app at a time.</b> Signing in to Lite is now blocked while the same Tesla account is signed in on Core, with a link to open Core instead.</li>
              <li><b>Sentry alerts now name your car.</b></li>
              <li><b>Bigger, animated battery bar</b> that pulses with a lightning-bolt icon while charging.</li>
              <li><b>Better fit on smaller phones.</b></li>
            </Rel>
            <Rel version="0.1.52" date="June 2026" color={C.green}>
              <li><b>Refreshed logo.</b></li>
              <li><b>Keep alerts active.</b> Open Lite at least once every 48 hours to keep its Sentry alerts running &mdash; a quick open is all it takes.</li>
            </Rel>
            <Rel version="0.1.47" date="June 2026" color={C.green}>
              <li><b>Units follow your car.</b> Lite now always matches your car&#8217;s own unit settings automatically.</li>
            </Rel>
            <Rel version="0.1.46" date="June 2026" color={C.green}>
              <li><b>No login flash.</b> No more brief &ldquo;Login with Tesla&rdquo; screen on open when you&#8217;re already signed in.</li>
            </Rel>
            <Rel version="0.1.45" date="June 2026" color={C.green}>
              <li><b>Units &amp; time format.</b> Choose Auto / Metric / Imperial and 12 or 24-hour time.</li>
            </Rel>
            <Rel version="0.1.44" date="June 2026" color={C.green}>
              <li><b>No more blank temperatures.</b> Shows the last known temperature with an age label when the car sleeps.</li>
            </Rel>
            <Rel version="0.1.43" date="June 2026" color={C.green}>
              <li><b>More secure sign-in</b> and <b>longer sessions</b>, so alerts keep working without frequent re-login.</li>
              <li><b>Pick your vehicle.</b> Choose which one car Lite watches and notifies you about.</li>
            </Rel>
          </Section>

          <Section id="web" color={C.red} title="Web dashboard (app.marit.es)">
            <Rel version="" date="June 2026" color={C.red}>
              <li><b>Energy used per trip.</b> Each drive now shows the kWh it used, estimated from your charging history.</li>
              <li><b>Charging status at a glance.</b> The dashboard now shows when your car is charging, with live power.</li>
              <li><b>Flexible charging tariff.</b> The night rate is now a reduced rate you can apply to up to three time windows a day.</li>
              <li><b>Stats marked Beta</b> &mdash; the estimated figures are still being fine-tuned.</li>
              <li><b>Refreshed logo.</b></li>
              <li><b>Predicted range.</b> Stats now estimates your real-world range from your driving history and the current temperature.</li>
              <li><b>Battery health &amp; phantom drain.</b> Stats shows capacity retention over time and how much battery you lose while parked &mdash; matching the Core app.</li>
              <li><b>Charging cost &amp; tariff.</b> Set your electricity price (with an optional night rate) in the new Settings page and see what every charge costs.</li>
              <li><b>Units &amp; time format.</b> Choose metric or imperial and 12 or 24-hour time in Settings.</li>
              <li><b>Driving-style trip maps.</b> Drive routes are coloured by hard acceleration and braking, with a count of each.</li>
              <li><b>Export your data.</b> Download Drives and Charges as CSV, Excel or PDF, with a date range and sorting.</li>
              <li><b>Trip maps fixed.</b> Drive routes show on the map again, even without saved addresses.</li>
              <li><b>Cleaner admin &amp; navigation.</b> Removed the unused notifications page (alerts are on mobile); the admin view now shows last login, cars and plan.</li>
              <li><b>Live temperatures &amp; range</b> are shown again on the dashboard.</li>
              <li><b>Trips &amp; charging history</b> are recorded and visible again.</li>
              <li><b>Clearer sign-in &amp; settings</b> pages, and a proper page title.</li>
            </Rel>
          </Section>

          <p style={{ color: C.dim, fontSize: 12.5, lineHeight: 1.6, margin: "4px 0 10px" }}>
            Looking for how things work? See the <a href="/faq/" style={{ color: C.purple, textDecoration: "none" }}>FAQ &amp; Manual</a>.
          </p>
        </div>

        <footer style={{
          padding: "20px 24px 40px", textAlign: "center",
          display: "flex", gap: 20, justifyContent: "center", flexWrap: "wrap",
          borderTop: "1px solid rgba(255,255,255,0.05)", marginTop: 20,
        }}>
          <a href="/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Home</a>
          <a href="/faq/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>FAQ</a>
          <a href="/privacy/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Privacy Policy</a>
          <a href="/terms/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Terms of Service</a>
          <a href="mailto:admin@marit.es" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Contact</a>
        </footer>
      </main>
    </Layout>
  );
}
