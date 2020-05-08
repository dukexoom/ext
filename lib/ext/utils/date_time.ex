defmodule Ext.Utils.DateTime do
  @doc ~S"""
    Convert iso8601 string to DateTime

    ## Examples

      iex> Ext.Utils.DateTime.from("2018-12-03T18:19:20.123456Z")
      ~U[2018-12-03 18:19:20.123456Z]
  """

  def from(str) do
    {:ok, date, _} = DateTime.from_iso8601(str)
    date
  end

  @shift_types [:days, :hours, :minutes, :seconds]
  @doc ~S"""
  Convert to Timex.shift params.

  ## Examples

      iex> Ext.Utils.DateTime.shift_normalize(:minutes, 1.5)
      [seconds: 90]

      iex> Ext.Utils.DateTime.shift_normalize(:hours, 1.51)
      [seconds: 5436]

      iex> Ext.Utils.DateTime.shift_normalize(:seconds, 1.51)
      [seconds: 1]

      iex> Ext.Utils.DateTime.shift_normalize(:days, 1.5)
      [hours: 36]

      iex> Ext.Utils.DateTime.shift_normalize(:minutes, -1.5)
      [seconds: -90]

  """
  def shift_normalize(type, value) when is_float(value) do
    floor_value = value |> Float.floor()

    cond do
      floor_value != value ->
        next_type = Enum.at(@shift_types, Enum.find_index(@shift_types, &(&1 == type)) + 1)
        value = shift_value_for_next_type(value, next_type)
        shift_normalize(unless(next_type, do: type, else: next_type), value)

      true ->
        [{type, trunc(value)}]
    end
  end

  def shift_normalize(type, value), do: [{type, trunc(value)}]

  defp shift_value_for_next_type(shift, type) do
    cond do
      Enum.member?([:days], type) -> shift * 7
      Enum.member?([:hours], type) -> shift * 24
      Enum.member?([:minutes, :seconds], type) -> shift * 60
      true -> shift |> Float.floor()
    end
  end

  @doc ~S"""
    Return begin of date with microseconds

    ## Examples

      iex> Ext.Utils.DateTime.beginning_of_day(Ext.Utils.DateTime.from("2018-12-03T18:19:20.123456Z"))
      ~U[2018-12-03 00:00:00.000000Z]
  """

  def beginning_of_day(date) do
    Timex.beginning_of_day(date) |> Timex.format!("%FT%H:%M:%S.%f%:z", :strftime) |> Timex.parse!("{ISO:Extended}")
  end

  @doc ~S"""
    Return begin of week with microseconds

    ## Examples

      iex> Ext.Utils.DateTime.beginning_of_week(Ext.Utils.DateTime.from("2018-12-02T18:19:20.123456Z"))
      ~U[2018-11-26 00:00:00.000000Z]
  """

  def beginning_of_week(date) do
    Timex.beginning_of_week(date) |> Timex.format!("%FT%H:%M:%S.%f%:z", :strftime) |> Timex.parse!("{ISO:Extended}")
  end

  @doc ~S"""
    Return DateTime from time string

    ## Examples

      iex> Ext.Utils.DateTime.from_time_string("11:20", Ext.Utils.DateTime.from("2018-12-02T18:19:20.123456Z"))
      ~U[2018-12-02 11:20:00.000000Z]
  """

  def from_time_string(time, date_time \\ DateTime.utc_now()) do
    beginning_of_day = beginning_of_day(date_time)

    case String.split(time, ":") |> Enum.map(&Ext.Utils.Base.to_int(&1)) do
      [hours, minutes, seconds] -> Timex.shift(beginning_of_day, hours: hours, minutes: minutes, seconds: seconds)
      [hours, minutes] -> Timex.shift(beginning_of_day, hours: hours, minutes: minutes)
    end
  end
end
