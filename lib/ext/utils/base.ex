defmodule Ext.Utils.Base do
  require IEx
  require Logger

  @moduledoc false

  @doc ~S"""
    Convert value to integer. If this is not possible returns value.

    ##Examples

      iex> Ext.Utils.Base.to_int(1.3)
      1

      iex> Ext.Utils.Base.to_int(1.5)
      2

      iex> Ext.Utils.Base.to_int(1.0, :ceil)
      1

      iex> Ext.Utils.Base.to_int(1.1, :ceil)
      2

      iex> Ext.Utils.Base.to_int(0.0, :ceil)
      0

      iex> Ext.Utils.Base.to_int(1.5, :floor)
      1

      iex> Ext.Utils.Base.to_int("11")
      11

      iex> Ext.Utils.Base.to_int("error")
      "error"
  """

  def to_int(value, type \\ nil)

  def to_int(value, :ceil) when is_float(value), do: value |> Float.ceil() |> trunc()
  def to_int(value, :floor) when is_float(value), do: value |> Float.floor() |> trunc()
  def to_int(value, _) when is_float(value), do: round(value)

  def to_int(value, _) do
    case :string.to_integer(value) do
      {:error, _} -> value
      {int, _} -> int
    end
  end

  @doc ~S"""
    Convert simple value, list elements or map keys to atom.

    ## Examples

      iex> Ext.Utils.Base.to_atom("test")
      :test

      iex> Ext.Utils.Base.to_atom(nil)
      nil

      iex> Ext.Utils.Base.to_atom(["first", "second"])
      [:first, :second]

      iex> Ext.Utils.Base.to_atom(%{"first" => "test", "second" => %{"key" => "value"}})
      %{first: "test", second: %{key: "value"}}

      iex> Ext.Utils.Base.to_atom([{"first", "test"}, {"second", "value"}])
      [first: "test", second: "value"]

      iex> Ext.Utils.Base.to_atom([first: "test", second: "value"])
      [first: "test", second: "value"]
  """

  def to_atom(value) when is_binary(value), do: String.to_atom(value)
  def to_atom(value) when is_nil(value), do: nil
  def to_atom(value) when is_list(value), do: Enum.map(value, &__MODULE__.to_atom(&1))
  def to_atom({key, value}), do: {__MODULE__.to_atom(key), AtomicMap.convert(value, safe: false)}
  def to_atom(value), do: AtomicMap.convert(value, safe: false)

  @doc ~S"""
    Convert map (or list of maps) keys to string.

    ## Examples

      iex> Ext.Utils.Base.stringify_keys(%{first: "test"})
      %{"first" => "test"}

      iex> Ext.Utils.Base.stringify_keys([%{first: 1}, %{second: "test"}])
      [%{"first" => 1}, %{"second" => "test"}]

      iex> Ext.Utils.Base.stringify_keys([%{first: %{nested: 1}}, %{second: "test"}])
      [%{"first" => %{"nested" => 1}}, %{"second" => "test"}]
  """

  def stringify_keys(nil), do: nil

  def stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} ->
      cond do
        is_atom(k) -> {Atom.to_string(k), stringify_keys(v)}
        is_binary(k) -> {k, stringify_keys(v)}
      end
    end)
    |> Enum.into(%{})
  end

  def stringify_keys([head | rest]), do: [stringify_keys(head) | stringify_keys(rest)]
  def stringify_keys(not_a_map), do: not_a_map

  def snake_keys(map), do: ProperCase.to_snake_case(map)

  @doc ~S"""
    Convert value to string

    ## Examples

      iex> Ext.Utils.Base.to_str(:test)
      "test"

      iex> Ext.Utils.Base.to_str("test")
      "test"

      iex> Ext.Utils.Base.to_str(1.234)
      "1.234"

      iex> Ext.Utils.Base.to_str(%{test: "value"})
      "%{test: \"value\"}"
  """
  def to_str(value) when is_atom(value), do: Atom.to_string(value)
  def to_str(value) when is_binary(value), do: value
  def to_str(value), do: inspect(value)

  def to_negative(value), do: -1 * value

  @doc ~S"""
    Convert value to boolean

    ## Examples

      iex> Ext.Utils.Base.to_bool("true")
      true

      iex> Ext.Utils.Base.to_bool("false")
      false

      iex> Ext.Utils.Base.to_bool(nil)
      false

      iex> Ext.Utils.Base.to_bool(%{})
      false

      iex> Ext.Utils.Base.to_bool([])
      false

      iex> Ext.Utils.Base.to_bool({})
      false

      iex> Ext.Utils.Base.to_bool(%{test: "any"})
      true
  """

  def to_bool("true"), do: true
  def to_bool("false"), do: false
  def to_bool(nil), do: false
  def to_bool(value), do: !Blankable.blank?(value)

  @doc ~S"""
    Get value from object by path

    ## Examples

      iex> Ext.Utils.Base.get_in(%{test: %{nested: "value"}}, [:test, :nested])
      "value"

      iex> Ext.Utils.Base.get_in(%{"test" => %{"nested" => "value"}}, [:test, :nested])
      "value"

      iex> Ext.Utils.Base.get_in(%{"test" => %{"nested" => "value"}}, [:second, :nested])
      nil

      iex> Ext.Utils.Base.get_in(%TestUser{name: "test"}, [:name])
      "test"

      iex> Ext.Utils.Base.get_in(%TestUser{name: "test"}, [:invalid_field])
      nil

      iex> Ext.Utils.Base.get_in(nil, [:id])
      nil
  """
  def get_in(nil, _), do: nil

  def get_in(object, list) do
    [source_column | path] = list

    new_value =
      if is_nil(Map.get(object, source_column)),
        do: Map.get(object, to_str(source_column)),
        else: Map.get(object, source_column)

    cond do
      new_value == nil -> nil
      length(path) == 0 -> new_value
      true -> __MODULE__.get_in(new_value, path)
    end
  end

  @doc ~S"""
    Put value to object by path

    ## Examples

      iex> Ext.Utils.Base.put_in(%{test: %{nested: "value"}}, [:added], "add")
      %{test: %{nested: "value"}, added: "add"}

      iex> Ext.Utils.Base.put_in(%{test: %{nested: "value"}}, [:test, :added], "add")
      %{test: %{nested: "value", added: "add"}}

      iex> Ext.Utils.Base.put_in(%{test: %{nested: "value"}}, [:test, "added"], "add")
      %{test: %{:nested => "value", "added" => "add"}}
  """

  def put_in(object, path, value) when length(path) == 1 do
    key = List.first(path)
    Map.merge(object, %{key => value})
  end

  def put_in(object, path, value) do
    [head | path] = path

    branch =
      case __MODULE__.get_in(object, [head]) do
        nil ->
          object = Kernel.put_in(object, [head], %{})
          __MODULE__.put_in(__MODULE__.get_in(object, [head]), path, value)

        new_object ->
          __MODULE__.put_in(new_object, path, value)
      end

    Map.merge(object, %{head => branch})
  end

  def check_env_variables(env_path \\ ".env.sample") do
    env_content = File.read!(env_path)

    env_array =
      String.split(env_content, "export ", trim: true) |> Enum.map(fn x -> String.replace(x, ~r/=.+\n/, "") end)

    Enum.each(env_array, fn env ->
      unless System.get_env(env), do: Logger.error("Environment variable #{env} does not set")
    end)
  end

  @doc ~S"""
    Convert string to to_existing_atom without rising error

    ## Examples

      iex> Ext.Utils.Base.to_existing_atom("String")
      :String

      iex> Ext.Utils.Base.to_existing_atom("NotExist")
      nil
  """

  def to_existing_atom(string) do
    String.to_existing_atom(string)
  rescue
    ArgumentError -> nil
  end

  @doc ~S"""
    Check if string is uuid

    ## Examples

      iex> Ext.Utils.Base.uuid?("invalid")
      false

      iex> Ext.Utils.Base.uuid?(Ecto.UUID.generate())
      true
  """

  def uuid?(string) do
    case Ecto.UUID.cast(string) do
      {:ok, _} -> true
      :error -> false
    end
  end

  def json?(value) do
    Jason.decode!(value)
    true
  rescue
    _ -> false
  end

  @doc ~S"""
    Decode and encode Any

    ## Examples

      iex> Ext.Utils.Base.encode(11)
      "g2EL"

      iex> Ext.Utils.Base.decode("g2EL")
      11

      iex> Ext.Utils.Base.encode({11, "aa"})
      "g2gCYQttAAAAAmFh"

      iex> Ext.Utils.Base.decode("g2gCYQttAAAAAmFh")
      {11, "aa"}
  """
  @spec decode(any) :: String.t()
  def decode(any), do: any |> Base.decode64!() |> :erlang.binary_to_term()

  @spec decode(String.t()) :: any
  def encode(any), do: any |> :erlang.term_to_binary() |> Base.encode64()
end
