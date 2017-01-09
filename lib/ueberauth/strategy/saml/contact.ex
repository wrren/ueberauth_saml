defmodule Ueberauth.Strategy.SAML.Contact do
  alias Ueberauth.Strategy.SAML.Contact
  import XmlBuilder

  defstruct name: "", email: ""

  def init(name, email) do
    %Contact{name: name, email: email}
  end

  def init() do
    config = Keyword.fetch!(Application.get_env(:ueberauth, Ueberauth.Strategy.SAML.Metadata), :contact)
    init( Keyword.get(config, :name, ""),
          Keyword.get(config, :email, "") )
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