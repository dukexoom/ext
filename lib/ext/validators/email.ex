defmodule Ext.Validators.Email do
  import Ecto.Changeset
  require IEx

  def call(form, args) do
    {field, message} = parse_args(args)

    case Map.get(form.changes, field) do
      nil ->
        form

      value ->
        if Regex.match?(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, value),
          do: form,
          else: form |> add_error(field, message)
    end
  end

  defp parse_args(args), do: {args[:field], args[:message] || "invalid_email"}
end
