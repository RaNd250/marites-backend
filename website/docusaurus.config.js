module.exports = {
  title: "marit.es",
  tagline: "Never Miss What Your Tesla Sees",
  url: "https://marit.es",
  baseUrl: "/",
  // Apache serves directory indexes with a 301 to the trailing-slash URL,
  // so emit trailing-slash links/canonicals/sitemap entries to match.
  trailingSlash: true,
  favicon: "img/favicon.ico",
  organizationName: "RaNd250",
  projectName: "marites",
  i18n: {
    defaultLocale: "en",
    locales: ["en", "el"],
    localeConfigs: {
      en: { label: "EN", htmlLang: "en" },
      el: { label: "ΕΛ", htmlLang: "el" },
    },
  },
  headTags: [
    { tagName: "link", attributes: { rel: "icon", type: "image/x-icon", href: "/img/favicon.ico" } },
    { tagName: "link", attributes: { rel: "icon", type: "image/png", sizes: "32x32", href: "/img/icon-32.png" } },
    { tagName: "link", attributes: { rel: "icon", type: "image/png", sizes: "16x16", href: "/img/icon-16.png" } },
    { tagName: "link", attributes: { rel: "apple-touch-icon", sizes: "180x180", href: "/img/icon-180.png" } },
    { tagName: "link", attributes: { rel: "manifest", href: "/site.webmanifest" } },
    { tagName: "meta", attributes: { name: "theme-color", content: "#0a0a0f" } },
  ],
  themeConfig: {
    image: "img/social-card.png",
    metadata: [
      { property: "og:site_name", content: "marit.es" },
      {
        name: "keywords",
        content:
          "tesla sentry alerts, tesla companion app android, tesla drive history, tesla charge tracking, sentry mode notifications, tesla fleet telemetry",
      },
    ],
    navbar: {
      title: "",
      logo: {
        alt: "marit.es",
        src: "img/logo.png",
        style: { height: "36px" },
      },
      items: [],
    },
    prism: {
      additionalLanguages: ["elixir"],
    },
    colorMode: {
      defaultMode: "dark",
      disableSwitch: true,
      respectPrefersColorScheme: false,
    },
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: false,
        blog: false,
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      },
    ],
  ],
};
