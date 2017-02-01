defmodule SAML.Assertion do
  import SAML.XML

  defstruct version: "",
            issue_instant: "",
            recipient: "",
            issuer: "",
            subject: %SAML.Subject{},
            conditions: [],
            attributes: []

  def decode(xpath_node) do
    xpath_node
    |> xpath(
        ~x"saml:Assertion",
        version: ~x"./@Version"s,
        issue_instant: ~x"./@IssueInstant"s,
        recipient: ~x"./saml:Subject/saml:SubjectConfirmation/saml:SubjectConfirmationData/@Recipient"s,
        issuer: ~x"./saml:Issuer/text()",
        subject: ~x"./saml:Subject" |> transform_by(&SAML.Subject.decode/1),
        conditions: ~x"./saml:Conditions"el |> transform_by(&SAML.Assertion.decode_conditions/1),
        attributes: ~x"./saml:AttributeStatement/saml:Attribute"el |> transform_by(&SAML.Assertion.decode_attributes/1)
      )
    |> SAML.to_struct(SAML.Assertion)
  end

  @doc """
  Get the value for the assertion attribute with the given key, returning the given default value if the attribute
  could not be found
  """
  def attribute(%SAML.Assertion{attributes: attr}, name, default \\ nil) do
    Enum.find_value(attr, default, 
      fn %SAML.Attribute{key: ^name, value: v} -> v
         %SAML.Attribute{} -> false end )
  end

  def decode_conditions(nodes) do
    for node <- nodes, do: SAML.Condition.decode(node)
  end

  def decode_attributes(nodes) do
    for node <- nodes, do: SAML.Attribute.decode(node)
  end
end