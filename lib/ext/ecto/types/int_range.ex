defmodule Ext.Ecto.Types.IntRange do
  @behaviour Ecto.Type
  def type, do: :int_range

  def cast([lower, upper]) do
    {:ok, [lower, upper]}
  end

  def cast(_), do: :error

  def load(%Postgrex.Range{lower: lower, upper: upper}) do
    {:ok, [lower, upper - 1]}
  end

  def dump([lower, upper]) do
    {:ok, %Postgrex.Range{lower: lower, upper: upper}}
  end

  def dump(_), do: :error
end
