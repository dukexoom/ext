defmodule Ext.Ecto.ComposeQuery do
  import Ecto.Query
  import Ext.Utils.Map
  require IEx

  def call({key, value}, query, extra) when is_map(value) do
    handle_map_value({key, Ext.Utils.Base.to_atom(value)}, query, extra)
  end

  @doc """
    iex> where(query, %{position: {"=", 1})
    WHERE position = 1
  """
  def call({key, {"=", value}}, query, extra), do: call({key, value}, query, extra ||| %{type: "="})

  @doc """
    iex> where(query, %{position: {"!=", 1})
    WHERE position != 1
  """
  def call({key, {"!=", value}}, query, extra), do: call({key, value}, query, extra ||| %{type: "!="})

  def call({key, {sign, value}}, query, %{table_module: table_module} = extra) do
    condition = table_module.call({key, {sign, value}}, extra)

    dynamic([entity], ^build_dynamic(query, condition))
  end

  @doc """
    iex> where(query, %{position: ["=", 1])
    WHERE position = 1
  """
  def call({key, [sign, value]}, query, extra) when sign in [">", ">=", "<", "<=", "=", "!=", "~="] do
    call({key, {sign, value}}, query, extra)
  end

  def call({key, value}, query, extra) do
    condition = extra.table_module.call({key, value}, extra)

    dynamic([entity], ^build_dynamic(query, condition))
  end

  @doc """
    iex> where(query, %{position: %{sign: ">", value: 1}})
    WHERE position > 1
  """
  def handle_map_value({key, %{sign: sign, value: value}}, query, extra), do: call({key, {sign, value}}, query, extra)

  @doc """
    iex> where(query, %{user: %{name: "Test Name"})
    WHERE position = 1
  """
  def handle_map_value({key, value}, query, %{main_query: %{joins: joins}} = extra) do
    table_number =
      case Enum.find_index(joins, fn %{assoc: {_, assoc}} -> assoc == key end) do
        nil -> 0
        index -> index + 1
      end

    module = String.to_existing_atom("Elixir.Ext.Ecto.GetCondition.Table#{table_number}")

    Enum.reduce(
      Ext.Utils.Base.to_atom(value),
      query,
      &call(&1, &2, extra ||| %{table_module: module})
    ) || true
  end

  def build_dynamic(nil, condition), do: dynamic([entity], ^condition)
  def build_dynamic(query, condition), do: dynamic([entity], ^query and ^condition)
end
