defmodule Ueberauth.Strategy.SAML do
	@moduledoc """
	SAML 2.0 Strategy for Überauth.
	"""
	use Ueberauth.Strategy
	
	alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
	alias Ueberauth.Strategy.Helpers
	alias SAML.AuthNRequest

  import Logger

	def handle_request!(conn) do
		options 			= Helpers.options(conn)
    idp 					= SAML.IDPMetadata.load!(Keyword.get(options, :metadata_url, %{}))
    sp 						= SAML.SPMetadata.init(Keyword.get(options, :sp_metadata, %{}))
		callback_url 	= Helpers.callback_url(conn)

    uri = AuthNRequest.init(idp, sp, callback_url)
    |> AuthNRequest.to_uri
		
    Logger.info "Callback URL: #{callback_url}"
    redirect!(conn, uri)
	end

	def handle_callback!(%Plug.Conn{ params: %{"SAMLResponse" => response} } = conn) do
		Logger.info "Received Response"
    assertion = response
    |> SAML.decode_response
    |> SAML.Assertion.decode

    put_private(conn, :saml_assertion, assertion)
	end

  def uid(conn) do
    conn.private.saml_assertion.subject.name
  end

  def credentials(conn) do
    
  end

  def info(conn) do
    assertion = conn.private.saml_assertion
    %Info{
      name: assertion.subject.name
    }
  end

  def extra(conn) do
    
  end
end
