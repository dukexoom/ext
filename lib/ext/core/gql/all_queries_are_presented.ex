defmodule Ext.GQL.AllQueriesArePresented do
  require IEx

  def call(_, nil), do: false

  def call(query, presented_names) do
    query_names = Ext.GQL.GetQueryNames.call(query)
    presented_names = Ext.Utils.Base.to_atom(presented_names)

    !Blankable.blank?(query_names) && Enum.all?(query_names, &(&1 in presented_names))
  end
end
