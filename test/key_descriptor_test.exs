defmodule SAML.KeyDescriptorTest do
  use ExUnit.Case
  alias SAML.KeyDescriptor

  test "encode to xml" do
    xml = File.read!("./test/fixtures/x509_cert.pem")
    |> KeyDescriptor.init
    |> KeyDescriptor.to_xml 
    |> String.replace("\t", "") 
    |> String.replace("\n", "")

    assert xml == File.read!("./test/fixtures/key_descriptor.xml")
  end
end
