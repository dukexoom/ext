defmodule Ext.Dataloaders.Base do
  import Ecto.Query

  def data(repo) do
    Dataloader.Ecto.new(repo, query: &data_query(&1, &2, repo), run_batch: &run_batch(&1, &2, &3, &4, &5, repo))
  end

  def data_query(queryable, params, repo) do
    queryable |> handle_filter(params, repo) |> handle_order_by(params) |> handle_limit(params)
  end

  defp handle_filter(query, %{filter: filter}, repo), do: repo.where(query, filter)
  defp handle_filter(query, _, _), do: query

  defp handle_order_by(query, %{order_by: order_by}), do: order_by(query, ^order_by)
  defp handle_order_by(query, _), do: query

  defp handle_limit(query, %{limit: count}), do: limit(query, ^count)
  defp handle_limit(query, _), do: query

  def run_batch(queryable, query, col, inputs, repo_opts, repo) do
    queryable_name = queryable |> Atom.to_string() |> String.replace(~r/Elixir./, "")

    case Ext.Utils.Base.to_existing_atom("Elixir.Dataloaders.#{queryable_name}") do
      nil -> Dataloader.Ecto.run_batch(repo, queryable, query, col, inputs, repo_opts)
      module -> module.run_batch(queryable, query, col, inputs, repo_opts, repo)
    end
  end

  defmacro __using__(_) do
    quote do
      @before_compile Ext.Dataloaders.Base
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run_batch(queryable, query, col, inputs, repo_opts, repo) do
        Dataloader.Ecto.run_batch(repo, queryable, query, col, inputs, repo_opts)
      end
    end
  end
end
