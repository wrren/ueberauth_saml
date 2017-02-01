defmodule SAML.XML do
  @moduledoc"""
  Exposes convenience functions for dealing with XML
  """
  require SweetXpath

  def xpath(path) do
    path
    |> SweetXml.add_namespace("samlp", "urn:oasis:names:tc:SAML:2.0:protocol")
    |> SweetXml.add_namespace("saml", "urn:oasis:names:tc:SAML:2.0:assertion")
    |> SweetXml.add_namespace("md", "urn:oasis:names:tc:SAML:2.0:metadata")
    |> SweetXml.add_namespace("ds", "http://www.w3.org/2000/09/xmldsig#")
  end

  def xpath(xml, path) do
    SweetXml.xpath(xml, xpath(path))
  end

  def xpath(xml, path, mapping) do
    SweetXml.xpath(xml, xpath(path), xmap(mapping))
  end

  def xmap(mapping) do
    Enum.map(mapping, fn  {k, %SweetXpath{} = v} -> {k, xpath(v)}
                          {k, v} -> {k, v} end)
  end

  def xmap(xml, mapping) do
    SweetXml.xmap(xml, xmap(mapping))
  end

  def transform_by(path = %SweetXpath{}, fun) do
    path
    |> xpath()
    |> SweetXml.transform_by(fun)
  end

  def sigil_x(path, modifiers \\ '') do
    SweetXml.sigil_x(path, modifiers)
  end
end