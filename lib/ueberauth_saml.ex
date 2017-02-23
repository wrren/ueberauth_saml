defmodule Ueberauth.Strategy.SAML do
	@moduledoc """
	SAML 2.0 Strategy for Überauth.
	"""
	use Ueberauth.Strategy
	
	alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
	alias Ueberauth.Strategy.Helpers
  import Record

  defrecord :esaml_sp,            extract(:esaml_sp,            from_lib: "esaml/include/esaml.hrl")
  defrecord :esaml_org,           extract(:esaml_org,           from_lib: "esaml/include/esaml.hrl")
  defrecord :esaml_contact,       extract(:esaml_contact,       from_lib: "esaml/include/esaml.hrl")
  defrecord :esaml_assertion,     extract(:esaml_assertion,     from_lib: "esaml/include/esaml.hrl")
  defrecord :esaml_subject,       extract(:esaml_subject,     from_lib: "esaml/include/esaml.hrl")
  defrecord :esaml_idp_metadata,  extract(:esaml_idp_metadata,  from_lib: "esaml/include/esaml.hrl")

  def make_sp(conn, options) do
    :esaml_sp.setup(esaml_sp(
      key:                    :esaml_util.load_private_key(Keyword.get(options, :private_key)),
      trusted_fingerprints:   Keyword.get(options, :trusted_fingerprints),
      idp_signs_envelopes:    Keyword.get(options, :idp_signs_envelopes, false),
      idp_signs_assertions:   Keyword.get(options, :idp_signs_assertions, true),
      consume_uri:            Helpers.callback_url(conn),
      metadata_uri:           Keyword.get(options, :metadata_uri, ""),
      verify_recipient:       Keyword.get(options, :verify_recipient, true),
      verify_audience:        Keyword.get(options, :verify_audience, true),
      org:                    case Keyword.get(options, :org, %{}) do
                                %{name: name, display_name: dn, url: url} ->
                                  esaml_org(name: name, displayname: dn, url: url)
                                _ ->
                                  :undefined
                              end,
      tech:                   case Keyword.get(options, :tech, %{}) do
                                %{name: name, email: email} ->
                                  esaml_contact(name: name, email: email)
                                _ ->
                                  :undefined
                              end
    ))
  end

	def handle_request!(%Plug.Conn{query_params: qp} = conn) do
		options = Helpers.options(conn)
    sp      = make_sp(conn, options)
    
    esaml_idp_metadata(login_location: login_location) =  case Keyword.get(options, :idp_metadata_url) do
                                                            nil -> raise "You must specify an IDP Metadata URI in your ueberauth_saml provider options"
                                                            url -> :esaml_util.load_metadata(:erlang.binary_to_list(url))
                                                          end
                                                          
    signed_xml  = sp.generate_authn_request(login_location)
    relay_state = Map.get(qp, "relay_state", "")
    url         = :esaml_binding.encode_http_redirect(login_location, signed_xml, relay_state)
    redirect!(conn, url)
	end

	def handle_callback!(%Plug.Conn{ params: %{"SAMLResponse" => response} = params } = conn) do
    sp = make_sp(conn, Helpers.options(conn))

    try do
      xml = :esaml_binding.decode_response(Map.get(params, "SAMLEncoding", :undefined), :erlang.binary_to_list(response))
      case sp.validate_assertion(xml, fn(_a, _digest) -> :ok end) do
          {:ok, assertion} ->
            put_private(conn, :saml_assertion, assertion)
          {:error, reason} -> 
            set_errors!(conn, [error("Assertion Invalid", reason)])
        end
    catch
      {:EXIT, reason} -> set_errors!(conn, [error("SAMLResponse", reason)])
    end
	end

  def uid(conn) do
    esaml_assertion(subject: esaml_subject(name: name)) = conn.private.saml_assertion
    name
  end

  def credentials(_) do
    %Credentials{ expires: false }
  end

  def info(conn) do
    esaml_assertion(attributes: attributes) = conn.private.saml_assertion
    first_name  = :erlang.list_to_binary(Keyword.get(attributes, :"User.FirstName", ""))
    last_name   = :erlang.list_to_binary(Keyword.get(attributes, :"User.LastName", ""))
    %Info{
      name: String.trim(Enum.join([first_name, last_name], " ")),
      first_name: first_name,
      last_name: last_name,
      email: :erlang.list_to_binary(Keyword.get(attributes, :"User.email", ""))
    }
  end
end
