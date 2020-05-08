defmodule Ext.Config do
  defmacro __using__(opts \\ []) do
    caller = Keyword.get(opts, :otp_app)

    quote do
      def get(path, default_value \\ nil)
      def get(path, default_value) when is_atom(path), do: Ext.Config.get(unquote(caller), path, default_value)

      def get(path, default_value) do
        [head | tail] = path
        unquote(caller) |> Ext.Config.get(head, nil) |> Ext.Config.get_in_object(tail) || default_value
      end
    end
  end

  def get(path, default_value \\ nil)
  def get(path, default_value) when is_atom(path), do: get(Mix.Project.config()[:app], path, default_value)

  def get(path, default_value) do
    [head | tail] = path
    head |> get() |> get_in_object(tail) || default_value
  end

  def get(app, path, default_value), do: Application.get_env(app, path, default_value || [])

  def get_in_object(map, []), do: map
  def get_in_object(map, path), do: get_in(map, path)
end
