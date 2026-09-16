defmodule TeslaApi.ErrorTest do
  use ExUnit.Case, tag: :tesla_api

  alias TeslaApi.Error

  describe "redact_env/1" do
    test "redacts access_token from query params" do
      env = %Tesla.Env{
        method: :GET,
        url: "https://example.com",
        query: [{"access_token", "secret123"}, {"page", "1"}],
        headers: [],
        opts: []
      }

      redacted = Error.redact_env(env)
      assert Enum.find_value(redacted.query, fn {k, v} -> k == "access_token" and v == "[redacted]" end)
      assert Enum.find_value(redacted.query, fn {k, v} -> k == "page" and v == "1" end)
    end

    test "redacts authorization header" do
      env = %Tesla.Env{
        method: :GET,
        url: "https://example.com",
        query: [],
        headers: [{"authorization", "Bearer secret"}, {"content-type", "application/json"}],
        opts: []
      }

      redacted = Error.redact_env(env)
      auth = Enum.find(redacted.headers, fn {k, _} -> k == "authorization" end)
      assert auth == {"authorization", "[redacted]"}
      content_type = Enum.find(redacted.headers, fn {k, _} -> k == "content-type" end)
      assert content_type == {"content-type", "application/json"}
    end

    test "returns non-Tesla.Env unchanged" do
      assert Error.redact_env("not an env") == "not an env"
      assert Error.redact_env(nil) == nil
    end
  end

  describe "redact_pairs/1" do
    test "redacts sensitive keys" do
      pairs = [access_token: "secret123", refresh_token: "tok456", page: 1]
      redacted = Error.redact_pairs(pairs)

      assert Keyword.get(redacted, :access_token) == "[redacted]"
      assert Keyword.get(redacted, :refresh_token) == "[redacted]"
      assert Keyword.get(redacted, :page) == 1
    end

    test "handles binary keys" do
      pairs = [{"access_token", "secret"}, {"name", "test"}]
      redacted = Error.redact_pairs(pairs)

      assert {"access_token", "[redacted]"} in redacted
      assert {"name", "test"} in redacted
    end

    test "handles non-list unchanged" do
      assert Error.redact_pairs("string") == "string"
    end
  end

  describe "sensitive_key?/1" do
    test "matches access_token" do
      assert Error.sensitive_key?("access_token")
      assert Error.sensitive_key?("Access_Token")
    end

    test "matches refresh_token" do
      assert Error.sensitive_key?("refresh_token")
    end

    test "matches token" do
      assert Error.sensitive_key?("token")
    end

    test "matches authorization" do
      assert Error.sensitive_key?("authorization")
    end

    test "does not match non-sensitive keys" do
      refute Error.sensitive_key?("page")
      refute Error.sensitive_key?("name")
      refute Error.sensitive_key?("access")
    end
  end

  describe "sensitive_header?/1" do
    test "matches authorization header" do
      assert Error.sensitive_header?("authorization")
      assert Error.sensitive_header?("Authorization")
      assert Error.sensitive_header?("AUTHORIZATION")
    end

    test "does not match other headers" do
      refute Error.sensitive_header?("content-type")
      refute Error.sensitive_header?("user-agent")
    end
  end

  describe "redacted/1" do
    test "returns new error with redacted env" do
      error = %Error{
        reason: :unknown,
        message: "test error",
        env: %Tesla.Env{
          method: :GET,
          url: "https://example.com?access_token=secret",
          query: [{"access_token", "secret"}],
          headers: [{"authorization", "Bearer tok"}],
          opts: []
        }
      }

      redacted = Error.redacted(error)
      assert redacted.env.query == [{"access_token", "[redacted]"}]
      assert redacted.env.headers == [{"authorization", "[redacted]"}]
      assert redacted.message == "test error"
    end
  end

  describe "message/1" do
    test "returns binary message" do
      error = %Error{reason: :unknown, message: "something went wrong"}
      assert Error.message(error) == "something went wrong"
    end

    test "inspects non-binary reason" do
      error = %Error{reason: :too_many_request, message: nil}
      assert Error.message(error) == ":too_many_request"
    end
  end

  describe "into/2" do
    test "converts {:ok, env} with error body" do
      env = %Tesla.Env{
        status: 403,
        body: %{"error" => "account disabled: test"},
        headers: [],
        query: [],
        opts: [],
        method: :GET,
        url: "https://example.com"
      }

      assert {:error, %Error{reason: :unknown}} = Error.into({:ok, env})
    end

    test "converts {:error, atom} to Error" do
      assert {:error, %Error{reason: :network}} = Error.into({:error, :network})
    end

    test "converts {:error, binary} to Error" do
      assert {:error, %Error{reason: :unknown, message: "connection refused"}} =
               Error.into({:error, "connection refused"})
    end
  end
end
