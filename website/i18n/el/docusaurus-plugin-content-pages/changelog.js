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
    <a href="/changelog/" lang="en" hrefLang="en" style={{ color: "#6b7280", textDecoration: "none" }} onClick={() => { try { localStorage.setItem("marites_lang_choice", "en"); } catch {} }}>EN</a>
    <span style={{ color: "#374151" }}>|</span>
    <span style={{ color: "#fff" }}>ΕΛ</span>
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
      title="Τι νέο υπάρχει"
      description="Τι νέο υπάρχει στο marit.es: οι τελευταίες λειτουργίες και διορθώσεις για τις εφαρμογές Core και Lite για Android και το web dashboard."
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
          <a href="/el/" style={{ display: "flex", alignItems: "center", gap: 10, textDecoration: "none" }}>
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
              Άνοιγμα App &#8594;
            </a>
          </div>
        </header>

        <div className="m-wrap">
          <div style={{ padding: "18px 0 6px" }}>
            <h1 style={{ color: "#fff", fontSize: 30, fontWeight: 900, margin: "0 0 8px", letterSpacing: "-0.5px" }}>
              Τι νέο υπάρχει
            </h1>
            <p style={{ color: C.dim, fontSize: 14, lineHeight: 1.6, margin: 0 }}>
              Οι τελευταίες λειτουργίες και διορθώσεις στις εφαρμογές Core και Lite για Android και στο
              web dashboard. Ενημερώνετε πάντα από το Google Play για να έχετε την πιο πρόσφατη έκδοση.
            </p>
          </div>

          <nav className="m-toc" style={{ marginTop: 22 }}>
            <a href="#core">Εφαρμογή Core</a>
            <a href="#lite">Εφαρμογή Lite</a>
            <a href="#web">Web dashboard</a>
          </nav>

          <Section id="core" color={C.purple} title="Εφαρμογή Core (Android)">
            <Rel version="0.1.94" date="Ιούλιος 2026" color={C.purple}>
              <li><b>Οι ειδοποιήσεις Sentry αναφέρουν πλέον το όνομα του οχήματος.</b> Οι ειδοποιήσεις &ldquo;Alarm Triggered&rdquo; δείχνουν ποιο όχημα ενεργοποίησε τον συναγερμό αντί για γενικό &ldquo;Your Tesla&rdquo;.</li>
              <li><b>Ώρες στη ζώνη ώρας του αυτοκινήτου.</b> Οι ώρες σε Sentry, διαδρομές και φορτίσεις εμφανίζονται πλέον στη ζώνη ώρας όπου βρίσκεται το αυτοκίνητο, όχι του κινητού σας.</li>
              <li><b>Ρυθμίσεις απόκρισης συναγερμού ανά όχημα.</b> Το honk/flash σε συναγερμό ρυθμίζεται τώρα ξεχωριστά για κάθε αυτοκίνητο αντί να ισχύει για όλα μαζί.</li>
              <li><b>Μεγαλύτερη, ζωντανή μπάρα μπαταρίας.</b> Η μπάρα είναι πιο χοντρή και παλλόμενη με μικρό εικονίδιο κεραυνού όσο φορτίζει.</li>
              <li><b>Καλύτερη προσαρμογή σε μικρότερες οθόνες.</b> Το UI πλέον κλιμακώνεται σωστά σε στενές οθόνες αντί να φαίνεται υπερμεγέθες.</li>
              <li><b>Υποστήριξη 16&nbsp;KB μεγέθους σελίδας μνήμης</b>, απαιτούμενη για νεότερες συσκευές Android.</li>
            </Rel>
            <Rel version="0.1.85" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Η ακύρωση της σύνδεσης Tesla δεν αφήνει πια κενή οθόνη.</b> Αν ξεκινήσετε τη σύνδεση Tesla και επιστρέψετε πίσω, η εφαρμογή γυρίζει τώρα στην οθόνη υποδοχής για να ξαναπροσπαθήσετε.</li>
            </Rel>
            <Rel version="0.1.84" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Ειδοποιήσεις στο Telegram.</b> Λάβετε τις ειδοποιήσεις Sentry και στο Telegram. Ανοίξτε <b>Ρυθμίσεις &rarr; Ειδοποιήσεις &rarr; Σύνδεση Telegram</b>, πατήστε Start στο bot, και συνδεθήκατε &mdash; χωρίς login Tesla. Επιλέξτε <b>ειδοποιήσεις κινητού, Telegram, ή και τα δύο</b>.</li>
              <li><b>Οι ειδοποιήσεις δείχνουν τώρα τη θέση του αυτοκινήτου.</b> Κάθε ειδοποίηση Telegram συνοδεύεται από πινέζα στον χάρτη με το πού βρίσκεται το αυτοκίνητο &mdash; πατήστε τη για οδηγίες.</li>
            </Rel>
            <Rel version="0.1.83" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Ενέργεια ανά διαδρομή.</b> Οι διαδρομές δείχνουν τώρα πόσες kWh χρησιμοποίησε κάθε ταξίδι, εκτιμώμενες από το δικό σας ιστορικό φόρτισης.</li>
              <li><b>Τα Στατιστικά επισημαίνονται ως Beta.</b> Τα εκτιμώμενα νούμερα στα Στατιστικά φέρουν ετικέτα Beta &mdash; βελτιώνονται ακόμα.</li>
              <li><b>Ευέλικτο τιμολόγιο φόρτισης.</b> Η νυχτερινή χρέωση είναι πλέον <b>μειωμένη</b> τιμή που μπορείτε να εφαρμόσετε σε έως τρία χρονικά παράθυρα την ημέρα.</li>
              <li><b>Ανανεωμένο λογότυπο</b> σε όλη την εφαρμογή.</li>
              <li><b>Τέλος οι διπλές ειδοποιήσεις.</b> Αν έχετε εγκατεστημένα και το Core και το Lite, η ειδοποίηση Sentry δεν φτάνει πια δύο φορές.</li>
            </Rel>
            <Rel version="0.1.73" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Ακριβέστερες διαδρομές &amp; φορτίσεις.</b> Διορθώθηκε η καταγραφή ώστε αποστάσεις, φορτίσεις και τιμές μπαταρίας να ταιριάζουν σωστά.</li>
              <li><b>Λιγότερες ημερομηνίες &laquo;Άγνωστο&raquo;</b> σε διαδρομές και φορτίσεις.</li>
              <li><b>Πιο ομαλές καρτέλες.</b> Το σύρσιμο ανάμεσα στις οθόνες δεν σπάει ούτε αναπηδά πια.</li>
            </Rel>
            <Rel version="0.1.70" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Χάρτες διαδρομών με στυλ οδήγησης.</b> Οι πορείες χρωματίζονται ανάλογα με τις απότομες επιταχύνσεις και τα φρεναρίσματα.</li>
              <li><b>Οι Ρυθμίσεις κυλούν πλήρως</b> σε μικρότερα κινητά, ώστε να μην κόβεται τίποτα.</li>
            </Rel>
            <Rel version="0.1.71" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Προβλεπόμενη αυτονομία.</b> Μια νέα κάρτα στα Στατιστικά εκτιμά πόσο μακριά μπορείτε πραγματικά να πάτε τώρα, μαθαίνοντας από τη δική σας οδήγηση σε διαφορετικές θερμοκρασίες &mdash; όχι απλώς από το ονομαστικό νούμερο του αυτοκινήτου.</li>
            </Rel>
            <Rel version="0.1.69" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Σύζευξη browser.</b> Συνδεθείτε στο web dashboard χωρίς Tesla &mdash; ανοίξτε <b>Ρυθμίσεις &rarr; Σύζευξη browser</b> και σκανάρετε το QR (ή πληκτρολογήστε τον κωδικό) στον υπολογιστή σας.</li>
            </Rel>
            <Rel version="0.1.68" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Phantom drain.</b> Μια νέα ενότητα στα Στατιστικά δείχνει πόση μπαταρία χάνετε όσο το αυτοκίνητο είναι παρκαρισμένο, ανά ημέρα και ανά τοποθεσία.</li>
            </Rel>
            <Rel version="0.1.67" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Ημερήσια &amp; νυχτερινή χρέωση φόρτισης.</b> Ορίστε προαιρετική νυχτερινή τιμή και τις ώρες που ισχύει· το κόστος κάθε φόρτισης μοιράζεται αυτόματα σε ημέρα και νύχτα.</li>
            </Rel>
            <Rel version="0.1.66" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Μονάδες &amp; μορφή ημερομηνίας, όπως τις θέλετε.</b> Κρατήστε το <b>Αυτόματο</b> για να ακολουθεί το αυτοκίνητο, ή ορίστε ανεξάρτητα μονάδες (μετρικές/αγγλοσαξονικές), 12ωρη/24ωρη ώρα και μορφή ημερομηνίας (DD/MM, MM/DD ή ISO).</li>
            </Rel>
            <Rel version="0.1.65" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Κόστος φόρτισης.</b> Ορίστε την τιμή ρεύματος και το νόμισμά σας στις Ρυθμίσεις, και κάθε φόρτιση δείχνει τώρα τι κόστισε.</li>
            </Rel>
            <Rel version="0.1.64" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Υγεία μπαταρίας.</b> Μια νέα ενότητα στα Στατιστικά δείχνει πόση χωρητικότητα μπαταρίας έχετε διατηρήσει με τον καιρό και την τάση της αυτονομίας σας.</li>
            </Rel>
            <Rel version="0.1.63" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Επέστρεψαν οι διαδρομές &amp; οι φορτίσεις.</b> Οι διαδρομές και οι φορτίσεις σας καταγράφονται και εμφανίζονται ξανά, με απόσταση, διάρκεια και μπαταρία που προστέθηκε.</li>
              <li><b>Ασφαλέστερη διαγραφή.</b> Σύρετε μια διαδρομή, φόρτιση ή συμβάν Sentry για να εμφανιστεί το κουμπί Διαγραφή, και πατήστε για επιβεβαίωση &mdash; τέλος οι κατά λάθος διαγραφές.</li>
              <li><b>Μαζικές ενέργειες.</b> Επιλέξτε και διαγράψτε πολλές διαδρομές μαζί.</li>
              <li><b>Χωρίς αναλαμπή login.</b> Η εφαρμογή δεν δείχνει πια στιγμιαία την οθόνη &laquo;Σύνδεση με Tesla&raquo; όταν είστε ήδη συνδεδεμένοι.</li>
            </Rel>
            <Rel version="0.1.62" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Μονάδες, όπως τις θέλετε.</b> Επιλέξτε Αυτόματο (ακολουθεί το αυτοκίνητο), Μετρικές ή Αγγλοσαξονικές, καθώς και 12ωρη ή 24ωρη ώρα, στις Ρυθμίσεις.</li>
            </Rel>
            <Rel version="0.1.61" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Τέλος οι κενές θερμοκρασίες.</b> Η εσωτερική/εξωτερική θερμοκρασία κρατά τώρα την τελευταία γνωστή τιμή με ένδειξη &laquo;πριν x λεπτά&raquo; όταν το αυτοκίνητο κοιμάται.</li>
            </Rel>
            <Rel version="0.1.60" date="Ιούνιος 2026" color={C.purple}>
              <li><b>Πιο ασφαλής σύνδεση.</b> Ανανεωμένο login Tesla με κωδικό μίας χρήσης και επαληθευμένα app links.</li>
              <li><b>Μείνετε συνδεδεμένοι περισσότερο.</b> Η διαχείριση συνεδριών ξαναδουλεύτηκε ώστε να σας ζητείται επανασύνδεση πολύ πιο σπάνια.</li>
            </Rel>
          </Section>

          <Section id="lite" color={C.green} title="Εφαρμογή Lite (Android)">
            <Rel version="0.1.61" date="Ιούλιος 2026" color={C.green}>
              <li><b>Παράταση ειδοποιήσεων.</b> Για να παραμείνουν ενεργές οι ειδοποιήσεις Sentry, ανοίξτε το Lite και πατήστε <b>Παράταση</b>, κρατώντας για περίπου 8 δευτερόλεπτα, τουλάχιστον κάθε 48 ώρες.</li>
            </Rel>
            <Rel version="0.1.58" date="Ιούλιος 2026" color={C.green}>
              <li><b>Η διαφήμιση μετακινήθηκε ψηλότερα.</b> Εμφανίζεται πλέον ακριβώς κάτω από τον διακόπτη Sentry, πάντα ορατή χωρίς κύλιση.</li>
              <li><b>Οι άδειες ανοιχτού κώδικα μετακινήθηκαν</b> μέσα στις Ρυθμίσεις, σε νέα ενότητα About.</li>
              <li><b>Ένας λογαριασμός, μία εφαρμογή τη φορά.</b> Η σύνδεση στο Lite μπλοκάρεται πλέον όσο ο ίδιος λογαριασμός Tesla είναι συνδεδεμένος στο Core, με σύνδεσμο για άνοιγμα του Core.</li>
              <li><b>Οι ειδοποιήσεις Sentry αναφέρουν πλέον το όνομα του οχήματος.</b></li>
              <li><b>Μεγαλύτερη, ζωντανή μπάρα μπαταρίας</b> με παλλόμενο εικονίδιο κεραυνού όσο φορτίζει.</li>
              <li><b>Καλύτερη προσαρμογή σε μικρότερες οθόνες.</b></li>
            </Rel>
            <Rel version="0.1.52" date="Ιούνιος 2026" color={C.green}>
              <li><b>Ανανεωμένο λογότυπο.</b></li>
              <li><b>Κρατήστε ενεργές τις ειδοποιήσεις.</b> Ανοίξτε το Lite τουλάχιστον μία φορά κάθε 48 ώρες για να συνεχίσουν οι ειδοποιήσεις Sentry &mdash; ένα γρήγορο άνοιγμα αρκεί.</li>
            </Rel>
            <Rel version="0.1.47" date="Ιούνιος 2026" color={C.green}>
              <li><b>Οι μονάδες ακολουθούν το αυτοκίνητο.</b> Το Lite ταιριάζει πλέον πάντα αυτόματα με τις ρυθμίσεις μονάδων του αυτοκινήτου σας.</li>
            </Rel>
            <Rel version="0.1.46" date="Ιούνιος 2026" color={C.green}>
              <li><b>Χωρίς αναλαμπή login.</b> Τέλος η στιγμιαία οθόνη &laquo;Σύνδεση με Tesla&raquo; στο άνοιγμα όταν είστε ήδη συνδεδεμένοι.</li>
            </Rel>
            <Rel version="0.1.45" date="Ιούνιος 2026" color={C.green}>
              <li><b>Μονάδες &amp; μορφή ώρας.</b> Επιλέξτε Αυτόματο / Μετρικές / Αγγλοσαξονικές και 12ωρη ή 24ωρη ώρα.</li>
            </Rel>
            <Rel version="0.1.44" date="Ιούνιος 2026" color={C.green}>
              <li><b>Τέλος οι κενές θερμοκρασίες.</b> Δείχνει την τελευταία γνωστή θερμοκρασία με ένδειξη παλαιότητας όταν το αυτοκίνητο κοιμάται.</li>
            </Rel>
            <Rel version="0.1.43" date="Ιούνιος 2026" color={C.green}>
              <li><b>Πιο ασφαλής σύνδεση</b> και <b>μεγαλύτερες συνεδρίες</b>, ώστε οι ειδοποιήσεις να συνεχίζουν χωρίς συχνά re-login.</li>
              <li><b>Επιλέξτε το όχημά σας.</b> Διαλέξτε ποιο ένα αυτοκίνητο παρακολουθεί και σας ειδοποιεί το Lite.</li>
            </Rel>
          </Section>

          <Section id="web" color={C.red} title="Web dashboard (app.marit.es)">
            <Rel version="" date="Ιούλιος 2026" color={C.red}>
              <li><b>Απόδοση ανά διαδρομή.</b> Οι διαδρομές δείχνουν τώρα kWh/100km μαζί με απόσταση και ενέργεια.</li>
              <li><b>Θερμοκρασία καμπίνας &amp; εξωτερικού ανά διαδρομή.</b> Κάθε διαδρομή δείχνει τη μέση εσωτερική και εξωτερική θερμοκρασία.</li>
              <li><b>Διόρθωση ταξινόμησης διαδρομών.</b> Η ταξινόμηση στη λίστα Drives (π.χ. Μέγιστη ταχύτητα) πλέον αναδιατάσσει πραγματικά τη λίστα, όχι μόνο την εξαγωγή.</li>
              <li><b>Ειδοποιήσεις ολοκλήρωσης φόρτισης.</b> Λάβετε ειδοποίηση (και στο Telegram, αν είναι συνδεδεμένο) όταν ολοκληρώνεται μια φόρτιση &mdash; ενεργοποιήστε το από Ρυθμίσεις &rarr; Ειδοποιήσεις. Διαθέσιμο στο web dashboard και στην εφαρμογή Core.</li>
            </Rel>
            <Rel version="" date="Ιούνιος 2026" color={C.red}>
              <li><b>Ενέργεια ανά διαδρομή.</b> Κάθε διαδρομή δείχνει τώρα τις kWh που χρησιμοποίησε, εκτιμώμενες από το ιστορικό φόρτισής σας.</li>
              <li><b>Κατάσταση φόρτισης με μια ματιά.</b> Το dashboard δείχνει τώρα πότε φορτίζει το αυτοκίνητο, με ζωντανή ισχύ.</li>
              <li><b>Ευέλικτο τιμολόγιο φόρτισης.</b> Η νυχτερινή χρέωση είναι πλέον μειωμένη τιμή που εφαρμόζεται σε έως τρία χρονικά παράθυρα την ημέρα.</li>
              <li><b>Τα Στατιστικά επισημαίνονται ως Beta</b> &mdash; τα εκτιμώμενα νούμερα βελτιώνονται ακόμα.</li>
              <li><b>Ανανεωμένο λογότυπο.</b></li>
              <li><b>Προβλεπόμενη αυτονομία.</b> Τα Στατιστικά εκτιμούν τώρα την πραγματική σας αυτονομία από το ιστορικό οδήγησης και την τρέχουσα θερμοκρασία.</li>
              <li><b>Υγεία μπαταρίας &amp; <a href="/el/phantom-drain/">phantom drain</a>.</b> Τα Στατιστικά δείχνουν τη διατήρηση χωρητικότητας στον χρόνο και πόση μπαταρία χάνετε παρκαρισμένοι &mdash; όπως στην εφαρμογή Core.</li>
              <li><b>Κόστος φόρτισης &amp; τιμολόγιο.</b> Ορίστε την τιμή ρεύματος (με προαιρετική νυχτερινή χρέωση) στη νέα σελίδα Ρυθμίσεων και δείτε τι κοστίζει κάθε φόρτιση.</li>
              <li><b>Μονάδες &amp; μορφή ώρας.</b> Επιλέξτε μετρικές ή αγγλοσαξονικές και 12ωρη ή 24ωρη ώρα στις Ρυθμίσεις.</li>
              <li><b>Χάρτες διαδρομών με στυλ οδήγησης.</b> Οι πορείες χρωματίζονται ανάλογα με απότομες επιταχύνσεις και φρεναρίσματα, με μετρητή για το καθένα.</li>
              <li><b>Εξαγωγή των δεδομένων σας.</b> Κατεβάστε Διαδρομές και Φορτίσεις σε CSV, Excel ή PDF, με εύρος ημερομηνιών και ταξινόμηση.</li>
              <li><b>Διορθώθηκαν οι χάρτες διαδρομών.</b> Οι πορείες εμφανίζονται ξανά στον χάρτη, ακόμα και χωρίς αποθηκευμένες διευθύνσεις.</li>
              <li><b>Καθαρότερο admin &amp; πλοήγηση.</b> Αφαιρέθηκε η αχρησιμοποίητη σελίδα ειδοποιήσεων (οι ειδοποιήσεις είναι στο κινητό)· η προβολή admin δείχνει τώρα τελευταία σύνδεση, αυτοκίνητα και πλάνο.</li>
              <li><b>Ζωντανές θερμοκρασίες &amp; αυτονομία</b> εμφανίζονται ξανά στο dashboard.</li>
              <li><b>Ιστορικό διαδρομών &amp; φορτίσεων</b> καταγράφεται και εμφανίζεται ξανά.</li>
              <li><b>Σαφέστερες σελίδες σύνδεσης &amp; ρυθμίσεων</b>, και σωστός τίτλος σελίδας.</li>
            </Rel>
          </Section>

          <p style={{ color: C.dim, fontSize: 12.5, lineHeight: 1.6, margin: "4px 0 10px" }}>
            Ψάχνετε πώς λειτουργούν όλα αυτά; Δείτε τις <a href="/el/faq/" style={{ color: C.purple, textDecoration: "none" }}>Συχνές ερωτήσεις &amp; Οδηγίες</a>.
          </p>
        </div>

        <footer style={{
          padding: "20px 24px 40px", textAlign: "center",
          display: "flex", gap: 20, justifyContent: "center", flexWrap: "wrap",
          borderTop: "1px solid rgba(255,255,255,0.05)", marginTop: 20,
        }}>
          <a href="/el/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Αρχική</a>
          <a href="/el/faq/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>FAQ</a>
          <a href="/privacy/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Πολιτική Απορρήτου</a>
          <a href="/terms/" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Όροι Χρήσης</a>
          <a href="mailto:admin@marit.es" style={{ color: C.dim, fontSize: 12, textDecoration: "none" }}>Επικοινωνία</a>
        </footer>
      </main>
    </Layout>
  );
}
