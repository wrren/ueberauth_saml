defmodule SAML.XMLTest do
  use ExUnit.Case
  alias SAML.XML
  import Record
  defrecord :rsa_private_key, extract(:RSAPrivateKey, from_lib: "public_key/include/public_key.hrl")

  test "sign xml" do
    assert XML.sign("", rsa_private_key, "cert") == :ok
  end
end