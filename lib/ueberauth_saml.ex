defmodule UeberauthSAML do
	@moduledoc """
	SAML 2.0 Strategy for Überauth.
	"""
	use Ueberauth.Strategy
	
	alias Ueberauth.Auth.Credentials
	alias Ueberauth.Auth.Extra
	alias Ueberauth.Strategy.Helpers
	alias SAML.AuthNRequest

	def handle_request!(conn) do
		options 			= Helpers.options(conn)
		idp 					= SAML.IDPMetadata.load!(Keyword.get!(options, :metadata_url))
		sp 						= SAML.SPMetadata.init(Keyword.get(options, :sp_metadata))
		callback_url 	= Helpers.callback_url(conn)
		redirect!(conn, AuthNRequest.init(idp, sp, callback_url) |> AuthNRequest.to_uri())
	end

	def handle_callback(%Plug.Conn{ params: %{} } = conn) do
		
	end

end
