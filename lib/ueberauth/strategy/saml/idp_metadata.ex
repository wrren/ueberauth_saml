defmodule Ueberauth.Strategy.SAML.IDPMetadata do
  @moduledoc """
  Provides a struct and functions for retrieving identity
  provider metadata.
  """
  alias Ueberauth.Strategy.SAML.IDPMetadata
  alias Ueberauth.Strategy.SAML.Organization
  alias Ueberauth.Strategy.SAML.Contact
  
  require HTTPoison.Response
  require HTTPoison.Error

  defstruct org: %Organization{},
            tech: %Contact{},
            signed_requests: true,
            certificate: "",
            entity_id: "",
            login_location: "",
            logout_location: "",
            name_format: ""

  def decode(xml) do
    
  end

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