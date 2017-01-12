defmodule SAML.KeyInfoTest do
  use ExUnit.Case
  alias SAML.KeyInfo

  test "encode to xml" do
    xml = File.read!("./test/fixtures/x509_cert.pem")
    |> KeyInfo.init
    |> KeyInfo.to_xml 
    |> String.replace("\t", "") 
    |> String.replace("\n", "")

    assert xml == File.read!("./test/fixtures/key_info.xml")
  end
end
