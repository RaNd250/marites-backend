module.exports = {
  title: "marit.es",
  tagline: "Self-hosted Tesla monitoring for your Android phone",
  url: "https://app.marit.es",
  baseUrl: "/",
  favicon: "img/favicon.ico",
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
      items: [
        {
          href: "https://github.com/RaNd250/marites",
          label: "GitHub",
          position: "right",
        },
      ],
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
