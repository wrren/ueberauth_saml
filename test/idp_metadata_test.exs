defmodule SAML.IDPMetadataTest do
  use ExUnit.Case
  alias SAML.IDPMetadata

  test "decode xml" do
    metadata = File.read!("./test/fixtures/idp_metadata.xml")
    |> IDPMetadata.decode

    assert metadata.entity_id == "https://idp.example.com/saml/metadata/1"
    assert metadata.login_location == "https://idp.example.com/trust/saml2/http-post/sso/1"
    assert metadata.certificate == :base64.decode("ABCD")
    assert metadata.tech.name == "IDP Support"
    assert metadata.org.name == "SAML Identity Provider"
  end
end
