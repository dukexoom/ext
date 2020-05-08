defmodule Ext.Ecto.Repo do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Ecto.Query
      import Ext.Utils.Map

      defoverridable exists?: 2, get_by: 3, get_by!: 3

      def exists?(queryable, clauses, opts \\ []) do
        Ecto.Repo.Queryable.exists?(__MODULE__, Ecto.Query.where(queryable, [], ^Enum.to_list(clauses)), opts)
      end

      def get_by(queryable, clauses, opts) do
        Ecto.Repo.Queryable.get_by(__MODULE__, queryable, Ext.Utils.Base.to_atom(clauses), opts)
      end

      def get_by!(queryable, clauses, opts) do
        Ecto.Repo.Queryable.get_by!(__MODULE__, queryable, Ext.Utils.Base.to_atom(clauses), opts)
      end

      def first(query) do
        query |> Ecto.Query.limit(1) |> one()
      end

      def where(query, {:or, conditions}) when is_list(conditions),
        do: Ecto.Query.where(query, ^build_or_dynamic(conditions, query))

      def build_or_dynamic(conditions, query) do
        Enum.reduce(conditions, nil, fn params, dynamic ->
          if dynamic,
            do: Ecto.Query.dynamic([e], ^build_conditions(params, query) or ^dynamic),
            else: Ecto.Query.dynamic([e], ^build_conditions(params, query))
        end)
      end

      def where(query, params), do: Ecto.Query.where(query, ^build_conditions(params, query))

      def build_conditions(params, query) do
        Enum.reduce(
          Ext.Utils.Base.to_atom(params),
          nil,
          &Ext.Ecto.ComposeQuery.call(&1, &2, %{
            main_query: query,
            type: "=",
            table_module: Ext.Ecto.GetCondition.Table0
          })
        ) || true
      end

      def batch_insert(schema_or_source, entries, batch \\ 5_000, opts \\ []) do
        Enum.each(
          Enum.chunk_every(entries, batch),
          &Ecto.Repo.Schema.insert_all(:repo, __MODULE__, schema_or_source, &1, opts)
        )
      end

      def order_by(query, fields), do: from(en in query, order_by: ^fields)

      def pluck(query, fields) when is_list(fields), do: from(en in query, select: map(en, ^fields))

      def pluck(query, field), do: from(en in query, select: field(en, ^field))

      def cache_key(%module{id: id, updated_at: updated_at}) do
        [Ext.Utils.Base.to_str(module), id, updated_at |> DateTime.to_string()] |> Enum.join("/")
      end

      def cache_key(query) do
        from(r in query, select: max(r.updated_at)) |> __MODULE__.one()
      end

      def transaction_repeateble_read! do
        if Mix.env() != :test do
          __MODULE__.query!("set transaction isolation level repeatable read;")
        end
      end

      def reload(%module{id: id}) do
        get(module, id)
      end

      def lock_for_update(query), do: Ecto.Query.lock(query, "FOR UPDATE")

      def save(struct, data), do: save(struct, data, nil)
      def save!(struct, data), do: save(struct, data, "!")

      def save(struct, data, bang) when is_list(data), do: save(struct, Enum.into(data, %{}), bang)

      def save(struct, data, bang),
        do: apply(__MODULE__, String.to_atom("insert_or_update#{bang}"), [struct.__struct__.changeset(struct, data)])

      def get_or_insert(schema, query, extra_params \\ %{}), do: get_or_insert(schema, query, extra_params, nil)
      def get_or_insert!(schema, query, extra_params \\ %{}), do: get_or_insert(schema, query, extra_params, "!")

      defp get_or_insert(schema, query, extra_params, bang) do
        case schema |> __MODULE__.get_by(query) do
          nil ->
            apply(__MODULE__, String.to_atom("save#{bang}"), [schema.__struct__, query ||| extra_params])

          entity ->
            case bang do
              "!" -> entity
              _ -> {:ok, entity}
            end
        end
      end

      @doc """
        iex> User |> join(:posts)
        INNER JOIN "posts" AS p1 ON p1."user_id" = u0."id"

        iex> User |> join(:posts, :left)
        LEFT OUTER JOIN "posts" AS p1 ON p1."user_id" = u0."id"

        iex> User |> join([:posts, :country])
        INNER JOIN "posts" AS p1 ON p1."user_id" = u0."id"
        INNER JOIN "country" AS c2 ON c2."id" = u0."country_id"

        iex> User |> join(%{posts: :comments})
        INNER JOIN "posts" AS p1 ON p1."user_id" = u0."id"
        INNER JOIN "comments" AS c2 ON c2."post_id" = p1."id"

        iex> User |> join(%{posts: [:comments, :likes]})
        INNER JOIN "posts" AS p1 ON p1."user_id" = u0."id"
        INNER JOIN "comments" AS c2 ON c2."post_id" = p1."id"
        INNER JOIN "likes" AS l3 ON l3."post_id" = p1."id"
      """
      def join(query, params, type \\ :inner)

      def join(query, params, type) when is_list(params), do: Enum.reduce(params, query, &__MODULE__.join(&2, &1, type))

      def join(query, params, type) when is_map(params) do
        [association] = Map.keys(params)
        __MODULE__.join(query, association, type) |> nested_join(params[association], type)
      end

      def join(query, association, type), do: query |> join(type, [entity], assoc in assoc(entity, ^association))

      def get_each(query, batch_size \\ 500) do
        batches_stream =
          Stream.unfold(0, fn
            :done ->
              nil

            offset ->
              results = query |> limit(^batch_size) |> offset(^offset) |> __MODULE__.all()

              if length(results) < batch_size,
                do: {results, :done},
                else: {results, offset + batch_size}
          end)

        Stream.concat(batches_stream)
      end

      defp nested_join(query, params, type) when is_list(params),
        do: Enum.reduce(params, query, &nested_join(&2, &1, type))

      defp nested_join(query, association, type),
        do: query |> join(type, [entity, assoc1], assoc2 in assoc(assoc1, ^association))
    end
  end
end
