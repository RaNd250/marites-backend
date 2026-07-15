import React from "react";
import Layout from "@theme/Layout";
import Head from "@docusaurus/Head";

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

const faqData = [
  {
    q: "What is Tesla phantom drain?",
    a: "Phantom drain (also called vampire drain) is the battery a parked Tesla loses without driving or charging. It's caused by background systems that keep running while the car is idle: Sentry Mode, climate keeping, cabin overheat protection, data connectivity, and periodic wake-ups for software updates.",
  },
  {
    q: "How much phantom drain is normal for a Tesla?",
    a: "A Tesla parked with Sentry Mode off typically loses well under 1% per day. With Sentry Mode on, 24/7, drain commonly runs 2-5% per day depending on the car, firmware and how often it's woken by movement nearby. Above that, something worth investigating is usually going on.",
  },
  {
    q: "How do I track phantom drain on my Tesla?",
    a: "Tesla's own app doesn't show a phantom drain trend. marit.es reads your car's live telemetry and calculates phantom drain automatically from every parked session — no setup, no extra sensor. Under Stats you get an average %/day, a daily trend chart, and your worst parking spot ranked by drain.",
  },
  {
    q: "Can I reduce phantom drain?",
    a: "Yes — schedule Sentry Mode instead of leaving it on all the time, park somewhere with less passing traffic (Sentry re-triggers on motion), and keep the car on the latest firmware. marit.es lets you schedule Sentry on a weekly timetable so it's only active when you actually want it.",
  },
];

const faqStructuredData = {
  "@context": "https://schema.org",
  "@type": "FAQPage",
  mainEntity: faqData.map(({ q, a }) => ({
    "@type": "Question",
    name: q,
    acceptedAnswer: { "@type": "Answer", text: a },
  })),
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
  <div style={{ background: C.card, borderRadius: 12, padding: "16px 18px" }}>
    <div style={{ color: "#fff", fontWeight: 700, fontSize: 14, marginBottom: 7 }}>{q}</div>
    <div style={{ color: C.muted, fontSize: 13.5, lineHeight: 1.65 }}>{children}</div>
  </div>
);

const LangSwitch = () => (
  <div style={{ display: "flex", gap: 6, alignItems: "center", fontSize: 12, fontWeight: 700, flexShrink: 0 }}>
    <span style={{ color: "#fff" }}>EN</span>
    <span style={{ color: "#374151" }}>|</span>
    <a href="/el/phantom-drain/" lang="el" hrefLang="el" style={{ color: "#6b7280", textDecoration: "none" }}>ΕΛ</a>
  </div>
);

export default function PhantomDrain() {
  return (
    <Layout
      title="Tesla Phantom Drain Tracker — See What's Draining Your Battery While Parked"
      description="Track Tesla phantom drain (vampire drain) automatically. Average %/day, a daily trend and your worst parking spot — free to see with marit.es Core, Lite or Web. No setup."
      noFooter
    >
      <Head>
        <script type="application/ld+json">{JSON.stringify(faqStructuredData)}</script>
      </Head>

      <style>{`
        .navbar { display: none !important; }
        .main-wrapper { padding-top: 0 !important; }
        .m-wrap { max-width: 860px; margin: 0 auto; width: 100%; padding: 0 20px; }
        .m-head {
          display: flex; align-items: center; justify-content: space-between;
          padding: 14px 20px; gap: 16px; max-width: 860px; margin: 0 auto; width: 100%;
        }
        .m-cta {
          display: flex; gap: 12px; flex-wrap: wrap; margin: 22px 0 34px;
        }
        .m-cta a {
          flex: 1 1 200px; text-decoration: none; text-align: center;
          border-radius: 8px; padding: 12px 16px; font-weight: 600; font-size: 13px;
        }
        @media (max-width: 600px) {
          .m-head { padding: 12px 16px; }
        }
      `}</style>

      <main style={{ background: C.bg, minHeight: "100vh", color: C.text }}>
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
          <div style={{ padding: "18px 0 6px" }}>
            <h1 style={{ color: "#fff", fontSize: 30, fontWeight: 900, margin: "0 0 8px", letterSpacing: "-0.5px" }}>
              Tesla Phantom Drain Tracker
            </h1>
            <p style={{ color: C.dim, fontSize: 14, lineHeight: 1.6, margin: 0 }}>
              See exactly how much battery your Tesla loses while parked — automatically, with no
              setup. Average %/day, a daily trend, and your worst parking spot.
            </p>
          </div>

          <div className="m-cta">
            <a href="https://play.google.com/store/apps/details?id=es.marit.app" target="_blank" rel="noopener noreferrer"
               style={{ background: C.purple, color: "#fff" }}>
              ▶ Get Core on Google Play
            </a>
            <a href="https://app.marit.es" target="_blank" rel="noopener noreferrer"
               style={{ background: "rgba(227,25,55,0.12)", border: "1px solid rgba(227,25,55,0.4)", color: C.red }}>
              🌐 Try the web dashboard
            </a>
          </div>

          <Section id="what" title="What is phantom drain?">
            <QA q="The short version">
              Phantom drain — also called vampire drain — is the charge a Tesla loses just sitting
              parked, with no drive and no charging session running. It comes from background
              systems that never fully switch off: Sentry Mode, cabin overheat protection, cellular
              and Wi-Fi connectivity, and periodic wake-ups to check for commands or software updates.
            </QA>
            <QA q="Why it's hard to notice">
              A car that loses 5 miles overnight looks fine. A car that loses 5 miles every night for
              a month has lost 150 miles of range to nothing. Without a day-by-day trend, phantom
              drain is invisible until the battery is unexpectedly low the morning you need it.
            </QA>
          </Section>

          <Section id="track" title="How marit.es tracks it">
            <QA q="Automatic, from telemetry you already have">
              marit.es reads your car's live Fleet Telemetry stream and works out phantom drain from
              every parked period automatically — there's nothing to enable and no extra hardware.
              Under <b>Stats</b> you get:
              <div style={{ marginTop: 8, display: "flex", flexDirection: "column", gap: 5 }}>
                <div>📉 Average phantom drain, in %/day</div>
                <div>📈 A daily trend chart, so a spike stands out immediately</div>
                <div>📍 Your worst parking spot, ranked by drain — useful for spotting a location where Sentry keeps re-triggering</div>
              </div>
            </QA>
            <QA q="Where to find it">
              Core and marit.es Web: open <b>Stats → Phantom Drain</b>. Lite doesn't include stats —
              upgrade to Core or use the web dashboard to see your trend.
            </QA>
          </Section>

          <Section id="faq" title="Frequently asked questions">
            {faqData.map(({ q, a }) => (
              <QA key={q} q={q}>{a}</QA>
            ))}
          </Section>

          <p style={{ color: C.dim, fontSize: 12, lineHeight: 1.6, marginTop: 30 }}>
            More on batteries and charging in the <a href="/faq/#insights" style={{ color: C.purple }}>full FAQ</a>.
          </p>
        </div>

        <footer style={{
          padding: "20px 24px 40px", textAlign: "center",
          display: "flex", gap: 20, justifyContent: "center", flexWrap: "wrap",
          borderTop: "1px solid rgba(255,255,255,0.05)", marginTop: 20,
        }}>
          <a href="/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Home</a>
          <a href="/faq/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>FAQ &amp; Manual</a>
          <a href="/changelog/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Changelog</a>
          <a href="/privacy/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Privacy Policy</a>
          <a href="mailto:admin@marit.es" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Contact</a>
        </footer>
      </main>
    </Layout>
  );
}
