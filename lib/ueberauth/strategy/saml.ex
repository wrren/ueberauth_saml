defmodule SAML do
    @moduledoc """
    SAML 2.0 Strategy for Überauth.
    """
    import XmlBuilder

    @saml_encoding "urn:oasis:names:tc:SAML:2.0:bindings:URL-Encoding:DEFLATE"

    @doc """
    Normally the struct/2 function takes the struct type into which the map is to be converted
    as the first parameter, making it awkward to use the |> operator. This function just reverses
    the parameter order
    """
    def to_struct(map, type), do: struct(type, map)

    @doc """
    Decode a response message from the IDP
    """
    def decode_response(@saml_encoding, response) do
        response
        |> :base64.decode
        |> :zlib.unzip
        |> SweetXml.parse(namespace_conformant: true)
    end

    def decode_response(_, response) do
        data = response
        |> :base64.decode

        xml = try do
            :zlib.unzip(data)
        catch
            _ -> data
        end

        SweetXml.parse(xml, namespace_conformant: true)
    end

    @doc """
    Given a request or response XML message, a relay state and the full URL to the 
    IDP consumption endpoint, generate a url that includes the encoded XML message
    to which the user's browser can be redirected in order to send the message
    """
    def encode_redirect(xml, idp_url, relay_state) do
        first_query_char = case has_query_params?(idp_url) do
            true    -> "&"
            false   -> "?"
        end

        type = case is_request?(xml) do
            true    -> "SAMLRequest"
            false   -> "SAMLResponse"
        end

        relay_state_enc = relay_state
        |> :erlang.binary_to_list
        |> :http_uri.encode
        |> :erlang.list_to_binary

        xml_enc = xml
        |> generate
        |> :erlang.binary_to_list
        |> :zlib.zip
        |> :base64.encode_to_string
        |> :http_uri.encode
        |> :erlang.list_to_binary

        Enum.join([idp_url, first_query_char, "SAMLEncoding=", @saml_encoding, "&", type, "=", xml_enc, "&RelayState=", relay_state_enc], "")
    end

    @doc """
    Given a request or response XML message, a relay state and the full URL to the 
    IDP consumption endpoint, generate a HTML page that POST's the message on behalf
    of the user using a javascript onload event.
    """
    def encode_post(xml, idp_url, relay_state) do
        type = case is_request?(xml) do
            true    -> "SAMLRequest"
            false   -> "SAMLResponse"
        end

        xml = xml |> generate |> :base64.encode

        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
        <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">
        <head>
        <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />
        <title>POST data</title>
        </head>
        <body onload=\"document.forms[0].submit()\">
        <noscript>
        <p><strong>Note:</strong> Since your browser does not support JavaScript, you must press the button below once to proceed.</p>
        </noscript>
        <form method=\"post\" action=\"#{idp_url}\">
        <input type=\"hidden\" name=\"#{type}\" value=\"#{xml}\" />
        <input type=\"hidden\" name=\"RelayState\" value=\"#{relay_state}\" />
        <noscript><input type=\"submit\" value=\"Submit\" /></noscript>
        </form>
        </body>
        </html>"
    end
    
    @doc """
    Given the root element of an XML document that denotes a SAML request or response,
    determine whether the XML represents a request and, if so, return true. False otherwise.
    """
    defp is_request?({name, _, _}) do
        String.contains? name, "Request"
    end

    @doc """
    Determine whether a URL already contains query parameters
    """
    defp has_query_params?(url) do
        String.contains? url, "?"
    end
end