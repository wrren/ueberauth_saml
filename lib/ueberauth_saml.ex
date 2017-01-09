defmodule UeberauthSAML do
	@moduledoc """
	SAML 2.0 Strategy for Überauth.
	"""
	use Ueberauth.Strategy
	
	alias Ueberauth.Auth.Credentials
	alias Ueberauth.Auth.Extra
	alias Ueberauth.Strategy.SAML.AuthNRequest

	def handle_request!(conn) do
		redirect!(conn, AuthNRequest.init() |> AuthNRequest.to_uri())
	end

	def handle_callback(%Plug.Conn{ params: %{} } = conn) do
		
	end

end
