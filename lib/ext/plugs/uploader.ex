defmodule Ext.Plugs.Uploader do
  @moduledoc false
  @behaviour Plug
  require IEx

  def init(opts), do: opts

  def call(conn, _) do
    operations = normalize_operations(conn.params["operations"], conn.params["map"])

    new_params = Map.merge(conn.params, operations)
    %{conn | params: new_params}
  end

  def normalize_operations(nil, _map), do: %{}

  def normalize_operations(operations, map) do
    operations = Jason.decode!(operations)
    map = Jason.decode!(map)
    %{operations | "variables" => enhance_variables(operations, map)}
  end

  def enhance_variables(operations, map) do
    operations =
      Enum.reduce(map, operations, fn {key, value}, vars ->
        path = String.split(List.first(value), ".")
        Ext.Utils.Base.put_in(vars, path, key)
      end)

    Jason.encode!(operations["variables"])
  end
end
