defmodule SAML.Contact do
  alias SAML.Contact
  import SAML.XML
  import XmlBuilder

  defstruct name: "", email: ""

  def init(name, email) do
    %Contact{name: name, email: email}
  end

  def init() do
    config = Keyword.fetch!(Application.get_env(:ueberauth, SAML.Metadata), :contact)
    init( Keyword.get(config, :name, ""),
          Keyword.get(config, :email, "") )
  end

  def decode(nil), do: %Contact{}
  def decode(xpath_node) do
    first_name  = xpath_node |> xpath(~x"/md:ContactPerson/md:GivenName/text()"S)     |> String.trim
    last_name   = xpath_node |> xpath(~x"/md:ContactPerson/md:SurName/text()"S)       |> String.trim
    email       = xpath_node |> xpath(~x"/md:ContactPerson/md:EmailAddress/text()"S)  |> String.trim

    struct(Contact, %{email: email, name: Enum.join([first_name, last_name], " ") |> String.trim()})
  end

  def to_elements(%Contact{} = contact) do
    element("md:ContactPerson", %{"contactType": "technical"}, [
      element("md:SurName", %{}, contact.name),
      element("md:EmailAddress", %{}, contact.email)
    ])
  end

  def to_xml(%Contact{} = contact) do
    to_elements(contact) |> generate
  end
end