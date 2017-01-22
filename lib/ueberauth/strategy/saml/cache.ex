defmodule SAML.Cache do
  @moduledoc"""
  ETS-Based cache for data such as assertions, private keys and certificates
  """
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__) 
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  def init(_) do
    :ets.new(:saml_privkey_cache, [:set, :protected, :named_table])
    :ets.new(:saml_assertion_seen_cache, [:set, :protected, :named_table])
    :ets.new(:saml_cert_cache, [:set, :protected, :named_table])
    :ets.new(:saml_metadata_cache, [:set, :protected, :named_table])
    {:ok, :no_state}
  end

  def handle_call({:write, table, key, value}, _from, state) do
    :ets.insert(table, {key, value})
    {:reply, :ok, state}
  end
  def handle_call(_, _, state), do: {:reply, :ok, state}

  defp lookup(table, key) do
    case :ets.lookup(table, key) do
      []              -> nil
      [{^key, value}] -> value
    end
  end

  defp write(table, key, value) do
    GenServer.call(__MODULE__, {:write, table, key, value})
  end

  @doc"""
  Look up the private key associated with the given path
  """
  def private_key(path) do
    lookup(:saml_privkey_cache, path)
  end

  @doc"""
  Store a private key and associate it with the given path
  """
  def private_key(path, key) do
    write(:saml_privkey_cache, path, key)
  end

  @doc"""
  Check whether an assertion has been seen previously
  """
  def assertion_seen?(digest) do
    case lookup(:saml_assertion_seen_cache, digest) do
      nil   -> false
      seen  -> seen
    end
  end

  @doc"""
  Set the 'seen' state of an assertion
  """
  def assertion_seen(digest, seen) do
    write(:saml_assertion_seen_cache, digest, seen)
  end

  @doc"""
  Look up the certificate associated with the given path
  """
  def cert(path) do
    lookup(:saml_cert_cache, path)
  end

  @doc"""
  Store a certificate and associate it with the given path
  """
  def cert(path, cert) do
    write(:saml_cert_cache, path, cert)
  end

  @doc"""
  Look up the IDP metadata associated with the given URL
  """
  def metadata(url) do
    lookup(:saml_metadata_cache, url)
  end

  @doc"""
  Stores IDP metadata and associates it with the given URL
  """
  def metadata(url, metadata) do
    write(:saml_metadata_cache, url, metadata)
  end
end