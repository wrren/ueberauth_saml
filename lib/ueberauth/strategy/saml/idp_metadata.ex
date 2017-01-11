defmodule SAML.IDPMetadata do
  @moduledoc """
  Provides a struct and functions for retrieving identity
  provider metadata.
  """
  alias SAML.IDPMetadata
  alias SAML.Organization
  alias SAML.Contact
  
  require HTTPoison.Response
  require HTTPoison.Error

  import SweetXml

  defstruct org: %Organization{},
            tech: %Contact{},
            signed_requests: true,
            certificate: "",
            entity_id: "",
            login_location: "",
            logout_location: "",
            name_format: ""
  def ns(xpath) do
    xpath
    |> add_namespace("samlp", "urn:oasis:names:tc:SAML:2.0:protocol")
    |> add_namespace("saml", "urn:oasis:names:tc:SAML:2.0:assertion")
    |> add_namespace("md", "urn:oasis:names:tc:SAML:2.0:metadata")
    |> add_namespace("ds", "http://www.w3.org/2000/09/xmldsig#")
  end

  def decode(xml_string) do
    doc = parse(xml_string, namespace_conformant: true)    
    struct(IDPMetadata, doc
    |> xpath(
        ns(~x"/md:EntityDescriptor"),
        entity_id: ~x"./@entityID"s,
        login_location: ns(~x"./md:IDPSSODescriptor/md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']/@Location"s),
        logout_location: ns(~x"./md:IDPSSODescriptor/md:SingleLogoutService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']/@Location"s),
        name_format: ns(~x"./md:IDPSSODescriptor/md:NameIDFormat/text()") |> transform_by(&IDPMetadata.nameid_map/1),
        certificate: ns(~x"./md:IDPSSODescriptor/md:KeyDescriptor[@use='signing']/ds:KeyInfo/ds:X509Data/ds:X509Certificate/text()") |> transform_by(fn x -> :base64.decode(:erlang.list_to_binary(x)) end),
        tech: ns(~x"./md:ContactPerson[@contactType='technical']") |> transform_by(&IDPMetadata.decode_contact/1)
      )
    )
  end


  def decode_contact(nil), do: %Contact{}
  def decode_contact(xpath_node) do
    first_name = xpath_node |> xpath(ns(~x"/md:ContactPerson/md:GivenName/text()"S))
    last_name = xpath_node |> xpath(ns(~x"/md:ContactPerson/md:SurName/text()"S))
    email = xpath_node |>xpath(ns(~x"/md:ContactPerson/md:EmailAddress/text()"S))

    struct(Contact, %{email: email, name: Enum.join([first_name, last_name], " ")})
  end

  def decode_org(nil), do: %Organization{}
  def decode_org(xpath_node) do
    struct(Contact, xpath_node
    |> xpath(
        ns(~x"/md:Organization"),
        name: ns(~x"./md:OrganizationName/text()"S),
        display_name: ns(~x"./md:OrganizationDisplayName/text()"S),
        url: ns(~x"./md:OrganizationURL/text()"S)
      )
    )
  end

  def nameid_map("urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"), do: :email
  def nameid_map("urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName"), do: :x509
  def nameid_map("urn:oasis:names:tc:SAML:1.1:nameid-format:WindowsDomainQualifiedName"), do: :windows
  def nameid_map("urn:oasis:names:tc:SAML:2.0:nameid-format:kerberos"), do: :krb
  def nameid_map("urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"), do: :persistent
  def nameid_map("urn:oasis:names:tc:SAML:2.0:nameid-format:transient"), do: :transient
  def nameid_map(s) when is_list(s), do: :unknown

  def load(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: xml}} ->
        decode(xml)
      {:ok, %HTTPoison.Response{}} ->
        {:error, :request_error}
      {:error,  %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def load!(url) do
    case load(url) do
      {:ok, metadata} -> metadata
      {:error, error} -> raise HTTPoison.Error, error
    end
  end
end