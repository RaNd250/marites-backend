defmodule MaritesWeb.Cldr do
  use Cldr,
    gettext: MaritesWeb.Gettext,
    locales: [],
    otp_app: :marites,
    providers: [],
    generate_docs: false,
    force_locale_download:
      Mix.env() == :prod and System.get_env("SKIP_LOCALE_DOWNLOAD") != "true",
    data_dir: System.get_env("LOCALES")
end
