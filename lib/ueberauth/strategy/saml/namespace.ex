defmodule SAML.Namespace do
  import SweetXml

  def attach(xpath) do
    xpath
    |> add_namespace("samlp", "urn:oasis:names:tc:SAML:2.0:protocol")
    |> add_namespace("saml", "urn:oasis:names:tc:SAML:2.0:assertion")
    |> add_namespace("md", "urn:oasis:names:tc:SAML:2.0:metadata")
    |> add_namespace("ds", "http://www.w3.org/2000/09/xmldsig#")
  end
end