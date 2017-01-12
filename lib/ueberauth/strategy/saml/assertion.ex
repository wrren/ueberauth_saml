defmodule SAML.Assertion do
  import SAML.Namespace, only: [attach: 1]
  import SweetXml

  defstruct version: "",
            issue_instant: "",
            recipient: "",
            issuer: "",
            subject: "",
            conditions: [],
            attributes: []

  def decode(xpath_node) do
    xpath_node
    |> xpath(
        attach(~x"/saml:Assertion"),
        version: ~x"./@Version",
        issue_instant: ~x"./@IssueInstant",
        recipient: attach(~x"./saml:Subject/saml:SubjectConfirmation/saml:SubjectConfirmationData/@Recipient"),
        issuer: attach(~x"./saml:Issuer/text()"),
        subject: attach(~x"./saml:Subject") |> transform_by(&SAML.Subject.decode/1),
        conditions: attach(~x"./saml:Conditions") |> transform_by(&SAML.Conditions.decode/1),
        attributes: attach(~x"./saml:AttributeStatement"l) |> transform_by(&SAML.Assertion.decode_attributes/1),
      )
    |> SAML.to_struct(SAML.Assertion)
  end

  def decode_attributes(xpath_node) do
    xpath_node
    |> xmap(  key: attach(~x"./saml:Attribute/@name"),
              value: attach(~x"./saml:Attribute/saml:AttributeValue/text()") )
  end
end