defmodule SAML.KeyInfo do
  import XmlBuilder

  defstruct certificate: ""

  def init(certificate) do
    %SAML.KeyInfo{certificate: certificate}
  end

  def from_file(path) do
    init(File.read!(path) |> :base64.encode)
  end

  def to_elements(%SAML.KeyInfo{} = desc) do
    element("KeyInfo", %{"xmlns": "http://www.w3.org/2000/09/xmldsig#"}, [
      element("X509Data", %{}, [
        element("X509Certificate", %{}, desc.certificate |> :base64.encode)
      ])
    ])
  end

  def to_xml(%SAML.KeyInfo{} = desc) do
    to_elements(desc) |> generate
  end
end