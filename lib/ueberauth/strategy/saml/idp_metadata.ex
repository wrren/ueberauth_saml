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
  import SAML.Namespace, only: [attach: 1]

  defstruct org: %Organization{},
            tech: %Contact{},
            signed_requests: true,
            certificate: "",
            entity_id: "",
            login_location: "",
            logout_location: "",
            name_format: ""
  
  @doc """
  Given a string containing XML-encoded IDP metadata or an XML element tree, decode the XML into an IDP Metadata struct
  """
  def decode(xml_string) when is_binary(xml_string), do: parse(xml_string, namespace_conformant: true) |> decode
  def decode(xml) do
    xml   
    |> xpath(
        attach(~x"/md:EntityDescriptor"),
        entity_id: ~x"./@entityID"s,
        login_location: attach(~x"./md:IDPSSODescriptor/md:SingleSignOnService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']/@Location"s),
        logout_location: attach(~x"./md:IDPSSODescriptor/md:SingleLogoutService[@Binding='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST']/@Location"s),
        name_format: attach(~x"./md:IDPSSODescriptor/md:NameIDFormat/text()") |> transform_by(&IDPMetadata.nameid_map/1),
        certificate: attach(~x"./md:IDPSSODescriptor/md:KeyDescriptor[@use='signing']/ds:KeyInfo/ds:X509Data/ds:X509Certificate/text()") |> transform_by(fn x -> :base64.decode(:erlang.list_to_binary(x)) end),
        tech: attach(~x"./md:ContactPerson[@contactType='technical']") |> transform_by(&Contact.decode/1),
        org: attach(~x"./md:Organization") |> transform_by(&Organization.decode/1)
      )
    |> SAML.to_struct(IDPMetadata)
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