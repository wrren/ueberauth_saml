defmodule SAML.AssertionTest do
  use ExUnit.Case
  alias SAML.Assertion

  test "decode" do
    assertion = File.read!("./test/fixtures/assertion.xml")
    |> Assertion.decode

    assert assertion.subject.name == "jdoe@example.com"
    assert Assertion.attribute(assertion, "User.FirstName", nil) == "John"
    assert Assertion.attribute(assertion, "User.LastName", nil) == "Doe"
  end

  test "attribute retrieval" do
    assertion = %Assertion{attributes: [
      %SAML.Attribute{key: "attr1", value: 1},
      %SAML.Attribute{key: "attr2", value: 2}
    ]}

    assert Assertion.attribute(assertion, "attr1", nil) == 1
    assert Assertion.attribute(assertion, "attr2", nil) == 2
    assert Assertion.attribute(assertion, "attr3", nil) == nil
  end
end
