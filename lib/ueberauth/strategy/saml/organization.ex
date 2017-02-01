defmodule SAML.Organization do
  alias SAML.Organization
  import XmlBuilder
  import SAML.XML

  defstruct name: "", display_name: "", url: ""

  def init(name, display_name, url) do
    %Organization{name: name, display_name: display_name, url: url}
  end

  def init() do
    config = Keyword.fetch!(Application.get_env(:ueberauth, SAML.Metadata), :organization)
    init( Keyword.get(config, :name, ""),
          Keyword.get(config, :display_name, ""),
          Keyword.get(config, :url, "") )
  end

  def to_elements(%Organization{} = org) do
    element("md:Organization", %{}, [
      element("md:OrganizationName", %{}, org.name),
      element("md:OrganizationDisplayName", %{}, org.display_name),
      element("md:OrganizationURL", %{}, org.url)
    ])
  end

  def decode(nil), do: %Organization{}
  def decode(xpath_node) do
    org = xpath_node
    |> xmap(
        name: ~x"./md:OrganizationName/text()"S,
        display_name: ~x"./md:OrganizationDisplayName/text()"S,
        url: ~x"./md:OrganizationURL/text()"S
      )
    |> SAML.to_struct(Organization)

    %{ org | name: String.trim(org.name), display_name: String.trim(org.display_name), url: String.trim(org.url) }
  end

  def to_xml(%Organization{} = org) do
    to_elements(org) |> generate
  end
end