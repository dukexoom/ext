defmodule Ext.Ecto.Types.Json do
  @behaviour Ecto.Type
  def type, do: :json
  require IEx

  def cast(value) do
    Jason.encode(value)
  end

  def load(value) do
    {:ok, value}
  end

  def dump(value) when is_binary(value) do
    Jason.decode(value)
  end

  def dump(value) do
    {:ok, value}
  end
end
