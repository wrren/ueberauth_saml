defmodule SAML.CacheTest do
  use ExUnit.Case
  alias SAML.Cache

  test "store and retrieve private keys" do
    Cache.start_link()
    Cache.private_key("key_path", "key_data")
    assert Cache.private_key("key_path") == "key_data"
    Cache.stop()
  end

  test "store and retrieve certificates" do
    Cache.start_link()
    Cache.cert("cert_path", "cert_data")
    assert Cache.cert("cert_path") == "cert_data"
    Cache.stop()
  end

  test "store and retrieve IDP metadata" do
    Cache.start_link()
    Cache.metadata("url", "metadata")
    assert Cache.metadata("url") == "metadata"
    Cache.stop()
  end

  test "mark assertion as seen" do
    Cache.start_link()
    Cache.assertion_seen("digest", false)
    assert Cache.assertion_seen?("digest") == false
    Cache.assertion_seen("digest", true)
    assert Cache.assertion_seen?("digest") == true
    Cache.stop()
  end
end
