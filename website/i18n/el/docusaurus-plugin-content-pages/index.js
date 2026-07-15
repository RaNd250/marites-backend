import React from "react";
import Layout from "@theme/Layout";
import Head from "@docusaurus/Head";

const structuredData = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      "@id": "https://marit.es/#org",
      name: "marit.es",
      url: "https://marit.es/",
      logo: "https://marit.es/img/icon-512.png",
    },
    {
      "@type": "WebSite",
      "@id": "https://marit.es/#website",
      name: "marit.es",
      url: "https://marit.es/",
      publisher: { "@id": "https://marit.es/#org" },
    },
    {
      "@type": "MobileApplication",
      name: "marit.es Core",
      operatingSystem: "Android",
      applicationCategory: "UtilitiesApplication",
      inLanguage: "el",
      description:
        "Εφαρμογή-σύντροφος για Tesla με ειδοποιήσεις Sentry, ιστορικό διαδρομών, παρακολούθηση φόρτισης και εντολές οχήματος.",
      installUrl: "https://play.google.com/store/apps/details?id=es.marit.app",
      offers: { "@type": "Offer", price: "0", priceCurrency: "EUR" },
      author: { "@id": "https://marit.es/#org" },
    },
    {
      "@type": "MobileApplication",
      name: "marit.es Lite",
      operatingSystem: "Android",
      applicationCategory: "UtilitiesApplication",
      inLanguage: "el",
      description:
        "Δωρεάν εφαρμογή για Android με ειδοποιήσεις Sentry και κατάσταση οχήματος Tesla.",
      installUrl: "https://play.google.com/store/apps/details?id=es.marit.lite",
      offers: { "@type": "Offer", price: "0", priceCurrency: "EUR" },
      author: { "@id": "https://marit.es/#org" },
    },
    {
      "@type": "WebApplication",
      name: "marit.es Web",
      url: "https://app.marit.es/",
      applicationCategory: "UtilitiesApplication",
      operatingSystem: "Web",
      browserRequirements: "Requires a modern web browser.",
      inLanguage: "el",
      description:
        "Web dashboard για Tesla με ιστορικό διαδρομών, παρακολούθηση φόρτισης, υγεία μπαταρίας και ειδοποιήσεις Sentry στο Telegram. Χωρίς εγκατάσταση εφαρμογής.",
      offers: {
        "@type": "Offer",
        price: "4.99",
        priceCurrency: "EUR",
        description: "Μηνιαία συνδρομή με δωρεάν δοκιμή 7 ημερών.",
      },
      author: { "@id": "https://marit.es/#org" },
    },
  ],
};

const FeatureItem = ({ icon, text }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 8, color: "#9ca3af", fontSize: 13 }}>
    <span style={{ color: "#7c3aed", fontSize: 14, flexShrink: 0 }}>{icon}</span>
    {text}
  </div>
);

const LangSwitch = () => (
  <div style={{ display: "flex", gap: 6, alignItems: "center", fontSize: 12, fontWeight: 700, flexShrink: 0 }}>
    <a href="/" lang="en" hrefLang="en" style={{ color: "#6b7280", textDecoration: "none" }} onClick={() => { try { localStorage.setItem("marites_lang_choice", "en"); } catch {} }}>EN</a>
    <span style={{ color: "#374151" }}>|</span>
    <span style={{ color: "#fff" }}>ΕΛ</span>
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
      title="Ειδοποιήσεις Sentry, ιστορικό διαδρομών & φόρτισης Tesla για Android"
      description="Παρακολουθήστε το Tesla σας σε πραγματικό χρόνο. Ειδοποιήσεις Sentry σε πραγματικό χρόνο, ιστορικό διαδρομών, παρακολούθηση φόρτισης και εντολές οχήματος για Android — marit.es Core και Lite."
      noFooter
    >
      <Head>
        <script type="application/ld+json">{JSON.stringify(structuredData)}</script>
      </Head>
      <style>{`
        .navbar { display: none !important; }
        .main-wrapper { padding-top: 0 !important; }

        /* ── Responsive layout ───────────────────────────────────── */
        .m-page { max-width: 1100px; margin: 0 auto; width: 100%; }
        .m-header {
          display: flex; align-items: center; justify-content: space-between;
          padding: 14px 40px; gap: 20px;
        }
        .m-tagline {
          color: #e5e7eb; font-size: 16px; font-weight: 700;
          text-align: center; flex: 1;
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
          letter-spacing: -0.2px;
        }
        .m-cards {
          display: flex; gap: 20px; flex-wrap: wrap; align-items: stretch;
          justify-content: center; width: 100%;
        }
        .m-card {
          flex: 1 1 320px; max-width: 420px;
          background: #111113; border-radius: 14px;
          padding: 24px 24px 20px;
          display: flex; flex-direction: column; gap: 14px;
        }
        .m-features {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 14px; padding: 0 40px 28px;
        }
        .m-feature-card {
          background: #111113; border-radius: 10px; padding: 16px 18px;
          display: flex; gap: 12px; align-items: flex-start;
        }

        /* ── Full HD tweak (≥1440px) ─────────────────────────────── */
        @media (min-width: 1440px) {
          .m-header { padding: 16px 60px; }
          .m-tagline { font-size: 18px; }
          .m-card { max-width: 480px; }
          .m-features { padding: 0 60px 32px; gap: 16px; }
        }

        /* ── Tablet (768–1099px) ─────────────────────────────────── */
        @media (max-width: 1099px) {
          .m-features { grid-template-columns: repeat(2, 1fr); }
        }

        /* ── Mobile (≤767px) ─────────────────────────────────────── */
        @media (max-width: 767px) {
          .m-header { padding: 12px 16px; gap: 10px; }
          .m-tagline { display: none; }
          .m-cards { gap: 12px; }
          .m-card { flex: 1 1 100%; max-width: 100%; padding: 18px 16px 14px; }
          .m-features { grid-template-columns: 1fr 1fr; padding: 0 16px 20px; gap: 10px; }
          .m-feature-card { padding: 12px 14px; }
        }

        /* ── Very small (≤480px) ─────────────────────────────────── */
        @media (max-width: 480px) {
          .m-features { grid-template-columns: 1fr; }
        }
      `}</style>

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
          <header className="m-header">
            <div style={{ display: "flex", alignItems: "center", gap: 10, flexShrink: 0 }}>
              <img src="/img/logo.png" alt="marit.es" style={{ width: 34, height: 34, borderRadius: 6 }} />
              <span style={{ color: "#fff", fontWeight: 800, fontSize: 17, letterSpacing: "-0.3px" }}>
                mari<span style={{ color: "#e31937" }}>t.es</span>
              </span>
            </div>
            <span className="m-tagline">Μην χάσετε ποτέ ξανά ένα συμβάν Sentry.</span>
            <LangSwitch />
          </header>

          {/* Hero */}
          <section style={{
            display: "flex", flexDirection: "column", alignItems: "center",
            padding: "18px 24px 28px", textAlign: "center",
          }}>
            <p style={{ color: "#6b7280", fontSize: 14, maxWidth: 1100, width: "100%", padding: "0 20px", boxSizing: "border-box", margin: "0 0 10px", lineHeight: 1.65 }}>
              Η εφαρμογή Android για προηγμένη παρακολούθηση Sentry, ιστορικό διαδρομών &amp; φορτίσεων,
              έλεγχο οχήματος και ειδοποιήσεις σε πραγματικό χρόνο — ή χρησιμοποιήστε Web + Telegram, χωρίς εγκατάσταση εφαρμογής.
            </p>
            <p style={{ color: "#6b7280", fontSize: 12, fontStyle: "italic", margin: "0 0 22px", padding: "0 20px" }}>
              &laquo;Marites&raquo;: αργκό των Φιλιππίνων για την κουτσομπόλα της γειτονιάς που τα βλέπει όλα — όπως το Tesla σας.
            </p>

            {/* Download cards */}
            <div className="m-page" style={{ padding: "0 20px" }}>
              <div className="m-cards">

                {/* Core */}
                <div className="m-card" style={{ border: "1px solid rgba(124,58,237,0.4)" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <div style={{
                      width: 40, height: 40, borderRadius: 10,
                      background: "rgba(124,58,237,0.15)",
                      display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22,
                    }}>🚗</div>
                    <div>
                      <div style={{ color: "#fff", fontWeight: 700, fontSize: 16 }}>marit.es Core</div>
                      <div style={{ color: "#7c3aed", fontSize: 11, fontWeight: 600 }}>Η πλήρης εμπειρία · 7 €/μήνα με δοκιμαστική περίοδο 2 εβδομάδων</div>
                    </div>
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
                    <FeatureItem icon="📍" text="Ιστορικό διαδρομών & ζωντανός χάρτης" />
                    <FeatureItem icon="⚡" text="Ιστορικό & στατιστικά φόρτισης" />
                    <FeatureItem icon="🛡" text="Έλεγχος Sentry mode & ειδοποιήσεις" />
                    <FeatureItem icon="📊" text={<>Battery Health &amp; <a href="/el/phantom-drain/" style={{ color: "inherit" }}>phantom drain</a></>} />
                    <FeatureItem icon="🔑" text="Κόρνα, φώτα & εντολές οχήματος" />
                    <FeatureItem icon="🔔" text="Push ειδοποιήσεις" />
                    <FeatureItem icon="📅" text="Προγραμματισμένο Sentry & απόκριση συναγερμού" />
                    <FeatureItem icon="✅" text="Όλες οι δυνατότητες" />
                  </div>
                  <div style={{ color: "#6b7280", fontSize: 11, textAlign: "center", marginTop: "auto" }}>
                    Δωρεάν για 2 εβδομάδες — ακυρώστε οποτεδήποτε στη δοκιμαστική περίοδο χωρίς καμία χρέωση.
                  </div>
                  <a
                    href="https://play.google.com/store/apps/details?id=es.marit.app"
                    target="_blank" rel="noopener noreferrer"
                    style={{ textDecoration: "none" }}
                  >
                    <div style={{
                      background: "#7c3aed", borderRadius: 8, padding: "12px 0",
                      display: "flex", alignItems: "center", justifyContent: "center",
                      gap: 8, color: "#fff", fontWeight: 600, fontSize: 13, cursor: "pointer",
                    }}>
                      ▶ Αποκτήστε το Core στο Google Play
                    </div>
                  </a>
                </div>

                {/* Lite */}
                <div className="m-card" style={{ border: "1px solid rgba(255,255,255,0.08)" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <div style={{
                      width: 40, height: 40, borderRadius: 10,
                      background: "rgba(74,222,128,0.10)",
                      display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22,
                    }}>🟢</div>
                    <div>
                      <div style={{ color: "#fff", fontWeight: 700, fontSize: 16 }}>marit.es Lite</div>
                      <div style={{ color: "#4ade80", fontSize: 11, fontWeight: 600 }}>Δωρεάν με διαφημίσεις · 1 όχημα · ιστορικό 7 ημερών</div>
                    </div>
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
                    <FeatureItem icon="🚗" text="1 όχημα" />
                    <FeatureItem icon="🛡" text="Ενεργοποίηση / Απενεργοποίηση Sentry" />
                    <FeatureItem icon="🔋" text="Ζωντανή μπαταρία & κατάσταση οχήματος" />
                    <FeatureItem icon="🔔" text="Push ειδοποιήσεις Sentry" />
                    <FeatureItem icon="📅" text="Ιστορικό διαδρομών & φορτίσεων (7 ημέρες)" />
                    <FeatureItem icon="✅" text="Δωρεάν, χωρίς συνδρομή" />
                    <div style={{ color: "#6b7280", fontSize: 11, paddingLeft: 22 }}>Περιέχει διαφημίσεις</div>
                    <MissingItem text="Δεν περιλαμβάνει στατιστικά ή απομακρυσμένες εντολές" />
                  </div>
                  <a
                    href="https://play.google.com/store/apps/details?id=es.marit.lite"
                    target="_blank" rel="noopener noreferrer"
                    style={{ textDecoration: "none", marginTop: "auto" }}
                  >
                    <div style={{
                      background: "rgba(74,222,128,0.12)",
                      border: "1px solid rgba(74,222,128,0.3)",
                      borderRadius: 8, padding: "12px 0",
                      display: "flex", alignItems: "center", justifyContent: "center",
                      gap: 8, color: "#4ade80", fontWeight: 600, fontSize: 13, cursor: "pointer",
                    }}>
                      ▶ Αποκτήστε το Lite στο Google Play
                    </div>
                  </a>
                </div>

                {/* Web (No-App) */}
                <div className="m-card" style={{ border: "1px solid rgba(227,25,55,0.4)" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <div style={{
                      width: 40, height: 40, borderRadius: 10,
                      background: "rgba(227,25,55,0.12)",
                      display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22,
                    }}>🌐</div>
                    <div>
                      <div style={{ color: "#fff", fontWeight: 700, fontSize: 16 }}>marit.es Web</div>
                      <div style={{ color: "#e31937", fontSize: 11, fontWeight: 600 }}>Android, Web και Telegram · 4,99 €/μήνα · δοκιμή 7 ημερών</div>
                    </div>
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
                    <FeatureItem icon="🌐" text="Πλήρες dashboard μέσω browser — σε κάθε συσκευή" />
                    <FeatureItem icon="📍" text="Διαδρομές & Ζωντανός χάρτης διαδρομής" />
                    <FeatureItem icon="⚡" text="Ιστορικό & στατιστικά φόρτισης" />
                    <FeatureItem icon="📊" text={<>Υγεία μπαταρίας &amp; <a href="/el/phantom-drain/" style={{ color: "inherit" }}>phantom drain</a></>} />
                    <FeatureItem icon="💬" text="Ειδοποιήσεις Sentry στο Telegram (με τοποθεσία)" />
                    <FeatureItem icon="🍏" text="iPhone και υπολογιστής — χωρίς εγκατάσταση εφαρμογής" />
                  </div>
                  <a
                    href="https://app.marit.es"
                    target="_blank" rel="noopener noreferrer"
                    style={{ textDecoration: "none", marginTop: "auto" }}
                  >
                    <div style={{
                      background: "#e31937", borderRadius: 8, padding: "12px 0",
                      display: "flex", alignItems: "center", justifyContent: "center",
                      gap: 8, color: "#fff", fontWeight: 600, fontSize: 13, cursor: "pointer",
                    }}>
                      🌐 Ανοίξτε το web app
                    </div>
                  </a>
                </div>

              </div>
            </div>
          </section>

          {/* Features strip */}
          <div className="m-page">
            <div className="m-features">
              {[
                { icon: "📡", title: "Τηλεμετρία σε πραγματικό χρόνο", body: "Μάθετε τι ακριβώς κάνει το Tesla σας." },
                { icon: "🛡", title: "Παρακολούθηση Sentry", body: "Άμεσες push ειδοποιήσεις σε κάθε δραστηριότητα." },
                { icon: "🗺", title: "Ιστορικό διαδρομών", body: "Κάθε διαδρομή σε έναν όμορφο διαδραστικό χάρτη." },
                { icon: "⚡", title: "Παρακολούθηση φόρτισης", body: "Κατανοήστε κάθε συνεδρία φόρτισης." },
                { icon: "🔔", title: "Απόκριση συναγερμού", body: "Αυτόματη κόρνα &amp; φώτα όταν χτυπήσει ο συναγερμός." },
                { icon: "📅", title: "Προγραμματισμός", body: "Sentry στο πρόγραμμα που ορίζετε εσείς." },
              ].map(({ icon, title, body }) => (
                <div key={title} className="m-feature-card">
                  <span style={{ fontSize: 22, flexShrink: 0 }}>{icon}</span>
                  <div>
                    <div style={{ color: "#fff", fontWeight: 700, fontSize: 12, marginBottom: 3 }}>{title}</div>
                    <div style={{ color: "#6b7280", fontSize: 11, lineHeight: 1.5 }} dangerouslySetInnerHTML={{ __html: body }} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Footer */}
          <footer style={{
            padding: "12px 24px 28px", textAlign: "center",
            display: "flex", gap: 20, justifyContent: "center", flexWrap: "wrap",
          }}>
            <a href="/el/faq/" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>FAQ &amp; Οδηγίες</a>
            <a href="/el/changelog/" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Τι νέο υπάρχει</a>
            <a href="/privacy/" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Πολιτική Απορρήτου</a>
            <a href="/terms/" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Όροι Χρήσης</a>
            <a href="mailto:admin@marit.es" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Επικοινωνία</a>
            <a href="https://github.com/RaNd250/marites-backend" target="_blank" rel="noopener noreferrer" style={{ color: "#374151", fontSize: 12, textDecoration: "none" }}>Πηγαίος κώδικας (AGPL-3.0)</a>
          </footer>

        </div>
      </main>
    </Layout>
  );
}
