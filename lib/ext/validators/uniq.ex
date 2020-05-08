defmodule Ext.Validators.Uniq do
  import Ecto.Changeset
  require IEx

  def call(form, args) do
    {schema, repo, fields, message} = parse_args(args)
    {_, repo} = Ext.Utils.Repo.get_config(repo)
    message = if message, do: message, else: "not_unique"

    checked_fields = Map.take(form.changes, fields)

    if Blankable.blank?(checked_fields) do
      form
    else
      cond do
        schema
        |> repo.where(%{id: {"!=", form.changes[:id]}})
        |> repo.exists?(Map.take(form.changes, fields)) ->
          form |> add_error(List.first(fields), message)

        true ->
          form
      end
    end
  end

  defp parse_args(args), do: {args[:schema], args[:repo], args[:fields], args[:message]}
end
