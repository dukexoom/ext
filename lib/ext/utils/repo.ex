defmodule Ext.Utils.Repo do
  @doc ~S"""
  Return app name and repo

  ## Examples

      iex> Ext.Utils.Repo.get_config(Repo)
      {:ext, Repo}

      iex> Ext.Utils.Repo.get_config(nil)
      {:ext, TestRepo}
  """

  def get_config(repo) do
    app_name = Mix.Project.config()[:app]
    repo = if repo, do: repo, else: Application.get_env(app_name, :ecto_repos) |> List.first()
    {app_name, repo}
  end

  def generate_uniq_hash(schema, column, length \\ 35, repo \\ nil) do
    hash = :crypto.strong_rand_bytes(length) |> Base.url_encode64()
    {_, repo} = get_config(repo)
    result = schema |> repo.exists?(%{column => hash})

    cond do
      result -> generate_uniq_hash(schema, column, length)
      true -> hash
    end
  end
end
