defmodule Ext.GQL.Resolvers.Proxy do
  require IEx

  @moduledoc """
    If the first argument is an atom or list of atoms, this argument is path. Else the first argument is default value

    ## Examples with function call

      iex> Ext.GQL.Resolvers.Proxy.call(:spin, 0).(%{spin: 1}, %{}, %{})
      {:ok, 1}

      iex> Ext.GQL.Resolvers.Proxy.call(:spin, 0).(%{spin: nil}, %{}, %{})
      {:ok, 0}

      iex> Ext.GQL.Resolvers.Proxy.call([:extra, :test]).(%{extra: %{test: "test"}}, %{}, %{})
      {:ok, "test"}

      iex> Ext.GQL.Resolvers.Proxy.call([:extra, :test]).(%{extra: %{test: nil}}, %{}, %{})
      {:ok, nil}

      iex> Ext.GQL.Resolvers.Proxy.call(10).(%{spin: 11}, %{}, %{definition: %{schema_node: %{identifier: :spin}}})
      {:ok, 11}

      iex> Ext.GQL.Resolvers.Proxy.call(10).(%{spin: nil}, %{}, %{definition: %{schema_node: %{identifier: :spin}}})
      {:ok, 10}
  """

  def call(fields \\ nil, default_value \\ nil)

  def call(fields, default_value) when is_atom(fields) do
    perform(fields, default_value)
  end

  # Check if fields is list of atoms [:extra, :spin]
  def call([field | _] = fields, default_value) when is_atom(field) do
    perform(fields, default_value)
  end

  def call(default_value, nil), do: perform(nil, default_value)

  defp perform(fields, default_value) do
    fn parent, _args, info ->
      get_value(parent, field_name(fields, info), default_value)
    end
  end

  defp get_value(parent, field_name, default_value) when is_atom(field_name) do
    {:ok, Map.get(parent, Ext.Utils.Base.to_str(field_name)) || Map.get(parent, field_name) || default_value}
  end

  defp get_value(parent, path, default_value) do
    value = Ext.Utils.Base.get_in(parent, path)
    {:ok, if(is_nil(value), do: default_value, else: value)}
  end

  defp field_name(nil, %{definition: %{schema_node: %{identifier: field_name}}}), do: field_name
  defp field_name(fields, _), do: fields
end
