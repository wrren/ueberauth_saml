defmodule SAML.AuthNRequestTest do
  use ExUnit.Case
  alias SAML.AuthNRequest

  test "request xml" do
    {:ok, dt} = DateTime.from_unix(0)
    request = AuthNRequest.init(%{login_location: "dest"}, %{}, "cl", "1234", dt ) 
    |> AuthNRequest.to_xml 
    |> String.replace("\t", "") 
    |> String.replace("\n", "")
    
    assert request == File.read! "test/fixtures/authn_request.xml"
  end

  test "url encoding without prior query parameters" do
    {:ok, dt} = DateTime.from_unix(0)
    uri = AuthNRequest.init(%{login_location: "dest"}, %{}, "cl", "1234", dt )
    |> AuthNRequest.to_elements
    |> SAML.encode_redirect("http://idp.example.com/endpoint", "1234")

    assert uri == "http://idp.example.com/endpoint?SAMLEncoding=urn:oasis:names:tc:SAML:2.0:bindings:URL-Encoding:DEFLATE&SAMLRequest=fVHBTgIxED3LVzS9w5bVRG3YJSgxkkAk7OLBi%2Bl2R6nZtthpiZ9vdxcSuJDMofM68%2Fre62T6pxtyAIfKmoyOR4wSMNLWynxndFu%2BDB8omeaDCQrd7Pks%2BJ3ZwG8A9GSGCM7HvWdrMGhwBbiDkrDdLDMqG0rmcUoZ4TvqOjaULObxkfT2Lp4QAywMemF8xB7v2ZCNY5WM8a4%2BKFk76620zZMyvaDgDLcCFXIjNCD3khez1ZKnI8arfgj5a1muh%2Bu3oqTk%2FWQsbY1FqwZ56%2BQ6kzgZO1%2FZX9%2FZH6XSfHDThcU7gy4PUIETMbfPFp0k53en0SJUPyB97C%2BBGOyXcrpLkKzA72x9XYXUvALhwNGkJU8u2fv%2B8hfzfw%3D%3D&RelayState=1234"
  end

  test "url encoding with prior query parameters" do
    {:ok, dt} = DateTime.from_unix(0)
    uri = AuthNRequest.init(%{login_location: "dest"}, %{}, "cl", "1234", dt )
    |> AuthNRequest.to_elements
    |> SAML.encode_redirect("http://idp.example.com/endpoint?foo=bar", "1234")

    assert uri == "http://idp.example.com/endpoint?foo=bar&SAMLEncoding=urn:oasis:names:tc:SAML:2.0:bindings:URL-Encoding:DEFLATE&SAMLRequest=fVHBTgIxED3LVzS9w5bVRG3YJSgxkkAk7OLBi%2Bl2R6nZtthpiZ9vdxcSuJDMofM68%2Fre62T6pxtyAIfKmoyOR4wSMNLWynxndFu%2BDB8omeaDCQrd7Pks%2BJ3ZwG8A9GSGCM7HvWdrMGhwBbiDkrDdLDMqG0rmcUoZ4TvqOjaULObxkfT2Lp4QAywMemF8xB7v2ZCNY5WM8a4%2BKFk76620zZMyvaDgDLcCFXIjNCD3khez1ZKnI8arfgj5a1muh%2Bu3oqTk%2FWQsbY1FqwZ56%2BQ6kzgZO1%2FZX9%2FZH6XSfHDThcU7gy4PUIETMbfPFp0k53en0SJUPyB97C%2BBGOyXcrpLkKzA72x9XYXUvALhwNGkJU8u2fv%2B8hfzfw%3D%3D&RelayState=1234"
  end

  test "HTTP POST encoding" do
    {:ok, dt} = DateTime.from_unix(0)
    html = AuthNRequest.init(%{login_location: "dest"}, %{}, "cl", "1234", dt )
    |> AuthNRequest.to_elements
    |> SAML.encode_post("http://idp.example.com/endpoint", "1234")
    
    assert html == File.read! "test/fixtures/authn_request.html"
  end
end
