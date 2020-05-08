defmodule Ext.GQL.Schema do
  defmacro __using__(project_name: project_name) do
    quote bind_quoted: [project_name: project_name] do
      use Absinthe.Schema

      def middleware(middleware, %Absinthe.Type.Field{__private__: [meta: meta]}, _object) do
        extra_middleware =
          Enum.map(meta, fn {key, value} ->
            case value do
              false ->
                nil

              _ ->
                key = key |> Ext.Utils.Base.to_str() |> Macro.camelize() |> Inflex.singularize()
                project_name = unquote(project_name) |> Ext.Utils.Base.to_str() |> Macro.camelize()
                Ext.Utils.Base.to_existing_atom("Elixir.#{project_name}.Middleware.#{key}")
            end
          end)
          |> Enum.reject(&is_nil/1)

        extra_middleware ++ middleware
      end

      def middleware(middleware, _field, _object), do: middleware
    end
  end
end
