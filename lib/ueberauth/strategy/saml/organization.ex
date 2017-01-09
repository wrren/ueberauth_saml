defmodule Ueberauth.Strategy.SAML.Organization do
  alias Ueberauth.Strategy.SAML.Organization
  import XmlBuilder

  defstruct name: "", display_name: "", url: ""

  def init(name, display_name, url) do
    %Organization{name: name, display_name: display_name, url: url}
  end

  def init() do
    config = Keyword.fetch!(Application.get_env(:ueberauth, Ueberauth.Strategy.SAML.Metadata), :organization)
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

  def to_xml(%Organization{} = org) do
    to_elements(org) |> generate
  end
end