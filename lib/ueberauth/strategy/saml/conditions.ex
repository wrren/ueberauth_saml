defmodule SAML.Conditions do
  import SweetXml
  import SAML.Namespace, only: [attach: 1]

  defstruct not_before: nil,
            not_on_or_after: nil,
            audience: nil
    
  def decode(xpath_node) do
    xpath_node
    |> xmap(  not_before: ~x"./@NotBefore"so,
              not_on_or_after: ~x"./@NotOnOrAfter"so,
              audience: attach(~x"./saml:AudienceRestriction/saml:Audience/text()"so) )
    |> SAML.to_struct(SAML.Conditions)
  end
end