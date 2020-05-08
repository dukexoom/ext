defmodule Ext.Utils.List do
  require IEx

  @doc ~S"""
  Convert an list to a map. Keys of new map should be uniq

  ## Examples

    iex> Ext.Utils.List.index_by([%{name: "one", value: 1}, %{name: "two", value: 2}], &(&1.value))
    %{1 => %{name: "one", value: 1}, 2 => %{name: "two", value: 2}}
  """
  def index_by(list, func) do
    Enum.reduce(list, %{}, &Map.put(&2, func.(&1), &1))
  end
end
