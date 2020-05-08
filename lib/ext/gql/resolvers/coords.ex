defmodule Ext.GQL.Resolvers.Coords do
  def call do
    fn entity, _args, %{definition: %{schema_node: %{identifier: identifier}}} ->
      case Map.get(entity, identifier) do
        %{coordinates: {long, lat}} -> {:ok, %{lat: lat, long: long}}
        _ -> {:ok, %{lat: nil, long: nil}}
      end
    end
  end
end
