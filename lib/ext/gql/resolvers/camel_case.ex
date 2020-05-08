defmodule Ext.GQL.Resolvers.CamelCase do
  require IEx

  def call(field_name) do
    fn parent, _args, _info ->
      {:ok, camel_case(Map.get(parent, field_name))}
    end
  end

  @doc ~S"""
    ## camel_case/1 test

      iex> Ext.GQL.Resolvers.CamelCase.camel_case(:test_data)
      "testData"

      iex> Ext.GQL.Resolvers.CamelCase.camel_case("test_data")
      "testData"

      iex> Ext.GQL.Resolvers.CamelCase.camel_case(%{test_data: :test_data})
      %{"testData" => :test_data}

      iex> Ext.GQL.Resolvers.CamelCase.camel_case(["fest_data", :second_data])
      ["fest_data", :second_data]
  """

  def camel_case(value) when is_binary(value) or is_atom(value), do: ProperCase.camel_case(value)
  def camel_case(value) when is_map(value), do: ProperCase.to_camel_case(value)
  def camel_case(value), do: value
end
