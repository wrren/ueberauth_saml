defmodule Ueberauth.Strategy.SAML.AuthNRequestTest do
  use ExUnit.Case
  alias Ueberauth.Strategy.SAML.AuthNRequest

  test "request xml" do
    request = AuthNRequest.init("dest", "issuer", "cl", "2000-01-01T00:00:00Z" )
    assert request |> AuthNRequest.to_xml() == "<saml:AuthnRequest AssertionConsumerServiceURL=\"cl\" Destination=\"dest\" IssueInstant=\"2000-01-01T00:00:00Z\" ProtocolBinding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Version=\"2.0\" xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\">\n\t<saml:Issuer>issuer</saml:Issuer>\n\t<saml:Subject>\n\t\t<saml:SubjectConfirmation Method=\"urn:oasis:names:tc:SAML:2.0:cm:bearer\"/>\n\t</saml:Subject>\n</saml:AuthnRequest>"
  end
end
