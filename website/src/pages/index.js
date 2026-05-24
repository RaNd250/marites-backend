import React from "react";
import Layout from "@theme/Layout";

const FeatureItem = ({ icon, text }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 10, color: "#9ca3af", fontSize: 14 }}>
    <span style={{ color: "#7c3aed", fontSize: 16 }}>{icon}</span>
    {text}
  </div>
);

const MissingItem = ({ text }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 10, color: "#4b5563", fontSize: 14 }}>
    <span style={{ fontSize: 16 }}>✗</span> {text}
  </div>
);

export default function Home() {
  return (
    <Layout title="marit.es — Tesla monitoring for Android" description="Advanced Tesla sentry monitoring, drive history, charge tracking and vehicle control for Android.">
      <main style={{ background: "#0a0a0f", minHeight: "100vh" }}>

        {/* Hero */}
        <section style={{
          display: "flex", flexDirection: "column", alignItems: "center",
          padding: "72px 24px 56px", textAlign: "center",
        }}>
          <img src="img/logo.png" alt="marit.es" style={{ width: 140, marginBottom: 28, borderRadius: 16 }} />

          <h1 style={{ color: "#fff", fontSize: 40, fontWeight: 800, margin: "0 0 12px", letterSpacing: "-0.5px", lineHeight: 1.15 }}>
            Marites knows what your<br />Tesla did last night.
          </h1>
          <p style={{ color: "#6b7280", fontSize: 18, maxWidth: 540, margin: "0 0 10px", lineHeight: 1.6 }}>
            Advanced sentry monitoring, drive &amp; charge history, vehicle control
            and real-time alerts — all on your Android phone.
          </p>
          <p style={{ color: "#4b5563", fontSize: 14, margin: "0 0 16px" }}>
            Available for free and as a full-featured edition on Google Play.
          </p>

          <a
            href="https://app.marit.es"
            style={{
              display: "inline-block", background: "#e31937", color: "#fff",
              fontWeight: 700, padding: "14px 36px", borderRadius: 8,
              textDecoration: "none", fontSize: 16, marginBottom: 56,
            }}
          >
            Open App
          </a>

          {/* Download cards */}
          <div style={{
            display: "flex", gap: 20, flexWrap: "wrap", justifyContent: "center",
            width: "100%", maxWidth: 760,
          }}>

            {/* Core */}
            <div style={{
              flex: "1 1 320px", maxWidth: 360,
              background: "#111113",
              border: "1px solid rgba(124,58,237,0.4)",
              borderRadius: 16, padding: "28px 28px 24px",
              display: "flex", flexDirection: "column", gap: 16,
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <div style={{
                  width: 44, height: 44, borderRadius: 10,
                  background: "rgba(124,58,237,0.15)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 22,
                }}>🚗</div>
                <div>
                  <div style={{ color: "#fff", fontWeight: 700, fontSize: 18 }}>marit.es Core</div>
                  <div style={{ color: "#7c3aed", fontSize: 12, fontWeight: 600 }}>Full experience</div>
                </div>
              </div>

              <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
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
                target="_blank"
                rel="noopener noreferrer"
                style={{ textDecoration: "none", marginTop: 4 }}
              >
                <div style={{
                  background: "#7c3aed",
                  borderRadius: 10, padding: "12px 0",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  gap: 8, color: "#fff", fontWeight: 600, fontSize: 14,
                  cursor: "pointer",
                }}>
                  <span>▶</span> Get Core on Google Play
                </div>
              </a>
            </div>

            {/* Lite */}
            <div style={{
              flex: "1 1 320px", maxWidth: 360,
              background: "#111113",
              border: "1px solid rgba(255,255,255,0.08)",
              borderRadius: 16, padding: "28px 28px 24px",
              display: "flex", flexDirection: "column", gap: 16,
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <div style={{
                  width: 44, height: 44, borderRadius: 10,
                  background: "rgba(74,222,128,0.10)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 22,
                }}>🟢</div>
                <div>
                  <div style={{ color: "#fff", fontWeight: 700, fontSize: 18 }}>marit.es Lite</div>
                  <div style={{ color: "#4ade80", fontSize: 12, fontWeight: 600 }}>Free · Sentry focus</div>
                </div>
              </div>

              <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                <FeatureItem icon="🛡" text="Sentry ON / OFF control" />
                <FeatureItem icon="🔋" text="Live battery &amp; vehicle status" />
                <FeatureItem icon="🔔" text="Sentry push notifications" />
                <FeatureItem icon="✅" text="Free — no subscription" />
                <MissingItem text="No drive/charge history" />
                <MissingItem text="No stats or commands" />
              </div>

              <a
                href="https://play.google.com/store/apps/details?id=es.marit.lite"
                target="_blank"
                rel="noopener noreferrer"
                style={{ textDecoration: "none", marginTop: 4 }}
              >
                <div style={{
                  background: "rgba(74,222,128,0.12)",
                  border: "1px solid rgba(74,222,128,0.3)",
                  borderRadius: 10, padding: "12px 0",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  gap: 8, color: "#4ade80", fontWeight: 600, fontSize: 14,
                  cursor: "pointer",
                }}>
                  <span>▶</span> Get Lite on Google Play
                </div>
              </a>
            </div>

          </div>
        </section>

        {/* Features strip */}
        <section style={{
          maxWidth: 760, margin: "0 auto", padding: "0 24px 64px",
          display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 24,
        }}>
          {[
            { icon: "📡", title: "Real-time telemetry", body: "Live vehicle status, battery level and location — always up to date." },
            { icon: "🛡", title: "Sentry monitoring", body: "Instant push alerts when sentry detects activity. Review events from anywhere." },
            { icon: "🗺", title: "Drive history", body: "Every trip logged with route map, energy used and efficiency stats." },
            { icon: "⚡", title: "Charge tracking", body: "Full charge history with cost, energy added and time at each session." },
            { icon: "🔔", title: "Alarm response", body: "Automatic honk and flash when your Tesla alarm triggers." },
            { icon: "📅", title: "Scheduling", body: "Set sentry to activate automatically on a schedule you control." },
          ].map(({ icon, title, body }) => (
            <div key={title} style={{ background: "#111113", borderRadius: 12, padding: "20px 20px 18px" }}>
              <div style={{ fontSize: 26, marginBottom: 8 }}>{icon}</div>
              <div style={{ color: "#fff", fontWeight: 700, fontSize: 14, marginBottom: 6 }}>{title}</div>
              <div style={{ color: "#6b7280", fontSize: 13, lineHeight: 1.6 }}>{body}</div>
            </div>
          ))}
        </section>

        {/* Footer links */}
        <section style={{
          maxWidth: 760, margin: "0 auto", padding: "0 24px 56px",
          textAlign: "center", display: "flex", gap: 24, justifyContent: "center", flexWrap: "wrap",
        }}>
          <a href="/privacy" style={{ color: "#4b5563", fontSize: 13, textDecoration: "none" }}>Privacy Policy</a>
          <a href="/terms" style={{ color: "#4b5563", fontSize: 13, textDecoration: "none" }}>Terms of Service</a>
          <a href="mailto:admin@marit.es" style={{ color: "#4b5563", fontSize: 13, textDecoration: "none" }}>Contact</a>
        </section>

      </main>
    </Layout>
  );
}
