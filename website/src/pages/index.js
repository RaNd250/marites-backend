import React from "react";
import Layout from "@theme/Layout";
import styles from "./styles.module.css";

const PlayStoreBadge = () => (
  <svg height="20" viewBox="0 0 135 40" fill="none" xmlns="http://www.w3.org/2000/svg" style={{ display: "block" }}>
    <rect width="135" height="40" rx="5" fill="#1a1a2e" />
    <text x="38" y="13" fill="#9ca3af" fontSize="7" fontFamily="sans-serif">GET IT ON</text>
    <text x="38" y="28" fill="#fff" fontSize="13" fontWeight="bold" fontFamily="sans-serif">Google Play</text>
    <text x="10" y="27" fill="#4ade80" fontSize="22" fontFamily="sans-serif">▶</text>
  </svg>
);

const FeatureItem = ({ icon, text }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 10, color: "#9ca3af", fontSize: 14 }}>
    <span style={{ color: "#7c3aed", fontSize: 16 }}>{icon}</span>
    {text}
  </div>
);

export default function Home() {
  return (
    <Layout title="marit.es — Tesla monitoring for Android" description="Self-hosted Tesla monitoring app for Android. Track drives, charges, sentry events and control your Tesla.">
      <main style={{ background: "#0a0a0f", minHeight: "100vh" }}>

        {/* Hero */}
        <section style={{
          display: "flex", flexDirection: "column", alignItems: "center",
          padding: "72px 24px 56px", textAlign: "center",
        }}>
          <img src="img/logo.png" alt="marit.es" style={{ width: 160, marginBottom: 32, borderRadius: 16 }} />
          <h1 style={{ color: "#fff", fontSize: 42, fontWeight: 800, margin: "0 0 16px", letterSpacing: "-0.5px" }}>
            Your Tesla. Your data.
          </h1>
          <p style={{ color: "#6b7280", fontSize: 18, maxWidth: 520, margin: "0 0 12px", lineHeight: 1.6 }}>
            Self-hosted Tesla monitoring for Android. Track every drive and charge,
            control sentry mode, and keep your data on your own server.
          </p>
          <p style={{ color: "#4b5563", fontSize: 14, margin: "0 0 48px" }}>
            Requires a self-hosted marit.es backend. Open source.
          </p>

          {/* Download cards */}
          <div style={{
            display: "flex", gap: 20, flexWrap: "wrap", justifyContent: "center",
            width: "100%", maxWidth: 740,
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
                <FeatureItem icon="🔑" text="Honk, flash, vehicle commands" />
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
                <div style={{ display: "flex", alignItems: "center", gap: 10, color: "#4b5563", fontSize: 14 }}>
                  <span style={{ fontSize: 16 }}>✗</span> No drive/charge history
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: 10, color: "#4b5563", fontSize: 14 }}>
                  <span style={{ fontSize: 16 }}>✗</span> No stats or commands
                </div>
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

        {/* Requirements */}
        <section style={{
          maxWidth: 740, margin: "0 auto", padding: "0 24px 72px",
          textAlign: "center",
        }}>
          <p style={{ color: "#4b5563", fontSize: 13, lineHeight: 1.7 }}>
            marit.es requires a self-hosted backend server running the open-source marit.es stack (Elixir/Phoenix + PostgreSQL + TeslaMate).{" "}
            <a href="https://github.com/RaNd250/marites" style={{ color: "#7c3aed" }}>
              View on GitHub →
            </a>
          </p>
        </section>

      </main>
    </Layout>
  );
}
