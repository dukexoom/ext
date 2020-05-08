defmodule Ext.GQL.Types.Scalar.Date do
  @moduledoc """
  """
  use Absinthe.Schema.Notation
  require IEx

  scalar :date, name: "Date" do
    description("""
    The `Date` scalar type represents a date.
    Standard is ISO_8601. E.g. 2015-01-23
    """)

    serialize(&serialize_date/1)
    parse(&parse_date/1)
  end

  @spec parse_date(Absinthe.Blueprint.Input.String.t()) :: {:ok, DateTime.t()} | :error
  @spec parse_date(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_date(%Absinthe.Blueprint.Input.String{value: value}) do
    case Date.from_iso8601(value) do
      {:ok, date} -> {:ok, date}
      _error -> :error
    end
  end

  defp parse_date(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_date(_) do
    :error
  end

  defp serialize_date(value) when is_binary(value), do: value
  defp serialize_date(value), do: Date.to_iso8601(value)
end
