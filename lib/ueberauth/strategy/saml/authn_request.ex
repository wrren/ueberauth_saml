defmodule SAML.AuthNRequest do
  @moduledoc """
  Exposes a struct and functions for dealing with SAML 2.0 authn requests
  """
  
  defstruct version: "2.0",
            id: "",
            issue_instant: "",
            destination: "",
            callback_url: ""

  alias SAML.AuthNRequest
  import XmlBuilder

  @doc """
  Initialize an AuthNRequest struct with the specified attributes
  idp_metadata: Identity provider metadata
  sp_metadata: Service Provider Metadata
  callback_url: Callback URI on the service provider that will consumer the response
  issue_instant: ISO8601 string describing the point in time at which the request was created
  """
  def init(idp_metadata, sp_metadata, callback_url, id \\ UUID.uuid1(), %DateTime{} = issue_instant) do
    %AuthNRequest{  issue_instant: SAML.datetime_format(issue_instant),
                    id: id,
                    destination: idp_metadata.login_location,
                    callback_url: callback_url }
  end

  @doc """
  Initialize an AuthNRequest struct with the specified attributes
  idp_metadata: Identity provider metadata
  sp_metadata: Service Provider Metadata
  callback_url: Callback URI on the service provider that will consumer the response
  """
  def init(idp_metadata, sp_metadata, callback_url) do
    init(idp_metadata, sp_metadata, callback_url, UUID.uuid1(), DateTime.utc_now())
  end

  @doc """
  Convert an AuthNRequest struct to an XML string suitable for transmission to an IDP
  """
  def to_xml(%AuthNRequest{} = request) do
    request |> to_elements |> generate
  end

  @doc """
  Generate an AuthNRequest XML element tree using the given request struct
  """
  def to_elements(%AuthNRequest{} = request) do
    element("samlp:AuthnRequest", %{ "xmlns:samlp": "urn:oasis:names:tc:SAML:2.0:protocol",
                                    "xmlns:saml": "urn:oasis:names:tc:SAML:2.0:assertion",
                                    "Version": request.version,
                                    "IssueInstant": request.issue_instant,
                                    "Destination": request.destination,
                                    "ID": request.id,
                                    "ProtocolBinding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                                    "AssertionConsumerServiceURL": request.callback_url }, [
      element("saml:Issuer", %{}, "ueberauth_saml" ),
      element("saml:Subject", %{}, [
        element("saml:SubjectConfirmation", %{"Method": "urn:oasis:names:tc:SAML:2.0:cm:bearer"}, [])
      ])
    ]) 
  end

  def to_uri(%AuthNRequest{destination: dest} = request) do
    to_elements(request) |> SAML.encode_redirect(dest)
  end
end