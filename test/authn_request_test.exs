defmodule Ueberauth.Strategy.SAML.AuthNRequestTest do
  use ExUnit.Case
  alias Ueberauth.Strategy.SAML.AuthNRequest

  test "request xml" do
    request = AuthNRequest.init("dest", "issuer", "cl", "2000-01-01T00:00:00Z" ) 
    |> AuthNRequest.to_xml 
    |> String.replace("\t", "") 
    |> String.replace("\n", "")
    
    assert request == File.read! "test/fixtures/authn_request.xml"
  end
end
