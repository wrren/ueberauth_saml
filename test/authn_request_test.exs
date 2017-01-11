defmodule SAML.AuthNRequestTest do
  use ExUnit.Case
  alias SAML.AuthNRequest

  test "request xml" do
    request = AuthNRequest.init("dest", "issuer", "cl", "2000-01-01T00:00:00Z" ) 
    |> AuthNRequest.to_xml 
    |> String.replace("\t", "") 
    |> String.replace("\n", "")
    
    assert request == File.read! "test/fixtures/authn_request.xml"
  end

  test "url encoding without prior query parameters" do
    uri = AuthNRequest.init("dest", "issuer", "cl", "2000-01-01T00:00:00Z" )
    |> AuthNRequest.to_elements
    |> SAML.encode_redirect("http://idp.example.com/endpoint", "1234")

    assert uri == "http://idp.example.com/endpoint?SAMLEncoding=urn:oasis:names:tc:SAML:2.0:bindings:URL-Encoding:DEFLATE&SAMLRequest=fVHBTsMwDD3DV0S5j4Ydo7bSgAOTNlGthQO3NDUsqHFGnCA%2BnzRsUnepZMl61vOz%2FVySsqPcxHDEA3xHoMA2ROCDcfjokKIF34L%2FMRpeD7uK65Gzp8QyqCZKxYcEONsSRdgiBYWh4mshxErcp%2BiEkDneOWu8C0678cHgYPCz4tGjdIoMSVQWSAYt281%2BJ9d3Qvb%2FJJLPXdesmpe24%2BwNPOWZicDZrx2R5LT%2BspK6nDNvOS33nM6r8vr2pswO5QN9bXIqi3ntQmlj%2FwU6JHxdSDZ%2BGG%2BzX2wP4eiG5enayh6UB8%2BLSby4Vj%2Fj%2BcvqPw%3D%3D&RelayState=1234"
  end

  test "url encoding with prior query parameters" do
    uri = AuthNRequest.init("dest", "issuer", "cl", "2000-01-01T00:00:00Z" )
    |> AuthNRequest.to_elements
    |> SAML.encode_redirect("http://idp.example.com/endpoint?foo=bar", "1234")

    assert uri == "http://idp.example.com/endpoint?foo=bar&SAMLEncoding=urn:oasis:names:tc:SAML:2.0:bindings:URL-Encoding:DEFLATE&SAMLRequest=fVHBTsMwDD3DV0S5j4Ydo7bSgAOTNlGthQO3NDUsqHFGnCA%2BnzRsUnepZMl61vOz%2FVySsqPcxHDEA3xHoMA2ROCDcfjokKIF34L%2FMRpeD7uK65Gzp8QyqCZKxYcEONsSRdgiBYWh4mshxErcp%2BiEkDneOWu8C0678cHgYPCz4tGjdIoMSVQWSAYt281%2BJ9d3Qvb%2FJJLPXdesmpe24%2BwNPOWZicDZrx2R5LT%2BspK6nDNvOS33nM6r8vr2pswO5QN9bXIqi3ntQmlj%2FwU6JHxdSDZ%2BGG%2BzX2wP4eiG5enayh6UB8%2BLSby4Vj%2Fj%2BcvqPw%3D%3D&RelayState=1234"
  end

  test "HTTP POST encoding" do
    html = AuthNRequest.init("dest", "issuer", "cl", "2000-01-01T00:00:00Z" )
    |> AuthNRequest.to_elements
    |> SAML.encode_post("http://idp.example.com/endpoint", "1234")
    
    assert html == File.read! "test/fixtures/authn_request.html"
  end
end
