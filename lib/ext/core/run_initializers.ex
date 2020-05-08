defmodule Ext.RunInitializers do
  @moduledoc false

  def call(app_name) do
    for initializer <- Path.wildcard("lib/#{app_name}/initializers/*.ex") do
      String.to_atom("Elixir.Initializers.#{initializer |> Path.basename(".ex") |> Macro.camelize()}")
      |> apply(:call, [])
    end
  end
end
