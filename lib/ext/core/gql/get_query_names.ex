defmodule Ext.GQL.GetQueryNames do
  require IEx

  def call(query) do
    case Absinthe.Phase.Parse.run(%Absinthe.Blueprint{input: query}) do
      {:ok, %{input: %{definitions: [%{selection_set: %{selections: selections}} | _tail]}}} ->
        selections |> Enum.map(&(&1.name |> ProperCase.snake_case() |> Ext.Utils.Base.to_atom()))

      _ ->
        []
    end
  end
end
