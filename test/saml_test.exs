defmodule SAMLTest do
  use ExUnit.Case
  alias SAML.AuthNRequest

  test "encode to xml" do
    {:ok, dt} = DateTime.from_unix(0)
    uri = AuthNRequest.init(%{login_location: "dest"}, %{}, "cl", "1234", dt )
    |> AuthNRequest.to_elements
    |> SAML.encode_redirect("http://idp.example.com/endpoint", "1234")

    assert uri == "http://idp.example.com/endpoint?SAMLEncoding=urn:oasis:names:tc:SAML:2.0:bindings:URL-Encoding:DEFLATE&SAMLRequest=fVHBTgIxED3LVzS9w5bVRG3YJSgxkkAk7OLBi%2Bl2R6nZtthpiZ9vdxcSuJDMofM68%2Fre62T6pxtyAIfKmoyOR4wSMNLWynxndFu%2BDB8omeaDCQrd7Pks%2BJ3ZwG8A9GSGCM7HvWdrMGhwBbiDkrDdLDMqG0rmcUoZ4TvqOjaULObxkfT2Lp4QAywMemF8xB7v2ZCNY5WM8a4%2BKFk76620zZMyvaDgDLcCFXIjNCD3khez1ZKnI8arfgj5a1muh%2Bu3oqTk%2FWQsbY1FqwZ56%2BQ6kzgZO1%2FZX9%2FZH6XSfHDThcU7gy4PUIETMbfPFp0k53en0SJUPyB97C%2BBGOyXcrpLkKzA72x9XYXUvALhwNGkJU8u2fv%2B8hfzfw%3D%3D&RelayState=1234"
  end

  test "decode from xml" do
    data = "PHNhbWxwOkF1dGhuUmVxdWVzdCBBc3NlcnRpb25Db25zdW1lclNlcnZpY2VVUkw9ImNsIiBEZXN0aW5hdGlvbj0iZGVzdCIgSUQ9IjEyMzQiIElzc3VlSW5zdGFudD0iMTk3MC0wMS0wMVQwMDowMDowMFoiIFByb3RvY29sQmluZGluZz0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmJpbmRpbmdzOkhUVFAtUE9TVCIgVmVyc2lvbj0iMi4wIiB4bWxuczpzYW1sPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIiB4bWxuczpzYW1scD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj4KCTxzYW1sOklzc3Vlcj51ZWJlcmF1dGhfc2FtbDwvc2FtbDpJc3N1ZXI+Cgk8c2FtbDpTdWJqZWN0PgoJCTxzYW1sOlN1YmplY3RDb25maXJtYXRpb24gTWV0aG9kPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6Y206YmVhcmVyIi8+Cgk8L3NhbWw6U3ViamVjdD4KPC9zYW1scDpBdXRoblJlcXVlc3Q+"

    assert :erlang.element(1, SAML.decode_response(data, :dummy_encoding)) == :xmlElement
  end
end