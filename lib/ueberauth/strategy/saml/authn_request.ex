defmodule Ueberauth.Strategy.SAML.AuthNRequest do
  @moduledoc """
  Exposes a struct and functions for dealing with SAML 2.0 authn requests
  """
  
  defstruct version: "2.0",
            issue_instant: "",
            idp_url: "",
            metadata_url: "",
            callback_url: ""

  alias Ueberauth.Strategy.SAML.AuthNRequest
  import XmlBuilder

  @doc """
  Initialize an AuthNRequest struct with the specified attributes
  idp_url: URI for the endpoint on the identity provider that will handle the request
  metadata_url: Metadata URI on the service provider
  callback_url: Callback URI on the service provider that will consumer the response
  issue_instant: ISO8601 string describing the point in time at which the request was created
  """
  def init(idp_url, metadata_url, callback_url, issue_instant) do
    %AuthNRequest{  issue_instant: issue_instant,
                    idp_url: idp_url,
                    metadata_url: metadata_url,
                    callback_url: callback_url }
  end

  @doc """
  Initialize an AuthNRequest struct with the specified attributes
  idp_url: URI for the endpoint on the identity provider that will handle the request
  metadata_url: Metadata URI on the service provider
  callback_url: Callback URI on the service provider that will consumer the response
  """
  def init(idp_url, metadata_url, callback_url) do
    init(idp_url, metadata_url, callback_url, DateTime.utc_now() |> DateTime.to_iso8601())
  end

  @doc """
  Initialize an AuthNRequest struct using attributes stored in the keyword list under the
  configuration key :ueberauth, Ueberauth.Strategy.SAML
  """
  def init() do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.SAML)
    init(Keyword.fetch!(config, :idp_url),
         Keyword.fetch!(config, :metadata_url),
         Keyword.fetch!(config, :callback_url))
  end

  @doc """
  Convert an AuthNRequest struct to an XML string suitable for transmission to an IDP
  """
  def to_xml(%AuthNRequest{} = request) do
    element("saml:AuthnRequest", %{ "xmlns:samlp": "urn:oasis:names:tc:SAML:2.0:protocol",
                                    "xmlns:saml": "urn:oasis:names:tc:SAML:2.0:assertion",
                                    "Version": request.version,
                                    "IssueInstant": request.issue_instant,
                                    "Destination": request.idp_url,
                                    "ProtocolBinding": "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                                    "AssertionConsumerServiceURL": request.callback_url }, [
      element("saml:Issuer", %{}, request.metadata_url ),
      element("saml:Subject", %{}, [
        element("saml:SubjectConfirmation", %{"Method": "urn:oasis:names:tc:SAML:2.0:cm:bearer"}, [])
      ])
    ]) |> generate
  end
end