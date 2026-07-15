import React, { useEffect } from "react";
import { useHistory, useLocation } from "@docusaurus/router";
import ExecutionEnvironment from "@docusaurus/ExecutionEnvironment";

const CHOICE_KEY = "marites_lang_choice";

export default function Root({ children }) {
  const history = useHistory();
  const location = useLocation();

  useEffect(() => {
    if (!ExecutionEnvironment.canUseDOM) return;

    let choice;
    try {
      choice = window.localStorage.getItem(CHOICE_KEY);
    } catch {
      return; // localStorage unavailable (private mode etc) — skip silently
    }
    if (choice) return; // user already made an explicit choice, never override

    const onEl = location.pathname.startsWith("/el/") || location.pathname === "/el";
    if (onEl) return; // already on the Greek site

    const browserLang = (navigator.language || navigator.languages?.[0] || "").toLowerCase();
    if (!browserLang.startsWith("el")) return;

    history.replace("/el" + location.pathname + location.search + location.hash);
  }, [location, history]);

  return <>{children}</>;
}
