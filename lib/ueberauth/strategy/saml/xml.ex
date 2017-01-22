defmodule SAML.XML do
  @moduledoc"""
  Exposes function for signing XML documents and verifying signatures
  """
  import Record

  defrecord :rsa_private_key, extract(:RSAPrivateKey, from_lib: "public_key/include/public_key.hrl")

  def sign(root, private_key = rsa_private_key(), certificate) when is_binary(certificate) do
    
  end
end