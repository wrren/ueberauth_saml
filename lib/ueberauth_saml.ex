defmodule Ueberauth.Strategy.SAML do
	@moduledoc """
	SAML 2.0 Strategy for Überauth.
	"""
	use Ueberauth.Strategy
	
	alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
	alias Ueberauth.Strategy.Helpers
	alias SAML.AuthNRequest
  alias SAML.Assertion

	def handle_request!(conn) do
		options 			= Helpers.options(conn)
    idp 					= SAML.IDPMetadata.load!(Keyword.get(options, :metadata_url, %{}))
    sp 						= SAML.SPMetadata.init(Keyword.get(options, :sp_metadata, %{}))
		callback_url 	= Helpers.callback_url(conn)

    uri = AuthNRequest.init(idp, sp, callback_url)
    |> AuthNRequest.to_uri
		
    redirect!(conn, uri)
	end

	def handle_callback!(%Plug.Conn{ params: %{"SAMLResponse" => response} } = conn) do
    assertion = response
    |> SAML.decode_response
    |> Assertion.decode

    put_private(conn, :saml_assertion, assertion)
	end

  def uid(conn) do
    conn.private.saml_assertion.subject.name
  end

  def credentials(conn) do
    assertion = conn.private.saml_assertion
    %Credentials{ expires: false,
                  scopes: Assertion.attribute(assertion, "memberOf", []) }
  end

  def info(conn) do
    assertion = conn.private.saml_assertion
    first_name = Assertion.attribute(assertion, "User.FirstName", "")
    last_name = Assertion.attribute(assertion, "User.LastName", "")
    %Info{
      name: String.trim(Enum.join([first_name, last_name], " ")),
      first_name: first_name,
      last_name: last_name,
      email: Assertion.attribute(assertion, "User.email", "")
    }
  end
end
