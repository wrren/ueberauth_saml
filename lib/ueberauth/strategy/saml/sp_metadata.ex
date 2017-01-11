defmodule SAML.SPMetadata do
  @moduledoc """
  Provides a struct and functions for generating service
  provider metadata XML.
  """
  alias SAML.SPMetadata
  alias SAML.Organization
  alias SAML.Contact

  import XmlBuilder

  defstruct org: %Organization{},
            tech: %Contact{},
            signed_requests: true,
            signed_assertions: true,
            certificate: "",
            cert_chain: [],
            entity_id: "",
            consumer_location: "",
            logout_location: ""

  def init() do
    config = Application.get_env(:ueberauth, SAML.Metadata)
    
  end 

  def to_xml(%SPMetadata{} = meta) do
    element("md:EntityDescriptor", %{ "xmlns:md": "urn:oasis:names:tc:SAML:2.0:metadata",
                                      "xmlns:saml": "urn:oasis:names:tc:SAML:2.0:assertion",
                                      "xmlns:ds": "http://www.w3.org/2000/09/xmldsig#",
                                      "entityID": meta.entity_id }, [
        
        meta.org |> Organization.to_elements,
        meta.tech |> Contact.to_elements,
    ]) |> generate
  end
end