import React from "react";
import Layout from "@theme/Layout";

const FeatureItem = ({ icon, text }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 8, color: "#9ca3af", fontSize: 13 }}>
    <span style={{ color: "#7c3aed", fontSize: 14, flexShrink: 0 }}>{icon}</span>
    {text}
  </div>
);

const MissingItem = ({ text }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 8, color: "#374151", fontSize: 13 }}>
    <span style={{ fontSize: 14, flexShrink: 0 }}>✗</span> {text}
  </div>
);

export default function Home() {
  return (
    <Layout
      title="marit.es — Tesla monitoring for Android"
      description="Advanced Tesla sentry monitoring, drive history, charge tracking and vehicle control for Android."
      noFooter
    >
      <main style={{
        background: "#0a0a0f",
        minHeight: "100vh",
        position: "relative",
        overflow: "hidden",
      }}>

        {/* Background blurred image */}
        <div style={{
          position: "fixed",
          top: 0, left: 0, right: 0, bottom: 0,
          backgroundImage: "url(/img/bg.png)",
          backgroundSize: "cover",
          backgroundPosition: "center",
          backgroundRepeat: "no-repeat",
          opacity: 0.12,
          filter: "blur(32px)",
          transform: "scale(1.05)",
          pointerEvents: "none",
          zIndex: 0,
        }} />

        <div style={{ position: "relative", zIndex: 1 }}>

          {/* Header */}
          <header style={{
            display: "flex", alignItems: "center", justifyContent: "space-between",
            padding: "16px 28px",
          }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <img src="/img/logo.png" alt="marit.es" style={{ width: 32, height: 32, borderRadius: 6 }} />
              <span style={{ color: "#fff", fontWeight: 800, fontSize: 16, letterSpacing: "-0.3px" }}>
                marit<span style={{ color: "#e31937" }}>.es</span>
              </span>
            </div>
            <a
              href="https://app.marit.es"
              target="_blank"
              rel="noopener noreferrer"
              style={{
                background: "#e31937", color: "#fff", fontWeight: 700,
                padding: "8px 20px", borderRadius: 6, textDecoration: "none", fontSize: 13,
              }}
            >
              Open App →
            </a>
          </header>

          {/* Hero */}
          <section style={{
            display: "flex", flexDirection: "column", alignItems: "center",
            padding: "32px 24px 28px", textAlign: "center",
          }}>
            <h1 style={{
              color: "#fff", fontSize: "clamp(26px, 5vw, 38px)",
              fontWeight: 800, margin: "0 0 10px", letterSpacing: "-0.5px", lineHeight: 1.15,
            }}>
              Marites knows what your Tesla<br />did last night.
            </h1>
            <p style={{ color: "#6b7280", fontSize: 16, maxWidth: 480, margin: "0 0 28px", lineHeight: 1.6 }}>
              Advanced sentry monitoring, drive &amp; charge history,
              vehicle control and real-time alerts — on your Android phone.
            </p>

            {/* Download cards */}
            <div style={{
              display: "flex", gap: 16, flexWrap: "wrap", justifyContent: "center",
              width: "100%", maxWidth: 740,
            }}>

              {/* Core */}
              <div style={{
                flex: "1 1 300px", maxWidth: 350,
                background: "#111113",
                border: "1px solid rgba(124,58,237,0.4)",
                borderRadius: 14, padding: "22px 22px 18px",
                display: "flex", flexDirection: "column", gap: 14,
              }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <div style={{
                    width: 38, height: 38, borderRadius: 9,
                    background: "rgba(124,58,237,0.15)",
                    display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20,
                  }}>🚗</div>
                  <div>
                    <div style={{ color: "#fff", fontWeight: 700, fontSize: 16 }}>marit.es Core</div>
                    <div style={{ color: "#7c3aed", fontSize: 11, fontWeight: 600 }}>Full experience</div>
                  </div>
                </div>
                <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
                  <FeatureItem icon="📍" text="Drive history &amp; live map" />
                  <FeatureItem icon="⚡" text="Charge history &amp; stats" />
                  <FeatureItem icon="🛡" text="Sentry mode control &amp; alerts" />
                  <FeatureItem icon="📊" text="Battery health &amp; statistics" />
                  <FeatureItem icon="🔑" text="Honk, flash &amp; vehicle commands" />
                  <FeatureItem icon="🔔" text="Push notifications" />
                  <FeatureItem icon="📅" text="Scheduled sentry &amp; alarm response" />
                </div>
                <a
                  href="https://play.google.com/store/apps/details?id=es.marit.app"
                  target="_blank" rel="noopener noreferrer"
                  style={{ textDecoration: "none" }}
                >
                  <div style={{
                    background: "#7c3aed", borderRadius: 8, padding: "11px 0",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    gap: 8, color: "#fff", fontWeight: 600, fontSize: 13, cursor: "pointer",
                  }}>
                    ▶ Get Core on Google Play
                  </div>
                </a>
              </div>

              {/* Lite */}
              <div style={{
                flex: "1 1 300px", maxWidth: 350,
                background: "#111113",
                border: "1px solid rgba(255,255,255,0.08)",
                borderRadius: 14, padding: "22px 22px 18px",
                display: "flex", flexDirection: "column", gap: 14,
              }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <div style={{
                    width: 38, height: 38, borderRadius: 9,
                    background: "rgba(74,222,128,0.10)",
                    display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20,
                  }}>🟢</div>
                  <div>
                    <div style={{ color: "#fff", fontWeight: 700, fontSize: 16 }}>marit.es Lite</div>
                    <div style={{ color: "#4ade80", fontSize: 11, fontWeight: 600 }}>Free · 1 vehicle · 7-day history</div>
                  </div>
                </div>
                <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
                  <FeatureItem icon="🚗" text="1 vehicle" />
                  <FeatureItem icon="🛡" text="Sentry ON / OFF control" />
                  <FeatureItem icon="🔋" text="Live battery &amp; vehicle status" />
                  <FeatureItem icon="🔔" text="Sentry push notifications" />
                  <FeatureItem icon="📅" text="Drive &amp; charge history (7 days)" />
                  <FeatureItem icon="✅" text="Free — no subscription" />
                  <MissingItem text="No stats or commands" />
                </div>
                <a
                  href="https://play.google.com/store/apps/details?id=es.marit.lite"
                  target="_blank" rel="noopener noreferrer"
                  style={{ textDecoration: "none" }}
                >
                  <div style={{
                    background: "rgba(74,222,128,0.12)",
                    border: "1px solid rgba(74,222,128,0.3)",
                    borderRadius: 8, padding: "11px 0",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    gap: 8, color: "#4ade80", fontWeight: 600, fontSize: 13, cursor: "pointer",
                  }}>
                    ▶ Get Lite on Google Play
                  </div>
                </a>
              </div>

            </div>
          </section>

          {/* Features strip — compact 3-col */}
          <section style={{
            maxWidth: 740, margin: "0 auto", padding: "0 20px 24px",
            display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: 12,
          }}>
            {[
              { icon: "📡", title: "Real-time telemetry", body: "Live status, battery and location." },
              { icon: "🛡", title: "Sentry monitoring", body: "Instant push alerts on any activity." },
              { icon: "🗺", title: "Drive history", body: "Every trip with route, energy and stats." },
              { icon: "⚡", title: "Charge tracking", body: "Cost, energy and time per session." },
              { icon: "🔔", title: "Alarm response", body: "Auto honk &amp; flash when alarm triggers." },
              { icon: "📅", title: "Scheduling", body: "Sentry on a schedule you control." },
            ].map(({ icon, title, body }) => (
              <div key={title} style={{
                background: "#111113", borderRadius: 10, padding: "14px 16px",
                display: "flex", gap: 10, alignItems: "flex-start",
              }}>
                <span style={{ fontSize: 20, flexShrink: 0 }}>{icon}</span>
                <div>
                  <div style={{ color: "#fff", fontWeight: 700, fontSize: 12, marginBottom: 2 }}>{title}</div>
                  <div style={{ color: "#6b7280", fontSize: 11, lineHeight: 1.5 }} dangerouslySetInnerHTML={{ __html: body }} />
                </div>
              </div>
            ))}
          </section>

          {/* Footer */}
          <footer style={{
            padding: "12px 24px 24px", textAlign: "center",
            display: "flex", gap: 20, justifyContent: "center", flexWrap: "wrap",
          }}>
            <a href="/privacy" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Privacy Policy</a>
            <a href="/terms" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Terms of Service</a>
            <a href="mailto:admin@marit.es" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Contact</a>
          </footer>

        </div>
      </main>
    </Layout>
  );
}
