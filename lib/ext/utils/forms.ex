defmodule Ext.Utils.Forms do
  @moduledoc false
  require Logger
  require IEx
  import Ecto.Changeset

  @doc ~S"""

  ## Examples

    iex> Ext.Utils.Forms.error(TestUser.changeset(%TestUser{}, %{}))
    %{email: ["can't be blank"], name: ["can't be blank"]}
  """

  def error(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        case value do
          {:array, :map} -> "Must be an array of objects"
          _ -> String.replace(acc, "%{#{key}}", to_string(value))
        end
      end)
    end)
  end
end
