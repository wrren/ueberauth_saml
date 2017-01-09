defmodule Ueberauth.Strategy.SAML.SPMetadata do
  @moduledoc """
  Provides a struct and functions for generating service
  provider metadata XML.
  """
  alias Ueberauth.Strategy.SAML.SPMetadata
  alias Ueberauth.Strategy.SAML.Organization
  alias Ueberauth.Strategy.SAML.Contact

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
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.SAML.Metadata)
    
  end 

  def to_xml(%SPMetadata{} = meta) do
    
  end
end