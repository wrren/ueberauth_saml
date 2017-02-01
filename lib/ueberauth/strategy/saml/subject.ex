defmodule SAML.Subject do
  import SAML.XML

  defstruct name: "",
            confirmation_method: :bearer,
            not_on_or_after: ""

  def decode(xpath_node) do
    xpath_node
    |> xmap(
      name: ~x"./saml:NameID/text()"s,
      confirmation_method: ~x"./saml:SubjectConfirmation/@Method" |> transform_by(&SAML.Subject.subject_method_map/1),
      not_on_or_after: ~x"./saml:SubjectConfirmation/saml:SubjectConfirmationData/@NotOnOrAfter" )
    |> SAML.to_struct(SAML.Subject)
  end

  def subject_method_map("urn:oasis:names:tc:SAML:2.0:cm:bearer"), do: :bearer
  def subject_method_map(_), do: :unknown
end