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
            metadata_url: "",
            logout_location: ""

  def init(options) do
    struct(__MODULE__, options)  
  end 

  def to_xml(%SPMetadata{} = meta) do
    additional = case meta.logout_location do
      "" -> []
      location ->
        [element("md:SingleLogoutService", %{ "isDefault": true,
                                              "index": "0",
                                              "Binding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-REDIRECT",
                                              "Location": location }, [] ),
         element("md:SingleLogoutService", %{ "index": "1",
                                              "Binding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                                              "Location": location }, [] )]
    end

    element("md:EntityDescriptor", %{ "xmlns:md": "urn:oasis:names:tc:SAML:2.0:metadata",
                                      "xmlns:saml": "urn:oasis:names:tc:SAML:2.0:assertion",
                                      "xmlns:ds": "http://www.w3.org/2000/09/xmldsig#",
                                      "entityID": meta.entity_id }, [
        
        meta.org |> Organization.to_elements,
        meta.tech |> Contact.to_elements,
        element("md:SPSSODescriptor", %{ "protocolSupportEnumeration": "urn:oasis:names:tc:SAML:2.0:protocol",
                                          "AuthnRequestsSigned": meta.signed_requests,
                                          "WantAssertionsSigned": meta.signed_assertions}, [
          element("md:AssertionConsumerService", %{ "isDefault": true,
                                                    "index": "0",
                                                    "Binding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                                                    "Location": meta.consumer_location }, []),
          element("md:AttributeConsumingService", %{ "isDefault": true,
                                                     "index": "0" }, [
            element("md:ServiceName", %{}, "SAML SP")
          ])

        ])
     | additional]) |> generate
  end
end