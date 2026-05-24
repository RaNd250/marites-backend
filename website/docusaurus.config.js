module.exports = {
  title: "marit.es",
  tagline: "Never Miss What Your Tesla Sees",
  url: "https://app.marit.es",
  baseUrl: "/",
  favicon: "img/logo.png",
  organizationName: "RaNd250",
  projectName: "marites",
  themeConfig: {
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
