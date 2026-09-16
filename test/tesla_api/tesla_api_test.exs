defmodule TeslaApiTest do
  use ExUnit.Case, tag: :tesla_api

  alias TeslaApi

  describe "redact_url/1" do
    test "redacts access_token from query string" do
      url = "https://example.com?access_token=secret123&page=1"
      redacted = TeslaApi.redact_url(url)
      # URI.encode_query percent-encodes the brackets in "[redacted]" -- the
      # value is still fully redacted, just URL-safe (%5B...%5D), so assert
      # against the actual encoded form rather than the literal placeholder.
      assert redacted == "https://example.com?access_token=%5Bredacted%5D&page=1"
      refute redacted =~ "secret123"
    end

    test "redacts refresh_token from query string" do
      url = "https://example.com?refresh_token=tok456"
      redacted = TeslaApi.redact_url(url)
      assert redacted == "https://example.com?refresh_token=%5Bredacted%5D"
      refute redacted =~ "tok456"
    end

    test "preserves non-sensitive query params" do
      url = "https://example.com?command=wake_up&lat=37.5"
      redacted = TeslaApi.redact_url(url)
      assert redacted == url
    end

    test "handles URL without query string" do
      url = "https://example.com/path"
      assert TeslaApi.redact_url(url) == url
    end

    test "handles nil gracefully" do
      assert TeslaApi.redact_url(nil) == nil
    end
  end

  describe "sensitive_query_param?/1" do
    test "matches access_token" do
      assert TeslaApi.sensitive_query_param?("access_token")
      assert TeslaApi.sensitive_query_param?("Access_Token")
    end

    test "matches refresh_token" do
      assert TeslaApi.sensitive_query_param?("refresh_token")
    end

    test "matches token" do
      assert TeslaApi.sensitive_query_param?("token")
    end

    test "does not match other params" do
      refute TeslaApi.sensitive_query_param?("command")
      refute TeslaApi.sensitive_query_param?("lat")
      refute TeslaApi.sensitive_query_param?("vin")
    end
  end

  describe "format_log/3" do
    test "returns formatted log string" do
      request = %Tesla.Env{method: :GET, url: "https://example.com", query: [], headers: [], opts: []}
      response = {:ok, %Tesla.Env{status: 200}}
      time = 1500

      result = TeslaApi.format_log(request, response, time)
      assert is_list(result)
      # format_log/3 returns an iolist (a `:io_lib.format` charlist is one of
      # its elements), so exact `in`-list membership on binaries is wrong --
      # flatten it to a binary first and check substrings.
      log = IO.iodata_to_binary(result)
      assert log =~ "GET"
      assert log =~ "1.500"
      assert log =~ "ms"
    end

    test "handles error response" do
      request = %Tesla.Env{method: :GET, url: "https://example.com", query: [], headers: [], opts: []}
      response = {:error, :timeout}
      time = 500

      result = TeslaApi.format_log(request, response, time)
      assert is_list(result)
      assert IO.iodata_to_binary(result) =~ "error"
    end
  end
end
