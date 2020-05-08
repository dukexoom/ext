defmodule Ext.Utils.Enum do
  require IEx

  @doc ~S"""
  Calculates a sum from the elements by callback

  ## Examples
    iex> Ext.Utils.Enum.sum_by([1, 2, 3], &(&1 - 1))
    3

    iex> Ext.Utils.Enum.sum_by(%{one: 1, two: 2, three: 3}, fn {_key, value} -> value + 1 end)
    9

    iex> Ext.Utils.Enum.sum_by([%{name: "one", value: 1}, %{name: "two", value: 2}], &(&1.value))
    3
  """
  def sum_by(enum, callback) do
    Enum.reduce(enum, 0, fn item, sum ->
      sum + callback.(item)
    end)
  end

  @doc """
  Randomize item by key weight

  ## Examples
    iex> Ext.Utils.Enum.randomize_by([], :key)
    nil

    iex> Ext.Utils.Enum.randomize_by([%{key: 100}], :key)
    %{key: 100}

    iex> Ext.Utils.Enum.randomize_by([%{key: 1_000_000}, %{key: 1}], :key)
    %{key: 1_000_000}
  """
  def randomize_by(items, key) do
    total_weight = items |> Enum.map(&Map.get(&1, key)) |> Enum.sum()

    {items, _} =
      Enum.reduce(items, {[], 0}, fn item, {resulted_items, range_from} ->
        range_to = range_from + Map.get(item, key) / total_weight
        item = %{item: item, range_from: range_from, range_to: range_to}
        {[item | resulted_items], range_to}
      end)

    random_value = :rand.uniform()
    items |> Enum.find(&(&1.range_from <= random_value && &1.range_to >= random_value)) |> get_in([:item])
  end
end
