defmodule SAML.Attribute do
  import SAML.XML

  defstruct key: "",
            value: ""

  def decode(node) do
    node
    |> xmap(key: ~x"./@Name"so,
            value: ~x"./saml:AttributeValue/text()"sl)
    |> condense
    |> SAML.trim
    |> SAML.to_struct(SAML.Attribute)
  end

  @doc """
  Attribute values are parsed into string lists. This function will transform each list
  depending on its contents for easier access. Empty lists are converted to nil values,
  lists with single elements are converted to a value equal to that element, lists 
  of strings are converted to trimmed string lists.
  """
  def condense(map) do
    Enum.map(map, fn {k, [v]} -> {k, v}
      {k, []} -> {k, nil}
      {k, v} when is_list(v)  -> {k, (for val <- v, do: SAML.trim(val))}
      {k, v} -> {k, v}
    end) 
  end
end