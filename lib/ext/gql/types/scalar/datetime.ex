defmodule Ext.GQL.Types.Scalar.DateTime do
  @moduledoc """
  """
  use Absinthe.Schema.Notation
  require IEx

  scalar :datetime, name: "DateTime" do
    description("""
    The `DateTime` scalar type represents a date and time in the UTC
    timezone. Standard is ISO_8601. E.g. 2015-01-23T23:50:07Z
    """)

    serialize(&serialize__datetime/1)
    parse(&parse_datetime/1)
  end

  def serialize__datetime(value) when is_binary(value) do
    {:ok, datetime, 0} = DateTime.from_iso8601(value)
    DateTime.to_iso8601(datetime)
  end

  def serialize__datetime(value), do: DateTime.to_iso8601(value)

  @spec parse_datetime(Absinthe.Blueprint.Input.String.t()) :: {:ok, DateTime.t()} | :error
  @spec parse_datetime(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, 0} -> {:ok, datetime}
      {:ok, _datetime, _offset} -> :error
      _error -> :error
    end
  end

  defp parse_datetime(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_datetime(_) do
    :error
  end
end
